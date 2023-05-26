CREATE OR REPLACE PACKAGE BODY pkg_exception_handling
IS
    PROCEDURE log_exception( in_code            IN NUMBER
                            ,in_message         IN VARCHAR2
                            ,in_object_name     IN VARCHAR2
                            ,in_ex_date         IN DATE )
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO exception_logs(code, message, object_name, ex_date)
        VALUES (in_code, in_message, in_object_name, in_ex_date);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20100, 'There is a problem with exception logging.');
    END log_exception;

END pkg_exception_handling;
/