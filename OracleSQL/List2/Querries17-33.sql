SELECT *
    FROM Bandy;

--Zad 17
SELECT K.pseudo "POLUJE W POLU", K.przydzial_myszy "PRZYDZIAL MYSZY", B.nazwa "BANDA"
    FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
    WHERE K.przydzial_myszy > 50 AND (B.teren = 'POLE' OR B.teren = 'CALOSC')
    ORDER BY 2 DESC;

--Zad 18
SELECT K.imie "IMIE", K.w_stadku_od "POLUJE OD"
    FROM Kocury K, Kocury K2
    WHERE K2.imie = 'JACEK' AND K.w_stadku_od < K2.w_stadku_od
    ORDER BY 2 DESC;

--Zad 18b
SELECT K.imie "IMIE", K.w_stadku_od "POLUJE OD"
    FROM Kocury K JOIN Kocury K2 ON K2.imie = 'JACEK' AND K.w_stadku_od < K2.w_stadku_od
    ORDER BY 2 DESC;

--Zad 19a
SELECT K.imie "Imie", K.funkcja "Funkcja", KS1.imie "Szef 1", KS2.imie "Szef 2", KS3.imie "Szef 3"
    FROM Kocury K 
    	LEFT JOIN Kocury KS1 ON K.szef=KS1.pseudo
    	LEFT JOIN Kocury KS2 ON KS1.szef=KS2.pseudo
    	LEFT JOIN Kocury KS3 ON KS2.szef=KS3.pseudo
    WHERE K.funkcja IN ('KOT','MILUSIA')
    ORDER BY 5, 4, 3;

--Zad 19b
SELECT *
    FROM (
    	SELECT CONNECT_BY_ROOT imie "Imie", CONNECT_BY_ROOT funkcja "Funkcja", imie, level "poziom"
            FROM Kocury
            CONNECT BY PRIOR szef=pseudo
            START WITH funkcja IN ('KOT', 'MILUSIA')
    	)
    PIVOT 
    (
    	MAX(imie)
    	FOR "poziom"
    	IN (2 "Szef 1", 3 "Szef 2", 4 "Szef 3")
    )
    ORDER BY 5, 4, 3;

--Zad 19c
SELECT "Imie", "Funkcja", REPLACE("path", ' | ' || "Imie", '') "Imiona kolejnych szefów"
    FROM 
    (
        SELECT CONNECT_BY_ROOT imie "Imie", CONNECT_BY_ROOT funkcja "Funkcja", SYS_CONNECT_BY_PATH(imie, ' | ') "path", level "poziom"
    	, MAX(level) OVER (PARTITION BY CONNECT_BY_ROOT imie ORDER BY level DESC) "max_poziom"
            FROM Kocury
            CONNECT BY PRIOR szef = pseudo
            START WITH funkcja IN ('KOT', 'MILUSIA')
    )
    WHERE "max_poziom" = "poziom"
    ORDER BY 3;

--Zad 20
SELECT K.imie "Imie kotki", B.nazwa "Nazwa bandy", WK.imie_wroga "Imie wroga", W.stopien_wrogosci "Ocena wroga", WK.data_incydentu "Data inc."
    FROM Kocury K JOIN Wrogowie_kocurow WK ON K.pseudo = WK.pseudo 
    AND WK.data_incydentu > DATE '2007-01-01' AND K.plec = 'D'
    	JOIN Bandy B ON K.nr_bandy = B.nr_bandy
    	JOIN Wrogowie W ON WK.imie_wroga = W.imie_wroga
    ORDER BY 1, 3;

--Zad 21
SELECT nazwa "Nazwa bandy", COUNT(DISTINCT K.pseudo) "Koty z wrogami"
    FROM Bandy B JOIN Kocury K ON B.nr_bandy = K.nr_bandy
    	JOIN Wrogowie_kocurow WK ON K.pseudo = WK.pseudo
    GROUP BY nazwa;

