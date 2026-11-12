

USE BENZINARII;


SET SQL_SAFE_UPDATES = 0;


START TRANSACTION;


DELETE FROM INCIDENT_NEPLATA;
DELETE FROM TRANZACTIE;
DELETE FROM INCARCARE_EV;
DELETE FROM ALIMENTARE;
DELETE FROM LINIE_LIVRARE;
DELETE FROM LIVRARE;
DELETE FROM LINIE_COMANDA;
DELETE FROM COMANDA;
DELETE FROM BON;
DELETE FROM CONECTOR;
DELETE FROM DUZA;
DELETE FROM POMPA;
DELETE FROM STATIE_EV;
DELETE FROM REZERVOR;
DELETE FROM PRET_CARBURANT;
DELETE FROM PRET_EV;
DELETE FROM ANGAJAT;
DELETE FROM FURNIZOR;
DELETE FROM TIP_CONECTOR;
DELETE FROM TIP_CARBURANT;
DELETE FROM STATIE;

-- --- statie (4 statii) ---
INSERT INTO STATIE (id_statie, denumire, localitate, judet, strada, numar, telefon, cui, activ) VALUES
                                                                                                    (1, 'Benzinaria Sud', 'Bucuresti', 'Sector 1', 'Splaiul Independentei', '123', '0213111222', 'RO12345678', TRUE),
                                                                                                    (2, 'Benzinaria Vest', 'Timisoara', 'Timis', 'Calea Aradului', '45', '0256222333', 'RO23456789', TRUE),
                                                                                                    (3, 'Benzinaria Nord', 'Cluj-Napoca', 'Cluj', 'Strada Mora', '7', '0264333444', 'RO34567890', TRUE),
                                                                                                    (4, 'Benzinaria Est', 'Constanta', 'Constanta', 'Strada Mircea cel Batran', '21', '0241444555', 'RO45678901', TRUE);

-- --- tip_carburant ---
INSERT INTO TIP_CARBURANT (id_tip_carburant, denumire, cod, adaos_procent, tva_procent, activ) VALUES
                                                                                                   (1, 'Benzina 95', 'BN95', 8.00, 19.00, TRUE),
                                                                                                   (2, 'Motorina', 'MD', 7.00, 19.00, TRUE);

-- --- tip_conector ---
INSERT INTO TIP_CONECTOR (id_tip_conector, denumire, curent, activ) VALUES
                                                                        (1, 'CCS2', 'DC', TRUE),
                                                                        (2, 'Type 2', 'AC', TRUE);

-- --- furnizor ---
INSERT INTO FURNIZOR (id_furnizor, denumire, cui, telefon, email, localitate, judet, strada, numar, activ) VALUES
                                                                                                               (1, 'RomPetrol Distributie', 'RO11111111', '0244555666', 'contact@rompetrol.ro', 'Ploiesti', 'Prahova', 'Strada Industriilor', '10', TRUE),
                                                                                                               (2, 'Petrom Solutions', 'RO22222222', '0217778888', 'office@petrom.ro', 'Bucuresti', 'Sector 2', 'Strada Libertatii', '50', TRUE);

-- --- angajat (admin + casieri/manager) ---
-- parole simple, hash-uite cu SHA-256 in aplicatie (clasa PasswordHasher).
INSERT INTO ANGAJAT (id_angajat, id_statie, functie, nume, prenume, cnp, telefon, email, data_angajare, utilizator, parola_hash, activ) VALUES
                                                                                                                                            (1, NULL, 'admin', 'Croitoru', 'Cristian', '1900101123456', '0722111222', 'cristian.croitoru@benzinarie.ro', '2020-01-01', 'admin', '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', TRUE),
                                                                                                                                            (2, 1, 'casier', 'Popescu', 'Ion', '1800201123457', '0733111223', 'ion.popescu@benzinarie.ro', '2021-03-15', 'ipopescu', 'a3a2754f94b4f8c1ca8d29290bc37ba90cedf0e13a9e702a829740835e5ed564', TRUE),
                                                                                                                                            (3, 2, 'manager', 'Ionescu', 'Maria', '1820301123458', '0733222334', 'maria.ionescu@benzinarie.ro', '2020-06-10', 'mionescu', 'a3a2754f94b4f8c1ca8d29290bc37ba90cedf0e13a9e702a829740835e5ed564', TRUE),
                                                                                                                                            (4, 3, 'casier', 'Stan', 'Andrei', '1910401123459', '0733333445', 'andrei.stan@benzinarie.ro', '2022-01-20', 'astan', 'a3a2754f94b4f8c1ca8d29290bc37ba90cedf0e13a9e702a829740835e5ed564', TRUE),
                                                                                                                                            (5, 4, 'casier', 'Voicu', 'Elena', '1950501123460', '0733444556', 'elena.voicu@benzinarie.ro', '2022-05-05', 'evoicu', 'a3a2754f94b4f8c1ca8d29290bc37ba90cedf0e13a9e702a829740835e5ed564', TRUE);

