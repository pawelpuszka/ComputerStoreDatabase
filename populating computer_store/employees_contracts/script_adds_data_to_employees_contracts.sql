SET SERVEROUTPUT ON;

DROP TABLE transform_employees_contracts;
CREATE TABLE transform_employees_contracts(
    contract_id INTEGER GENERATED ALWAYS AS IDENTITY,
    wages       NUMBER(8, 2),
    section_id  SMALLINT,
    position_id SMALLINT,
    hire_date   DATE,
    end_date    DATE
);
SELECT *
FROM transform_employees_contracts
;


CREATE OR REPLACE
PROCEDURE generate_contract_date 
IS
    CURSOR current_contract IS
        SELECT contract_id
        FROM transform_employees_contracts
    ;
    v_start                 DATE := TO_DATE('2015-01-01');
    v_hire_date             DATE;
    v_end_contract_date     DATE;
    v_additional_months     PLS_INTEGER;
    v_contract_id           employees_contracts.contract_id%TYPE;
BEGIN
    OPEN current_contract;
    
    LOOP
        LOOP
            v_additional_months := SYS.dbms_random.value(2, 72);
            v_hire_date := ADD_MONTHS(v_start, v_additional_months);
            v_additional_months := SYS.dbms_random.value(2, 36);
            v_end_contract_date := ADD_MONTHS(SYSDATE, v_additional_months);
            EXIT WHEN v_hire_date < v_end_contract_date - 365;
        END LOOP;
        FETCH current_contract INTO v_contract_id;
        EXIT WHEN current_contract%NOTFOUND;
        UPDATE transform_employees_contracts t
        SET  t.hire_date = v_hire_date
            ,t.end_date = v_end_contract_date
        WHERE t.contract_id = v_contract_id;
        COMMIT;
    END LOOP;
    
    CLOSE current_contract;
END generate_contract_date;
/

BEGIN
    generate_contract_date();
END;
/

INSERT INTO employees_contracts(
     wages       
    ,section_id 
    ,position_id 
    ,hire_date   
    ,end_date    
)
SELECT
     wages       
    ,section_id 
    ,position_id 
    ,hire_date   
    ,end_date 
FROM transform_employees_contracts
;

SELECT *
FROM employees_contracts;