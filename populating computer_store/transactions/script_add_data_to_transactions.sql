SET SERVEROUTPUT ON;

SELECT e.employee_id
FROM employees e
    INNER JOIN employees_contracts ec
        ON e.contract_id = ec.contract_id
WHERE ec.position_id = 8 OR ec.position_id = 9 
;

DROP PROCEDURE generate_transaction_data;
CREATE OR REPLACE 
PROCEDURE generate_transaction_data 
IS
    TYPE transaction_type IS TABLE OF transactions%ROWTYPE INDEX BY PLS_INTEGER;
    at_transactions transaction_type;
    
    v_delivery_id   transactions.delivery_method_id%TYPE;
    v_payment_id    transactions.payment_method_id%TYPE;
    
    PROCEDURE set_transaction_id(in_id INTEGER) IS
    BEGIN
        at_transactions(in_id).transaction_id := in_id;
    END set_transaction_id;
    
    PROCEDURE set_delivery_id(in_id INTEGER) IS
    BEGIN
        at_transactions(in_id).delivery_method_id := DBMS_RANDOM.value(1, 4);
    END set_delivery_id;
    
    PROCEDURE set_payment_id(in_id INTEGER) IS
    BEGIN
        IF at_transactions(in_id).delivery_method_id = 4 THEN -- 4- jeżeli sprzedaż stacjonarna
            at_transactions(in_id).payment_method_id := DBMS_RANDOM.value(1, 3); -- nie placimy przelewem
        ELSE
            LOOP
                at_transactions(in_id).payment_method_id := DBMS_RANDOM.value(1, 4);
                EXIT WHEN at_transactions(in_id).payment_method_id != 2; --jeżeli nie sprzedaż stacjonarna to nie pacimy gotówką
            END LOOP;
        END IF;
    END set_payment_id;
    
    PROCEDURE set_employee_id(in_id INTEGER) IS
    BEGIN
        
    END set_employee_id;
    
BEGIN
    FOR next_id IN 1..100
    LOOP
        set_transaction_id(next_id);
        set_delivery_id(next_id);
        set_payment_id(next_id);
        
        dbms_output.put_line('payment_id ' || at_transactions(next_id).payment_method_id || ', delivery_id: ' || at_transactions(next_id).delivery_method_id);
    END LOOP;
END generate_transaction_data;
/

BEGIN
    generate_transaction_data();
END;