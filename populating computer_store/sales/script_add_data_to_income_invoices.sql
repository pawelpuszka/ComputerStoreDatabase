SET SERVEROUTPUT ON;

DROP PROCEDURE generate_income_invoices_data;
CREATE OR REPLACE 
PROCEDURE generate_income_invoices_data 
IS
    TYPE rec_transaction_type IS RECORD (
         transaction_id     transactions.transaction_id%TYPE
        ,payment_method_id  transactions.payment_method_id%TYPE
        ,delivery_method_id transactions.delivery_method_id%TYPE
        ,status_id          transactions.status_id%TYPE
        ,start_time         transactions.start_time%TYPE
    );
    
    TYPE rec_client_type IS RECORD (
             wholesale_client_id     wholesale_clients.wholesale_client_id%TYPE
            ,loyalty_card_id        wholesale_clients.loyalty_card_id%TYPE
        );

    TYPE transaction_type IS TABLE OF rec_transaction_type INDEX BY PLS_INTEGER;
    TYPE invoice_type IS TABLE OF income_invoices%ROWTYPE INDEX BY PLS_INTEGER;
    TYPE wholesale_client_type IS TABLE OF rec_client_type INDEX BY PLS_INTEGER;
    
    at_transactions     transaction_type;
    at_invoices         invoice_type;
    at_clients          wholesale_client_type;
    v_trans_count       INTEGER;
    
    PROCEDURE get_transactions IS
    BEGIN
        SELECT
             transaction_id
            ,payment_method_id 
            ,delivery_method_id
            ,status_id
            ,start_time
        BULK COLLECT INTO
            at_transactions
        FROM 
            transactions
        WHERE 
            (status_id IN (2, 3, 5))
            AND
            (delivery_method_id IN (1, 2))
        ;
    END get_transactions;
    
    PROCEDURE get_transactions_count IS
    BEGIN
        SELECT
            COUNT(*)
        INTO
            v_trans_count
        FROM 
            transactions
        WHERE 
            (status_id IN (2, 5))
            AND
            (delivery_method_id IN (1, 2))
        ;
    END get_transactions_count;
    
    PROCEDURE get_clients IS
    BEGIN
        SELECT 
             wholesale_client_id
            ,loyalty_card_id
        BULK COLLECT INTO
            at_clients 
        FROM 
            wholesale_clients
        ;
    END get_clients;
    
    
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
        v_random_client_id  income_invoices.wholesale_client_id%TYPE;
    BEGIN
        v_random_client_id := DBMS_RANDOM.value(1, at_clients.COUNT);
        at_invoices(in_index).wholesale_client_id := at_clients(v_random_client_id).wholesale_client_id;
    END set_client_id;
    
    
    PROCEDURE set_payment_term_id(in_index INTEGER) 
    IS
        v_client_id             wholesale_clients.wholesale_client_id%TYPE;
        v_client_rec            rec_client_type;
            
            FUNCTION get_current_client(in_client_id wholesale_clients.wholesale_client_id%TYPE) RETURN rec_client_type
            IS
                v_current_client rec_client_type;
            BEGIN
                SELECT 
                     wholesale_client_id
                    ,loyalty_card_id
                INTO v_current_client
                FROM wholesale_clients
                WHERE wholesale_client_id = in_client_id
                ;
                RETURN v_current_client;
            END get_current_client;
            
            FUNCTION has_loyalty_card RETURN BOOLEAN IS
            BEGIN
                RETURN v_client_rec.loyalty_card_id IS NOT NULL;
            END has_loyalty_card;
            
            FUNCTION is_golden RETURN BOOLEAN IS
            BEGIN
                RETURN v_client_rec.loyalty_card_id = 1;
            END is_golden;
            
            FUNCTION is_silver RETURN BOOLEAN IS
            BEGIN
                RETURN v_client_rec.loyalty_card_id = 2;
            END is_silver;
    BEGIN
        v_client_id := at_invoices(in_index).wholesale_client_id;
        v_client_rec := get_current_client(v_client_id);
        
        IF has_loyalty_card THEN
            IF is_golden THEN
                at_invoices(in_index).payment_term_id := 4; 
            ELSIF is_silver THEN
                at_invoices(in_index).payment_term_id := 3;
            ELSE
                at_invoices(in_index).payment_term_id := 2;
            END IF;
        ELSE
            at_invoices(in_index).payment_term_id := 1;
        END IF;
    END set_payment_term_id;
    
    
    PROCEDURE generate_invoice_no(in_index INTEGER)
    IS
        v_invoice_no    NVARCHAR2(40);
        v_transact_no   VARCHAR2(10);
        v_month_no      VARCHAR2(10);
        v_year_no       VARCHAR2(10);
        v_client_id     VARCHAR2(10);
    BEGIN
        v_transact_no := TO_CHAR(at_invoices(in_index).transaction_id, '999999');
        v_month_no := TO_CHAR(EXTRACT(MONTH FROM at_invoices(in_index).income_invoice_date), '99');
        v_year_no := TO_CHAR(EXTRACT(YEAR FROM at_invoices(in_index).income_invoice_date), '9999');
        v_client_id := TO_CHAR(at_invoices(in_index).wholesale_client_id, '999');
        v_invoice_no := 'FV/' || v_transact_no || '/' || v_month_no || '/' || v_year_no || '/' || v_client_id;
        v_invoice_no := REPLACE(v_invoice_no, ' ', '');
        at_invoices(in_index).income_invoice_no := v_invoice_no;
    END generate_invoice_no;
    
    
    PROCEDURE copy_data_into_invoices_table IS
    BEGIN
        FORALL invoice IN at_invoices.FIRST..at_invoices.LAST
            INSERT INTO income_invoices(
                 income_invoice_no
                ,wholesale_client_id
                ,income_invoice_date
                ,transaction_id
                ,payment_term_id
            )
            VALUES(
                 at_invoices(invoice).income_invoice_no
                ,at_invoices(invoice).wholesale_client_id
                ,at_invoices(invoice).income_invoice_date
                ,at_invoices(invoice).transaction_id
                ,at_invoices(invoice).payment_term_id
            );
        COMMIT;
    END copy_data_into_invoices_table;
    
