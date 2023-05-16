CREATE OR REPLACE PACKAGE BODY pkg_orders_service
IS
    --v_transaction_id    transactions.transaction_id%type;

    --in default transaction is in stationary store
    --somewhere during completing the order there should be change in transaction delivery method if it is online
    PROCEDURE begin_transaction (in_employee_id IN transactions.employee_id%type
                                ,out_transaction_id OUT transactions.transaction_id%type
                                )
    IS
    BEGIN
        INSERT INTO transactions(employee_id, delivery_method_id, status_id, start_time)
        VALUES (in_employee_id, 4, 1, sysdate)
        RETURNING transaction_id INTO out_transaction_id;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            --logging the exception
            ROLLBACK;
            RAISE;
    END begin_transaction;



    PROCEDURE create_receipt(in_transaction_id IN transactions.transaction_id%type
                            ,out_receipt_id OUT receipts.receipt_id%type)
    IS

        FUNCTION generate_receipt_no RETURN receipts.receipt_no%type
        IS
            v_date_string VARCHAR2(10);
        BEGIN
            SELECT TO_CHAR(start_time, 'YYYY/MM/DD')
            INTO v_date_string
            FROM transactions
            WHERE transaction_id = in_transaction_id;

            RETURN TO_CHAR(in_transaction_id) || REPLACE(v_date_string, '/', '');
        EXCEPTION
            WHEN OTHERS THEN
                --LOG
                RAISE;
        END generate_receipt_no;

        v_receipt_no receipts.receipt_no%type := generate_receipt_no();
    BEGIN
        INSERT INTO receipts (receipt_no, transaction_id)
        VALUES (v_receipt_no, in_transaction_id)
        RETURNING receipt_id INTO out_receipt_id;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            --logging the exception
            ROLLBACK;
            RAISE;
    END create_receipt;



    PROCEDURE add_product_to_receipt_list(in_product_id IN products.product_id%type
                                        ,in_receipt_id IN receipts.receipt_id%type
                                        ,in_quantity IN receipt_products_lists.purchased_product_qty%type
        --,in_set_new_status IN BOOLEAN DEFAULT TRUE /*comes from GUI, */
    )
    IS

        FUNCTION set_status_pending RETURN BOOLEAN
        IS
            v_tmp NUMBER;
        BEGIN
            SELECT 1
            INTO v_tmp
            FROM transactions
            WHERE transaction_id = (SELECT transaction_id FROM receipts WHERE receipt_id = in_receipt_id)
                AND status_id = 2;

            RETURN v_tmp = 1;
        EXCEPTION
            WHEN no_data_found THEN
                RETURN FALSE;
            WHEN OTHERS THEN
                --logging the exception
                ROLLBACK;
                RAISE;
        END set_status_pending;

    BEGIN
        IF (NOT set_status_pending()) THEN
            UPDATE transactions
            SET status_id = 2 --pending
            WHERE transaction_id = (SELECT transaction_id FROM receipts WHERE receipt_id = in_receipt_id);
        END IF;

        INSERT INTO receipt_products_lists(receipt_id, product_id, purchased_product_qty)
        VALUES(in_receipt_id, in_product_id, in_quantity);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            --logging the exception
            ROLLBACK;
            RAISE;
    END add_product_to_receipt_list;



    PROCEDURE set_payment_term(in_payment_term_id IN receipts.payment_term_id%type --that will come from GUI
                              ,in_transaction_id IN transactions.transaction_id%type)
    IS
    BEGIN
        UPDATE receipts
        SET payment_term_id = in_payment_term_id
        WHERE transaction_id = in_transaction_id;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            --LOG
            ROLLBACK;
            RAISE;
    END set_payment_term;



    PROCEDURE set_payment(in_payment_id transactions.payment_method_id%type
                         ,in_transaction_id IN transactions.transaction_id%type) IS
    BEGIN
        UPDATE transactions
        SET payment_method_id = in_payment_id
        WHERE transaction_id = in_transaction_id;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            --logging the exception
            ROLLBACK;
            RAISE;
    END set_payment;



    PROCEDURE set_delivery(in_delivery_id transactions.delivery_method_id%type
                            ,in_transaction_id IN transactions.transaction_id%type) IS
    BEGIN
        UPDATE transactions
        SET delivery_method_id = in_delivery_id
        WHERE transaction_id = in_transaction_id;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            --logging the exception
            ROLLBACK;
            RAISE;
    END set_delivery;



    PROCEDURE finish_transaction(in_transaction_id IN transactions.transaction_id%type) IS
    BEGIN
        UPDATE transactions
        SET end_time = SYSDATE
           ,status_id = 5
        WHERE transaction_id = in_transaction_id;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
        --logging the exception
        ROLLBACK;
        RAISE;
    END finish_transaction;

END pkg_orders_service;
/

SELECT sysdate
FROM dual;
