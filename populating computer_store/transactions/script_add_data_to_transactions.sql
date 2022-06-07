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
    
    PROCEDURE generate_transactions --RETURN delivery_meth_id_type 
    IS
        v_delivery_id transactions%ROWTYPE;
    BEGIN
        FOR trans_id IN 1..100
        LOOP
            at_transactions(trans_id).delivery_method_id := DBMS_RANDOM.value(1, 4);
            IF at_transactions(trans_id).delivery_method_id = 4 THEN
                at_transactions(trans_id).payment_method_id := DBMS_RANDOM.value(1, 3);
            ELSE
                LOOP
                    at_transactions(trans_id).payment_method_id := DBMS_RANDOM.value(1, 4);
                    EXIT WHEN at_transactions(trans_id).payment_method_id != 2;
                END LOOP;
            END IF;
                
            dbms_output.put_line('payment_id ' || at_transactions(trans_id).payment_method_id || ', delivery_id: ' || at_transactions(trans_id).delivery_method_id);
        END LOOP;
    END generate_transactions;
BEGIN
    generate_transactions();
    
END generate_transaction_data;
/

BEGIN
    generate_transaction_data();
END;