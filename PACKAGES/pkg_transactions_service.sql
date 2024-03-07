CREATE OR REPLACE PACKAGE pkg_transactions_service
IS
    /*
     payment_method is not going to be set now because the customer will decide at the very end of transaction
     delivery_method is not going to be set now because the customer will decide at the very end of transaction
     */
    function start_transaction(in_employee_id in EMPLOYEES.employee_id%type) return transactions.transaction_id%type;

    function create_receipt(in_transaction_id TRANSACTIONS.transaction_id%type) return RECEIPTS.RECEIPT_ID%type;

END pkg_transactions_service;
/