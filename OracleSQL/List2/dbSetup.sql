CREATE TABLE Funkcje
    (funkcja VARCHAR2(10) CONSTRAINT fun_pk PRIMARY KEY,
    min_myszy NUMBER(3) CONSTRAINT fun_min_con CHECK (min_myszy > 5),
    max_myszy NUMBER(3) CONSTRAINT fun_max_con CHECK (max_myszy < 200),
    CONSTRAINT fun_minmax_con CHECK (max_myszy >= min_myszy)
    
    );

CREATE TABLE Wrogowie
    (imie_wroga VARCHAR2(15) CONSTRAINT wrog_pk PRIMARY KEY,
    stopien_wrogosci NUMBER(2) CONSTRAINT wrog_stop_con CHECK (stopien_wrogosci BETWEEN 1 AND 10),
    gatunek VARCHAR2(15),
    lapowka VARCHAR2(20)
    );

CREATE TABLE Kocury
    (imie VARCHAR2(15) CONSTRAINT koc_imie NOT NULL,
    plec VARCHAR2(1) CONSTRAINT koc_plec CHECK (plec IN ('M', 'D')),
    pseudo VARCHAR2(15) CONSTRAINT koc_pk PRIMARY KEY,
    funkcja VARCHAR2(10) CONSTRAINT koc_fun_fk REFERENCES Funkcje(funkcja),
    szef VARCHAR2(15) CONSTRAINT koc_szef_fk REFERENCES Kocury(pseudo),
    w_stadku_od DATE DEFAULT SYSDATE,
    przydzial_myszy NUMBER(3),
    myszy_extra NUMBER(2),
    nr_bandy NUMBER(2)
    );

CREATE TABLE Bandy
    (nr_bandy NUMBER(2) CONSTRAINT ban_pk PRIMARY KEY,
    nazwa VARCHAR2(20) CONSTRAINT ban_naz NOT NULL,
    teren VARCHAR2(15) CONSTRAINT ban_ter UNIQUE,
    szef_bandy VARCHAR2(15) CONSTRAINT ban_szef UNIQUE CONSTRAINT ban_szef_fk REFERENCES Kocury(pseudo)
    );

ALTER TABLE Kocury ADD CONSTRAINT koc_ban_fk FOREIGN KEY (nr_bandy) REFERENCES Bandy(nr_bandy);

CREATE TABLE Wrogowie_kocurow
    (pseudo VARCHAR2(15) CONSTRAINT wrkoc_ps_fk REFERENCES Kocury(pseudo),
    imie_wroga VARCHAR2(15) CONSTRAINT wrkoc_imwr_fk REFERENCES Wrogowie(imie_wroga),
    data_incydentu DATE CONSTRAINT wrkoc_data NOT NULL,
    opis_incydentu VARCHAR2(50),
    CONSTRAINT wrkoc_pk PRIMARY KEY(pseudo, imie_wroga)
    );

INSERT ALL 
    INTO Funkcje VALUES('SZEFUNIO',90,110)
    INTO Funkcje VALUES('BANDZIOR',70,90)
    INTO Funkcje VALUES('LOWCZY',60,70)
    INTO Funkcje VALUES('LAPACZ',50,60)
    INTO Funkcje VALUES('KOT',40,50)
    INTO Funkcje VALUES('MILUSIA',20,30)
    INTO Funkcje VALUES('DZIELCZY',45,55)
    INTO Funkcje VALUES('HONOROWA',6,25)
SELECT * FROM Dual;

INSERT ALL
    INTO Wrogowie VALUES('KAZIO',10,'CZLOWIEK','FLASZKA')
    INTO Wrogowie VALUES('GLUPIA ZOSKA',1,'CZLOWIEK','KORALIK')
    INTO Wrogowie VALUES('SWAWOLNY DYZIO',7,'CZLOWIEK','GUMA DO ZUCIA')
    INTO Wrogowie VALUES('BUREK',4,'PIES','KOSC')
    INTO Wrogowie VALUES('DZIKI BILL',10,'PIES',NULL)
    INTO Wrogowie VALUES('REKSIO',2,'PIES','KOSC')
    INTO Wrogowie VALUES('BETHOVEN',1,'PIES','PEDIGRIPALL')
    INTO Wrogowie VALUES('CHYTRUSEK',5,'LIS','KURCZAK')
    INTO Wrogowie VALUES('SMUKLA',1,'SOSNA',NULL)
    INTO Wrogowie VALUES('BAZYLI',3,'KOGUT','KURA DO STADA')
SELECT * FROM Dual;

ALTER TABLE Kocury
DISABLE CONSTRAINT koc_szef_fk;

ALTER TABLE Kocury
DISABLE CONSTRAINT koc_ban_fk;

