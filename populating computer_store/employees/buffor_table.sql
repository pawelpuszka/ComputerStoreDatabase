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

SELECT * 
FROM buf_pracownicy
;

CREATE TABLE transformation_Pracownicy(
    data_import         DATE,
    data_source         VARCHAR2(100),
	IdPracownicy        VARCHAR2(10) NOT NULL,
	Imie                VARCHAR2(40) NOT NULL,
	Nazwisko            VARCHAR2(40) NOT NULL,
	PESEL               VARCHAR2(11) NULL,
	PensjaPodstawowa    VARCHAR2(40) NOT NULL,
	Premia              VARCHAR2(40) NOT NULL,
	DataZatrudnienia    VARCHAR2(40) NOT NULL,
	IdDzialu            VARCHAR2(40) NOT NULL,
	IdPrzelozonego      VARCHAR2(40)
)