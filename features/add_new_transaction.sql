SET SERVEROUTPUT ON;

CREATE OR REPLACE
PACKAGE transaction_pkg IS
    PROCEDURE start_new_transaction(employee_id_in          transactions.employee_id%TYPE 
                                   ,payment_method_id_in    transactions.payment_method_id%TYPE
                                   ,delivery_method_id_in   transactions.delivery_method_id%TYPE
                                   );
END transaction_pkg;
/

CREATE OR REPLACE
PACKAGE BODY transaction_pkg IS

    constraint_violation_ex EXCEPTION;
    insert_null_ex          EXCEPTION;
    PRAGMA EXCEPTION_INIT(constraint_violation_ex, -02291);
    PRAGMA EXCEPTION_INIT(insert_null_ex, -01400);
        

    PROCEDURE start_new_transaction(employee_id_in          transactions.employee_id%TYPE 
                                   ,payment_method_id_in    transactions.payment_method_id%TYPE
                                   ,delivery_method_id_in   transactions.delivery_method_id%TYPE
                                   )
    IS
        FUNCTION is_online_transaction
    
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
            RETURN  v_position_id = 9; -- 9-online seller
        END is_online_seller;
        
        
    BEGIN
        INSERT INTO transactions(employee_id, payment_method_id, delivery_method_id, status_id, start_time)
        VALUES(employee_id_in, payment_method_id_in, delivery_method_id_in, 1, SYSTIMESTAMP);
        COMMIT;
        
    EXCEPTION
        WHEN constraint_violation_ex THEN
            DBMS_OUTPUT.put_line('Naruszono wiêzy integralnoœci.');
        WHEN insert_null_ex THEN
            DBMS_OUTPUT.put_line('WartoœcTRANSACTIONS TRANSACTION_STATUSES STATUS_NAME  nie mo¿e by pusta.');
        
    END start_new_transaction;
    
END transaction_pkg;
/

EXEC transaction_pkg.start_new_transaction(5, null, 70);

