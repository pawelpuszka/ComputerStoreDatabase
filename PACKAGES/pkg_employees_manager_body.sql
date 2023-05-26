CREATE OR REPLACE PACKAGE BODY pkg_employees_manager
IS

    FUNCTION employees_number_in_section RETURN nt_emp_num_type
    IS
        emp_num_nt nt_emp_num_type := nt_emp_num_type();
    BEGIN
        SELECT
            REC_EMP_NUM_TYPE(count(*), s.section_name)
        BULK COLLECT INTO
            emp_num_nt
        FROM
            employees e
                JOIN employees_contracts ec ON e.contract_id = ec.contract_id
                JOIN sections s ON s.section_id = ec.section_id
        GROUP BY
            s.section_name
        ;
        RETURN emp_num_nt;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE ;
    END employees_number_in_section;



    FUNCTION get_emp_with_salary_above_avg(in_section_id IN sections.section_id%type) RETURN nt_emp_type
    IS
        ex_value_error  EXCEPTION;
        PRAGMA EXCEPTION_INIT ( ex_value_error,  -06502);
        nt_employees    nt_emp_type := nt_emp_type();
    BEGIN
        SELECT
             employee_id
            ,employee_name
            ,employee_surname
        BULK COLLECT INTO nt_employees
        FROM employees e
            JOIN employees_contracts ec ON e.contract_id = ec.contract_id
        WHERE ec.wages > (SELECT avg(ec2.wages) FROM employees_contracts ec2
                            WHERE ec2.section_id = ec.section_id
                            GROUP BY ec2.section_id)
            AND ec.section_id = in_section_id
        ;
        --w tym miejscu pokombinować z EXISTS
        IF (nt_employees.exists(1)) then
            dbms_output.PUT_LINE('jesr ok');
        else
            dbms_output.PUT_LINE('pusto');
        END IF;
        RETURN nt_employees;

    EXCEPTION
        --WHEN ex_value_error THEN
            --RAISE_APPLICATION_ERROR(-20010, 'Section with ID ' || in_section_id || ' does not exist.');
        WHEN OTHERS THEN
            --sprawdzić czy tutaj da radę zalogować jakiś wyjątek w przypadku gdy kolekcja jest pusta
            RAISE ;
    END get_emp_with_salary_above_avg;

END pkg_employees_manager;