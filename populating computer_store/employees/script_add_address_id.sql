SET SERVEROUTPUT ON;

SELECT * FROM addresses;

DECLARE
    CURSOR current_employee(v_emp_id employees.employee_id%TYPE) IS
        SELECT address_id
        FROM addresses
        WHERE address_id > v_emp_id
    ;
    v_addr_id employees.address_id%TYPE;
BEGIN
    OPEN current_employee(50);
    
    LOOP
        FETCH current_employee INTO v_addr_id;
        EXIT WHEN current_employee%NOTFOUND;
        UPDATE employees
        SET address_id = v_addr_id
        WHERE employee_id = v_addr_id - 50;
        COMMIT;
        --dbms_output.put_line(v_addr_id - 50);
    END LOOP;
    
    CLOSE current_employee;
END;
/

DECLARE
    CURSOR current_employee(v_emp_id employees.employee_id%TYPE) IS
        SELECT address_id
        FROM addresses
        WHERE address_id <= v_emp_id
    ;
    v_addr_id employees.address_id%TYPE;
BEGIN
    OPEN current_employee(50);
    
    LOOP
        FETCH current_employee INTO v_addr_id;
        EXIT WHEN current_employee%NOTFOUND;
        UPDATE employees
        SET address_id = v_addr_id
        WHERE 
            employee_id BETWEEN 13 AND 35
            AND
            employee_id - 12 = v_addr_id ;
        COMMIT;
       -- dbms_output.put_line(v_addr_id || ', ' || employee_id - 12);
    END LOOP;
    
    CLOSE current_employee;
END;
/

UPDATE employees
SET address_id = 4
WHERE employee_id = 36
;