--Zad 22
SELECT MAX(funkcja) "Funkcja", K.pseudo "Pseudonim kota", COUNT(*) "Liczba wrogow"
    FROM Kocury K JOIN Wrogowie_kocurow WK ON K.pseudo = WK.pseudo
    GROUP BY K.pseudo
    HAVING COUNT(*) > 1;

--Zad 23
SELECT imie "IMIE", (przydzial_myszy+myszy_extra)*12 "DAWKA ROCZNA", 'powyzej 864' "DAWKA"
    FROM Kocury
    WHERE myszy_extra IS NOT NULL AND (przydzial_myszy+myszy_extra)*12 > 864
UNION
SELECT imie, (przydzial_myszy+myszy_extra)*12, '864'
    FROM Kocury
    WHERE myszy_extra IS NOT NULL AND (przydzial_myszy+myszy_extra)*12 = 864
UNION
SELECT imie, (przydzial_myszy+myszy_extra)*12, 'ponizej 864'
    FROM Kocury
    WHERE myszy_extra IS NOT NULL AND (przydzial_myszy+myszy_extra)*12 < 864
    ORDER BY 2 DESC;

--Zad 24
SELECT B.nr_bandy, B.nazwa, B.teren
    FROM Bandy B LEFT JOIN Kocury K ON B.nr_bandy = K.nr_bandy
    WHERE K.nr_bandy IS NULL;
--Zad 24 zbior
SELECT B.nr_bandy, B.nazwa, B.teren
    FROM Bandy B
MINUS
SELECT B.nr_bandy, B.nazwa, B.teren
    FROM Bandy B JOIN Kocury K ON B.nr_bandy = K.nr_bandy;

--Zad 25
SELECT imie, funkcja, przydzial_myszy
    FROM Kocury
    WHERE przydzial_myszy >= ALL( 
    	SELECT przydzial_myszy*3 
    		FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy AND B.teren IN ('SAD', 'CALOSC')
    		WHERE funkcja = 'MILUSIA');

--Zad 26
WITH Subque AS 
    (
    SELECT funkcja, ROUND(AVG(przydzial_myszy+NVL(myszy_extra,0))) "avg"
        FROM Kocury
        WHERE funkcja != 'SZEFUNIO'
        GROUP BY funkcja
    )
SELECT funkcja, "avg" "Srednio najw. i najm. myszy"
        FROM Subque
        WHERE "avg" IN ( ( SELECT MAX("avg") FROM Subque), ( SELECT MIN("avg") FROM Subque))
    ORDER BY 2;

--Zad 27a n=6
SELECT pseudo, przydzial_myszy+NVL(myszy_extra, 0) zjada
    FROM Kocury K
    WHERE 
    (
    	SELECT COUNT(DISTINCT przydzial_myszy+NVL(myszy_extra, 0)) 
    		FROM Kocury 
    		WHERE przydzial_myszy+NVL(myszy_extra, 0) >= K.przydzial_myszy+NVL(K.myszy_extra, 0)
    ) <= 6
    ORDER BY 2 DESC;

--Zad 27b n=6
WITH Myszy AS
(
    SELECT DISTINCT przydzial_myszy+NVL(myszy_extra, 0) zjada
        FROM Kocury
        ORDER BY 1 DESC
)
SELECT pseudo, przydzial_myszy+NVL(myszy_extra, 0) zjada
	FROM Kocury
    WHERE przydzial_myszy+NVL(myszy_extra, 0) >= (SELECT MIN(zjada) FROM Myszy WHERE ROWNUM <= 6)
    ORDER BY 2 DESC;

--Zad 27c n=6
SELECT K.pseudo, MAX(K.przydzial_myszy+NVL(K.myszy_extra, 0)) zjada
    FROM Kocury K JOIN Kocury K2 ON K.przydzial_myszy+NVL(K.myszy_extra, 0) <= K2.przydzial_myszy+NVL(K2.myszy_extra, 0)
    GROUP BY K.pseudo
    HAVING COUNT(DISTINCT K2.przydzial_myszy+NVL(K2.myszy_extra, 0)) <= 6
    ORDER BY 2 DESC;

