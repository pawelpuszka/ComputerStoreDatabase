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
    
    at_products_lists   products_list_type;
    at_receipts         receipt_type;
    
    v_products_volume   INTEGER;
    
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
        ;
    END get_all_receipts;
    
    
    PROCEDURE set_products_volume(in_idx INTEGER) 
    IS
        v_duration TIMESTAMP := at_receipts(in_idx).end_time - at_receipts(in_idx).start_time;
        
        FUNCTION is_stationary(in_idx INTEGER) RETURN BOOLEAN IS
        BEGIN
            RETURN at_receipts(in_idx).delivery_method_id = 4;
        END is_stationary;
        
        FUNCTION is_letter(in_idx INTEGER) RETURN BOOLEAN IS
        BEGIN
            RETURN at_receipts(in_idx).delivery_method_id = 3;
        END is_letter;
    BEGIN
        IF is_stationary(in_idx) THEN
            IF v_duration < INTERVAL '2' MINUTE THEN
                v_products_volume := DBMS_RANDOM.value(1, 2);
            ELSIF v_duration >= INTERVAL '2' MINUTE AND v_duration < INTERVAL '5' MINUTE THEN
                v_products_volume := DBMS_RANDOM.value(1, 5);
            ELSIF v_duration >= INTERVAL '5' MINUTE AND INTERVAL '10' MINUTE THEN
                v_products_volume := DBMS_RANDOM.value(3, 8);
            ELSE
                v_products_volume := DBMS_RANDOM.value(6, 10);
        END IF;
        IF is_letter(in_idx) THEN
    END set_products_volume;
    
    
    PROCEDURE set_receipt_id(in_idx INTEGER) IS
    BEGIN
            
    END set_receipt_id;
    
BEGIN
    FOR idx IN at_receipts.FIRST..at_receipts.LAST
    LOOP
        JEŻELI STACJONARNIE TO
            w zależności od dugości transakcji przydziel ilość produktów
                przypisz nr rachunki
                przydziel produkty do listy + ilość każdego produktu
        jeżeli wysyane listem
            ilość produktów =1 z kolekcji small_products
            przydziel nr rachunku
            listem może być wyslane do 2 produtów
    END LOOP;
END generate_receipt_products_lists;

