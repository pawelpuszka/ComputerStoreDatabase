SET SERVEROUTPUT ON;

DROP TABLE buffer_addresses;
CREATE TABLE buffer_addresses (
     street         VARCHAR2(100)
    ,city           VARCHAR2(100)
    ,postal_code    VARCHAR2(100)
    ,phone_number   VARCHAR2(100)
    ,email          VARCHAR2(100)
);

SELECT *
FROM buffer_addresses
;

DROP TABLE buffer_addresses_2;
CREATE TABLE buffer_addresses_2 (
     street         VARCHAR2(100)
    ,city           VARCHAR2(100)
    ,postal_code    VARCHAR2(100)
    ,phone_number   VARCHAR2(100)
    ,email          VARCHAR2(100)
);

SELECT *
FROM buffer_addresses_2
;