--Zad 27d n=6
SELECT pseudo, zjada
    FROM
    (
    	SELECT pseudo, przydzial_myszy+NVL(myszy_extra, 0) zjada, DENSE_RANK() 
    		OVER (ORDER BY przydzial_myszy+NVL(myszy_extra, 0) DESC) ranga
    		FROM Kocury
    )
    WHERE ranga <= 6;

--Zad 28
WITH Przyst_all AS
(
    SELECT EXTRACT(YEAR FROM w_stadku_od) rok, COUNT(*) liczba
    	FROM Kocury
    	GROUP BY EXTRACT(YEAR FROM w_stadku_od)
), 
    Przyst_dist AS
(
    SELECT DISTINCT liczba
    	FROM Przyst_all
)
SELECT TO_CHAR(rok), liczba "LICZBA WYSTAPIEN"
    FROM Przyst_all
    WHERE liczba = (
    	SELECT MAX(liczba) 
    		FROM Przyst_dist WHERE liczba < (SELECT AVG(liczba) FROM Przyst_all)
    )
UNION
SELECT 'Srednia', ROUND(AVG(liczba), 7) 
    FROM Przyst_all
UNION
SELECT TO_CHAR(rok), liczba "LICZBA WYSTAPIEN"
    FROM Przyst_all
    WHERE liczba = (
    	SELECT MIN(liczba) 
    		FROM Przyst_dist WHERE liczba > (SELECT AVG(liczba) FROM Przyst_all)
    )
ORDER BY 2;

--Zad 29a
SELECT K.imie, K.przydzial_myszy + NVL(K.myszy_extra, 0) zjada, K.nr_bandy, ROUND(AVG(K2.przydzial_myszy + NVL(K2.myszy_extra, 0)),2) "SREDNIA BANDY"
    FROM Kocury K JOIN Kocury K2 ON K.nr_bandy = K2.nr_bandy AND K.plec = 'M'
    GROUP BY K.imie, K.przydzial_myszy + NVL(K.myszy_extra, 0), K.nr_bandy
    HAVING K.przydzial_myszy + NVL(K.myszy_extra, 0) < ROUND(AVG(K2.przydzial_myszy + NVL(K2.myszy_extra, 0)),2)
    ORDER BY 4;

--Zad 29b
SELECT K.imie, K.przydzial_myszy + NVL(K.myszy_extra, 0) zjada, K.nr_bandy, ROUND(KA."srednia", 2) "SREDNIA BANDY"
    FROM Kocury K JOIN (SELECT nr_bandy, AVG(przydzial_myszy + NVL(myszy_extra, 0)) "srednia" FROM Kocury GROUP BY nr_bandy) KA ON K.nr_bandy = KA.nr_bandy AND K.plec = 'M'
    WHERE K.przydzial_myszy + NVL(K.myszy_extra, 0) < KA."srednia"
    ORDER BY 4;

--Zad 29c
SELECT K.imie, K.przydzial_myszy + NVL(K.myszy_extra, 0) zjada, K.nr_bandy, ROUND(
    (
    	SELECT AVG(przydzial_myszy + NVL(myszy_extra, 0)) "srednia" 
    		FROM Kocury 
    		WHERE nr_bandy=K.nr_bandy
    ) , 2) "SREDNIA BANDY"
    FROM Kocury K
    WHERE K.plec = 'M' AND K.przydzial_myszy + NVL(K.myszy_extra, 0) < (SELECT AVG(przydzial_myszy + NVL(myszy_extra, 0)) "srednia" FROM Kocury WHERE nr_bandy=K.nr_bandy)
    ORDER BY 4;

--Zad 30

