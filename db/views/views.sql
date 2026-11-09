-- view-uri benzinarii.
-- depinde de: db/schema/.

USE BENZINARII;

-- 1. v_bon_complet: toate liniile unui bon (carburant si ev), cu baza impozabila, tva si total per linie
-- folosit in aplicatie pentru afisarea bonului fiscal si pentru calculul totalului de plata.

CREATE VIEW v_bon_complet AS
SELECT
    b.id_bon,
    b.id_statie,
    s.denumire AS denumire_statie,
    s.cui AS cui_statie,
    b.id_angajat,
    CONCAT(a.nume, ' ', a.prenume) AS angajat,
    b.numar_bon,
    b.data_ora,
    b.stare AS stare_bon,
    'ALIMENTARE' AS tip_linie,
    al.id_alimentare AS id_linie,
    al.id_duza AS id_duza_conector,
    tc.denumire AS produs,
    al.litri AS cantitate,
    al.pret_litru AS pret_unitar,
    al.tva_procent,
    al.litri * al.pret_litru AS valoare,
    al.litri * al.pret_litru / (1 + al.tva_procent / 100) AS baza_impozabila,
    al.litri * al.pret_litru - al.litri * al.pret_litru / (1 + al.tva_procent / 100) AS valoare_tva
FROM BON b
JOIN STATIE s ON b.id_statie = s.id_statie
JOIN ANGAJAT a ON b.id_angajat = a.id_angajat
JOIN ALIMENTARE al ON al.id_bon = b.id_bon
JOIN DUZA d ON al.id_duza = d.id_duza
JOIN REZERVOR r ON d.id_rezervor = r.id_rezervor
JOIN TIP_CARBURANT tc ON r.id_tip_carburant = tc.id_tip_carburant
WHERE b.stare = 'valid'

UNION ALL

SELECT
    b.id_bon,
    b.id_statie,
    s.denumire AS denumire_statie,
    s.cui AS cui_statie,
    b.id_angajat,
    CONCAT(a.nume, ' ', a.prenume) AS angajat,
    b.numar_bon,
    b.data_ora,
    b.stare AS stare_bon,
    'INCARCARE_EV' AS tip_linie,
    inc.id_incarcare AS id_linie,
    inc.id_conector AS id_duza_conector,
    'Incarcare EV' AS produs,
    inc.kwh AS cantitate,
    inc.pret_kwh AS pret_unitar,
    inc.tva_procent,
    inc.kwh * inc.pret_kwh AS valoare,
    inc.kwh * inc.pret_kwh / (1 + inc.tva_procent / 100) AS baza_impozabila,
    inc.kwh * inc.pret_kwh - inc.kwh * inc.pret_kwh / (1 + inc.tva_procent / 100) AS valoare_tva
FROM BON b
JOIN STATIE s ON b.id_statie = s.id_statie
JOIN ANGAJAT a ON b.id_angajat = a.id_angajat
JOIN INCARCARE_EV inc ON inc.id_bon = b.id_bon
WHERE b.stare = 'valid';

-- 2. v_stare_alimentare_incarcare: starea fiec�rei alimentari/incarcari (neplatita / platita / incident)
-- folosit in aplicatie pentru lista de incasari pendente (casier vede ce trebuie platit)
CREATE VIEW v_stare_alimentare_incarcare AS
SELECT
    'ALIMENTARE' AS tip,
    al.id_alimentare AS id_vanzare,
    al.id_duza,
    al.data_ora,
    al.litri * al.pret_litru AS valoare_datorata,
    CASE
        WHEN i.id_incident IS NOT NULL THEN 'incident'
        WHEN al.id_bon IS NOT NULL THEN 'platita'
        ELSE 'neplatita'
    END AS stare
FROM ALIMENTARE al
LEFT JOIN INCIDENT_NEPLATA i ON i.id_alimentare = al.id_alimentare

UNION ALL

SELECT
    'INCARCARE_EV' AS tip,
    inc.id_incarcare AS id_vanzare,
    inc.id_conector AS id_duza,
    inc.data_ora_start AS data_ora,
    inc.kwh * inc.pret_kwh AS valoare_datorata,
    CASE
        WHEN i.id_incident IS NOT NULL THEN 'incident'
        WHEN inc.id_bon IS NOT NULL THEN 'platita'
        ELSE 'neplatita'
    END AS stare
FROM INCARCARE_EV inc
LEFT JOIN INCIDENT_NEPLATA i ON i.id_incarcare = inc.id_incarcare;

-- 3. v_alerte_stoc: rezervoarele cu stoc_curent < nivel_minim (doar carburant).
-- folosit in aplicatie pentru alertele managerului de statie.
CREATE VIEW v_alerte_stoc AS
SELECT
    r.id_rezervor,
    r.id_statie,
    s.denumire AS denumire_statie,
    r.numar,
    tc.denumire AS carburant,
    r.capacitate_max,
    r.stoc_curent,
    r.nivel_minim,
    (r.nivel_minim - r.stoc_curent) AS lipsa_la_minim
FROM REZERVOR r
JOIN STATIE s ON r.id_statie = s.id_statie
JOIN TIP_CARBURANT tc ON r.id_tip_carburant = tc.id_tip_carburant
WHERE r.stoc_curent < r.nivel_minim;

-- 4. v_preturi_curente: pretul curent (data_sfarsit null) carburant si ev, per statie.
-- folosit in aplicatie pentru afisarea preturilor la pompa / conector.
CREATE VIEW v_preturi_curente AS
SELECT
    'CARBURANT' AS tip,
    p.id_statie,
    s.denumire AS denumire_statie,
    p.id_tip_carburant,
    tc.denumire AS denumire_carb,
    p.pret AS valoare,
    p.data_inceput
