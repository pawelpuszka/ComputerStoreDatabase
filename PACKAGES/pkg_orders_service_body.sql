CREATE OR REPLACE PACKAGE BODY pkg_orders_service
IS
    function start_transaction(in_employee_id in EMPLOYEES.employee_id%type)
        return transactions.transaction_id%type
    is
        v_trans_id  transactions.transaction_id%type;
        v_emp_id    EMPLOYEES.employee_id%type;
    begin
        begin
            select EMPLOYEE_ID
            into v_emp_id
            from EMPLOYEES emp
                     join EMPLOYEES_CONTRACTS ec
                          on emp.CONTRACT_ID = ec.CONTRACT_ID
                              and ec.END_DATE > sysdate
                              and ec.HIRE_DATE <= sysdate
                     join EMPLOYEE_POSITIONS ep
                          on ep.POSITION_ID = ec.POSITION_ID
            where ec.POSITION_ID in (8, 9)
              and emp.EMPLOYEE_ID = in_employee_id;
        exception
            when NO_DATA_FOUND then
                raise_application_error(-20010, 'There''s no such seller');
        end;

        insert into TRANSACTIONS(employee_id, status_id, start_time)
        values(in_employee_id, 1, sysdate)
        returning TRANSACTION_ID into v_trans_id;

        commit;

        return v_trans_id;
    exception
        when others then
            --maybe log
            rollback;
            raise;
    end start_transaction;

END pkg_orders_service;
/

