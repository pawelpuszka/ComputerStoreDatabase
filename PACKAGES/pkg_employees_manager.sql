CREATE OR REPLACE PACKAGE pkg_employees_manager
IS
    TYPE rec_emp_type IS RECORD (
        --section_name        sections.section_name%TYPE
         employee_id        employees.employee_id%TYPE
        ,employee_name      employees.employee_name%TYPE
        ,employee_surname   employees.employee_surname%TYPE
    );
    TYPE nt_emp_type IS TABLE OF rec_emp_type;

    FUNCTION get_emp_with_salary_above_avg(in_section_id IN sections.section_id%type) RETURN nt_emp_type;

    FUNCTION employees_number_in_section RETURN nt_emp_num_type;

END pkg_employees_manager;