SET SERVEROUTPUT ON;

DROP PROCEDURE generate_income_invoices_data;
CREATE OR REPLACE 
PROCEDURE generate_income_invoices_data 
IS
    TYPE transactions_type IS TABLE OF transactions%ROWTYPE INDEX BY PLS_INTEGER;
    at_transactions         transactions_type;
    at_invoce_transactions  transactions_type;
    
    PROCEDURE get_transactions IS
    BEGIN
        SELECT *
        BULK COLLECT INTO at_transactions
        FROM transactions;
    END get_transactions;
    
    PROCEDURE prepare_transactions_for_invoices 
    IS
        v_random_index INTEGER;
    BEGIN
        FOR idx IN 1..700
        LOOP
            
        END LOOP;
    END prepare_transactions_for_invoices;
BEGIN

END generate_income_invoices_data;