BEGIN
    get_transactions();
    get_clients();
    get_transactions_count();
    
    FOR idx IN 1..v_trans_count
    LOOP
        set_transaction_id(idx);
        set_invoice_date(idx);
        set_client_id(idx);
        set_payment_term_id(idx);
        generate_invoice_no(idx);
        DBMS_OUTPUT.put_line(idx || ' ' || 
                             'transaction_id: ' || at_invoices(idx).transaction_id || ' ' ||
                             'invoice_date: ' || at_invoices(idx).income_invoice_date || ' ' ||
                             'client_id: ' || at_invoices(idx).wholesale_client_id || ' ' ||
                             'payment_term_id: ' || at_invoices(idx).payment_term_id || ' ' ||
                             'invoice_no: ' || at_invoices(idx).income_invoice_no );
    END LOOP;
    copy_data_into_invoices_table();
END generate_income_invoices_data;
/

EXECUTE generate_income_invoices_data();
/

--EXECUTE WHEN BOTH TRANSACTIONS AND INCOME_INVOICES ARE POPULATED
PROCEDURE update_transaction_end_time 
IS
    PROCEDURE overwrite_end_date_for_finished_transactions
    IS
        CURSOR c_current_transact IS
            SELECT
                 t.transaction_id
                ,t.start_time
                ,t.end_time
                ,i.payment_term_id
            FROM 
                transactions t
                INNER JOIN income_invoices i
                    ON t.transaction_id = i.transaction_id
            WHERE 
                t.status_id = 5;
        
       v_transact           c_current_transact%ROWTYPE;
       v_random_days_num    INTEGER;
    BEGIN
        OPEN c_current_transact;
        LOOP
            FETCH c_current_transact INTO v_transact;
            EXIT WHEN c_current_transact%NOTFOUND;
            IF v_transact.payment_term_id = 4 THEN
                v_random_days_num := DBMS_RANDOM.value(10, 45);
            ELSIF v_transact.payment_term_id = 3 THEN
                v_random_days_num := DBMS_RANDOM.value(10, 30);
            ELSIF v_transact.payment_term_id = 2 THEN
                v_random_days_num := DBMS_RANDOM.value(1, 14);
            ELSE
                v_random_days_num := DBMS_RANDOM.value(1, 7);
            END IF;
            
            UPDATE transactions
            SET end_time = start_time + v_random_days_num
            WHERE transaction_id = v_transact.transaction_id;
        END LOOP;
        CLOSE c_current_transact;
    END overwrite_end_date_for_finished_transactions;
                
                
    PROCEDURE overwrite_end_date_for_cancelled_transactions
    IS
        CURSOR c_current_transact IS
            SELECT
                 t.transaction_id
                ,t.start_time
                ,t.end_time
                ,i.payment_term_id
            FROM 
                transactions t
                INNER JOIN income_invoices i
                    ON t.transaction_id = i.transaction_id
            WHERE 
                t.status_id = 3;
        
        v_transact    c_current_transact%ROWTYPE;        
        v_days_over   INTEGER;       
    BEGIN            
        OPEN c_current_transact;
        LOOP
            FETCH c_current_transact INTO v_transact;
            EXIT WHEN c_current_transact%NOTFOUND;
            IF v_transact.payment_term_id = 4 THEN
                v_days_over := 46;
            ELSIF v_transact.payment_term_id = 3 THEN
                v_days_over := 31;
            ELSIF v_transact.payment_term_id = 2 THEN
                v_days_over := 15;
            ELSE
                v_days_over := 8;
            END IF;
            
            UPDATE transactions
            SET end_time = start_time + v_days_over
            WHERE transaction_id = v_transact.transaction_id;
        END LOOP;
        CLOSE c_current_transact;            
                
    END overwrite_end_date_for_cancelled_transactions;            
    
BEGIN
    overwrite_end_date_for_finished_transactions();
    overwrite_end_date_for_cancelled_transactions();
END update_transaction_end_time;
/

EXECUTE update_transaction_end_time();

