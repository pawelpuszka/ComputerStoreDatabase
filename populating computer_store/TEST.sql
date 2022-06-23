SET SERVEROUTPUT ON;

alter table INCOME_INVOICES modify INCOME_INVOICE_ID GENERATED ALWAYS AS IDENTITY (START WITH 1);
SELECT count(*)
FROM transactions
;
truncate TABLE transactions;

INSERT INTO payment_terms(payment_term_name, days_to_payment)
VALUES('zerowy', 0);

alter table WHOLESALE_CLIENTS add loyalty_card_id INTEGER;

ALTER TABLE income_invoices MODIFY INCOME_INVOICE_NR VARCHAR2(40);
ALTER TABLE income_invoices RENAME COLUMN income_invoice_nr TO income_invoice_no;
ALTER TABLE income_invoices DROP CONSTRAINT PAYMENT_TERM_UN;

CREATE TABLE clients_loyalty_cards (
    loyalty_card_id	    INTEGER GENERATED ALWAYS AS IDENTITY,
    loyalty_card_label  VARCHAR2 (15 CHAR),
    CONSTRAINT loyalty_card_PK PRIMARY KEY (loyalty_card_id)
);

INSERT INTO CLIENTS_LOYALTY_CARDS (LOYALTY_CARD_LABEL)
VALUES('zwykla');

update transaction_statuses
set status_name = 'cancelled'
where status_id = 3;




    PROCEDURE get_invoice_info IS
    BEGIN
        SELECT 
             income_invoice_id
            ,payment_term_id
        BULK COLLECT INTO
            at_invoices
        FROM
            income_invoices
        ;
    END get_invoice_info;
    
    PROCEDURE get_products_volume IS
    BEGIN
        SELECT COUNT(*)
        INTO v_prods_volume
        FROM products
        ;
    END get_products_volume;
    
    PROCEDURE get_all_products_ids IS
    BEGIN
        SELECT product_id
        BULK COLLECT INTO at_product_ids
        FROM products;
    END get_all_products_ids;
    
    
    FUNCTION is_45_days(in_id INTEGER) RETURN BOOLEAN IS
    BEGIN
        RETURN  at_invoices(in_id).payment_term_id = 4;
    END is_45_days;
    
    
    PROCEDURE set_products_on_list(in_number_of_prods INTEGER, in_invoice_id INTEGER) 
    IS
        v_random_prod_id INTEGER;
            
            FUNCTION is_prod_on_list(in_prod_id INTEGER, in_current_invoice_id income_invoices.income_invoice_id%TYPE) RETURN BOOLEAN IS
            BEGIN
                IF at_invoice_products_lists.COUNT = 0 THEN
                    RETURN FALSE;
                END IF;
                FOR i IN at_invoice_products_lists.FIRST..at_invoice_products_lists.LAST
                LOOP
                    IF in_prod_id = at_invoice_products_lists(i).product_id AND in_current_invoice_id = at_invoice_products_lists(i).income_invoice_id THEN
                        RETURN TRUE;
                    END IF;
                END LOOP;
                RETURN FALSE;
            END is_prod_on_list;
    BEGIN
        FOR prod IN 1..in_number_of_prods
        LOOP
            at_invoice_products_lists(prod).income_invoice_id := in_invoice_id;--at_invoices(in_invoice_id).income_invoice_id;
            --LOOP
                v_random_prod_id := DBMS_RANDOM.value(1, v_prods_volume);
                --EXIT WHEN NOT is_prod_on_list(v_random_prod_id, at_invoice_products_lists(prod).income_invoice_id);
            --END LOOP;
            at_invoice_products_lists(prod).product_id := at_product_ids(v_random_prod_id);
            at_invoice_products_lists(prod).purchased_product_qty := DBMS_RANDOM.value(1, 25);
        END LOOP;
    END set_products_on_list;