SELECT imie "IMIE", w_stadku_od "WSTAPIL DO STADA", CASE K.w_stadku_od
    WHEN (SELECT MAX(w_stadku_od) FROM Kocury WHERE nr_bandy = K.nr_bandy) 
    	THEN 'NAJMLODSZY STAZEM W BANDZIE ' || B.nazwa
    WHEN (SELECT MIN(w_stadku_od) FROM Kocury WHERE nr_bandy = K.nr_bandy)
    	THEN 'NAJSTARSZY STAZEM W BANDZIE ' || B.nazwa
    ELSE ' ' END " "
    FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
    WHERE K.nr_bandy = 1
UNION
SELECT imie, w_stadku_od, CASE K.w_stadku_od
    WHEN (SELECT MAX(w_stadku_od) FROM Kocury WHERE nr_bandy = K.nr_bandy) 
    	THEN 'NAJMLODSZY STAZEM W BANDZIE ' || B.nazwa
    WHEN (SELECT MIN(w_stadku_od) FROM Kocury WHERE nr_bandy = K.nr_bandy)
    	THEN 'NAJSTARSZY STAZEM W BANDZIE ' || B.nazwa
    ELSE ' ' END
    FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
    WHERE K.nr_bandy = 2
UNION
SELECT imie, w_stadku_od, CASE K.w_stadku_od
    WHEN (SELECT MAX(w_stadku_od) FROM Kocury WHERE nr_bandy = K.nr_bandy) 
    	THEN 'NAJMLODSZY STAZEM W BANDZIE ' || B.nazwa
    WHEN (SELECT MIN(w_stadku_od) FROM Kocury WHERE nr_bandy = K.nr_bandy)
    	THEN 'NAJSTARSZY STAZEM W BANDZIE ' || B.nazwa
    ELSE ' ' END
    FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
    WHERE K.nr_bandy = 3
UNION
SELECT imie, w_stadku_od, CASE K.w_stadku_od
    WHEN (SELECT MAX(w_stadku_od) FROM Kocury WHERE nr_bandy = K.nr_bandy) 
    	THEN 'NAJMLODSZY STAZEM W BANDZIE ' || B.nazwa
    WHEN (SELECT MIN(w_stadku_od) FROM Kocury WHERE nr_bandy = K.nr_bandy)
    	THEN 'NAJSTARSZY STAZEM W BANDZIE ' || B.nazwa
    ELSE ' ' END
    FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
    WHERE K.nr_bandy = 4
    ORDER BY 1;

--Zad 31
CREATE VIEW Bandy_Spoz
AS
SELECT B.nazwa nazwa_bandy, ROUND(AVG(przydzial_myszy),2) sre_spoz,
    MAX(przydzial_myszy) max_spoz, MIN(przydzial_myszy) min_spoz,
    COUNT(K.pseudo) koty, COUNT(K.myszy_extra) koty_od
    FROM Bandy B JOIN Kocury K ON B.nr_bandy = K.nr_bandy
    GROUP BY B.nazwa;

SELECT K.pseudo, imie, funkcja, przydzial_myszy+NVL(myszy_extra,0) zjada,
    'OD ' || min_spoz || ' DO ' || max_spoz "GRANICE SPOZYCIA", w_stadku_od "LOWI OD"
    FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
		JOIN Bandy_Spoz BS ON B.nazwa = BS.nazwa_bandy
    WHERE K.pseudo = 'PLACEK'; --UPPER(&pseudo) - dalbym to, gdyby dzialalo mi SQL PLUS

DROP VIEW Bandy_Spoz;

--Zad 32
CREATE OR REPLACE VIEW Starzy
AS
SELECT pseudo, plec, przydzial_myszy, NVL(myszy_extra, 0) myszy_extra, nr_bandy
    FROM 
    (
    	SELECT pseudo, plec, przydzial_myszy, myszy_extra, K.nr_bandy nr_bandy
    		FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
    		WHERE B.nazwa = 'CZARNI RYCERZE'
    		ORDER BY w_stadku_od
    )
    WHERE ROWNUM <= 3
