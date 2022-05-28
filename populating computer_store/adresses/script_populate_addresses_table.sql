SET SERVEROUTPUT ON;

DROP TABLE buffer_addresses;
CREATE TABLE buffer_addresses (
     addr_id        INTEGER GENERATED ALWAYS AS IDENTITY
    ,street         VARCHAR2(100)
    ,city           VARCHAR2(100)
    ,postal_code    VARCHAR2(100)
    ,phone_number   VARCHAR2(100)
    ,email          VARCHAR2(100)
);

SELECT *
FROM buffer_addresses
;
DELETE buffer_addresses
WHERE addr_id = 14;

DELETE buffer_addresses
WHERE phone_number IS NOT NULL;


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

DROP TABLE phone_nimbers;
CREATE TABLE phone_nimbers (
     phone_id       INTEGER GENERATED ALWAYS AS IDENTITY
    ,phone_number   VARCHAR2(100)
);

SELECT *
FROM phone_nimbers
;

DECLARE
    CURSOR phones IS
        SELECT 
             phone_id
            ,phone_number
        FROM phone_nimbers
        --FOR UPDATE
        ;
    
    v_phone_number phone_nimbers%ROWTYPE;
BEGIN
    OPEN phones;
    LOOP
        EXIT WHEN phones%ROWCOUNT > 13;
        FETCH phones INTO v_phone_number;
        UPDATE buffer_addresses ba
        SET ba.phone_number = v_phone_number.phone_number
        WHERE 
            ba.addr_id = v_phone_number.phone_id
            ;
        COMMIT;
    END LOOP;
    
    CLOSE phones;
END;
/