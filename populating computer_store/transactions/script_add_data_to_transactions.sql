SET SERVEROUTPUT ON;

DROP PROCEDURE generate_transaction_data;
CREATE OR REPLACE 
PROCEDURE generate_transaction_data 
IS
    TYPE transaction_type IS TABLE OF transactions%ROWTYPE INDEX BY PLS_INTEGER;
    TYPE salesman_id_type IS TABLE OF employees.employee_id%TYPE INDEX BY PLS_INTEGER;
    
    at_transactions             transaction_type;
    at_online_salesmen_id       salesman_id_type;
    at_stationary_salesmen_id   salesman_id_type;
    
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
        IF at_transactions(in_id).delivery_method_id = 4 THEN -- 4-if stationary sale 
            at_transactions(in_id).payment_method_id := DBMS_RANDOM.value(1, 3); -- can't pay with bank transfer
        ELSE
            LOOP
                at_transactions(in_id).payment_method_id := DBMS_RANDOM.value(1, 4);
                EXIT WHEN at_transactions(in_id).payment_method_id != 2; -- if not stationary sale then can't pay with cash
            END LOOP;
        END IF;
    END set_payment_id;
    
    PROCEDURE set_employee_id(in_id INTEGER) 
    IS
        v_random_id                 PLS_INTEGER;
        
        PROCEDURE find_salesmen_id IS
        BEGIN
            SELECT e.employee_id
            BULK COLLECT INTO at_online_salesmen_id
            FROM employees e
            INNER JOIN employees_contracts ec
                ON e.contract_id = ec.contract_id
            WHERE ec.position_id = 9 
            ;
            SELECT e.employee_id
            BULK COLLECT INTO at_stationary_salesmen_id
            FROM employees e
            INNER JOIN employees_contracts ec
                ON e.contract_id = ec.contract_id
            WHERE ec.position_id = 8
            ;
        END find_salesmen_id;
        
        FUNCTION salesmen_found(in_id_a INTEGER) RETURN BOOLEAN IS
        BEGIN
            RETURN in_id_a != 1;
        END;
        
        FUNCTION stationary_sale(in_id_b INTEGER) RETURN BOOLEAN IS
        BEGIN
            RETURN at_transactions(in_id_b).delivery_method_id = 4; -- 4-stationary sale 
        END stationary_sale;
        
    BEGIN
        IF NOT salesmen_found(in_id) THEN
            find_salesmen_id();
        END IF;
        
        IF stationary_sale(in_id) THEN
            v_random_id := DBMS_RANDOM.value(1, 8);
            at_transactions(in_id).employee_id := at_stationary_salesmen_id(v_random_id);
        ELSE
            v_random_id := DBMS_RANDOM.value(1, 5);
            at_transactions(in_id).employee_id := at_online_salesmen_id(v_random_id);
        END IF;
    END set_employee_id;
    
BEGIN
    FOR next_id IN 1..200
    LOOP
        set_transaction_id(next_id);
        set_delivery_id(next_id);
        set_payment_id(next_id);
        set_employee_id(next_id);
        --dbms_output.put_line('transaction_id: ' || at_transactions(next_id).transaction_id || ', payment_id ' || at_transactions(next_id).payment_method_id || ', delivery_id: ' || at_transactions(next_id).delivery_method_id || ', employee_id: ' || at_transactions(next_id).employee_id);
    END LOOP;
END generate_transaction_data;
/

BEGIN
    generate_transaction_data();
END;