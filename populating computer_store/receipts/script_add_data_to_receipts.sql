SET SERVEROUTPUT ON SIZE UNLIMITED;

CREATE OR REPLACE
PROCEDURE generate_receipts
IS
    TYPE rec_transaction IS RECORD(
         transaction_id     transactions.transaction_id%TYPE
        ,payment_method_id  transactions.payment_method_id%TYPE
        ,delivery_method_id transactions.delivery_method_id%TYPE
        ,status_id          transactions.status_id%TYPE
        ,start_time         TIMESTAMP
        ,end_time           TIMESTAMP
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
            ,t.payment_method_id 
            ,t.delivery_method_id 
            ,t.status_id          
            ,t.start_time         
            ,t.end_time     
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
    
    PROCEDURE overwrite_transaction_end_date(in_idx INTEGER, is_online BOOLEAN) 
    IS
        v_random_number INTEGER := DBMS_RANDOM.value(1, 15);
    BEGIN
        IF at_transactions(in_idx).status_id IN (1, 2) THEN
            at_transactions(in_idx).end_time := NULL;
        ELSIF at_transactions(in_idx).status_id = 3 THEN
            CASE
                WHEN at_transactions(in_idx).payment_method_id = 4                     THEN at_transactions(in_idx).end_time := at_transactions(in_idx).start_time + 8;
                WHEN at_transactions(in_idx).payment_method_id = 3 AND is_online       THEN at_transactions(in_idx).end_time := at_transactions(in_idx).start_time + 1 + (v_random_number / (24 * 60));
                WHEN at_transactions(in_idx).payment_method_id = 3 AND NOT is_online   THEN at_transactions(in_idx).end_time := at_transactions(in_idx).start_time + (v_random_number / (24 * 60));
                WHEN at_transactions(in_idx).payment_method_id = 2                     THEN at_transactions(in_idx).end_time := at_transactions(in_idx).start_time + (v_random_number / (24 * 60));
                WHEN at_transactions(in_idx).payment_method_id = 1 AND is_online       THEN at_transactions(in_idx).end_time := at_transactions(in_idx).start_time + 1 + (v_random_number / (24 * 60));
                WHEN at_transactions(in_idx).payment_method_id = 1 AND NOT is_online   THEN at_transactions(in_idx).end_time := at_transactions(in_idx).start_time + (v_random_number / (24 * 60));
            END CASE;
        ELSIF at_transactions(in_idx).status_id = 5 THEN
            CASE
                WHEN at_transactions(in_idx).payment_method_id = 4                     THEN at_transactions(in_idx).end_time := at_transactions(in_idx).start_time + DBMS_RANDOM.value(1, 7);
                WHEN at_transactions(in_idx).payment_method_id = 3 AND is_online       THEN at_transactions(in_idx).end_time := at_transactions(in_idx).start_time + DBMS_RANDOM.value(ROUND(DBMS_RANDOM.value(), 3), 1);
                WHEN at_transactions(in_idx).payment_method_id = 3 AND NOT is_online   THEN at_transactions(in_idx).end_time := at_transactions(in_idx).start_time + (v_random_number / (24 * 60));
                WHEN at_transactions(in_idx).payment_method_id = 2                     THEN at_transactions(in_idx).end_time := at_transactions(in_idx).start_time + (v_random_number / (24 * 60));
                WHEN at_transactions(in_idx).payment_method_id = 1 AND is_online       THEN at_transactions(in_idx).end_time := at_transactions(in_idx).start_time + DBMS_RANDOM.value(ROUND(DBMS_RANDOM.value(), 3), 1);
                WHEN at_transactions(in_idx).payment_method_id = 1 AND NOT is_online   THEN at_transactions(in_idx).end_time := at_transactions(in_idx).start_time + (v_random_number / (24 * 60));
            END CASE;
        END IF;
    END overwrite_transaction_end_date;
    
    PROCEDURE set_payment_term(in_idx INTEGER) 
    IS
        v_online        BOOLEAN := TRUE;
        v_not_online    BOOLEAN := FALSE;
        v_payment_meth  transactions.payment_method_id%TYPE;
        v_delivery_meth transactions.delivery_method_id%TYPE;
    BEGIN 
        v_delivery_meth := at_transactions(in_idx).delivery_method_id;
        v_payment_meth := at_transactions(in_idx).payment_method_id;
        
        IF v_delivery_meth != 4 THEN 
            IF v_payment_meth = 4 THEN
                at_receipts(in_idx).payment_term_id := 1;
                overwrite_transaction_end_date(in_idx, v_online);
            ELSIF v_payment_meth IN (1, 3) THEN
                at_receipts(in_idx).payment_term_id := 5;
                overwrite_transaction_end_date(in_idx, v_online);
            END IF;
        ELSE
            at_receipts(in_idx).payment_term_id := 5;
            overwrite_transaction_end_date(in_idx, v_not_online);
        END IF;
    END set_payment_term;
    
    PROCEDURE generate_receipt_number(in_idx INTEGER) 
    IS
        v_receipt_no    VARCHAR2(50);
        v_date_string   VARCHAR2(50);
    BEGIN
        v_date_string := TO_CHAR(at_transactions(in_idx).start_time, 'YYYY/MM/DD');
        v_receipt_no := TO_CHAR(at_transactions(in_idx).transaction_id) || REPLACE(v_date_string, '/', '');
        at_receipts(in_idx).receipt_no := v_receipt_no;
    END generate_receipt_number;
    
    PROCEDURE copy_data_into_receipts IS
    BEGIN
    
    END copy_data_into_receipts;
    
BEGIN
    get_transactions();
    
    FOR idx IN at_transactions.FIRST..at_transactions.LAST
    LOOP
        set_transaction_id(idx);
        set_payment_term(idx);
        generate_receipt_number(idx);
        /*DBMS_OUTPUT.put_line(idx || ' ' ||
                            'receipt_no: ' || at_receipts(idx).receipt_no || ' ' ||
                            'transaction_id: ' || at_receipts(idx).transaction_id || ' ' ||
                            'time of transaction: ' || at_transactions(idx).end_time || ' ' || at_transactions(idx).start_time || ' ' ||
                            'payment_term_id: ' || at_receipts(idx).payment_term_id);*/
                           
        
    END LOOP;
    
    FORALL receipt IN at_receipts.FIRST..at_receipts.LAST
       INSERT INTO receipts (
            transaction_id
       ) 
       VALUES (
            at_receipts(receipt).transaction_id
       );
    COMMIT;
END generate_receipts;
/

EXECUTE generate_receipts();