-- schema benzinarii
-- ordinea de rulare: 1. schema, 2. seed, 3. view-uri, 4. proceduri, 5. triggere, 6. interogari, 7. teste.

DROP DATABASE IF EXISTS BENZINARII;

CREATE DATABASE BENZINARII;

USE BENZINARII;

-- tip_carburant: tipurile de carburant vandute
CREATE TABLE TIP_CARBURANT (
    id_tip_carburant INT AUTO_INCREMENT PRIMARY KEY,
    denumire VARCHAR(100) NOT NULL UNIQUE,
    cod VARCHAR(10) NOT NULL UNIQUE,
    adaos_procent DECIMAL(5,2) NOT NULL,
    tva_procent DECIMAL(5,2) NOT NULL,
    activ BOOLEAN NOT NULL DEFAULT TRUE
);

-- statie: o benzinarie din lant
CREATE TABLE STATIE (
    id_statie INT AUTO_INCREMENT PRIMARY KEY,
    denumire VARCHAR(100) NOT NULL,
    localitate VARCHAR(100) NOT NULL,
    judet VARCHAR(50) NOT NULL,
    strada VARCHAR(100) NOT NULL,
    numar VARCHAR(20) NOT NULL,
    telefon VARCHAR(20),
    cui VARCHAR(20) NOT NULL,
    activ BOOLEAN NOT NULL DEFAULT TRUE
);

-- furnizor: furnizorul de carburant
CREATE TABLE FURNIZOR (
    id_furnizor INT AUTO_INCREMENT PRIMARY KEY,
    denumire VARCHAR(100) NOT NULL,
    cui VARCHAR(20) NOT NULL UNIQUE,
    telefon VARCHAR(20),
    email VARCHAR(100),
    localitate VARCHAR(100) NOT NULL,
    judet VARCHAR(50) NOT NULL,
    strada VARCHAR(100),
    numar VARCHAR(20),
    activ BOOLEAN NOT NULL DEFAULT TRUE
);

-- tip_conector: tip de conector ev
CREATE TABLE TIP_CONECTOR (
    id_tip_conector INT AUTO_INCREMENT PRIMARY KEY,
    denumire VARCHAR(50) NOT NULL,
    curent ENUM('AC','DC') NOT NULL,
    activ BOOLEAN NOT NULL DEFAULT TRUE
);

-- angajat: casier, manager sau admin
CREATE TABLE ANGAJAT (
    id_angajat INT AUTO_INCREMENT PRIMARY KEY,
    id_statie INT,
    functie ENUM('casier','manager','admin') NOT NULL,
    nume VARCHAR(50) NOT NULL,
    prenume VARCHAR(50) NOT NULL,
    cnp CHAR(13) NOT NULL UNIQUE,
    telefon VARCHAR(20),
    email VARCHAR(100),
    data_angajare DATE NOT NULL,
    utilizator VARCHAR(50) NOT NULL UNIQUE,
    parola_hash VARCHAR(255) NOT NULL,
    activ BOOLEAN NOT NULL DEFAULT TRUE,
    --CHECK care permite adminul sa nu fie asociat unei statii si obliga casierul si managerul sa fie
    CONSTRAINT chk_angajat_statie CHECK (
        (functie = 'admin' AND id_statie IS NULL) OR
        (functie <> 'admin' AND id_statie IS NOT NULL)
    ),
    CONSTRAINT fk_angajat_statie FOREIGN KEY (id_statie) REFERENCES STATIE(id_statie) ON DELETE RESTRICT
);

-- pret_carburant: istoric preturi carburant pe statie
CREATE TABLE PRET_CARBURANT (
    id_pret INT AUTO_INCREMENT PRIMARY KEY,
    id_statie INT NOT NULL,
    id_tip_carburant INT NOT NULL,
    pret DECIMAL(10,2) NOT NULL,
    data_inceput DATE NOT NULL,
    data_sfarsit DATE,
    CONSTRAINT fk_pret_carb_statie FOREIGN KEY (id_statie) REFERENCES STATIE(id_statie) ON DELETE RESTRICT,
    CONSTRAINT fk_pret_carb_tip FOREIGN KEY (id_tip_carburant) REFERENCES TIP_CARBURANT(id_tip_carburant) ON DELETE RESTRICT
);

