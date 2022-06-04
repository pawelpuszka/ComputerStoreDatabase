SET SERVEROUTPUT ON;


--online storehouse
INSERT INTO online_storehouse (
    product_id
)
SELECT p.product_id
FROM products p
;


DROP PROCEDURE generate_online_product_qty;
CREATE OR REPLACE
PROCEDURE generate_online_product_qty
IS  
    CURSOR current_product IS
        SELECT product_id
        FROM products
    ;
    v_prod_qty      INTEGER;
    v_product_id    online_storehouse.product_id%TYPE;
    v_deficit_alert online_storehouse.deficit_alert%TYPE;
BEGIN
    OPEN current_product;
    LOOP
        v_prod_qty := SYS.dbms_random.value(5, 50);
        v_deficit_alert := SYS.dbms_random.value(5, 15);
        FETCH current_product INTO v_product_id;
        EXIT WHEN current_product%NOTFOUND;
        UPDATE 
            online_storehouse
        SET
             online_product_qty = v_prod_qty
            ,deficit_alert = v_deficit_alert
        WHERE
            product_id = v_product_id
        ;
        COMMIT;
    END LOOP;
    CLOSE current_product;
END generate_online_product_qty;
/

BEGIN
    generate_online_product_qty();
END;
/

SELECT * 
FROM online_storehouse;



--stationary storehouse
DROP PROCEDURE copy_product_ids;
CREATE OR REPLACE
PROCEDURE copy_product_ids IS
BEGIN
    EXECUTE IMMEDIATE 'INSERT INTO stationary_storehouse (product_id)
                       SELECT p.product_id
                       FROM products p'
                       ;
END copy_product_ids;
/


DROP PROCEDURE generate_stationary_product_qty;
CREATE OR REPLACE
PROCEDURE generate_stationary_product_qty
IS  
    CURSOR current_product IS
        SELECT product_id
        FROM products
    ;
    v_prod_qty      INTEGER;
    v_product_id    stationary_storehouse.product_id%TYPE;
    v_deficit_alert stationary_storehouse.deficit_alert%TYPE;
BEGIN
    OPEN current_product;
    LOOP
        v_prod_qty := SYS.dbms_random.value(5, 50);
        v_deficit_alert := SYS.dbms_random.value(5, 15);
        FETCH current_product INTO v_product_id;
        EXIT WHEN current_product%NOTFOUND;
        UPDATE 
            stationary_storehouse
        SET
             product_quantity = v_prod_qty
            ,deficit_alert = v_deficit_alert
        WHERE
            product_id = v_product_id
        ;
        COMMIT;
    END LOOP;
    CLOSE current_product;
END generate_stationary_product_qty;
/

BEGIN
    --copy_product_ids();
    generate_stationary_product_qty();
END;
/

SELECT * 
FROM stationary_storehouse;