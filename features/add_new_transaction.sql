/*
    file contains the package for creating the entire process of purchasing products in the store.
    procedures from that package provide an interface to the client application.
    
    file ver.: 1.0 
    author: Pawe³ Puszka
    contact: pawel.puszka@gmail.com
    
    changelog
        20.08.2022 
        - package specification and body created
        - procedure start_new_transaction
        5.09.2022
        - improving exception handling in procedure start_new_transaction - now all exceptions have to be handled by calling program
        - start of generate_invoice procedure development
        6.09.2022
        - generate_invoice_number - procedure generates invoice number based on given data from transaction table
        - get_payment_term - function returns  id of payment term based on client_id
        - generate_invoice procedure body implemented 
         
    
*/


CREATE OR REPLACE
PACKAGE transaction_pkg IS
PROCEDURE start_new_transaction(employee_id_in              transactions.employee_id%TYPE 
                                                ,payment_method_id_in   transactions.payment_method_id%TYPE
                                                ,delivery_method_id_in   	transactions.delivery_method_id%TYPE
                                                );
    PROCEDURE create_products_list;
    
END transaction_pkg;
/

CREATE OR REPLACE
PACKAGE BODY transaction_pkg 
IS
    constraint_violation_ex         	EXCEPTION;
    pragma exception_init(constraint_violation_ex, -02291);
    insert_null_ex              			EXCEPTION;
    pragma exception_init(insert_null_ex, -01400);
    incorrect_transact_ex       		EXCEPTION;
    pragma exception_init(incorrect_transact_ex, -20012);
    online_seller_needed_ex    		EXCEPTION;
    pragma exception_init(online_seller_needed_ex, -20010);
    stationary_seller_needed_ex 	EXCEPTION;
    pragma exception_init(stationary_seller_needed_ex, -20011);
    
    v_curr_transact_rec transactions%ROWTYPE;
 

   PROCEDURE start_new_transaction(employee_id_in               transactions.employee_id%TYPE 
                                                    ,payment_method_id_in   transactions.payment_method_id%TYPE
                                                    ,delivery_method_id_in   	transactions.delivery_method_id%TYPE
                                                    )
    IS
        stationary_sale     	CONSTANT integer := 4;
        cash_payment        	CONSTANT integer := 2;
        transfer_payment    CONSTANT integer := 4;
        online_seller       		CONSTANT integer := 9;        
    
        FUNCTION is_online_transaction(delivery_method_id_in    transactions.delivery_method_id%TYPE
                                                  ,payment_method_id_in     transactions.payment_method_id%TYPE 
                                                   ) RETURN BOOLEAN IS
        BEGIN
            RETURN delivery_method_id_in != stationary_sale AND payment_method_id_in != cash_payment;
        END is_online_transaction;
        
        FUNCTION is_stationary_transaction(delivery_method_id_in    transactions.delivery_method_id%TYPE
                                                          ,payment_method_id_in     transactions.payment_method_id%TYPE 
                                                           ) RETURN BOOLEAN IS
        BEGIN
            RETURN delivery_method_id_in = stationary_sale AND payment_method_id_in != transfer_payment;
        END is_stationary_transaction;

        FUNCTION is_online_seller(employee_id_in transactions.employee_id%TYPE) RETURN BOOLEAN 
        IS
            v_position_id employees_contracts.position_id%TYPE;
        BEGIN
            SELECT position_id
            INTO v_position_id
            FROM employees_contracts ec
                INNER JOIN employees E 
                    ON  ec.contract_id = e.contract_id
            WHERE e.employee_id = employee_id_in
            ;
            
            RETURN  v_position_id = online_seller;
        END is_online_seller;
                
        PROCEDURE insert_transaction_data(employee_id_in          transactions.employee_id%TYPE 
                                                            ,payment_method_id_in    transactions.payment_method_id%TYPE
                                                            ,delivery_method_id_in   transactions.delivery_method_id%TYPE
                                                            ) IS
        BEGIN
            INSERT INTO transactions(employee_id, payment_method_id, delivery_method_id, status_id, start_time)
            VALUES(employee_id_in, payment_method_id_in, delivery_method_id_in, 1, SYSTIMESTAMP)
            RETURNING transaction_id, employee_id_in, payment_method_id, delivery_method_id, status_id, start_time, end_time INTO v_curr_transact_rec;
            COMMIT;
            dbms_output.put_line('transakcja rozpoczêta ' || v_curr_transact_rec.transaction_id);
        END insert_transaction_data;
                
    BEGIN
        IF is_online_transaction(delivery_method_id_in, payment_method_id_in) THEN
            IF is_online_seller(employee_id_in) THEN
                insert_transaction_data(employee_id_in, payment_method_id_in, delivery_method_id_in);
            ELSE
                RAISE online_seller_needed_ex;
            END IF;
        ELSIF is_stationary_transaction(delivery_method_id_in, payment_method_id_in) THEN
            IF NOT is_online_seller(employee_id_in) THEN
                insert_transaction_data(employee_id_in, payment_method_id_in, delivery_method_id_in);
            ELSE
                RAISE stationary_seller_needed_ex;
            END IF;
        ELSE
            RAISE incorrect_transact_ex;
        END IF;
 
    EXCEPTION
        WHEN constraint_violation_ex THEN
            ROLLBACK;
            RAISE;	
        WHEN insert_null_ex THEN
            ROLLBACK;
            RAISE;
        WHEN incorrect_transact_ex THEN
            raise_application_error(-20012, 'nie mo¿na ustanowic takiej transakcji. b³êdny sposób dostawy lub p³atnoœci.');
        WHEN online_seller_needed_ex THEN
            raise_application_error(-20010, 'wybierz odpowiedniego sprzedawcê. transakcja online.');
        WHEN stationary_seller_needed_ex THEN
            raise_application_error(-20011, 'wybierz odpowiedniego sprzedawcê. transakcja w sklepie stacjonarnym.');
        WHEN others	THEN	
            RAISE;
        
    END start_new_transaction;
    
    
    PROCEDURE generate_invoice(client_id_in income_invoices.wholesale_client_id%TYPE)
    IS
        v_invoice_number income_invoices.income_invoice_no%TYPE;
        v_payment_term   income_invoices.payment_term_id%TYPE;
        
        FUNCTION generate_invoice_number(client_id_in income_invoices.wholesale_client_id%TYPE) RETURN income_invoices.income_invoice_no%TYPE
        IS
            v_invoice_no    NVARCHAR2(40);
            v_transact_no   VARCHAR2(10);
            v_month_no      VARCHAR2(10);
            v_year_no       VARCHAR2(10);
            v_client_id     VARCHAR2(10);
        BEGIN
            v_transact_no := TO_CHAR(v_curr_transact_rec.transaction_id, '999999'); 
            v_month_no := TO_CHAR(EXTRACT(MONTH FROM v_curr_transact_rec.start_time), '99'); 
            v_year_no := TO_CHAR(EXTRACT(YEAR FROM v_curr_transact_rec.start_time), '9999');
            v_client_id := TO_CHAR(client_id_in, '999');
            v_invoice_no := 'FV/' || v_transact_no || '/' || v_month_no || '/' || v_year_no || '/' || v_client_id;
            v_invoice_no := REPLACE(v_invoice_no, ' ', '');
            
            RETURN v_invoice_no;
        END generate_invoice_number;
        
        FUNCTION get_payment_term(client_id_in income_invoices.wholesale_client_id%TYPE) RETURN income_invoices.payment_term_id%TYPE 
        IS
            v_loyalty_card_id clients_loyalty_cards.loyalty_card_id%TYPE;
        BEGIN
            SELECT loyalty_card_id
            INTO v_loyalty_card_id
            FROM wholesale_clients
            WHERE wholesale_client_id = client_id_in
            ;
            RETURN computer_store_db_utils.get_payment_term_id(v_loyalty_card_id);               
        END get_payment_term;
        
    BEGIN
        v_invoice_number := generate_invoice_number(client_id_in);
        v_payment_term := get_payment_term(client_id_in);
        INSERT INTO income_invoices (income_invoice_no, wholesale_client_id, transaction_id, payment_term_id)
        VALUES (v_invoice_number, client_id_in, v_curr_transact_rec.transaction_id, v_payment_term);
        COMMIT;
        
    EXCEPTION --next to impementation
        WHEN OTHERS THEN
             NULL;
    
    END	generate_invoice;
    
    --procedure get_product
    
    PROCEDURE create_products_list IS
    BEGIN
        NULL;
    END create_products_list;
    
END transaction_pkg;
/

BEGIN
transaction_pkg.start_new_transaction(employee_id_in   => 17
                                     ,payment_method_id_in     => 1
                                     ,delivery_method_id_in    => 1
                                     );
END;
/

