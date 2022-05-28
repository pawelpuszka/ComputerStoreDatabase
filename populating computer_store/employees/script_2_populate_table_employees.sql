DROP TABLE buffer_Podrozny;
CREATE TABLE buffer_Podrozny(
	IdPodrozny int NOT NULL,
	Imie varchar(10) NOT NULL,
	Nazwisko varchar(13) NOT NULL,
	PESEL varchar(11) NOT NULL
)
;

SELECT *
FROM buffer_podrozny
;

DROP TABLE transform_Podrozny;
CREATE TABLE transform_Podrozny(
    data_import         DATE,
    data_source         VARCHAR2(100),
	EMPLOYEE_ID         int NOT NULL,
	EMPLOYEE_NAME       nvarchar2(20) NOT NULL,
	EMPLOYEE_SURNAME    nvarchar2(30) NOT NULL,
	PESEL               varchar2(11 BYTE) 
)
;

INSERT INTO transform_podrozny (
     data_import         
    ,data_source         
	,EMPLOYEE_ID         
	,EMPLOYEE_NAME       
	,EMPLOYEE_SURNAME    
	,PESEL 
)
SELECT 
     SYSDATE
    ,'MS SQL [Biuro_Podrozy].[Podrozny]'
    ,IdPodrozny
    ,Imie
    ,Nazwisko
    ,PESEL
FROM buffer_podrozny
;






INSERT INTO employees(
     EMPLOYEE_NAME --NVARCHAR2(20 CHAR)
    ,EMPLOYEE_SURNAME --NVARCHAR2(20 CHAR)
    ,PESEL --VARCHAR2(11 BYTE)
)
SELECT 
     EMPLOYEE_NAME --VARCHAR2(20 CHAR)
    ,EMPLOYEE_SURNAME --VARCHAR2(30 CHAR)
    ,PESEL --VARCHAR2(11 BYTE)
FROM 
    transform_podrozny
UNION ALL
SELECT
     tp.employee_name --NVARCHAR2(20 CHAR)
    ,tp.employee_surname --NVARCHAR2(30 CHAR)
    ,tp.pesel --VARCHAR2(11 BYTE)
FROM
    transformation_pracownicy tp
; 

SELECT *
FROM employees
;