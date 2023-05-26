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
        nt_employees    nt_emp_type := nt_emp_type();
        first_index     CONSTANT PLS_INTEGER := 1;
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
            AND ec.section_id = in_section_id;

        IF (NOT nt_employees.exists(first_index)) THEN
            RAISE_APPLICATION_ERROR(-20010, 'There are no employees with salary above average in section ' || in_section_id );
        END IF;

        RETURN nt_employees;

    EXCEPTION
        WHEN OTHERS THEN
            pkg_exception_handling.LOG_EXCEPTION(sqlcode
                                                ,sqlerrm
                                                ,'pkg_employees_manager.get_emp_with_salary_above_avg'
                                                ,sysdate);
            RAISE ;
    END get_emp_with_salary_above_avg;


END pkg_employees_manager;