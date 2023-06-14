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


    PROCEDURE add_employee(  in_name          IN EMPLOYEES.EMPLOYEE_NAME%TYPE
                            ,in_surname       IN EMPLOYEES.EMPLOYEE_SURNAME%TYPE
                            ,in_pesel         IN EMPLOYEES.PESEL%TYPE
                            ,in_email         IN EMPLOYEES.EMAIL%TYPE
                            ,in_wages         IN EMPLOYEES_CONTRACTS.WAGES%TYPE
                            ,in_position_id   IN EMPLOYEES_CONTRACTS.POSITION_ID%TYPE
                            ,in_street        IN ADDRESSES.STREET%TYPE
                            ,in_city          IN ADDRESSES.CITY%TYPE
                            ,in_postal_code   IN ADDRESSES.POSTAL_CODE%TYPE
                            ,in_phone_no      IN ADDRESSES.PHONE_NUMBER%TYPE);


    PROCEDURE update_employee_data(  in_employee_id IN EMPLOYEES.employee_id%TYPE
                                    ,in_email         IN EMPLOYEES.EMAIL%TYPE DEFAULT NULL
                                    ,in_wages         IN EMPLOYEES_CONTRACTS.WAGES%TYPE DEFAULT NULL
                                    ,in_position_id   IN EMPLOYEES_CONTRACTS.POSITION_ID%TYPE DEFAULT NULL
                                    ,in_end_date      IN employees_contracts.hire_date%type DEFAULT NULL
                                    ,in_street        IN ADDRESSES.STREET%TYPE DEFAULT NULL
                                    ,in_city          IN ADDRESSES.CITY%TYPE DEFAULT NULL
                                    ,in_postal_code   IN ADDRESSES.POSTAL_CODE%TYPE DEFAULT NULL
                                    ,in_phone_no      IN ADDRESSES.PHONE_NUMBER%TYPE DEFAULT NULL);

END pkg_employees_manager;