UNION
SELECT pseudo, plec, przydzial_myszy, NVL(myszy_extra, 0) myszy_extra, nr_bandy
    FROM 
    (
    	SELECT pseudo, plec, przydzial_myszy, myszy_extra, K.nr_bandy nr_bandy
    		FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
    		WHERE B.nazwa = 'LACIACI MYSLIWI'
    		ORDER BY w_stadku_od
    )
    WHERE ROWNUM <= 3;

SELECT * FROM Starzy;

SELECT pseudo "Pseudonim", plec "Plec", przydzial_myszy "Myszy przed podw.", myszy_extra "Extra przed podw." FROM Starzy ORDER BY nr_bandy;
CREATE OR REPLACE VIEW Podwyzki 
AS
    SELECT S.nr_bandy nr_bandy, plec, DECODE(plec, 'M', 10, (SELECT MIN(przydzial_myszy) FROM Kocury)*0.1 ) pod_myszy,
    	ROUND((SELECT AVG(NVL(myszy_extra,0))*0.15 FROM Kocury WHERE nr_bandy=S.nr_bandy),0) pod_extra
    	FROM Starzy S;
UPDATE Kocury K
    SET K.przydzial_myszy = K.przydzial_myszy+(SELECT MAX(pod_myszy) FROM Podwyzki WHERE plec=K.plec),
    K.myszy_extra = NVL(K.myszy_extra,0)+(SELECT MAX(pod_extra) FROM Podwyzki WHERE nr_bandy=K.nr_bandy)
	WHERE K.pseudo IN (SELECT pseudo FROM Starzy);

SELECT pseudo "Pseudonim", plec "Plec", przydzial_myszy "Myszy po podw." , myszy_extra "Extra po podw." FROM Starzy ORDER BY nr_bandy;
ROLLBACK;

--Zad 32b
DROP VIEW Starzy;
CREATE OR REPLACE VIEW Starzy
AS
SELECT pseudo, plec, przydzial_myszy, myszy_extra, nr_bandy
    FROM Kocury
    WHERE pseudo IN
    (
        SELECT pseudo
        FROM 
        (
        	SELECT pseudo, plec, przydzial_myszy, myszy_extra, K.nr_bandy nr_bandy
        		FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
        		WHERE B.nazwa = 'CZARNI RYCERZE'
        		ORDER BY w_stadku_od
        )
        WHERE ROWNUM <= 3
    UNION
    SELECT pseudo
        FROM 
        (
        	SELECT pseudo, plec, przydzial_myszy, myszy_extra, K.nr_bandy nr_bandy
        		FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
        		WHERE B.nazwa = 'LACIACI MYSLIWI'
        		ORDER BY w_stadku_od
        )
        WHERE ROWNUM <= 3
    );

SELECT pseudo "Pseudonim", plec "Plec", przydzial_myszy "Myszy przed podw.", NVL(myszy_extra, 0) "Extra przed podw." FROM Starzy ORDER BY nr_bandy;

UPDATE Starzy K
    SET K.przydzial_myszy = K.przydzial_myszy+DECODE(plec, 'M', 10, (SELECT MIN(przydzial_myszy) FROM Kocury)*0.1 ),
    K.myszy_extra = NVL(K.myszy_extra,0)+ROUND((SELECT AVG(NVL(myszy_extra,0))*0.15 FROM Kocury WHERE nr_bandy=K.nr_bandy),0);

SELECT pseudo "Pseudonim", plec "Plec", przydzial_myszy "Myszy po podw." , myszy_extra "Extra po podw." FROM Starzy ORDER BY nr_bandy;
ROLLBACK;

