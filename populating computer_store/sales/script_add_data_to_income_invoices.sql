SET SERVEROUTPUT ON;

DROP PROCEDURE generate_income_invoices_data;
CREATE OR REPLACE 
PROCEDURE generate_income_invoices_data 
IS
    TYPE income_invoces_type IS TABLE OF income_invoices%ROWTYPE INDEX BY PLS_INTEGER; 
    TYPE transactions_type IS TABLE OF transactions%ROWTYPE INDEX BY PLS_INTEGER;
    
    at_invoices     income_invoces_type;
    at_transactions transactions_type;
    
    PROCEDURE get_transactions IS
    BEGIN
        SELECT *
        BULK COLLECT INTO at_transactions
        FROM transactions;
    END get_transactions;
    
    PROCEDURE generate_transaction_ids_for_invoices 
    IS
        at_invoce_transactions  transactions_type;
        v_random_index          INTEGER;
        
        FUNCTION index_exists(in_index INTEGER) RETURN BOOLEAN IS
        BEGIN
            FOR idx IN at_invoce_transactions.FIRST..at_invoce_transactions.LAST
            LOOP
                IF at_invoce_transactions(idx).transaction_id IS NULL OR in_index != at_invoce_transactions(idx).transaction_id  THEN
                    RETURN FALSE;
                END IF;
            END LOOP;
            RETURN TRUE;
        END index_exists;
        
        FUNCTION is_letter(in_index INTEGER) RETURN BOOLEAN IS
        BEGIN
            FOR idx IN at_transactions.FIRST..at_transactions.LAST
            LOOP
                IF at_transactions(idx).transaction_id = in_index AND at_transactions(idx).delivery_method_id = 3 THEN --3 - letter(delivery method)
                    RETURN TRUE;
                END IF;
            END LOOP;
            RETURN FALSE;
        END is_letter;
        
        PROCEDURE copy_transactions_into_invoices IS
        BEGIN
            FOR idx IN at_invoce_transactions.FIRST..at_invoce_transactions.LAST
            LOOP
                at_invoices(idx).transaction_id := at_invoce_transactions(idx).transaction_id;
                dbms_output.put_line(idx || ':  ' || at_invoices(idx).transaction_id);
            END LOOP;
        END copy_transactions_into_invoices;
        
    BEGIN
        get_transactions();
        v_random_index := DBMS_RANDOM.value(1, 2000);
        at_invoce_transactions(1).transaction_id := v_random_index;
        FOR idx IN 1..700
        LOOP
            v_random_index := DBMS_RANDOM.value(1, 2000);
            IF NOT index_exists(v_random_index) AND NOT is_letter(v_random_index) THEN
                at_invoce_transactions(idx).transaction_id := v_random_index;
                --dbms_output.put_line(idx || ':  ' || at_invoce_transactions(idx).transaction_id);
            END IF;
        END LOOP;
        copy_transactions_into_invoices();
    END generate_transaction_ids_for_invoices;
    
    
    /*PROCEDURE generate_invoce_no 
    IS*/
    
    
BEGIN
    generate_transaction_ids_for_invoices();
END generate_income_invoices_data;
/

EXECUTE generate_income_invoices_data();
/
