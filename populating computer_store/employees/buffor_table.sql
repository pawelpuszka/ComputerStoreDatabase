--STWORZENIE TABELI BUFOROWEJ DO ZAIMPORTOWANIA DANYCH Z PLIKU .CSV
DROP TABLE buf_Pracownicy;
CREATE TABLE buf_Pracownicy(
	IdPracownicy VARCHAR2(10) NOT NULL,
	Imie VARCHAR2(40) NOT NULL,
	Nazwisko VARCHAR2(40) NOT NULL,
	PESEL VARCHAR2(11) NULL,
	PensjaPodstawowa VARCHAR2(40) NOT NULL,
	Premia VARCHAR2(40) NOT NULL,
	DataZatrudnienia VARCHAR2(40) NOT NULL,
	IdDzialu VARCHAR2(40) NOT NULL,
	IdPrzelozonego VARCHAR2(40)
)
;
SELECT * 
FROM buf_pracownicy
;

--STWORZENIE TABELI TRANSFORMACJI 
DROP TABLE transformation_Pracownicy;
CREATE TABLE transformation_Pracownicy(
    data_import         DATE,
    data_source         VARCHAR2(100),
	employee_ID         NUMBER(38,0) PRIMARY KEY,
	employee_name       NVARCHAR2(20) NOT NULL,
	employee_surname    NVARCHAR2(30) NOT NULL,
	pesel               VARCHAR2(11) NULL,
	PensjaPodstawowa    VARCHAR2(40) ,
	Premia              VARCHAR2(40) ,
	DataZatrudnienia    VARCHAR2(40) ,
	IdDzialu            VARCHAR2(40) ,
	IdPrzelozonego      VARCHAR2(40)
)
;

--POLECENIE DO TRANSFERU DANYCH Z BUFORA DO TABELI TRANSFORMACJI
INSERT INTO transformation_pracownicy (
     data_import
    ,data_source
    ,employee_ID
    ,employee_name
    ,employee_surname
    ,pesel
)
SELECT
     SYSDATE
    ,'MSSQL [Sklep_Internetowy_Kurs_SQL].[dbo].[Pracownicy]'
    ,IdPracownicy
    ,Imie
    ,Nazwisko
    ,PESEL
FROM buf_pracownicy
;

SELECT *
FROM transformation_pracownicy
;













