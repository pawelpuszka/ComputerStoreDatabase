SET SERVEROUTPUT ON SIZE UNLIMITED;

CREATE OR REPLACE 
PROCEDURE generate_lists_for_invoices_with_short_payment_term 
IS
    TYPE type_invoice_prod_list IS TABLE OF invoice_products_lists%ROWTYPE INDEX BY PLS_INTEGER;
    TYPE type_product_id IS TABLE OF products.product_id%TYPE INDEX BY PLS_INTEGER;
    
    at_product_lists    type_invoice_prod_list;
    at_products_ids     type_product_id;

    v_iterator              INTEGER := 0;
    v_product_num_on_list   INTEGER;
    v_random_prod_id        INTEGER;
    v_product_id            invoice_products_lists.product_id%TYPE;
    v_product_amount        INTEGER;
    v_invoice_id            invoice_products_lists.income_invoice_id%TYPE;
    v_list_id               INTEGER := 1;
BEGIN
    SELECT 
        product_id
    BULK COLLECT INTO
        at_products_ids
    FROM
        products
    ;

    FOR invoice IN (
        SELECT 
             income_invoice_id
            ,payment_term_id
        FROM
            income_invoices
        WHERE
            payment_term_id IN (1, 5)
    )
    LOOP
        v_product_num_on_list := DBMS_RANDOM.value(1, 3);
        WHILE(v_iterator < v_product_num_on_list)
        LOOP
            v_invoice_id := invoice.income_invoice_id;
            v_random_prod_id := DBMS_RANDOM.value(1, at_products_ids.COUNT);
            v_product_amount := DBMS_RANDOM.value(1, 10);
            INSERT INTO invoice_products_lists(
                 income_invoice_id
                ,product_id
                ,purchased_product_qty
            )
            VALUES(
                 v_invoice_id
                ,at_products_ids(v_random_prod_id)
                ,v_product_amount
            ); 
            COMMIT;
            v_list_id := v_list_id + 1;
            v_iterator := v_iterator + 1;
        END LOOP;
        v_iterator := 0;
    END LOOP;
END generate_lists_for_invoices_with_short_payment_term;
/

EXECUTE generate_lists_for_invoices_with_short_payment_term();

