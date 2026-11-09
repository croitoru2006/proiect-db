-- test t01: unique pe angajat.cnp.
-- ce verifica: nu se pot insera doi angajati cu acelasi cnp.
-- ce se executa: insert angajat cu cnp deja existent ('1900101123456' = admin).
-- rezultat asteptat: error (er_dup_entry, cod 1062).
START TRANSACTION;
INSERT INTO ANGAJAT (id_statie, functie, nume, prenume, cnp, telefon, email, data_angajare, utilizator, parola_hash, activ)
VALUES (1, 'casier', 'Test', 'Duplicat', '1900101123456', '0700000000', 'testdup@x.ro', '2025-01-01', 'testdup', '$2a$12$x', TRUE);
ROLLBACK;

-- test t02: not null pe angajat.nume.
-- ce verifica: nu se poate insera angajat fara nume.
-- ce se executa: insert cu nume = null.
-- rezultat asteptat: error (not null, cod 1364).
START TRANSACTION;
INSERT INTO ANGAJAT (id_statie, functie, nume, prenume, cnp, telefon, email, data_angajare, utilizator, parola_hash, activ)
VALUES (1, 'casier', NULL, 'FaraNume', '1900101123457', '0700000001', 'fnonume@x.ro', '2025-01-01', 'fnonume', '$2a$12$x', TRUE);
ROLLBACK;

-- test t03: fk alimentare.id_duza -> duza(id_duza).
-- ce verifica: nu se poate insera alimentare pentru o duza inexistenta.
-- ce se executa: insert cu id_duza = 99999.
-- rezultat asteptat: error (fk, cod 1452).
START TRANSACTION;
INSERT INTO ALIMENTARE (id_duza, id_tip_carburant, id_bon, data_ora, litri, pret_litru, tva_procent)
VALUES (99999, 1, NULL, NOW(), 10.000, 6.45, 19.00);
ROLLBACK;

-- test t04: check incident_neplata (exact unul dintre id_alimentare / id_incarcare).
-- ce verifica: nu se poate insera incident cu ambele chei null.
-- ce se executa: insert cu id_alimentare=null si id_incarcare=null.
-- rezultat asteptat: error (check, cod 3819).
START TRANSACTION;
INSERT INTO INCIDENT_NEPLATA (id_alimentare, id_incarcare, id_angajat, nr_inmatriculare, descriere, data_ora, stare)
VALUES (NULL, NULL, 1, 'TEST 001', 'Ambele NULL', NOW(), 'deschis');
ROLLBACK;

-- test t05: check angajat (casier/manager trebuie sa aiba statie; admin are id_statie null).
-- ce verifica: nu se poate insera un casier fara statie.
-- ce se executa: insert cu functie='casier' si id_statie=null.
-- rezultat asteptat: error (check, cod 3819).
START TRANSACTION;
INSERT INTO ANGAJAT (id_statie, functie, nume, prenume, cnp, telefon, email, data_angajare, utilizator, parola_hash, activ)
VALUES (NULL, 'casier', 'Fara', 'Statie', '1900101123458', '0700000002', 'fs@x.ro', '2025-01-01', 'fstatie', '$2a$12$x', TRUE);
ROLLBACK;

-- test t06: trigger trg_alimentare_scade_stoc (blocare stoc negativ).
-- ce verifica: nu se poate alimenta mai mult decat stocul disponibil in rezervor.
-- ce se executa: insert alimentare (id_duza=5 -> rezervor 3, stoc 1100) cu litri=5000.
-- rezultat asteptat: error (trigger, cod 45000, mesaj 'stoc insuficient').
START TRANSACTION;
INSERT INTO ALIMENTARE (id_duza, id_tip_carburant, id_bon, data_ora, litri, pret_litru, tva_procent)
VALUES (5, 1, NULL, NOW(), 5000.000, 6.50, 19.00);
ROLLBACK;

-- test t07: trigger trg_bon_anulat + procedura sp_anuleaza_bon.
-- ce verifica: anularea bonului face liniile (alimentare/incarcare_ev) sa revina neplatite (id_bon=null).
-- ce se executa: emite bon (sp_emite_bon), adauga o alimentare pe bon, anuleaza bon (sp_anuleaza_bon), verifica id_bon.
-- rezultat asteptat: ok (id_bon devine null dupa anularie).
START TRANSACTION;
CALL sp_emite_bon(1, 2, 998, NOW(), @id_b);
INSERT INTO ALIMENTARE (id_duza, id_tip_carburant, id_bon, data_ora, litri, pret_litru, tva_procent)
VALUES (1, 1, @id_b, NOW(), 10.000, 6.45, 19.00);
SET @id_al = LAST_INSERT_ID();
CALL sp_anuleaza_bon(@id_b);
SELECT id_bon FROM ALIMENTARE WHERE id_alimentare = @id_al; -- asteptat NULL
ROLLBACK;


-- test t08: trigger trg_comanda_livrata.
-- ce verifica: completarea unei comenzi partiale trece comanda pe 'livrata'.
-- ce se executa: adauga o linie de livrare pentru comanda 2 (linie 3) care completeaza cantitatea comandata.
-- rezultat asteptat: ok (comanda.stare devine 'livrata').
START TRANSACTION;
INSERT INTO LIVRARE (id_comanda, data_livrare, nr_aviz, nr_factura) VALUES (2, NOW(), 'AV-TEST', 'F-TEST');
SET @id_liv = LAST_INSERT_ID();
INSERT INTO LINIE_LIVRARE (id_livrare, id_linie_comanda, id_rezervor, cantitate_primita, pret_achizitie)
VALUES (@id_liv, 3, 3, 1000.000, 5.25);
SELECT stare FROM COMANDA WHERE id_comanda = 2; -- asteptat 'livrata'
ROLLBACK;

-- test t09: procedura sp_seteaza_pret_carb (inchide randul vechi, deschide rand nou).
-- ce verifica: dupa setarea pretului nou, randul vechi are data_sfarsit completat si noul rand are data_sfarsit null.
-- ce se executa: call sp_seteaza_pret_carb(1, 1, 7.00, '2025-11-01').
-- rezultat asteptat: ok (randul vechi are data_sfarsit='2025-10-31', randul nou are data_sfarsit=null).
START TRANSACTION;
CALL sp_seteaza_pret_carb(1, 1, 7.00, '2025-11-01');
SELECT id_pret, pret, data_inceput, data_sfarsit FROM PRET_CARBURANT WHERE id_statie=1 AND id_tip_carburant=1 ORDER BY data_inceput;
ROLLBACK;

-- test t10: unique pe bon(id_statie, numar_bon).
-- ce verifica: nu se pot emite doua bonuri cu acelasi numar pe aceeasi statie.
-- ce se executa: insert bon cu id_statie=1, numar_bon=101 (deja existent).
-- rezultat asteptat: error (er_dup_entry, cod 1062).
START TRANSACTION;
INSERT INTO BON (id_statie, id_angajat, numar_bon, data_ora, stare) VALUES (1, 2, 101, NOW(), 'valid');
ROLLBACK;