-- rezervor: rezervor de carburant la statie
CREATE TABLE REZERVOR (
    id_rezervor INT AUTO_INCREMENT PRIMARY KEY,
    id_statie INT NOT NULL,
    id_tip_carburant INT NOT NULL,
    numar INT NOT NULL,
    capacitate_max DECIMAL(12,3) NOT NULL,
    stoc_curent DECIMAL(12,3) NOT NULL DEFAULT 0,
    nivel_minim DECIMAL(12,3) NOT NULL DEFAULT 0,
    UNIQUE (id_statie, numar),
    CONSTRAINT fk_rezervor_statie FOREIGN KEY (id_statie) REFERENCES STATIE(id_statie) ON DELETE RESTRICT,
    CONSTRAINT fk_rezervor_tip_carb FOREIGN KEY (id_tip_carburant) REFERENCES TIP_CARBURANT(id_tip_carburant) ON DELETE RESTRICT
);

-- pompa: pompa de carburant la statie
CREATE TABLE POMPA (
    id_pompa INT AUTO_INCREMENT PRIMARY KEY,
    id_statie INT NOT NULL,
    numar INT NOT NULL,
    activ BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE (id_statie, numar),
    CONSTRAINT fk_pompa_statie FOREIGN KEY (id_statie) REFERENCES STATIE(id_statie) ON DELETE RESTRICT
);

-- duza: duza de carburant
CREATE TABLE DUZA (
    id_duza INT AUTO_INCREMENT PRIMARY KEY,
    id_pompa INT NOT NULL,
    id_rezervor INT NOT NULL,
    numar INT NOT NULL,
    activ BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE (id_pompa, numar),
    CONSTRAINT fk_duza_pompa FOREIGN KEY (id_pompa) REFERENCES POMPA(id_pompa) ON DELETE RESTRICT,
    CONSTRAINT fk_duza_rezervor FOREIGN KEY (id_rezervor) REFERENCES REZERVOR(id_rezervor) ON DELETE RESTRICT
);

-- statie_ev: parcare de incarcare ev la statie
CREATE TABLE STATIE_EV (
    id_statie_ev INT AUTO_INCREMENT PRIMARY KEY,
    id_statie INT NOT NULL,
    numar INT NOT NULL,
    activ BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE (id_statie, numar),
    CONSTRAINT fk_statie_ev_statie FOREIGN KEY (id_statie) REFERENCES STATIE(id_statie) ON DELETE RESTRICT
);

-- conector: conector de incarcare ev
CREATE TABLE CONECTOR (
    id_conector INT AUTO_INCREMENT PRIMARY KEY,
    id_statie_ev INT NOT NULL,
    id_tip_conector INT NOT NULL,
    numar INT NOT NULL,
    putere_kw DECIMAL(10,2) NOT NULL,
    activ BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE (id_statie_ev, numar),
    CONSTRAINT fk_conector_statie_ev FOREIGN KEY (id_statie_ev) REFERENCES STATIE_EV(id_statie_ev) ON DELETE RESTRICT,
    CONSTRAINT fk_conector_tip_conector FOREIGN KEY (id_tip_conector) REFERENCES TIP_CONECTOR(id_tip_conector) ON DELETE RESTRICT
);

-- pret_ev: istoric pret kwh pe statie
CREATE TABLE PRET_EV (
    id_pret_ev INT AUTO_INCREMENT PRIMARY KEY,
    id_statie INT NOT NULL,
    cost_kwh DECIMAL(10,2) NOT NULL,
    adaos_procent DECIMAL(5,2) NOT NULL,
    tva_procent DECIMAL(5,2) NOT NULL,
    pret_kwh DECIMAL(10,2) NOT NULL,
    data_inceput DATE NOT NULL,
    data_sfarsit DATE,
    CONSTRAINT fk_pret_ev_statie FOREIGN KEY (id_statie) REFERENCES STATIE(id_statie) ON DELETE RESTRICT
);

