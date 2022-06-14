SET SERVEROUTPUT ON;

DROP PROCEDURE generate_income_invoices_data;
CREATE OR REPLACE 
PROCEDURE generate_income_invoices_data 
IS
    TYPE transaction_rec IS RECORD (
         transaction_id     transactions.transaction_id%TYPE
        ,payment_method_id  transactions.payment_method_id%TYPE
        ,status_id          transactions.status_id%TYPE
        ,start_time         transactions.start_time%TYPE
        --,is_used          NUMBER(1, 0)
    );
    TYPE transaction_type IS TABLE OF transaction_rec INDEX BY PLS_INTEGER;
    TYPE invoice_type IS TABLE OF income_invoices%ROWTYPE INDEX BY PLS_INTEGER;
    
    at_transactions transaction_type;
    at_invoices     invoice_type;
    
    PROCEDURE get_transactions IS
    BEGIN
        SELECT
             transaction_id
            ,payment_method_id 
            ,status_id
            ,start_time
        BULK COLLECT INTO
            at_transactions
        FROM 
            transactions
        WHERE 
            status_id = 5
            AND
            delivery_method_id != 3
        ;
    END get_transactions;
        
    
    PROCEDURE set_transaction_id(in_index INTEGER) IS
    BEGIN
        at_invoices(in_index).transaction_id := at_transactions(in_index).transaction_id;
    END set_transaction_id;
    
    
    PROCEDURE set_invoice_date(in_index INTEGER) IS
    BEGIN
        IF at_invoices(in_index).transaction_id = at_transactions(in_index).transaction_id THEN
            at_invoices(in_index).income_invoice_date := at_transactions(in_index).start_time;
        END IF;
    END set_invoice_date;
    
    
    PROCEDURE set_client_id(in_index INTEGER) 
    IS
        TYPE wholesale_client_type IS TABLE OF wholesale_clients.wholesale_client_id%TYPE INDEX BY PLS_INTEGER;
        v_random_client_id  income_invoices.wholesale_client_id%TYPE;
        at_clients          wholesale_client_type;
        
        PROCEDURE get_clients IS
        BEGIN
            SELECT 
                wholesale_client_id
            BULK COLLECT INTO
                at_clients 
            FROM 
                wholesale_clients
            ;
        END get_clients;
    BEGIN
        get_clients();
        v_random_client_id := DBMS_RANDOM.value(1, at_clients.COUNT);
        at_invoices(in_index).wholesale_client_id := at_clients(v_random_client_id);
    END set_client_id;
    
    PROCEDURE set_payment_term IS
    BEGIN
        NULL;s
    END set_payment_term;
    
BEGIN
    get_transactions();
    
    FOR idx IN 1..747
    LOOP
        set_transaction_id_for_invoice(idx);
        set_invoice_date(idx);
        set_client_for_invoice(idx);
        DBMS_OUTPUT.put_line(idx || ' ' || 
                             'transaction_id: ' || at_invoices(idx).transaction_id || ' ' ||
                             'invoice_date: ' || at_invoices(idx).income_invoice_date || ' ' ||
                             'client_id: ' || at_invoices(idx).wholesale_client_id);
    END LOOP;
END generate_income_invoices_data;
/

EXECUTE generate_income_invoices_data();
/
