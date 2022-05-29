SET SERVEROUTPUT ON;

DROP TABLE buffer_addresses_employees;
CREATE TABLE buffer_addresses_employees (
     addr_id        INTEGER GENERATED ALWAYS AS IDENTITY
    ,street         VARCHAR2(100)
    ,city           VARCHAR2(100)
    ,postal_code    VARCHAR2(100)
    ,phone_number   VARCHAR2(100)
);

SELECT *
FROM buffer_addresses_employees
;

DROP TABLE phone_numbers;
CREATE TABLE phone_numbers (
     phone_id       INTEGER GENERATED ALWAYS AS IDENTITY
    ,phone_number   VARCHAR2(100)
);

SELECT *
FROM phone_numbers
;

DECLARE
    CURSOR phones IS
        SELECT 
             phone_id
            ,phone_number
        FROM phone_numbers
        WHERE phone_id > 32
        ;
    
    v_phone_number phone_numbers%ROWTYPE;
BEGIN
    OPEN phones;
    LOOP
        
        FETCH phones INTO v_phone_number;
        EXIT WHEN phones%NOTFOUND;
        UPDATE buffer_addresses_employees ba
        SET ba.phone_number = v_phone_number.phone_number
        WHERE 
            ba.addr_id = v_phone_number.phone_id + 53
            ;
        COMMIT;
    END LOOP;
    CLOSE phones;
END;
/

DROP TABLE transform_addresses_employees;
CREATE TABLE transform_addresses_employees (
     street         NVARCHAR2(100)
    ,city           NVARCHAR2(50)
    ,postal_code    CHAR(6 CHAR)
    ,phone_number   VARCHAR2(12 CHAR)
);

INSERT INTO transform_addresses_employees ta(
     ta.street         
    ,ta.city          
    ,ta.postal_code   
    ,ta.phone_number   
)
SELECT
     ba.street
    ,ba.city
    ,ba.postal_code
    ,ba.phone_number
FROM
    buffer_addresses_employees ba
;

SELECT *
FROM transform_addresses_employees;

INSERT INTO addresses e(
     e.street         
    ,e.city          
    ,e.postal_code   
    ,e.phone_number   
)
SELECT
     ba.street
    ,ba.city
    ,ba.postal_code
    ,ba.phone_number
FROM
    transform_addresses_employees ba
;

SELECT *
FROM addresses;