--Zad 33
WITH Podsumowanie AS
(
    SELECT B.nazwa nazwa, plec, COUNT(K.pseudo) ile, 
    	SUM(DECODE(funkcja, 'SZEFUNIO', przydzial_myszy+NVL(myszy_extra, 0), 0)) szefunio,
    	SUM(DECODE(funkcja, 'BANDZIOR', przydzial_myszy+NVL(myszy_extra, 0), 0)) bandzior,
    	SUM(DECODE(funkcja, 'LOWCZY', przydzial_myszy+NVL(myszy_extra, 0), 0)) LOWCZY,
    	SUM(DECODE(funkcja, 'LAPACZ', przydzial_myszy+NVL(myszy_extra, 0), 0)) LAPACZ,
    	SUM(DECODE(funkcja, 'KOT', przydzial_myszy+NVL(myszy_extra, 0), 0)) KOT,
    	SUM(DECODE(funkcja, 'MILUSIA', przydzial_myszy+NVL(myszy_extra, 0), 0)) MILUSIA,
    	SUM(DECODE(funkcja, 'DZIELCZY', przydzial_myszy+NVL(myszy_extra, 0), 0)) DZIELCZY,
        SUM(przydzial_myszy+NVL(myszy_extra, 0)) suma
        FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
        GROUP BY B.nazwa, K.plec
)
SELECT DECODE(plec, 'M', ' ', nazwa) "NAZWA BANDY", DECODE(plec, 'D', 'Kotka', 'M', 'Kocur', plec) plec, DECODE(ile, NULL, ' ', TO_CHAR(ile)), szefunio, bandzior, lowczy, lapacz, kot, milusia, dzielczy, suma  
    FROM 
    (
    	SELECT * 
    		FROM Podsumowanie 
    	UNION
    	SELECT 'ZJADA RAZEM', ' ', NULL, SUM(szefunio),  SUM(bandzior),  SUM(lowczy),  SUM(lapacz),  SUM(kot),  SUM(milusia),  SUM(dzielczy),  SUM(suma)  
    		FROM Podsumowanie
    )
    ORDER BY nazwa, plec DESC;

--Zad 33a
WITH Podsumowanie AS
(
    SELECT B.nazwa nazwa, plec, COUNT(K.pseudo) ile, 
    	SUM(DECODE(funkcja, 'SZEFUNIO', przydzial_myszy+NVL(myszy_extra, 0), 0)) szefunio,
    	SUM(DECODE(funkcja, 'BANDZIOR', przydzial_myszy+NVL(myszy_extra, 0), 0)) bandzior,
    	SUM(DECODE(funkcja, 'LOWCZY', przydzial_myszy+NVL(myszy_extra, 0), 0)) LOWCZY,
    	SUM(DECODE(funkcja, 'LAPACZ', przydzial_myszy+NVL(myszy_extra, 0), 0)) LAPACZ,
    	SUM(DECODE(funkcja, 'KOT', przydzial_myszy+NVL(myszy_extra, 0), 0)) KOT,
    	SUM(DECODE(funkcja, 'MILUSIA', przydzial_myszy+NVL(myszy_extra, 0), 0)) MILUSIA,
    	SUM(DECODE(funkcja, 'DZIELCZY', przydzial_myszy+NVL(myszy_extra, 0), 0)) DZIELCZY,
        SUM(przydzial_myszy+NVL(myszy_extra, 0)) suma
        FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
        GROUP BY B.nazwa, K.plec
)
SELECT DECODE(plec, 'M', ' ', nazwa) "NAZWA BANDY", DECODE(plec, 'D', 'Kotka', 'M', 'Kocur', plec) plec, DECODE(ile, NULL, ' ', TO_CHAR(ile)) ile, szefunio, 
    bandzior, lowczy, lapacz, kot, milusia, dzielczy, suma 
    FROM 
    (
    	SELECT nazwa, plec, (TO_CHAR(ile)) ile, TO_CHAR(szefunio) szefunio, 
    TO_CHAR(bandzior) bandzior, TO_CHAR(lowczy) lowczy, TO_CHAR(lapacz) lapacz, TO_CHAR(kot) kot, TO_CHAR(milusia) milusia, TO_CHAR(dzielczy) dzielczy, TO_CHAR(suma) suma
    		FROM Podsumowanie 
    	UNION
    	SELECT 'Z----------------', '------', '----', '---------',  '---------',  '---------',  '---------',  '---------',  '---------',  '---------',  '---------'
    		FROM DUAL
    	UNION
    	SELECT 'ZJADA RAZEM', ' ', NULL, TO_CHAR(SUM(szefunio)),  TO_CHAR(SUM(bandzior)),  TO_CHAR(SUM(lowczy)),
            TO_CHAR(SUM(lapacz)),  TO_CHAR(SUM(kot)),  TO_CHAR(SUM(milusia)),  TO_CHAR(SUM(dzielczy)),  TO_CHAR(SUM(suma))  
    		FROM Podsumowanie
    )
    ORDER BY nazwa, plec DESC;

