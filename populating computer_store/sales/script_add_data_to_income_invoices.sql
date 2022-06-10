SET SERVEROUTPUT ON;

DROP PROCEDURE generate_income_invoices_data;
CREATE OR REPLACE 
PROCEDURE generate_income_invoices_data 
IS
    TYPE transactions_type IS TABLE OF transactions.transaction_id%TYPE INDEX BY PLS_INTEGER;
    at_transactions         transactions_type;
    at_invoce_transactions  transactions_type;
    
    PROCEDURE get_transactions IS
    BEGIN
        SELECT transaction_id
        BULK COLLECT INTO at_transactions
        FROM transactions;
    END get_transactions;
    
    PROCEDURE generate_transaction_ids_for_invoices 
    IS
        v_random_index INTEGER;
        
        FUNCTION index_exists(in_index INTEGER) RETURN BOOLEAN IS
        BEGIN
            FOR idx IN at_invoce_transactions.FIRST..at_invoce_transactions.LAST
            LOOP
                IF at_invoce_transactions(idx) IS NULL OR in_index != at_invoce_transactions(idx)  THEN
                    RETURN FALSE;
                END IF;
            END LOOP;
            RETURN TRUE;
        END index_exists;
        
    BEGIN
        v_random_index := DBMS_RANDOM.value(1, 2000);
        at_invoce_transactions(1) := v_random_index;
        FOR idx IN 1..700
        LOOP
            v_random_index := DBMS_RANDOM.value(1, 2000);
            IF NOT index_exists(v_random_index) THEN
                at_invoce_transactions(idx) := v_random_index;
                dbms_output.put_line(idx || ':  ' || at_invoce_transactions(idx));
            END IF;
        END LOOP;
    END generate_transaction_ids_for_invoices;
    
    
    
BEGIN
    generate_transaction_ids_for_invoices();
END generate_income_invoices_data;
/

EXECUTE generate_income_invoices_data();
/