INSERT ALL
    INTO Kocury VALUES('JACEK','M','PLACEK','LOWCZY','LYSY',DATE '2008-12-01',67,NULL,2)
    INTO Kocury VALUES('BARI','M','RURA','LAPACZ','LYSY',DATE '2009-09-01',56,NULL,2)
    INTO Kocury VALUES('MICKA','D','LOLA','MILUSIA','TYGRYS',DATE '2009-10-14',25,47,1)
    INTO Kocury VALUES('LUCEK','M','ZERO','KOT','KURKA',DATE '2010-03-01',43,NULL,3)
    INTO Kocury VALUES('SONIA','D','PUSZYSTA','MILUSIA','ZOMBI',DATE '2010-11-18',20,35,3)
    INTO Kocury VALUES('LATKA','D','UCHO','KOT','RAFA',DATE '2011-01-01',40,NULL,4)
    INTO Kocury VALUES('DUDEK','M','MALY','KOT','RAFA',DATE '2011-05-15',40,NULL,4)
    INTO Kocury VALUES('MRUCZEK','M','TYGRYS','SZEFUNIO',NULL,DATE '2002-01-01',103,33,1)
    INTO Kocury VALUES('CHYTRY','M','BOLEK','DZIELCZY','TYGRYS',DATE '2002-05-05',50,NULL,1)
    INTO Kocury VALUES('KOREK','M','ZOMBI','BANDZIOR','TYGRYS',DATE '2004-03-16',75,13,3)
    INTO Kocury VALUES('BOLEK','M','LYSY','BANDZIOR','TYGRYS',DATE '2006-08-15',72,21,2)
    INTO Kocury VALUES('ZUZIA','D','SZYBKA','LOWCZY','LYSY',DATE '2006-07-21',65,NULL,2)
    INTO Kocury VALUES('RUDA','D','MALA','MILUSIA','TYGRYS',DATE '2006-09-17',22,42,1)
    INTO Kocury VALUES('PUCEK','M','RAFA','LOWCZY','TYGRYS',DATE '2006-10-15',65,NULL,4)
    INTO Kocury VALUES('PUNIA','D','KURKA','LOWCZY','ZOMBI',DATE '2008-01-01',61,NULL,3)
    INTO Kocury VALUES('BELA','D','LASKA','MILUSIA','LYSY',DATE '2008-02-01',24,28,2)
    INTO Kocury VALUES('KSAWERY','M','MAN','LAPACZ','RAFA',DATE '2008-07-12',51,NULL,4)
    INTO Kocury VALUES('MELA','D','DAMA','LAPACZ','RAFA',DATE '2008-11-01',51,NULL,4)
SELECT * FROM Dual;

ALTER TABLE Kocury
ENABLE CONSTRAINT koc_szef_fk;

INSERT ALL
    INTO Bandy VALUES(1,'SZEFOSTWO','CALOSC','TYGRYS')
    INTO Bandy VALUES(2,'CZARNI RYCERZE','POLE','LYSY')
    INTO Bandy VALUES(3,'BIALI LOWCY','SAD','ZOMBI')
    INTO Bandy VALUES(4,'LACIACI MYSLIWI','GORKA','RAFA')
    INTO Bandy VALUES(5,'ROCKERSI','ZAGRODA',NULL)
SELECT * FROM Dual;

ALTER TABLE Kocury
ENABLE CONSTRAINT koc_ban_fk;

INSERT ALL
    INTO wrogowie_kocurow VALUES('TYGRYS','KAZIO',DATE '2004-10-13','USILOWAL NABIC NA WIDLY')
    INTO wrogowie_kocurow VALUES('ZOMBI','SWAWOLNY DYZIO',DATE '2005-03-07','WYBIL OKO Z PROCY')
    INTO wrogowie_kocurow VALUES('BOLEK','KAZIO',DATE '2005-03-29','POSZCZUL BURKIEM')
    INTO wrogowie_kocurow VALUES('SZYBKA','GLUPIA ZOSKA',DATE '2006-09-12','UZYLA KOTA JAKO SCIERKI')
    INTO wrogowie_kocurow VALUES('MALA','CHYTRUSEK',DATE '2007-03-07','ZALECAL SIE')
    INTO wrogowie_kocurow VALUES('TYGRYS','DZIKI BILL',DATE '2007-06-12','USILOWAL POZBAWIC ZYCIA')
    INTO wrogowie_kocurow VALUES('BOLEK','DZIKI BILL',DATE '2007-11-10','ODGRYZL UCHO')
    INTO wrogowie_kocurow VALUES('LASKA','DZIKI BILL',DATE '2008-12-12','POGRYZL ZE LEDWO SIE WYLIZALA')
    INTO wrogowie_kocurow VALUES('LASKA','KAZIO',DATE '2009-01-07','ZLAPAL ZA OGON I ZROBIL WIATRAK')
    INTO wrogowie_kocurow VALUES('DAMA','KAZIO',DATE '2009-02-07','CHCIAL OBEDRZEC ZE SKORY')
    INTO wrogowie_kocurow VALUES('MAN','REKSIO',DATE '2009-04-14','WYJATKOWO NIEGRZECZNIE OBSZCZEKAL')
    INTO wrogowie_kocurow VALUES('LYSY','BETHOVEN',DATE '2009-05-11','NIE PODZIELIL SIE SWOJA KASZA')
    INTO wrogowie_kocurow VALUES('RURA','DZIKI BILL',DATE '2009-09-03','ODGRYZL OGON')
    INTO wrogowie_kocurow VALUES('PLACEK','BAZYLI',DATE '2010-07-12','DZIOBIAC UNIEMOZLIWIL PODEBRANIE KURCZAKA')
    INTO wrogowie_kocurow VALUES('PUSZYSTA','SMUKLA',DATE '2010-11-19','OBRZUCILA SZYSZKAMI')
    INTO wrogowie_kocurow VALUES('KURKA','BUREK',DATE '2010-12-14','POGONIL')
    INTO wrogowie_kocurow VALUES('MALY','CHYTRUSEK',DATE '2011-07-13','PODEBRAL PODEBRANE JAJKA')
    INTO wrogowie_kocurow VALUES('UCHO','SWAWOLNY DYZIO',DATE '2011-07-14','OBRZUCIL KAMIENIAMI')
SELECT * FROM Dual;