--Zad 33b
WITH Podsumowanie AS
(
    SELECT nazwa, plec, COUNT(*) ile, SUM(DECODE(szefunio, NULL, 0, szefunio)) szefunio,  SUM(DECODE(bandzior, NULL, 0, bandzior)) bandzior,
        SUM(DECODE(lowczy, NULL, 0, lowczy)) lowczy,
        SUM(DECODE(lapacz, NULL, 0, lapacz)) lapacz,
        SUM(DECODE(kot, NULL, 0, kot)) kot,
        SUM(DECODE(milusia, NULL, 0, milusia)) milusia,
        SUM(DECODE(dzielczy, NULL, 0, dzielczy)) dzielczy, SUM(myszy_all) suma
        FROM (SELECT B.nazwa, K.plec, K.funkcja, przydzial_myszy, myszy_extra, przydzial_myszy+NVL(myszy_extra, 0) myszy_all FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy)
        PIVOT
        (
        	SUM(przydzial_myszy+NVL(myszy_extra, 0))
        	FOR funkcja
        	IN('SZEFUNIO' szefunio, 'BANDZIOR' bandzior, 'LOWCZY' lowczy, 'LAPACZ' lapacz, 'KOT' kot, 'MILUSIA' milusia, 'DZIELCZY' dzielczy)
        )
        GROUP BY nazwa, plec
)
SELECT DECODE(plec, 'M', ' ', nazwa) "NAZWA BANDY", DECODE(plec, 'D', 'Kotka', 'M', 'Kocur', plec) plec, DECODE(ile, NULL, ' ', TO_CHAR(ile)) ile, szefunio, 
    bandzior, lowczy, lapacz, kot, milusia, dzielczy, suma 
    FROM 
    (
    	SELECT nazwa, plec, (TO_CHAR(ile)) ile, TO_CHAR(szefunio) szefunio, 
    TO_CHAR(bandzior) bandzior, TO_CHAR(lowczy) lowczy, TO_CHAR(lapacz) lapacz, TO_CHAR(kot) kot, TO_CHAR(milusia) milusia, TO_CHAR(dzielczy) dzielczy, TO_CHAR(suma) suma
    		FROM Podsumowanie 
    	UNION
    	SELECT 'Z----------------', '------', '----', '---------',  '---------',  '---------',  '---------',  '---------',  '---------',  '---------',  '---------'
    		FROM DUAL
    	UNION
    	SELECT 'ZJADA RAZEM', ' ', NULL, TO_CHAR(SUM(szefunio)),  TO_CHAR(SUM(bandzior)),  TO_CHAR(SUM(lowczy)),
            TO_CHAR(SUM(lapacz)),  TO_CHAR(SUM(kot)),  TO_CHAR(SUM(milusia)),  TO_CHAR(SUM(dzielczy)),  TO_CHAR(SUM(suma))  
    		FROM Podsumowanie
    )
    ORDER BY nazwa, plec DESC;