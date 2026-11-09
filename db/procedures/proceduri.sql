-- proceduri benzinarii.
-- depinde de: db/schema/, db/views/.

USE BENZINARII;

DELIMITER //

-- 1. sp_emite_bon: creaza un bon gol pentru o statie si un angajat.
-- folosit in aplicatie la emiterea bonului (casier/manager).

CREATE PROCEDURE sp_emite_bon (
    IN p_id_statie INT,
    IN p_id_angajat INT,
    IN p_numar_bon INT,
    IN p_data_ora DATETIME,
    OUT p_id_bon INT
)
BEGIN
    INSERT INTO BON (id_statie, id_angajat, numar_bon, data_ora, stare)
    VALUES (p_id_statie, p_id_angajat, p_numar_bon, p_data_ora, 'valid');
    SET p_id_bon = LAST_INSERT_ID();
END //

-- 2. sp_anuleaza_bon: anuleaza un bon si face liniile lui neplatite (id_bon = null)
-- folosit in aplicatie la anularea bonului (casier).
CREATE PROCEDURE sp_anuleaza_bon (IN p_id_bon INT)
BEGIN
    UPDATE BON SET stare = 'anulat' WHERE id_bon = p_id_bon;
END //

-- 3. sp_inregistreaza_livrare: inregistreaza o livrarea (cisterna) pentru o comanda
-- folosit in aplicatie la confirmarea livrarii
CREATE PROCEDURE sp_inregistreaza_livrare (
    IN p_id_comanda INT,
    IN p_data_livrare DATE,
    IN p_nr_aviz VARCHAR(50),
    IN p_nr_factura VARCHAR(50),
    OUT p_id_livrare INT
)
BEGIN
    INSERT INTO LIVRARE (id_comanda, data_livrare, nr_aviz, nr_factura)
    VALUES (p_id_comanda, p_data_livrare, p_nr_aviz, p_nr_factura);
    SET p_id_livrare = LAST_INSERT_ID();
END //

-- 4. sp_seteaza_pret_carb: inchide pretul curent al unui carburant la o statie si insereaza unul nou
-- folosit in aplicatie dupa calculul pretului sugerat
CREATE PROCEDURE sp_seteaza_pret_carb (
    IN p_id_statie INT,
    IN p_id_tip_carburant INT,
    IN p_pret DECIMAL(10,2),
    IN p_data_inceput DATE
)
BEGIN
    UPDATE PRET_CARBURANT
    SET data_sfarsit = DATE_SUB(p_data_inceput, INTERVAL 1 DAY)
    WHERE id_statie = p_id_statie
      AND id_tip_carburant = p_id_tip_carburant
      AND data_sfarsit IS NULL;

    INSERT INTO PRET_CARBURANT (id_statie, id_tip_carburant, pret, data_inceput, data_sfarsit)
    VALUES (p_id_statie, p_id_tip_carburant, p_pret, p_data_inceput, NULL);
END //

-- 5. sp_seteaza_pret_ev: inchide pretul ev curent al unei statii si insereaza unul nou
-- folosit in aplicatie dupa calculul pretului sugerat
CREATE PROCEDURE sp_seteaza_pret_ev (
    IN p_id_statie INT,
    IN p_cost_kwh DECIMAL(10,2),
    IN p_adaos_procent DECIMAL(5,2),
    IN p_tva_procent DECIMAL(5,2),
    IN p_pret_kwh DECIMAL(10,2),
    IN p_data_inceput DATE
)
BEGIN
    UPDATE PRET_EV
    SET data_sfarsit = DATE_SUB(p_data_inceput, INTERVAL 1 DAY)
    WHERE id_statie = p_id_statie
      AND data_sfarsit IS NULL;

    INSERT INTO PRET_EV (id_statie, cost_kwh, adaos_procent, tva_procent, pret_kwh, data_inceput, data_sfarsit)
    VALUES (p_id_statie, p_cost_kwh, p_adaos_procent, p_tva_procent, p_pret_kwh, p_data_inceput, NULL);
END //

-- 6. sp_inregistreaza_incident: inregistreaza un incident de neplata pentru o alimentare sau o incarcare ev
-- folosit in aplicatie la inregistrarea incidentului (casier/manager)
CREATE PROCEDURE sp_inregistreaza_incident (
    IN p_id_alimentare INT,
    IN p_id_incarcare INT,
    IN p_id_angajat INT,
    IN p_nr_inmatriculare VARCHAR(20),
    IN p_descriere VARCHAR(500),
    IN p_data_ora DATETIME
)
BEGIN
    INSERT INTO INCIDENT_NEPLATA (id_alimentare, id_incarcare, id_angajat, nr_inmatriculare, descriere, data_ora, stare)
    VALUES (p_id_alimentare, p_id_incarcare, p_id_angajat, p_nr_inmatriculare, p_descriere, p_data_ora, 'deschis');
END //

DELIMITER ;
