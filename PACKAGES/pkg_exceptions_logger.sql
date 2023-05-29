CREATE or REPLACE PACKAGE pkg_exception_handling
IS
    PROCEDURE log_exception( in_code            IN NUMBER
                            ,in_message         IN VARCHAR2
                            ,in_object_name     IN VARCHAR2
                            ,in_ex_date         IN DATE);



END pkg_exception_handling;
/