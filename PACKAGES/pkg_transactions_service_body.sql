CREATE OR REPLACE PACKAGE BODY pkg_transactions_service
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

        --commit;

        return v_trans_id;
    exception
        when others then
            --maybe log
            rollback;
            raise;
    end start_transaction;


    function create_receipt(in_transaction_id TRANSACTIONS.transaction_id%type)
        return RECEIPTS.RECEIPT_ID%type
    is
        v_receipt_no RECEIPTS.RECEIPT_NO%type;
        v_receipt_id RECEIPTS.RECEIPT_ID%type;
        v_start_time TRANSACTIONS.START_TIME%type;

    begin
        begin
            select START_TIME
            into v_start_time
            from TRANSACTIONS
            where TRANSACTION_ID = in_transaction_id;
        exception
            when no_data_found then
                --log
                raise_application_error(-20010, 'No such transaction');
        end;

        v_receipt_no := to_char(in_transaction_id) || to_char(v_start_time);

        insert into RECEIPTS(receipt_no, transaction_id, payment_term_id)
        values (v_receipt_no, in_transaction_id, (select DAYS_TO_PAYMENT from PAYMENT_TERMS where PAYMENT_TERM_NAME = 'none'))
        returning RECEIPT_ID into v_receipt_id;

        --commit;
        return v_receipt_id;
    exception
        when others then
            --maybe log
            rollback;
            raise;
    end create_receipt;


    procedure create_receipt_list

END pkg_transactions_service;
/

