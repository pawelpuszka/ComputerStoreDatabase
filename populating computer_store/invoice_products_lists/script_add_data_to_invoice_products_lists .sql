SET SERVEROUTPUT ON ;

CREATE OR REPLACE
PROCEDURE generate_invoice_products_lists 
IS
    TYPE rec_invoice IS RECORD(
         income_invoice_id   income_invoices.income_invoice_id%TYPE
        ,payment_term_id     income_invoices.payment_term_id%TYPE
    );
    TYPE type_invoice_product_list IS TABLE OF invoice_products_lists%ROWTYPE INDEX BY PLS_INTEGER;
    TYPE type_product_id IS TABLE OF products.product_id%TYPE INDEX BY PLS_INTEGER;
    TYPE type_invoice_id IS TABLE OF rec_invoice INDEX BY PLS_INTEGER;
    
    at_invoice_products_lists   type_invoice_product_list;
    at_product_ids              type_product_id;
    at_invoices_ids             type_invoice_id;
    
    v_list_id                   INTEGER;
    v_iterator                  INTEGER;
    v_number_of_prods_on_list   INTEGER;
    v_random_product_id         INTEGER;
    v_current_invoice_id        invoice_products_lists.income_invoice_id%TYPE;
    
    REGULAR_CUSTOMER_TERM       CONSTANT INTEGER := 4;
    LONG_TERM                   CONSTANT INTEGER := 3;
    STANDART_TERM               CONSTANT INTEGER := 2;
    SHORT_TERM                  CONSTANT INTEGER := 1;
    NONE_TERM                   CONSTANT INTEGER := 5;
       
        
    PROCEDURE get_invoice_info IS
    BEGIN
        SELECT 
             income_invoice_id
            ,payment_term_id
        BULK COLLECT INTO
            at_invoices_ids
        FROM
            income_invoices
        ;
    END get_invoice_info;
    
    
    PROCEDURE get_all_products_ids IS
    BEGIN
        SELECT product_id
        BULK COLLECT INTO at_product_ids
        FROM products
        ;
    END get_all_products_ids;
    
    
    FUNCTION is_regular_customer(in_id INTEGER) RETURN BOOLEAN IS
    BEGIN
        RETURN at_invoices_ids(in_id).payment_term_id = REGULAR_CUSTOMER_TERM;
    END is_regular_customer;
    
    FUNCTION is_long_term(in_id INTEGER) RETURN BOOLEAN IS
    BEGIN
        RETURN at_invoices_ids(in_id).payment_term_id = LONG_TERM;
    END is_long_term;
    
    FUNCTION is_standart_term(in_id INTEGER) RETURN BOOLEAN IS
    BEGIN
        RETURN at_invoices_ids(in_id).payment_term_id = STANDART_TERM;
    END is_standart_term;
    
    FUNCTION is_short_term(in_id INTEGER) RETURN BOOLEAN IS
    BEGIN
        RETURN at_invoices_ids(in_id).payment_term_id = STANDART_TERM;
    END is_short_term;
    
       
BEGIN
    v_list_id   := 1;
    v_iterator  := 1;
    get_invoice_info();
    get_all_products_ids();
    
    FOR id IN at_invoices_ids.FIRST..at_invoices_ids.LAST
    LOOP
        v_current_invoice_id := at_invoices_ids(id).income_invoice_id;
        IF is_regular_customer(id) THEN
            v_number_of_prods_on_list := DBMS_RANDOM.value(3, 15);
            LOOP
                at_invoice_products_lists(v_list_id).income_invoice_id := v_current_invoice_id;
                v_random_product_id := DBMS_RANDOM.value(1, at_product_ids.COUNT);
                at_invoice_products_lists(v_list_id).product_id := at_product_ids(v_random_product_id);
                at_invoice_products_lists(v_list_id).purchased_product_qty := DBMS_RANDOM.value(1, 25);
                v_list_id := v_list_id + 1;
                v_iterator := v_iterator + 1;
                EXIT WHEN v_iterator = v_number_of_prods_on_list;
            END LOOP;
        END IF;
        v_iterator := 1;
    END LOOP;

    for i in at_invoice_products_lists.FIRST..at_invoice_products_lists.LAST
    loop
    DBMS_OUTPUT.put_line(i || ' ' ||
                         'invoice_id: ' || at_invoice_products_lists(i).income_invoice_id || ' ' ||
                         'product_id: ' || at_invoice_products_lists(i).product_id || ' ' ||
                         'quantity: ' || at_invoice_products_lists(i).purchased_product_qty);
    end loop;
END generate_invoice_products_lists;
/

EXECUTE generate_invoice_products_lists();





