SET SERVEROUTPUT ON SIZE UNLIMITED;

CREATE OR REPLACE
PROCEDURE generate_receipts
IS
    TYPE rec_transaction IS RECORD(
         transaction_id transactions.transaction_id%TYPE
        ,start_time     TIMESTAMP
    );
    TYPE type_transaction IS TABLE OF rec_transaction INDEX BY PLS_INTEGER;
    TYPE type_receipt IS TABLE OF receipts%ROWTYPE INDEX BY PLS_INTEGER;
    
    at_transactions         type_transaction;
    at_receipts             type_receipt;  
    v_random_transact_id    INTEGER;
    v_transaction_id        transactions.transaction_id%TYPE;
    
    PROCEDURE get_transactions IS
    BEGIN
        SELECT 
            t.transaction_id
            ,start_time
        BULK COLLECT INTO at_transactions
        FROM transactions t
            LEFT JOIN income_invoices i
                ON t.transaction_id = i.transaction_id
        WHERE i.income_invoice_id IS NULL
        ;
    END get_transactions;
    
    PROCEDURE set_transaction_id(in_idx INTEGER) IS
    BEGIN
        at_receipts(in_idx).transaction_id := at_transactions(in_idx).transaction_id;
    END set_transaction_id;
    
    PROCEDURE set_date(in_idx INTEGER) IS
    BEGIN
        at_receipts(in_idx).receipt_date :=  at_transactions(in_idx).start_time;
    END set_date;
    
    PROCEDURE set_payment_term IS
    BEGIN 
        /*
        RECEIPTS
        online
        if payment_method = transfer
            payment_term = 1
            overwrite_end_date(v_payment_method, is_online)
                if status_id = 1 new or 2 pending
                    end_date := null
                if status_id = 3 cancelled
                    case 
                        when v_payment_method=4 then end_date := start_date + 8
                        when v_payment_method=3 and is_online then end_date := start_date + 1dzień + kilka minut
                        when v_payment_method=3 then end_date := start_date + kilka minut
                        when v_payment_method=2 then end_date := start_date + kilka minut
                        when v_payment_method=1 and is_online then end_date := start_date + 1dzień + kilka minut
                        when v_payment_method=1 then end_date := start_date + 1dzień + kilka minut
                if status_id = 5 finished
                    case 
                        when v_payment_method=4 then end_date := start_date + random(1, 7)
                        when v_payment_method=3 and is_online then end_date := start_date + kilka minut do 1 dzień
                        when v_payment_method=3 then end_date := start_date + kilka minut
                        when v_payment_method=2 then end_date := start_date + kilka minut
                        when v_payment_method=1 and is_online then end_date := start_date + kilka minut do 1 dzień
                        when v_payment_method=1 then end_date := start_date + kilka minut
        
        if payment_method = blik or card
            payment_term = 5
            overwrite_end_date(v_payment_method)
        
        stationary sale
            payment_term = 5
            overwrite_end_date(v_payment_method, is_online)
        */
    END set_payment_term;
BEGIN
    get_transactions();
    
    FOR idx IN at_transactions.FIRST..at_transactions.LAST
    LOOP
        set_transaction_id(idx);
        DBMS_OUTPUT.put_line(idx || ' ' ||
                            'transaction_id: ' || at_receipts(idx).transaction_id || ' ' ||);
    END LOOP;
    
    /*FORALL receipt IN at_receipts.FIRST..at_receipts.LAST
       INSERT INTO receipts (
            transaction_id
       ) 
       VALUES (
            at_receipts(receipt).transaction_id
       );
    COMMIT;*/
END generate_receipts;
/

EXECUTE generate_receipts();