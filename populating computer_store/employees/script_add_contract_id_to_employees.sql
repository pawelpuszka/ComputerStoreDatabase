SET SERVEROUTPUT ON;

DROP TABLE employees_copy;
CREATE TABLE employees_copy
AS
(SELECT * FROM employees)
;

SELECT *
FROM employees;

DROP PROCEDURE fill_emp_table_with_contract_id;
CREATE OR REPLACE
PROCEDURE fill_emp_table_with_contract_id
IS
    CURSOR curr_emp_id IS
        SELECT employee_id
        FROM employees
    ;
    
    TYPE at_contract_id_type IS TABLE OF employees_contracts.contract_id%TYPE INDEX BY PLS_INTEGER;
    at_contract_ids at_contract_id_type;
    
    v_random_id     employees.contract_id%TYPE;
    v_emp_id        employees.employee_id%TYPE;
    v_rowcount      BOOLEAN;
BEGIN
    SELECT contract_id
    BULK COLLECT INTO at_contract_ids
    FROM employees_contracts
    ;
    OPEN curr_emp_id;
    LOOP
        FETCH curr_emp_id INTO v_emp_id;
                EXIT WHEN curr_emp_id%NOTFOUND;
                
        FOR curr_contract_id IN at_contract_ids.FIRST..at_contract_ids.LAST
        LOOP
        
            LOOP
                v_random_id := dbms_random.value(at_contract_ids.FIRST, at_contract_ids.LAST);
                UPDATE employees
                SET contract_id = v_random_id
                WHERE 
                    employee_id = v_emp_id
                    AND
                    v_random_id NOT IN (SELECT contract_id
                                        FROM employees
                                        WHERE contract_id IS NOT NULL
                                        );
                v_rowcount := sql%NOTFOUND;
                
                COMMIT;
                EXIT WHEN v_rowcount;
            END LOOP;
            
        END LOOP;
    END LOOP;
    CLOSE curr_emp_id;
END;
/

BEGIN
    fill_emp_table_with_contract_id();
END;
/

SELECT employee_id, contract_id, COUNT(*)
FROM employees
GROUP BY employee_id, contract_id
ORDER BY  contract_id;