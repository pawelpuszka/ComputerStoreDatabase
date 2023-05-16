CREATE OR REPLACE PACKAGE pkg_orders_service
IS
    PROCEDURE begin_transaction (in_employee_id IN transactions.employee_id%type
                                --,out_transaction_id OUT transactions.transaction_id%type
                                );

    PROCEDURE set_payment(in_payment_id transactions.payment_method_id%type);

    PROCEDURE set_delivery(in_delivery_id transactions.delivery_method_id%type);

    PROCEDURE finish_transaction(in_transaction_id IN transactions.transaction_id%type);
END pkg_orders_service;