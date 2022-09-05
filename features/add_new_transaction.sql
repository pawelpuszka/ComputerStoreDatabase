/*
    File contains the package for creating the entire process of purchasing products in the store.
    Procedures from that package provide an interface to the client application.
    
    file ver.: 1.0 
    author: Pawe³ Puszka
    
    ChangeLog
        20.08.2022 
        - package specification and body created
        - procedure start_new_transaction
        5.09.2022
        - improving exception handling in procedure start_new_transaction - now all exceptions have to be handled by client app 
    
*/


CREATE OR REPLACE
PACKAGE transaction_pkg IS
    PROCEDURE start_new_transaction(employee_id_in          transactions.employee_id%TYPE 
                                   ,payment_method_id_in    transactions.payment_method_id%TYPE
                                   ,delivery_method_id_in   transactions.delivery_method_id%TYPE
                                   );
    PROCEDURE create_products_list;
    PROCEDURE finish_transaction;
END transaction_pkg;
/

CREATE OR REPLACE
PACKAGE BODY transaction_pkg IS

constraint_violation_ex         EXCEPTION;
    PRAGMA EXCEPTION_INIT(constraint_violation_ex, -02291);
    insert_null_ex              EXCEPTION;
    PRAGMA EXCEPTION_INIT(insert_null_ex, -01400);
    incorrect_transact_ex       EXCEPTION;
    PRAGMA EXCEPTION_INIT(incorrect_transact_ex, -20012);
    online_seller_needed_ex     EXCEPTION;
    PRAGMA EXCEPTION_INIT(online_seller_needed_ex, -20010);
    stationary_seller_needed_ex EXCEPTION;
    PRAGMA EXCEPTION_INIT(stationary_seller_needed_ex, -20011);
    
    v_transact_id           transactions.transaction_id%TYPE;
 

    PROCEDURE start_new_transaction(employee_id_in          transactions.employee_id%TYPE 
                                   ,payment_method_id_in    transactions.payment_method_id%TYPE
                                   ,delivery_method_id_in   transactions.delivery_method_id%TYPE
                                   )
    IS
        stationary_sale     CONSTANT INTEGER := 4;
        cash_payment        CONSTANT INTEGER := 2;
        transfer_payment    CONSTANT INTEGER := 4;
        online_seller       CONSTANT INTEGER := 9;        
    
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
                INNER JOIN employees e 
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
            RETURNING transaction_id INTO v_transact_id;
            COMMIT;
            DBMS_OUTPUT.put_line('Transakcja rozpoczêta.' || v_transact_id);
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
            RAISE_APPLICATION_ERROR(-20012, 'Nie mo¿na ustanowic takiej transakcji. B³êdny sposób dostawy lub p³atnoœci.');
        WHEN online_seller_needed_ex THEN
            RAISE_APPLICATION_ERROR(-20010, 'Wybierz odpowiedniego sprzedawcê. Transakcja online.');
        WHEN stationary_seller_needed_ex THEN
            RAISE_APPLICATION_ERROR(-20011, 'Wybierz odpowiedniego sprzedawcê. Transakcja w sklepie stacjonarnym.');
        WHEN OTHERS	THEN	
            RAISE;
        
    END start_new_transaction;
    
    
    PROCEDURE generate_invoice (client_id_in INCOME_INVOICES.WHOLESALE_CLIENT_ID%TYPE)
    IS
        PROCEDURE generate_invoice_number IS
        BEGIN
            NULL;
        END;
        
    BEGIN
        NULL;
    END	generate_invoice;
    
    --PROCEDURE get_product
    
    PROCEDURE create_products_list IS
    BEGIN
        NULL;
    END create_products_list;
    
END transaction_pkg;
/

BEGIN
transaction_pkg.start_new_transaction(employee_id_in           => 17
                                     ,payment_method_id_in     => 4
                                     ,delivery_method_id_in    => 4
                                     );
END;
/

