-- triggere benzinarii.
-- depinde de: db/schema/.


USE BENZINARII;

DELIMITER //

-- 1. trg_alimentare_scade_stoc: la o alimentare noua, scade stocul rezervorului.
-- blocheaza (eroare) daca litri <= 0 sau daca stocul ar deveni negativ.
-- folosit automat la inregistrarea alimentarii (simulator / pompa).
CREATE TRIGGER trg_alimentare_scade_stoc
BEFORE INSERT ON ALIMENTARE
FOR EACH ROW
BEGIN
    DECLARE v_stoc DECIMAL(12,3);
    DECLARE v_id_rezervor INT;

    IF NEW.litri <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Alimentare invalida: litri trebuie sa fie mai mare decat zero.';
    END IF;

    SELECT r.id_rezervor, r.stoc_curent INTO v_id_rezervor, v_stoc
    FROM DUZA d
    JOIN REZERVOR r ON d.id_rezervor = r.id_rezervor
    WHERE d.id_duza = NEW.id_duza;

    IF v_stoc < NEW.litri THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Alimentare blocata: stoc insuficient in rezervor.';
    END IF;

    UPDATE REZERVOR
    SET stoc_curent = stoc_curent - NEW.litri
    WHERE id_rezervor = v_id_rezervor;
END //

-- 2. trg_livrare_valideaza_capacitate: inainte de o linie de livrare, verifica ca stocul + cantitate <= capacitate_max.
-- folosit automat inainte de inregistrarea livrarii.
CREATE TRIGGER trg_livrare_valideaza_capacitate
BEFORE INSERT ON LINIE_LIVRARE
FOR EACH ROW
BEGIN
    DECLARE v_capacitate DECIMAL(12,3);
    DECLARE v_stoc DECIMAL(12,3);
    SELECT capacitate_max, stoc_curent INTO v_capacitate, v_stoc
    FROM REZERVOR WHERE id_rezervor = NEW.id_rezervor;
    IF v_stoc + NEW.cantitate_primita > v_capacitate THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Livrare blocata: capacitatea maxima a rezervorului ar fi depasita.';
    END IF;
END //

-- 3. trg_livrare_creste_stoc: dupa o linie de livrare, creste stocul rezervorului.
-- folosit automat dupa inregistrarea livrarii (simulator / cisterna).
CREATE TRIGGER trg_livrare_creste_stoc
AFTER INSERT ON LINIE_LIVRARE
FOR EACH ROW
BEGIN
    UPDATE REZERVOR
    SET stoc_curent = stoc_curent + NEW.cantitate_primita
    WHERE id_rezervor = NEW.id_rezervor;
END //

-- 4. trg_comanda_livrata: comanda trece pe 'livrata' cand suma primita >= cantitatea comandata (pe fiecare linie).
-- folosit automat dupa fiecare livrare.
CREATE TRIGGER trg_comanda_livrata
AFTER INSERT ON LINIE_LIVRARE
FOR EACH ROW
BEGIN
    DECLARE v_id_comanda INT;
    SELECT lc.id_comanda INTO v_id_comanda
    FROM LINIE_COMANDA lc WHERE lc.id_linie_comanda = NEW.id_linie_comanda;

    IF (SELECT COALESCE(SUM(ll.cantitate_primita),0)
        FROM LINIE_LIVRARE ll
        JOIN LINIE_COMANDA lc2 ON ll.id_linie_comanda = lc2.id_linie_comanda
        WHERE lc2.id_comanda = v_id_comanda) >=
       (SELECT COALESCE(SUM(cantitate_comandata),0)
        FROM LINIE_COMANDA WHERE id_comanda = v_id_comanda)
    THEN
        UPDATE COMANDA SET stare = 'livrata' WHERE id_comanda = v_id_comanda;
    END IF;
END //

-- 5. trg_bon_anulat: la anularea unui bon, alimentarile si incarcarile lui revin neplatite (id_bon = null).
-- se declanseaza cand sp_anuleaza_bon schimba stare in 'anulat'.
-- folosit in aplicatie la anularea bonului (casier).
CREATE TRIGGER trg_bon_anulat
AFTER UPDATE ON BON
FOR EACH ROW
BEGIN
    IF NEW.stare = 'anulat' AND OLD.stare = 'valid' THEN
        UPDATE ALIMENTARE SET id_bon = NULL WHERE id_bon = NEW.id_bon;
        UPDATE INCARCARE_EV SET id_bon = NULL WHERE id_bon = NEW.id_bon;
    END IF;
END //

DELIMITER ;
