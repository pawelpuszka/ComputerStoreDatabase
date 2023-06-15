/*
    The main purpose of this package is to provide a help while developing features for Computer_Store database.
    ver.: 1.0
    author: Pawe³ Puszka
    contact: pawel.puszka@gmail.com
    
    ChangeLog
        6.09.2022
        get_payment_term_id - utility fixes badly designed connection between  CLIENT_LOYALTY_CARDS and PAYMENT_TERMS tables. While creating new invoice there is payment_term_id needed based 
                                         on customer's loyalty_card_id. It can't be connected through SQL statement because  payment_term_id doesn't exist yet in INCOME_INVOICES table.
*/

CREATE OR REPLACE
PACKAGE computer_store_db_utils 
IS
    FUNCTION get_payment_term_id(loy_card_id_in wholesale_clients.loyalty_card_id%TYPE) RETURN payment_terms.payment_term_id%TYPE;

    PROCEDURE update_outdated_contracts(in_months IN NUMBER);
END  computer_store_db_utils;
/


CREATE OR REPLACE
PACKAGE BODY computer_store_db_utils 
IS
    v_object_name VARCHAR2(200);

    --should be moved to package orders_service
    FUNCTION get_payment_term_id(loy_card_id_in wholesale_clients.loyalty_card_id%TYPE) RETURN payment_terms.payment_term_id%TYPE
    IS
        paymnt_term_id payment_terms.payment_term_id%TYPE;
    BEGIN
        CASE loy_card_id_in
             WHEN 1 THEN paymnt_term_id := 4;
             WHEN 2 THEN paymnt_term_id := 3;
             WHEN 3 THEN paymnt_term_id := 2;
             ELSE paymnt_term_id := 1;
        END CASE;
        RETURN	paymnt_term_id;
    END get_payment_term_id;


    PROCEDURE update_outdated_contracts(in_months IN NUMBER)
    IS
        CURSOR cur_outdated_contracts_emps IS
            SELECT
                vw.employee_id
                ,vw.remaining_time_to_terminate
            FROM
                vw_employees_with_expiring_contract vw
            WHERE
                remaining_time_to_terminate < 0;

        TYPE nt_emps_outdt_contr_type IS TABLE OF cur_outdated_contracts_emps%ROWTYPE;
        v_emps_outdt_contr_nt nt_emps_outdt_contr_type;

    BEGIN
        v_object_name := 'computer_store_db_utils.update_outdated_contracts';

        FOR emp IN cur_outdated_contracts_emps
        LOOP
            BEGIN
                UPDATE employees_contracts
                SET end_date = add_months(end_date + abs(emp.remaining_time_to_terminate), in_months)
                WHERE contract_id = (SELECT e.contract_id FROM employees e WHERE e.employee_id = emp.employee_id)
                ;
                COMMIT;
            END;
        END LOOP;

        --COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            IF cur_outdated_contracts_emps%ISOPEN THEN
                CLOSE cur_outdated_contracts_emps;
            END IF;
            pkg_exception_handling.LOG_EXCEPTION(sqlcode
                                                ,sqlerrm
                                                ,v_object_name
                                                ,sysdate);
            ROLLBACK;
            RAISE;
    END update_outdated_contracts;
    
END  computer_store_db_utils;
/