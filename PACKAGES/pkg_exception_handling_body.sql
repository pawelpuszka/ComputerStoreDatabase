CREATE OR REPLACE PACKAGE BODY pkg_exception_handling
IS
    PROCEDURE log_exception( code           NUMBER
                            ,message        VARCHAR2(4000)
                            ,object_name    VARCHAR2(200)
                            ,ex_date        DATE )
    IS

    BEGIN
        INSERT INTO
    END log_exception;

END pkg_exception_handling;