SET SERVEROUTPUT ON;

CREATE OR REPLACE
PROCEDURE generate_receipt_products_lists
IS
    TYPE receipt_rec IS RECORD(
         receipt_id             receipts.receipt_id%TYPE
        ,receipt_no             receipts.receipt_no%TYPE
        ,delivery_method_id     transactions.delivery_method_id%TYPE
        ,start_time             transactions.start_time%TYPE
        ,end_time               transactions.end_time%TYPE
    );
    TYPE products_list_type IS TABLE OF receipt_products_lists%ROWTYPE INDEX BY PLS_INTEGER;
    TYPE receipt_type IS TABLE OF receipt_rec INDEX BY PLS_INTEGER;
    TYPE product_id_type IS TABLE OF products.product_id%TYPE INDEX BY PLS_INTEGER;
    
    at_products_lists       products_list_type;
    at_receipts             receipt_type;
    at_all_products_ids     product_id_type;
    at_small_products_ids   product_id_type;
    
    v_products_volume   INTEGER;
    v_products_qty      INTEGER;
    v_duration          TIMESTAMP;
    v_list_id           INTEGER;
    
    PROCEDURE get_all_receipts IS
    BEGIN
        SELECT
             r.receipt_id
            ,r.receipt_no
            ,t.delivery_method_id
            ,t.start_time
            ,t.end_time
        BULK COLLECT INTO
            at_receipts
        FROM 
            receipts r
            INNER JOIN transactions t
                ON r.transaction_id = t.transaction_id
        ORDER BY
            t.start_time
        ;
    END get_all_receipts;
    
    PROCEDURE get_all_products_ids IS
    BEGIN
        SELECT product_id
        BULK COLLECT INTO at_all_products_ids
        FROM products
        ;
    END get_all_products_ids;
    
    PROCEDURE get_small_products_ids IS
    BEGIN
        SELECT product_id
        BULK COLLECT INTO at_small_products_ids
        FROM products
        WHERE category_id IN (3, 4, 5, 6, 8, 12)
        ;
    END get_small_products_ids;
    
    
    FUNCTION is_stationary_sale(in_idx INTEGER) RETURN BOOLEAN IS
    BEGIN
        RETURN at_receipts(in_idx).delivery_method_id = 4;
    END is_stationary_sale;
    
    PROCEDURE set_prod_volume_when_stationary IS
    BEGIN
        IF v_duration < INTERVAL '2' MINUTE THEN
            v_products_volume := DBMS_RANDOM.value(1, 2);
        ELSIF v_duration >= INTERVAL '2' MINUTE AND v_duration < INTERVAL '5' MINUTE THEN
            v_products_volume := DBMS_RANDOM.value(1, 5);
        ELSIF v_duration >= INTERVAL '5' MINUTE AND INTERVAL '10' MINUTE THEN
            v_products_volume := DBMS_RANDOM.value(3, 8);
        ELSE
            v_products_volume := DBMS_RANDOM.value(6, 10);
        END IF;
    END set_prod_volume_when_stationary;
    
    
    FUNCTION is_sendby_letter(in_idx INTEGER) RETURN BOOLEAN IS
    BEGIN
        RETURN at_receipts(in_idx).delivery_method_id = 3;
    END is_sendby_letter;
    
    PROCEDURE set_prod_volume_when_letter IS
    BEGIN
        v_products_volume := 1;
    END;
    
    
    PROCEDURE set_receipt_id(in_idx INTEGER, in_list_id INTEGER) IS
    BEGIN
        at_products_lists(in_list_id).receipt_id := at_receipts(in_idx).receipt_id;    
    END set_receipt_id;
    
    
    PROCEDURE set_product_id(in_list_id INTEGER) 
    IS
        v_random_product_id products.product_id%TYPE := DBMS_RANDOM.value(1, at_all_products_ids.COUNT);
    BEGIN
        at_products_lists(in_list_id).product_id := at_all_products_ids(v_random_product_id);
    END set_product_id;
    
    
    PROCEDURE set_product_qty(in_list_id INTEGER) IS
    BEGIN
        at_products_lists(in_list_id).purchased_product_qty := DBMS_RANDOM.value(1, 10);
    END set_product_qty;
    
    
BEGIN
    v_list_id := 1;
    FOR idx IN at_receipts.FIRST..at_receipts.LAST
    LOOP
        IF is_stationary_sale(idx) THEN
            v_duration := at_receipts(idx).end_time - at_receipts(idx).start_time;
            set_prod_volume_when_stationary();
            WHILE(v_products_volume > 0)
            LOOP
                set_receipt_id(idx, v_list_id);
                set_product_id(v_list_id);
                set_product_qty(v_list_id);
                v_list_id := v_list_id + 1;
                v_products_volume := v_products_volume - 1;
                DBMS_OUTPUT.put_line(at_products_lists('RECEIPT_ID: ' || v_list_id).RECEIPT_ID || '; PRODUCT_ID: ' || at_products_lists(v_list_id).PRODUCT_ID || '; PURCHASED_PRODUCT_QTY: ' || at_products_lists(v_list_id).PURCHASED_PRODUCT_QTY);
            END LOOP;
       -- ELSIF is_sendby_letter(idx) THEN
        
        --ELSE
        END IF;
    END LOOP;

END generate_receipt_products_lists;