-- comanda: comanda de carburant plasata la un furnizor pentru o statie
CREATE TABLE COMANDA (
    id_comanda INT AUTO_INCREMENT PRIMARY KEY,
    id_statie INT NOT NULL,
    id_angajat INT NOT NULL,
    id_furnizor INT NOT NULL,
    data_comanda DATE NOT NULL,
    stare ENUM('plasata','livrata','anulata') NOT NULL DEFAULT 'plasata',
    CONSTRAINT fk_comanda_statie FOREIGN KEY (id_statie) REFERENCES STATIE(id_statie) ON DELETE RESTRICT,
    CONSTRAINT fk_comanda_angajat FOREIGN KEY (id_angajat) REFERENCES ANGAJAT(id_angajat) ON DELETE RESTRICT,
    CONSTRAINT fk_comanda_furnizor FOREIGN KEY (id_furnizor) REFERENCES FURNIZOR(id_furnizor) ON DELETE RESTRICT
);

-- linie_comanda: carburantul si cantitatea comandata in cadrul unei comenzi
CREATE TABLE LINIE_COMANDA (
    id_linie_comanda INT AUTO_INCREMENT PRIMARY KEY,
    id_comanda INT NOT NULL,
    id_tip_carburant INT NOT NULL,
    cantitate_comandata DECIMAL(12,3) NOT NULL,
    CONSTRAINT fk_linie_comanda_comanda FOREIGN KEY (id_comanda) REFERENCES COMANDA(id_comanda) ON DELETE RESTRICT,
    CONSTRAINT fk_linie_comanda_tip_carb FOREIGN KEY (id_tip_carburant) REFERENCES TIP_CARBURANT(id_tip_carburant) ON DELETE RESTRICT
);

-- livrare: livrarea fizica (cisterna) a unei comenzi
CREATE TABLE LIVRARE (
    id_livrare INT AUTO_INCREMENT PRIMARY KEY,
    id_comanda INT NOT NULL,
    data_livrare DATE NOT NULL,
    nr_aviz VARCHAR(50),
    nr_factura VARCHAR(50),
    CONSTRAINT fk_livrare_comanda FOREIGN KEY (id_comanda) REFERENCES COMANDA(id_comanda) ON DELETE RESTRICT
);

-- linie_livrare: ce cantitate a ajuns in ce rezervor
CREATE TABLE LINIE_LIVRARE (
    id_linie_livrare INT AUTO_INCREMENT PRIMARY KEY,
    id_livrare INT NOT NULL,
    id_linie_comanda INT NOT NULL,
    id_rezervor INT NOT NULL,
    cantitate_primita DECIMAL(12,3) NOT NULL,
    pret_achizitie DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_linie_livrare_livrare FOREIGN KEY (id_livrare) REFERENCES LIVRARE(id_livrare) ON DELETE RESTRICT,
    CONSTRAINT fk_linie_livrare_linie_comanda FOREIGN KEY (id_linie_comanda) REFERENCES LINIE_COMANDA(id_linie_comanda) ON DELETE RESTRICT,
    CONSTRAINT fk_linie_livrare_rezervor FOREIGN KEY (id_rezervor) REFERENCES REZERVOR(id_rezervor) ON DELETE RESTRICT
);

-- bon: bon fiscal digital
CREATE TABLE BON (
    id_bon INT AUTO_INCREMENT PRIMARY KEY,
    id_statie INT NOT NULL,
    id_angajat INT NOT NULL,
    numar_bon INT NOT NULL,
    data_ora DATETIME NOT NULL,
    stare ENUM('valid','anulat') NOT NULL DEFAULT 'valid',
    UNIQUE (id_statie, numar_bon),
    CONSTRAINT fk_bon_statie FOREIGN KEY (id_statie) REFERENCES STATIE(id_statie) ON DELETE RESTRICT,
    CONSTRAINT fk_bon_angajat FOREIGN KEY (id_angajat) REFERENCES ANGAJAT(id_angajat) ON DELETE RESTRICT
);

