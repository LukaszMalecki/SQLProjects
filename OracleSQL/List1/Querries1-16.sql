--Zad 1
SELECT imie_wroga, opis_incydentu 
    FROM Wrogowie_kocurow
    WHERE data_incydentu BETWEEN Date '2009-01-01' AND Date '2009-12-31';

--Zad 2
SELECT imie, funkcja, w_stadku_od "Z nami od" 
	FROM Kocury 
	WHERE plec = 'D' AND w_stadku_od BETWEEN Date '2005-09-01' AND Date '2007-07-31';

--Zad 3
SELECT imie_wroga, gatunek, stopien_wrogosci 
	FROM Wrogowie 
    WHERE lapowka IS NULL 
    ORDER BY stopien_wrogosci;

--Zad 4
SELECT imie || ' zwany ' || pseudo || ' (fun. ' || funkcja || ') lowi myszki w bandzie ' || TO_CHAR(nr_bandy) || ' od ' || TO_CHAR(w_stadku_od) "Wszystko o kocurach" 
	FROM Kocury 
    WHERE plec = 'M' 
    ORDER BY w_stadku_od DESC, pseudo;

--Zad 5
SELECT pseudo, REGEXP_REPLACE(REGEXP_REPLACE(pseudo, 'A', '#', 1, 1), 'L', '%', 1, 1) "Po wymianie A na # oraz L na %"
	FROM Kocury 
    WHERE pseudo LIKE '%L%' AND pseudo LIKE '%A%';

--Test Date
SELECT TRUNC(DATE '2011-06-23', 'YYYY'), EXTRACT(YEAR FROM DATE '2011-06-23'), EXTRACT(YEAR FROM DATE '2011-06-23')
	FROM DUAL;

--Zad 6
SELECT imie, w_stadku_od "W stadku", ROUND(przydzial_myszy/1.1) "Zjadal", ADD_MONTHS(w_stadku_od, 6) "Podwyzka", przydzial_myszy "Zjada"
	FROM Kocury
    WHERE MONTHS_BETWEEN(DATE '2022-07-14', w_stadku_od)/12 >= 13 AND EXTRACT(MONTH FROM w_stadku_od) BETWEEN 3 AND 9
    ORDER BY przydzial_myszy DESC;

--Zad 7
SELECT imie, przydzial_myszy*3 "Myszy kwartalnie", NVL(myszy_extra, 0)*3 "Kwartalne dodatki"
	FROM Kocury
    WHERE przydzial_myszy > NVL(myszy_extra, 0)*2 AND przydzial_myszy >= 55
    ORDER BY 2 DESC;

--Zad 8
SELECT imie, DECODE( SIGN((przydzial_myszy+NVL(myszy_extra, 0))*12-660),
    -1, 'Ponizej 660',
    0, 'Limit',
    1, (przydzial_myszy+NVL(myszy_extra, 0))*12) "Zjada rocznie"
	FROM Kocury
    ORDER BY 1;

--Zad 8 version with CASE WHEN, no SIGN
SELECT imie, CASE
    WHEN (przydzial_myszy+NVL(myszy_extra, 0))*12 < 660
    	THEN 'Ponizej 660'
    WHEN (przydzial_myszy+NVL(myszy_extra, 0))*12 = 660
    	THEN 'LIMIT'
    ELSE
    	TO_CHAR((przydzial_myszy+NVL(myszy_extra, 0))*12) END "Zjada rocznie"
	FROM Kocury
    ORDER BY 1;

--Zad 9 - 25.10
SELECT pseudo, w_stadku_od, CASE
    WHEN NEXT_DAY(LAST_DAY(DATE '2022-10-25')-7, 'WED') < DATE '2022-10-25'
    	THEN NEXT_DAY(LAST_DAY(ADD_MONTHS(DATE '2022-10-25', 1))-7, 'WED')
    ELSE
    	DECODE( SIGN(EXTRACT(DAY FROM w_stadku_od)-15), 1,
    	NEXT_DAY(LAST_DAY(ADD_MONTHS(DATE '2022-10-25', 1))-7, 'WED'),
    	NEXT_DAY(LAST_DAY(DATE '2022-10-25')-7, 'WED')) END "Wyplata"
    FROM Kocury
    ORDER BY 2;

--Zad 9 - 27.10
SELECT pseudo, w_stadku_od, CASE
    WHEN NEXT_DAY(LAST_DAY(DATE '2022-10-27')-7, 'WED') < DATE '2022-10-27'
    	THEN NEXT_DAY(LAST_DAY(ADD_MONTHS(DATE '2022-10-27', 1))-7, 'WED')
    ELSE
    	DECODE( SIGN(EXTRACT(DAY FROM w_stadku_od)-15), 1,
    	NEXT_DAY(LAST_DAY(ADD_MONTHS(DATE '2022-10-27', 1))-7, 'WED'),
    	NEXT_DAY(LAST_DAY(DATE '2022-10-27')-7, 'WED')) END "Wyplata"
    FROM Kocury
    ORDER BY 2;

--Zad 10 - pseudo
SELECT pseudo || ' - ' || DECODE(COUNT(pseudo), 1, 'Unikalny', 'nieunikalny') "Unikalnosc atr. PSEUDO"
    FROM Kocury
    GROUP BY pseudo
    ORDER BY 1;

--Zad 10 - szef
SELECT szef || ' - ' || DECODE(COUNT(szef), 1, 'Unikalny',  'nieunikalny') "Unikalnosc atr. szef"
    FROM Kocury
    WHERE szef IS NOT NULL
    GROUP BY szef
    ORDER BY 1;

--Zad 11
SELECT pseudo "Pseudonim", COUNT(pseudo) "Liczba wrogow"
    FROM Wrogowie_kocurow
    GROUP BY pseudo
    HAVING COUNT(pseudo) >= 2;

--Zad 12
SELECT 'Liczba kotow=' " ", COUNT(*) " ", 'lowi jako' " ", funkcja " ", 'i zjada max.' " ", MAX(przydzial_myszy+NVL(myszy_extra, 0)) " ", 'myszy miesiecznie' " "
    FROM Kocury
    WHERE plec != 'M' AND funkcja != 'SZEFUNIO'
    GROUP BY funkcja
    HAVING SUM(przydzial_myszy+NVL(myszy_extra, 0)) > 50
	ORDER BY 2;

--Zad 13
SELECT nr_bandy, plec, MIN(przydzial_myszy)
    FROM Kocury
    GROUP BY nr_bandy, plec
    ORDER BY 1, 2;

--Zad 14
SELECT level "Poziom", pseudo "Pseudonim",funkcja "Funkcja", nr_bandy "Nr bandy"
    FROM Kocury
    WHERE plec='M'
    CONNECT BY PRIOR pseudo = szef
    START WITH funkcja='BANDZIOR' AND plec = 'M'
    ORDER SIBLINGS BY pseudo;

--Zad 15
SELECT RPAD('===>', (level-1)*4, '===>') || (level-1) || '            ' || imie Hierarchia, NVL(szef, 'Sam sobie panem') "Pseudo szefa", funkcja
    FROM Kocury
    WHERE myszy_extra IS NOT NULL
    CONNECT BY PRIOR pseudo = szef
    START WITH szef IS NULL;

--Zad 16
SELECT RPAD(' ', (level-1)*4, ' ' )|| pseudo "Droga sluzbowa"
    FROM Kocury
    CONNECT BY PRIOR szef = pseudo
    START WITH szef IS NOT NULL AND myszy_extra IS NULL AND plec='M' AND ADD_MONTHS(w_stadku_od, 13*12) < DATE '2022-07-14';