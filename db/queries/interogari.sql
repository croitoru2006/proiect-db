-- depinde de: db/schema/, db/views/.

USE BENZINARII;

-- q01. statiile active ale lantului
-- aplicatie: lista de statii disponibile pentru login / selectare statie
SELECT id_statie, denumire, localitate, judet, strada, numar, telefon, cui
FROM STATIE
WHERE activ = TRUE
ORDER BY denumire;

-- q02. angajatii unei statii cu functia lor
-- aplicatie: ecranul de gestionare angajati (manager/admin)
SELECT a.id_angajat, a.nume, a.prenume, a.functie, a.utilizator, a.cnp, a.telefon, a.email,
       a.data_angajare, s.denumire AS statie, a.activ
FROM ANGAJAT a
LEFT JOIN STATIE s ON a.id_statie = s.id_statie
WHERE a.activ = TRUE
ORDER BY s.denumire, a.functie, a.nume;

-- q03. bonuri valide cu totalul platit (baza impozabila + tva)
-- aplicatie: afisarea bonului fiscal si verificarea sumei de plata (casier)
SELECT b.id_bon, b.numar_bon, b.data_ora, s.denumire AS statie,
       CONCAT(a.nume, ' ', a.prenume) AS casier,
       COALESCE(SUM(lb.valoare),0) AS total_bon,
       COALESCE(SUM(lb.baza_impozabila),0) AS baza_impozabila,
       COALESCE(SUM(lb.valoare_tva),0) AS tva
FROM BON b
JOIN STATIE s ON b.id_statie = s.id_statie
JOIN ANGAJAT a ON b.id_angajat = a.id_angajat
LEFT JOIN v_linii_bon lb ON lb.id_bon = b.id_bon
WHERE b.stare = 'valid'
GROUP BY b.id_bon, b.numar_bon, b.data_ora, s.denumire, casier
ORDER BY b.data_ora DESC;

-- q04. vanzari neplatite (alimentari si incarcari ev) asteptate de incasat
-- aplicatie: lista de incasari pendente pentru casier
SELECT tip, id_vanzare, data_ora, valoare_datorata, stare
FROM v_stare_alimentare_incarcare
WHERE stare = 'neplatita'
ORDER BY data_ora;

-- q05. alerte de stoc: rezervoare sub nivelul minim
-- aplicatie: pagina de alerte pentru managerul de statie
SELECT id_rezervor, denumire_statie, numar, carburant, capacitate_max, stoc_curent,
       nivel_minim, lipsa_la_minim
FROM v_alerte_stoc
ORDER BY lipsa_la_minim DESC;

-- q06. preturi curente (carburant si ev) per statie
-- aplicatie: afisarea preturilor la pompa / conector (client si angajat)
SELECT tip, denumire_statie, denumire_carb, valoare AS pret, data_inceput
FROM v_preturi_curente
ORDER BY denumire_statie, tip;

-- q07. comenzi ne livrate (plasata) cu furnizorul si angajatul care le-a plasat
-- aplicatie: gestionarea comenzilor pendente (manager/admin)
SELECT c.id_comanda, c.data_comanda, c.stare,
       s.denumire AS statie, f.denumire AS furnizor,
       CONCAT(a.nume, ' ', a.prenume) AS angajat
FROM COMANDA c
JOIN STATIE s ON c.id_statie = s.id_statie
JOIN FURNIZOR f ON c.id_furnizor = f.id_furnizor
JOIN ANGAJAT a ON c.id_angajat = a.id_angajat
WHERE c.stare = 'plasata'
ORDER BY c.data_comanda;

-- q08. incidente deschise cu valoarea datorata si sursa (alimentare sau incarcare ev)
-- aplicatie: pagina de incidente pentru casier/manager
SELECT id_incident, nr_inmatriculare, descriere, data_ora, stare,
       tip_sursa, id_sursa, valoare_datorata
FROM v_incidente_deschise
ORDER BY data_ora DESC;