-- alimentare: alimentare carburant la duza
CREATE TABLE ALIMENTARE (
    id_alimentare INT AUTO_INCREMENT PRIMARY KEY,
    id_duza INT NOT NULL,
    id_tip_carburant INT NOT NULL,
    id_bon INT,
    data_ora DATETIME NOT NULL,
    litri DECIMAL(12,3) NOT NULL,
    pret_litru DECIMAL(10,2) NOT NULL,
    tva_procent DECIMAL(5,2) NOT NULL,
    CONSTRAINT fk_alimentare_duza FOREIGN KEY (id_duza) REFERENCES DUZA(id_duza) ON DELETE RESTRICT,
    CONSTRAINT fk_alimentare_tip_carb FOREIGN KEY (id_tip_carburant) REFERENCES TIP_CARBURANT(id_tip_carburant) ON DELETE RESTRICT,
    CONSTRAINT fk_alimentare_bon FOREIGN KEY (id_bon) REFERENCES BON(id_bon) ON DELETE SET NULL
);

-- incarcare_ev: incarcare ev la conector
CREATE TABLE INCARCARE_EV (
    id_incarcare INT AUTO_INCREMENT PRIMARY KEY,
    id_conector INT NOT NULL,
    id_bon INT,
    data_ora_start DATETIME NOT NULL,
    data_ora_sfarsit DATETIME,
    kwh DECIMAL(12,3) NOT NULL,
    pret_kwh DECIMAL(10,2) NOT NULL,
    tva_procent DECIMAL(5,2) NOT NULL,
    CONSTRAINT fk_incarcare_conector FOREIGN KEY (id_conector) REFERENCES CONECTOR(id_conector) ON DELETE RESTRICT,
    CONSTRAINT fk_incarcare_bon FOREIGN KEY (id_bon) REFERENCES BON(id_bon) ON DELETE SET NULL
);

-- tranzactie: plata pentru un bon
CREATE TABLE TRANZACTIE (
    id_tranzactie INT AUTO_INCREMENT PRIMARY KEY,
    id_bon INT NOT NULL,
    metoda ENUM('numerar','card') NOT NULL,
    suma DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_tranzactie_bon FOREIGN KEY (id_bon) REFERENCES BON(id_bon) ON DELETE RESTRICT
);

-- incident_neplata: incident deschis pentru o alimentare sau o incarcare neplatita

CREATE TABLE INCIDENT_NEPLATA (
    id_incident INT AUTO_INCREMENT PRIMARY KEY,
    id_alimentare INT UNIQUE,
    id_incarcare INT UNIQUE,
    id_angajat INT NOT NULL,
    nr_inmatriculare VARCHAR(20) NOT NULL,
    descriere VARCHAR(500),
    data_ora DATETIME NOT NULL,
    stare ENUM('deschis','recuperat','anuntata politia','inchis') NOT NULL DEFAULT 'deschis',
    --CHECK pt. blocarea inregistratii uni incident fara cel putin o legatura la alimentare sau incarcare
    CONSTRAINT chk_incident_exact_una CHECK (
        (id_alimentare IS NOT NULL AND id_incarcare IS NULL) OR
        (id_alimentare IS NULL AND id_incarcare IS NOT NULL)
    ),
    CONSTRAINT fk_incident_alimentare FOREIGN KEY (id_alimentare) REFERENCES ALIMENTARE(id_alimentare) ON DELETE RESTRICT,
    CONSTRAINT fk_incident_incarcare FOREIGN KEY (id_incarcare) REFERENCES INCARCARE_EV(id_incarcare) ON DELETE RESTRICT,
    CONSTRAINT fk_incident_angajat FOREIGN KEY (id_angajat) REFERENCES ANGAJAT(id_angajat) ON DELETE RESTRICT
);