-- --- pret_carburant (istoric, rand cu data_sfarsit null = curent) ---
INSERT INTO PRET_CARBURANT (id_pret, id_statie, id_tip_carburant, pret, data_inceput, data_sfarsit) VALUES
-- benzinaria sud (1): benzina 95 (1) - pret curent si istoric
(1, 1, 1, 5.90, '2025-09-01', '2025-09-30'),
(2, 1, 1, 6.45, '2025-10-01', NULL),
-- benzinaria sud: motorina (2)
(3, 1, 2, 6.10, '2025-10-01', NULL),
-- benzinaria vest (2)
(4, 2, 1, 6.50, '2025-10-01', NULL),
(5, 2, 2, 6.15, '2025-10-01', NULL),
-- benzinaria nord (3)
(6, 3, 1, 6.40, '2025-10-01', NULL),
(7, 3, 2, 6.05, '2025-10-01', NULL),
-- benzinaria est (4)
(8, 4, 1, 6.55, '2025-10-01', NULL),
(9, 4, 2, 6.20, '2025-10-01', NULL);

-- --- pret_ev (istoric, rand cu data_sfarsit null = curent) ---
INSERT INTO PRET_EV (id_pret_ev, id_statie, cost_kwh, adaos_procent, tva_procent, pret_kwh, data_inceput, data_sfarsit) VALUES
                                                                                                                            (1, 1, 1.80, 10.00, 19.00, 2.10, '2025-09-01', '2025-09-30'),
                                                                                                                            (2, 1, 1.80, 10.00, 19.00, 2.36, '2025-10-01', NULL),
                                                                                                                            (3, 2, 1.75, 12.00, 19.00, 2.28, '2025-10-01', NULL),
                                                                                                                            (4, 3, 1.90, 8.00, 19.00, 2.42, '2025-10-01', NULL),
                                                                                                                            (5, 4, 1.85, 11.00, 19.00, 2.40, '2025-10-01', NULL);

-- --- rezervor (2 per statie = 8) ---
INSERT INTO REZERVOR (id_rezervor, id_statie, id_tip_carburant, numar, capacitate_max, stoc_curent, nivel_minim) VALUES
                                                                                                                     (1, 1, 1, 1, 15000.000, 5200.000, 2000.000),
                                                                                                                     (2, 1, 2, 2, 12000.000, 3100.000, 1500.000),
                                                                                                                     (3, 2, 1, 1, 10000.000, 1100.000, 1500.000),
                                                                                                                     (4, 2, 2, 2, 9000.000, 2900.000, 1000.000),
                                                                                                                     (5, 3, 1, 1, 11000.000, 4300.000, 1800.000),
                                                                                                                     (6, 3, 2, 2, 8500.000, 700.000, 1000.000),
                                                                                                                     (7, 4, 1, 1, 13000.000, 5100.000, 2200.000),
                                                                                                                     (8, 4, 2, 2, 10000.000, 2200.000, 1600.000);

-- --- pompa (2 per statie) ---
INSERT INTO POMPA (id_pompa, id_statie, numar, activ) VALUES
                                                          (1, 1, 1, TRUE),
                                                          (2, 1, 2, TRUE),
                                                          (3, 2, 1, TRUE),
                                                          (4, 2, 2, TRUE),
                                                          (5, 3, 1, TRUE),
                                                          (6, 3, 2, TRUE),
                                                          (7, 4, 1, TRUE),
                                                          (8, 4, 2, TRUE);

