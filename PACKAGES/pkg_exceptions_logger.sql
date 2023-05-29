CREATE or REPLACE PACKAGE pkg_exception_handling
IS
    PROCEDURE log_exception( in_code            IN NUMBER
                            ,in_message         IN VARCHAR2
                            ,in_object_name     IN VARCHAR2
                            ,in_ex_date         IN DATE);

    PROCEDURE add_employee(  in_name          IN EMPLOYEES.EMPLOYEE_NAME%TYPE
                            ,in_surname       IN EMPLOYEES.EMPLOYEE_SURNAME%TYPE
                            ,in_pesel         IN EMPLOYEES.PESEL%TYPE
                            ,in_email         IN EMPLOYEES.EMAIL%TYPE
                            ,in_wages         IN EMPLOYEES_CONTRACTS.WAGES%TYPE
                                --,in_section_id    IN EMPLOYEES_CONTRACTS.SECTION_ID%TYPE
                            ,in_position_id   IN EMPLOYEES_CONTRACTS.POSITION_ID%TYPE
                            ,in_street        IN ADDRESSES.STREET%TYPE
                            ,in_city          IN ADDRESSES.CITY%TYPE
                            ,in_postal_code   IN ADDRESSES.POSTAL_CODE%TYPE
                            ,in_phone_no      IN ADDRESSES.PHONE_NUMBER%TYPE);

END pkg_exception_handling;
/