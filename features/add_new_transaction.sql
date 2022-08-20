SET SERVEROUTPUT ON;

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

    constraint_violation_ex EXCEPTION;
    PRAGMA EXCEPTION_INIT(constraint_violation_ex, -02291);
    insert_null_ex          EXCEPTION;
    PRAGMA EXCEPTION_INIT(insert_null_ex, -01400);
    incorrect_transact_ex   EXCEPTION;
    PRAGMA EXCEPTION_INIT(incorrect_transact_ex, -20011);
    incorrect_seller_ex     EXCEPTION;
    PRAGMA EXCEPTION_INIT(incorrect_seller_ex, -20010);
 

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
            VALUES(employee_id_in, payment_method_id_in, delivery_method_id_in, 1, SYSTIMESTAMP);
            -- potrzebny jest transaction_id aby wykonac kolejne operacje
            COMMIT;
            DBMS_OUTPUT.put_line('Transakcja rozpoczêta.');
        END insert_transaction_data;
                
    BEGIN
        IF is_online_transaction(delivery_method_id_in, payment_method_id_in) THEN
            IF is_online_seller(employee_id_in) THEN
                insert_transaction_data(employee_id_in, payment_method_id_in, delivery_method_id_in);
            ELSE
                RAISE_APPLICATION_ERROR(-20010, 'Wybierz odpowiedniego sprzedawcê. Transakcja online.');
            END IF;
        ELSIF is_stationary_transaction(delivery_method_id_in, payment_method_id_in) THEN
            IF NOT is_online_seller(employee_id_in) THEN
                insert_transaction_data(employee_id_in, payment_method_id_in, delivery_method_id_in);
            ELSE
                RAISE_APPLICATION_ERROR(-20010, 'Wybierz odpowiedniego sprzedawcê. Transakcja w sklepie stacjonarnym.');
            END IF;
        ELSE
            RAISE incorrect_transact_ex;
        END IF;
 
    EXCEPTION
        WHEN constraint_violation_ex THEN
            DBMS_OUTPUT.put_line('System nie posiada takich danych.');
            ROLLBACK;
        WHEN insert_null_ex THEN
            ROLLBACK;
            DBMS_OUTPUT.put_line('Wartoœc nie mo¿e by pusta.');
        WHEN incorrect_transact_ex THEN
            DBMS_OUTPUT.put_line('Nie mo¿na ustanowic takiej transakcji.');
        WHEN incorrect_seller_ex THEN
            DBMS_OUTPUT.put_line(sqlerrm);
        
    END start_new_transaction;
    
END transaction_pkg;
/

BEGIN
transaction_pkg.start_new_transaction(employee_id_in           => 7
                                     ,payment_method_id_in     => 3
                                     ,delivery_method_id_in    => 2
                                     );
END;
/