-- --- duza (2-3 per pompa) ---
INSERT INTO DUZA (id_duza, id_pompa, id_rezervor, numar, activ) VALUES
                                                                    (1, 1, 1, 1, TRUE),
                                                                    (2, 1, 1, 2, TRUE),
                                                                    (3, 2, 2, 1, TRUE),
                                                                    (4, 2, 2, 2, TRUE),
                                                                    (5, 3, 3, 1, TRUE),
                                                                    (6, 3, 3, 2, TRUE),
                                                                    (7, 4, 4, 1, TRUE),
                                                                    (8, 5, 5, 1, TRUE),
                                                                    (9, 5, 5, 2, TRUE),
                                                                    (10, 6, 6, 1, TRUE),
                                                                    (11, 7, 7, 1, TRUE),
                                                                    (12, 7, 7, 2, TRUE),
                                                                    (13, 8, 8, 1, TRUE);

-- --- statie_ev (1-2 per statie) ---
INSERT INTO STATIE_EV (id_statie_ev, id_statie, numar, activ) VALUES
                                                                  (1, 1, 1, TRUE),
                                                                  (2, 1, 2, TRUE),
                                                                  (3, 2, 1, TRUE),
                                                                  (4, 3, 1, TRUE),
                                                                  (5, 4, 1, TRUE),
                                                                  (6, 4, 2, TRUE);

-- --- conector (2 per statie_ev) ---
INSERT INTO CONECTOR (id_conector, id_statie_ev, id_tip_conector, numar, putere_kw, activ) VALUES
                                                                                               (1, 1, 1, 1, 150.00, TRUE),
                                                                                               (2, 1, 2, 2, 22.00, TRUE),
                                                                                               (3, 2, 1, 1, 150.00, TRUE),
                                                                                               (4, 2, 2, 2, 22.00, TRUE),
                                                                                               (5, 3, 1, 1, 50.00, TRUE),
                                                                                               (6, 3, 2, 2, 22.00, TRUE),
                                                                                               (7, 4, 1, 1, 150.00, TRUE),
                                                                                               (8, 4, 2, 2, 22.00, TRUE),
                                                                                               (9, 5, 1, 1, 50.00, TRUE),
                                                                                               (10, 5, 2, 2, 22.00, TRUE),
                                                                                               (11, 6, 1, 1, 150.00, TRUE),
                                                                                               (12, 6, 2, 2, 22.00, TRUE);

-- --- comanda (plasata / partial livrata / livrata / anulata) ---
INSERT INTO COMANDA (id_comanda, id_statie, id_angajat, id_furnizor, data_comanda, stare) VALUES
                                                                                              (1, 1, 3, 1, '2025-09-10', 'livrata'),
                                                                                              (2, 2, 3, 2, '2025-09-15', 'plasata'),
                                                                                              (3, 3, 3, 1, '2025-09-18', 'plasata'),
                                                                                              (4, 4, 1, 1, '2025-09-20', 'anulata');

-- --- linie_comanda ---
INSERT INTO LINIE_COMANDA (id_linie_comanda, id_comanda, id_tip_carburant, cantitate_comandata) VALUES
                                                                                                    (1, 1, 1, 5000.000),
                                                                                                    (2, 1, 2, 3000.000),
                                                                                                    (3, 2, 1, 2000.000),
                                                                                                    (4, 3, 1, 4000.000),
                                                                                                    (5, 4, 2, 2500.000);

-- --- livrare ---
INSERT INTO LIVRARE (id_livrare, id_comanda, data_livrare, nr_aviz, nr_factura) VALUES
                                                                                    (1, 1, '2025-09-12', 'AV-1001', 'F-2001'),
                                                                                    (2, 1, '2025-09-14', 'AV-1002', 'F-2002'),
                                                                                    (3, 2, '2025-09-18', 'AV-1003', 'F-2003');

-- --- linie_livrare ---
INSERT INTO LINIE_LIVRARE (id_linie_livrare, id_livrare, id_linie_comanda, id_rezervor, cantitate_primita, pret_achizitie) VALUES
                                                                                                                               (1, 1, 1, 1, 3000.000, 5.20),
                                                                                                                               (2, 2, 1, 1, 2000.000, 5.20),
                                                                                                                               (3, 2, 2, 2, 3000.000, 4.90),
                                                                                                                               (4, 3, 3, 3, 1000.000, 5.25);

