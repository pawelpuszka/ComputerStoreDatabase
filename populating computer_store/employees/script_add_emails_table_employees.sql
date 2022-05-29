SET SERVEROUTPUT ON;

SELECT * 
FROM employees;

DELETE employees
WHERE employee_id > 16;

UPDATE employees
SET pesel = 68061307445
WHERE employee_id = 15;

DROP TABLE emails;
CREATE TABLE emails (
     email_id   INTEGER GENERATED ALWAYS AS IDENTITY
    ,email      VARCHAR2(100)
);

DECLARE
    CURSOR email IS
        SELECT *
        FROM emails
    ;
    v_email emails%ROWTYPE;
BEGIN
    OPEN email;
    LOOP
        FETCH email INTO v_email;
        EXIT WHEN email%NOTFOUND;
        UPDATE employees e
        SET e.email = v_email.email
        WHERE e.employee_id = v_email.email_id + 16;
        COMMIT;
        --dbms_output.put_line(v_email.email_id + 16 || ', ' || v_email.email);
    END LOOP;
    CLOSE email;
END;
/

DECLARE
    CURSOR email IS
        SELECT *
        FROM emails
    ;
    v_email emails%ROWTYPE;
BEGIN
    OPEN email;
    LOOP
        FETCH email INTO v_email;
        EXIT WHEN email%NOTFOUND;
        UPDATE employees e
        SET e.email = v_email.email
        WHERE e.employee_id = v_email.email_id;
        COMMIT;
        --dbms_output.put_line(v_email.email_id || ', ' || v_email.email);
    END LOOP;
    CLOSE email;
END;
/
