SET SERVEROUTPUT ON;

DROP PROCEDURE generate_transaction_data;
CREATE OR REPLACE 
PROCEDURE generate_transaction_data 
IS
    TYPE transaction_type IS TABLE OF transactions%ROWTYPE INDEX BY PLS_INTEGER;
    TYPE salesman_id_type IS TABLE OF employees.employee_id%TYPE INDEX BY PLS_INTEGER;
    
    at_transactions             transaction_type;
    at_online_salesmen_id       salesman_id_type;
    at_stationary_salesmen_id   salesman_id_type;
    
    v_delivery_id   transactions.delivery_method_id%TYPE;
    v_payment_id    transactions.payment_method_id%TYPE;
    
    PROCEDURE set_transaction_id(in_id INTEGER) IS
    BEGIN
        at_transactions(in_id).transaction_id := in_id;
    END set_transaction_id;
    
    PROCEDURE set_delivery_id(in_id INTEGER) IS
    BEGIN
        at_transactions(in_id).delivery_method_id := DBMS_RANDOM.value(1, 4);
    END set_delivery_id;
    
    PROCEDURE set_payment_id(in_id INTEGER) IS
    BEGIN
        IF at_transactions(in_id).delivery_method_id = 4 THEN -- 4-if stationary sale 
            at_transactions(in_id).payment_method_id := DBMS_RANDOM.value(1, 3); -- can't pay with bank transfer
        ELSE
            LOOP
                at_transactions(in_id).payment_method_id := DBMS_RANDOM.value(1, 4);
                EXIT WHEN at_transactions(in_id).payment_method_id != 2; -- if not stationary sale then can't pay with cash
            END LOOP;
        END IF;
    END set_payment_id;
    
    PROCEDURE set_employee_id(in_id INTEGER) 
    IS
        v_random_id                 PLS_INTEGER;
        
        PROCEDURE find_salesmen_id IS
        BEGIN
            SELECT e.employee_id
            BULK COLLECT INTO at_online_salesmen_id
            FROM employees e
            INNER JOIN employees_contracts ec
                ON e.contract_id = ec.contract_id
            WHERE ec.position_id = 9 
                AND ec.end_date > SYSDATE
            ;
            SELECT e.employee_id
            BULK COLLECT INTO at_stationary_salesmen_id
            FROM employees e
            INNER JOIN employees_contracts ec
                ON e.contract_id = ec.contract_id
            WHERE ec.position_id = 8
                AND ec.end_date > SYSDATE
            ;
        END find_salesmen_id;
        
        FUNCTION salesmen_found(in_id_a INTEGER) RETURN BOOLEAN IS
        BEGIN
            RETURN in_id_a != 1;
        END;
        
        FUNCTION stationary_sale(in_id_b INTEGER) RETURN BOOLEAN IS
        BEGIN
            RETURN at_transactions(in_id_b).delivery_method_id = 4; -- 4-stationary sale 
        END stationary_sale;
        
    BEGIN
        IF NOT salesmen_found(in_id) THEN
            find_salesmen_id();
        END IF;
        
        IF stationary_sale(in_id) THEN
            v_random_id := DBMS_RANDOM.value(at_stationary_salesmen_id.FIRST, at_stationary_salesmen_id.LAST);
            at_transactions(in_id).employee_id := at_stationary_salesmen_id(v_random_id);
        ELSE
            v_random_id := DBMS_RANDOM.value(at_online_salesmen_id.FIRST, at_online_salesmen_id.LAST);
            at_transactions(in_id).employee_id := at_online_salesmen_id(v_random_id);
        END IF;
    END set_employee_id;
    
    PROCEDURE set_status_id(in_id INTEGER)
    IS
        v_status_id transactions.status_id%TYPE;
        v_random_id INTEGER := 0;
    BEGIN
        IF at_transactions(in_id).delivery_method_id = 4 THEN -- 4-stationary sale
            at_transactions(in_id).status_id := 5;            -- 5-FINISHED
        ELSE
            IF at_transactions(in_id).payment_method_id IN (1, 3) THEN --if paid with card(1) or blik(3)
                LOOP
                    v_random_id := DBMS_RANDOM.value(3, 5);
                    at_transactions(in_id).status_id := v_random_id;
                    EXIT WHEN v_random_id IN (3, 5);
                END LOOP;
            ELSIF at_transactions(in_id).payment_method_id = 4 THEN -- 4-BANK TRANSFER
                LOOP
                    v_random_id := DBMS_RANDOM.value(1, 5);
                    at_transactions(in_id).status_id := v_random_id;
                    EXIT WHEN v_random_id IN (1, 2, 3, 5);
                END LOOP;
            END IF;
        END IF;
    END set_status_id;
    
    
    PROCEDURE generate_dates(in_id INTEGER)
    IS
        v_start_date    TIMESTAMP;
        v_end_date      TIMESTAMP;
        v_rand_days_num INTEGER;
        
        FUNCTION is_stationary_sale(in_id INTEGER) RETURN BOOLEAN IS
        BEGIN
            RETURN at_transactions(in_id).delivery_method_id = 4;
        END is_stationary_sale;
        
        FUNCTION get_emp_hire_date(in_id INTEGER) RETURN employees_contracts.hire_date%TYPE 
        IS
            v_hire_date DATE;
        BEGIN
            SELECT ec.hire_date
            INTO v_hire_date
            FROM employees_contracts ec
                INNER JOIN employees e
                    ON ec.contract_id = e.contract_id
            WHERE e.employee_id = at_transactions(in_id).employee_id
            ;
            RETURN v_hire_date;
        END get_emp_hire_date;
        
        PROCEDURE set_sale_start_date(in_id INTEGER)IS
        BEGIN
            LOOP
                v_rand_days_num := DBMS_RANDOM.value(10, 2500);
                v_start_date := CAST((get_emp_hire_date(in_id) + v_rand_days_num) AS TIMESTAMP);
                EXIT WHEN v_start_date < CAST(TO_DATE(SYSDATE - 1, 'YYYY/MM/DD') AS TIMESTAMP);
            END LOOP;
            at_transactions(in_id).start_time := v_start_date;
        END set_sale_start_date;
        
        PROCEDURE set_stationary_sale_end_date(in_id INTEGER) IS
        BEGIN
            v_end_date := v_start_date + DBMS_RANDOM.value(((1/24) * (1/60)),((1/24) * (1/6))); -- PERIOD OF TIME 1 minute - 10 minutes 
            at_transactions(in_id).end_time := v_end_date;
        END set_stationary_sale_end_date;
        
        PROCEDURE set_online_sale_dates(in_id INTEGER) 
        IS
            PROCEDURE set_new_transaction_start_date(in_id INTEGER) IS
            BEGIN
                at_transactions(in_id).start_time := SYSDATE - 1;
            END set_new_transaction_start_date;
            
            PROCEDURE set_pending_transaction_start_date(in_id INTEGER) IS
            BEGIN
                v_rand_days_num := DBMS_RANDOM.value(1, 20);
                at_transactions(in_id).start_time := SYSDATE - v_rand_days_num;
            END set_pending_transaction_start_date;
            
            PROCEDURE set_just_started_transaction_end_date(in_id INTEGER) IS
            BEGIN
                at_transactions(in_id).end_time := NULL;
            END set_just_started_transaction_end_date;
            
            PROCEDURE set_cancelled_transaction_start_date(in_id INTEGER) IS
            BEGIN
                LOOP
                    v_rand_days_num := DBMS_RANDOM.value(31, 2000);
                    v_start_date := SYSDATE - v_rand_days_num;
                    EXIT WHEN get_emp_hire_date(in_id) + 5 < v_start_date;
                END LOOP;
                at_transactions(in_id).start_time := v_start_date;
            END set_cancelled_transaction_start_date;
            
            PROCEDURE set_cancelled_transaction_end_date(in_id INTEGER) IS
            BEGIN
                at_transactions(in_id).end_time := at_transactions(in_id).start_time + 31;
            END set_cancelled_transaction_end_date;
            
            PROCEDURE set_finished_transaction_start_date(in_id INTEGER) IS
            BEGIN
                set_sale_start_date(in_id);
            END set_finished_transaction_start_date;
            
            PROCEDURE set_finished_trans_card_blik_end_date(in_id INTEGER) IS
            BEGIN
                v_rand_days_num := DBMS_RANDOM.value(((1/24) * (1/60)),((1/24) * (1/6)));
                at_transactions(in_id).end_time := at_transactions(in_id).start_time + v_rand_days_num;
            END set_finished_trans_card_blik_end_date;
            
            PROCEDURE set_finished_trans_transfer_end_date(in_id INTEGER) IS
            BEGIN
                v_rand_days_num := DBMS_RANDOM.value(1, 30);
                at_transactions(in_id).end_time := at_transactions(in_id).start_time + v_rand_days_num;
            END set_finished_trans_transfer_end_date;
            
        BEGIN
            IF at_transactions(in_id).status_id = 1 THEN -- 1-new (status_id)
                set_new_transaction_start_date(in_id);
                set_just_started_transaction_end_date(in_id);
            ELSE
                IF at_transactions(in_id).status_id = 2 THEN -- 2-PENDING (status_id)
                    set_pending_transaction_start_date(in_id);
                    set_just_started_transaction_end_date(in_id);
                ELSIF at_transactions(in_id).status_id = 3 THEN -- 3-cancelled (status_id)
                    set_cancelled_transaction_start_date(in_id);
                    set_cancelled_transaction_end_date(in_id);
                ELSIF at_transactions(in_id).status_id = 5 THEN -- 5-finished (status_id)
                    set_finished_transaction_start_date(in_id);
                    IF at_transactions(in_id).payment_method_id IN (1, 3) THEN
                        set_finished_trans_card_blik_end_date(in_id);
                    ELSE
                        set_finished_trans_transfer_end_date(in_id);
                    END IF;
                END IF;
            END IF;
        END;
        
    BEGIN
        IF is_stationary_sale(in_id) THEN
            set_sale_start_date(in_id);
            set_stationary_sale_end_date(in_id);
        ELSE
            set_online_sale_dates(in_id);
        END IF;
        --dbms_output.put_line(get_hire_date(in_id) || ', ' || TO_CHAR(at_transactions(in_id).start_time, 'YYYY/MM/DD HH24:MI:SS') || ', ' || TO_CHAR(at_transactions(in_id).end_time, 'YYYY/MM/DD HH24:MI:SS'));
    END generate_dates;
    
    PROCEDURE copy_data_into_transactions_tab IS
    BEGIN
        FORALL trnscts IN at_transactions.FIRST..at_transactions.LAST
            INSERT INTO transactions(
                 employee_id
                ,payment_method_id
                ,delivery_method_id
                ,status_id
                ,start_time
                ,end_time
            )
            VALUES(
                 at_transactions(trnscts).employee_id
                ,at_transactions(trnscts).payment_method_id
                ,at_transactions(trnscts).delivery_method_id
                ,at_transactions(trnscts).status_id
                ,at_transactions(trnscts).start_time
                ,at_transactions(trnscts).end_time
            );
    END copy_data_into_transactions_tab;
    
BEGIN
    FOR next_id IN 1..2000
    LOOP
        set_transaction_id(next_id);
        set_delivery_id(next_id);
        set_payment_id(next_id);
        set_employee_id(next_id);
        set_status_id(next_id);
        generate_dates(next_id);
        dbms_output.put_line('transaction_id: ' || at_transactions(next_id).transaction_id || 
                             ', payment_id ' || at_transactions(next_id).payment_method_id || 
                             ', delivery_id: ' || at_transactions(next_id).delivery_method_id || 
                             ', employee_id: ' || at_transactions(next_id).employee_id ||
                             ', STATUS_ID: ' || at_transactions(next_id).status_id ||
                             ', start_date ' || at_transactions(next_id).start_time ||
                             ', end_date ' || at_transactions(next_id).end_time);
    END LOOP;
    copy_data_into_transactions_tab();
END generate_transaction_data;
/

BEGIN
    generate_transaction_data();
END;
/

SELECT *
FROM transactions
where rownum < 100;