FROM PRET_CARBURANT p
JOIN STATIE s ON p.id_statie = s.id_statie
JOIN TIP_CARBURANT tc ON p.id_tip_carburant = tc.id_tip_carburant
WHERE p.data_sfarsit IS NULL

UNION ALL

SELECT
    'EV' AS tip,
    p.id_statie,
    s.denumire AS denumire_statie,
    NULL AS id_tip_carburant,
    NULL AS denumire_carb,
    p.pret_kwh AS valoare,
    p.data_inceput
FROM PRET_EV p
JOIN STATIE s ON p.id_statie = s.id_statie
WHERE p.data_sfarsit IS NULL;

-- 5. v_stoc_rezervoare: stocul actual al fiec�rui rezervor.
-- tolosit in aplicatie pentru pagina de stocuri (manager).
CREATE VIEW v_stoc_rezervoare AS
SELECT
    r.id_rezervor,
    r.id_statie,
    s.denumire AS denumire_statie,
    r.numar,
    tc.denumire AS carburant,
    r.capacitate_max,
    r.stoc_curent,
    r.nivel_minim,
    (r.capacitate_max - r.stoc_curent) AS spatiu_disponibil
FROM REZERVOR r
JOIN STATIE s ON r.id_statie = s.id_statie
JOIN TIP_CARBURANT tc ON r.id_tip_carburant = tc.id_tip_carburant;

-- 6. v_linii_bon: detalii pe fiecare linie de bon (unde s-a facut vanzarea).
-- folosit in aplicatie pentru detaliile bonului (pompa/duza/conector folosit).
CREATE VIEW v_linii_bon AS
SELECT
    al.id_bon,
    'ALIMENTARE' AS tip_linie,
    al.id_alimentare AS id_linie,
    d.id_duza,
    d.numar AS numar_duza,
    p.id_pompa,
    p.numar AS numar_pompa,
    r.id_rezervor,
    r.numar AS numar_rezervor,
    NULL AS id_conector,
    NULL AS numar_conector,
    al.litri AS cantitate
FROM ALIMENTARE al
JOIN DUZA d ON al.id_duza = d.id_duza
JOIN POMPA p ON d.id_pompa = p.id_pompa
JOIN REZERVOR r ON d.id_rezervor = r.id_rezervor

UNION ALL

SELECT
    inc.id_bon,
    'INCARCARE_EV' AS tip_linie,
    inc.id_incarcare AS id_linie,
    NULL AS id_duza,
    NULL AS numar_duza,
    NULL AS id_pompa,
    NULL AS numar_pompa,
    NULL AS id_rezervor,
    NULL AS numar_rezervor,
    c.id_conector,
    c.numar AS numar_conector,
    inc.kwh AS cantitate
FROM INCARCARE_EV inc
JOIN CONECTOR c ON inc.id_conector = c.id_conector;

-- 7. v_comenzi_stare: comenzi cu detaliile statiei, furnizorului si angajatului.
-- folosit in aplicatie pentru gestionarea comenzilor (manager/admin).
CREATE VIEW v_comenzi_stare AS
SELECT
    c.id_comanda,
    c.id_statie,
    s.denumire AS denumire_statie,
    c.id_furnizor,
    f.denumire AS denumire_furnizor,
    c.id_angajat,
    CONCAT(a.nume, ' ', a.prenume) AS angajat,
    c.data_comanda,
    c.stare
FROM COMANDA c
JOIN STATIE s ON c.id_statie = s.id_statie
JOIN FURNIZOR f ON c.id_furnizor = f.id_furnizor
JOIN ANGAJAT a ON c.id_angajat = a.id_angajat;

-- 8. v_incidente_deschise: incidente deschise cu valoarea datorata si sursa (alimentare / incarcare).
-- folosit in aplicatie pentru pagina incidente (casier/manager).
CREATE VIEW v_incidente_deschise AS
SELECT
    i.id_incident,
    i.id_angajat,
    CONCAT(a.nume, ' ', a.prenume) AS angajat,
    i.nr_inmatriculare,
    i.descriere,
    i.data_ora,
    i.stare,
    'ALIMENTARE' AS tip_sursa,
    al.id_alimentare AS id_sursa,
    al.litri * al.pret_litru AS valoare_datorata,
    st.id_statie
FROM INCIDENT_NEPLATA i
JOIN ANGAJAT a ON i.id_angajat = a.id_angajat
JOIN ALIMENTARE al ON i.id_alimentare = al.id_alimentare
JOIN DUZA d ON al.id_duza = d.id_duza
JOIN REZERVOR r ON d.id_rezervor = r.id_rezervor
JOIN STATIE st ON r.id_statie = st.id_statie
WHERE i.stare <> 'inchis'

UNION ALL

SELECT
    i.id_incident,
    i.id_angajat,
    CONCAT(a.nume, ' ', a.prenume) AS angajat,
    i.nr_inmatriculare,
    i.descriere,
    i.data_ora,
    i.stare,
    'INCARCARE_EV' AS tip_sursa,
    inc.id_incarcare AS id_sursa,
    inc.kwh * inc.pret_kwh AS valoare_datorata,
    st.id_statie
FROM INCIDENT_NEPLATA i
JOIN ANGAJAT a ON i.id_angajat = a.id_angajat
JOIN INCARCARE_EV inc ON i.id_incarcare = inc.id_incarcare
JOIN CONECTOR c ON inc.id_conector = c.id_conector
JOIN STATIE_EV se ON c.id_statie_ev = se.id_statie_ev
JOIN STATIE st ON se.id_statie = st.id_statie
WHERE i.stare <> 'inchis';
