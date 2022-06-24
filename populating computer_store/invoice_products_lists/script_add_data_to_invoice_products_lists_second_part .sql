CREATE OR REPLACE
PROCEDURE generate_invoice_products_lists_second_part 
IS
    TYPE rec_invoice IS RECORD(
         income_invoice_id   income_invoices.income_invoice_id%TYPE
        ,payment_term_id     income_invoices.payment_term_id%TYPE
    );
    TYPE type_invoice_product_list IS TABLE OF invoice_products_lists%ROWTYPE INDEX BY PLS_INTEGER;
    TYPE type_product_id IS TABLE OF products.product_id%TYPE INDEX BY PLS_INTEGER;
    TYPE type_invoice_id IS TABLE OF rec_invoice INDEX BY PLS_INTEGER;
    
    at_invoice_prod_lists    type_invoice_product_list;
    at_prod_ids              type_product_id;
    at_inv_ids               type_invoice_id;
    
    v_list_id                   INTEGER;
    v_iterator                  INTEGER;
    v_number_of_prods_on_list   INTEGER;
    v_random_product_id         INTEGER;
    v_current_invoice_id        invoice_products_lists.income_invoice_id%TYPE;
    
    SHORT_TERM                  CONSTANT INTEGER := 1;
        
    PROCEDURE get_invoice_info IS
    BEGIN
        SELECT 
             income_invoice_id
            ,payment_term_id
        BULK COLLECT INTO
            at_inv_ids
        FROM
            income_invoices
        WHERE
            payment_term_id = 1
        ;
    END get_invoice_info;
    
    
    PROCEDURE get_all_products_ids IS
    BEGIN
        SELECT product_id
        BULK COLLECT INTO at_prod_ids
        FROM products
        ;
    END get_all_products_ids;
    
    
    PROCEDURE generate_list(v_products_max_qty INTEGER) IS
    BEGIN
        LOOP
            at_invoice_prod_lists(v_list_id).income_invoice_id := v_current_invoice_id;
            v_random_product_id := DBMS_RANDOM.value(1, at_prod_ids.COUNT);
            at_invoice_prod_lists(v_list_id).product_id := at_prod_ids(v_random_product_id);
            at_invoice_prod_lists(v_list_id).purchased_product_qty := DBMS_RANDOM.value(1, v_products_max_qty);
            v_list_id := v_list_id + 1;
            v_iterator := v_iterator + 1;
            EXIT WHEN v_iterator = v_number_of_prods_on_list;
        END LOOP;
        v_iterator := 1;
    END generate_list;
       
BEGIN
    sys.DBMS_SESSION.free_unused_user_memory;
    v_list_id   := 1;
    v_iterator  := 1;
    get_invoice_info();
    get_all_products_ids();
    
    FOR id IN at_inv_ids.FIRST..at_inv_ids.LAST
    LOOP
        v_current_invoice_id := at_inv_ids(id).income_invoice_id;
        v_number_of_prods_on_list := DBMS_RANDOM.value(1, 3);
        generate_list(10);
    END LOOP;
    
    FORALL list_id IN at_invoice_prod_lists.FIRST..at_invoice_prod_lists.LAST
        INSERT INTO invoice_products_lists(
             income_invoice_id
            ,product_id
            ,purchased_product_qty
        )
        VALUES(
             at_invoice_prod_lists(list_id).income_invoice_id
            ,at_invoice_prod_lists(list_id).product_id
            ,at_invoice_prod_lists(list_id).purchased_product_qty
        );
    commit;

END generate_invoice_products_lists_second_part;
/

EXECUTE generate_invoice_products_lists_second_part();
EXEC sys.DBMS_SESSION.free_unused_user_memory;