-- --- bon (valid / anulat, numar_bon unic pe statie) ---
INSERT INTO BON (id_bon, id_statie, id_angajat, numar_bon, data_ora, stare) VALUES
                                                                                (1, 1, 2, 101, '2025-10-05 08:30:00', 'valid'),
                                                                                (2, 1, 2, 102, '2025-10-05 09:15:00', 'anulat'),
                                                                                (3, 2, 3, 201, '2025-10-06 10:00:00', 'valid'),
                                                                                (4, 3, 4, 301, '2025-10-07 11:00:00', 'valid');

-- --- alimentare (id_bon null = neplatita) ---
INSERT INTO ALIMENTARE (id_alimentare, id_duza, id_tip_carburant, id_bon, data_ora, litri, pret_litru, tva_procent) VALUES
                                                                                                                        (1, 1, 1, 1, '2025-10-05 08:35:00', 35.500, 6.45, 19.00),
                                                                                                                        (2, 3, 2, 1, '2025-10-05 08:40:00', 25.000, 6.10, 19.00),
                                                                                                                        (3, 5, 1, NULL, '2025-10-06 09:00:00', 40.000, 6.50, 19.00),
                                                                                                                        (4, 2, 1, 2, '2025-10-05 09:20:00', 20.000, 6.45, 19.00),
                                                                                                                        (5, 8, 1, 3, '2025-10-06 10:05:00', 30.000, 6.40, 19.00),
                                                                                                                        (6, 10, 2, NULL, '2025-10-07 11:05:00', 15.000, 6.05, 19.00),
                                                                                                                        (7, 11, 1, 4, '2025-10-07 11:15:00', 45.000, 6.55, 19.00),
                                                                                                                        (8, 13, 2, NULL, '2025-10-08 12:00:00', 12.000, 6.20, 19.00);

-- --- incarcare_ev (id_bon null = neplatita) ---
INSERT INTO INCARCARE_EV (id_incarcare, id_conector, id_bon, data_ora_start, data_ora_sfarsit, kwh, pret_kwh, tva_procent) VALUES
                                                                                                                               (1, 1, 1, '2025-10-05 08:45:00', '2025-10-05 09:00:00', 25.000, 2.36, 19.00),
                                                                                                                               (2, 3, NULL, '2025-10-06 10:30:00', NULL, 18.000, 2.28, 19.00),
                                                                                                                               (3, 5, 3, '2025-10-06 11:00:00', '2025-10-06 11:30:00', 22.000, 2.42, 19.00),
                                                                                                                               (4, 7, 4, '2025-10-07 11:30:00', '2025-10-07 11:50:00', 30.000, 2.40, 19.00),
                                                                                                                               (5, 9, NULL, '2025-10-08 12:30:00', NULL, 10.000, 2.40, 19.00);

-- --- tranzactie ---
INSERT INTO TRANZACTIE (id_tranzactie, id_bon, metoda, suma) VALUES
                                                                 (1, 1, 'numerar', 200.00),
                                                                 (2, 1, 'card', 240.48),
                                                                 (3, 3, 'card', 245.24),
                                                                 (4, 4, 'numerar', 294.75);

-- --- incident_neplata ---
INSERT INTO INCIDENT_NEPLATA (id_incident, id_alimentare, id_incarcare, id_angajat, nr_inmatriculare, descriere, data_ora, stare) VALUES
                                                                                                                                      (1, 3, NULL, 3, 'B 123 XYZ', 'Clientul a parsat si nu a platit alimentarea la duza 5.', '2025-10-06 09:30:00', 'deschis'),
                                                                                                                                      (2, NULL, 2, 3, 'C 456 ABC', 'Incarcare EV neplatita, masina a parsat de la conectorul 3.', '2025-10-06 11:00:00', 'anuntata politia'),
                                                                                                                                      (3, 6, NULL, 4, 'CJ 789 DEF', 'Alimentare neplatita, plata recuperata ulterior.', '2025-10-07 11:10:00', 'recuperat');

-- Daca toate INSERT-urile au reusit, confirma modificarile.
COMMIT;

-- Reactivare Safe Updates.
SET SQL_SAFE_UPDATES = 1;

-- Verificare rapida.
SELECT 'STATIE' AS tabel, COUNT(*) AS inregistrari FROM STATIE
UNION ALL SELECT 'ANGAJAT', COUNT(*) FROM ANGAJAT
UNION ALL SELECT 'FURNIZOR', COUNT(*) FROM FURNIZOR
UNION ALL SELECT 'ALIMENTARE', COUNT(*) FROM ALIMENTARE
UNION ALL SELECT 'BON', COUNT(*) FROM BON;
