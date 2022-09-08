set serveroutput ON;

ALTER TABLE receipts MODIFY receipt_id GENERATED ALWAYS AS IDENTITY (start WITH 1);
SELECT COUNT(*)
FROM transactions
;
TRUNCATE TABLE transactions;

INSERT INTO payment_terms(payment_term_name, days_to_payment)
VALUES('zerowy', 0);

ALTER TABLE wholesale_clients ADD loyalty_card_id integer;

ALTER TABLE income_invoices MODIFY income_invoice_nr varchar2(40);
ALTER TABLE income_invoices RENAME column income_invoice_nr TO income_invoice_no;
ALTER TABLE income_invoices DROP CONSTRAINT payment_term_un;
ALTER TABLE invoice_products_lists DROP CONSTRAINT invoice_products_lists__un;
invoice_products_lists__un

CREATE TABLE clients_loyalty_cards (
    loyalty_card_id	    integer GENERATED ALWAYS AS IDENTITY,
    loyalty_card_label  varchar2 (15 char),
    CONSTRAINT loyalty_card_pk PRIMARY KEY (loyalty_card_id)
);

UPDATE payment_terms
set payment_term_name = 'short'
WHERE payment_term_id = 1;
UPDATE payment_terms
set payment_term_name = 'long'
WHERE payment_term_id = 3;
UPDATE payment_terms
set payment_term_name = 'regular client'
WHERE payment_term_id = 4;
UPDATE payment_terms
set payment_term_name = 'none'
WHERE payment_term_id = 5;    

ALTER TABLE receipts ADD payment_term_id integer;
ALTER TABLE receipts 
    ADD CONSTRAINT receipts_payment_terms_fk FOREIGN KEY (payment_term_id)
    REFERENCES payment_terms (payment_term_id);

SELECT *
FROM transactions T
    INNER JOIN income_invoices i
    ON t.transaction_id = i.transaction_id
WHERE t.payment_method_id = 1
AND t.delivery_method_id = 2;

SELECT 
     t.transaction_id
    ,t.start_time
    ,t.end_time
    ,ts.status_name
    ,pm.payment_method_name
FROM transactions T
    LEFT JOIN income_invoices i
        ON t.transaction_id = i.transaction_id
    INNER JOIN transaction_statuses ts
        ON t.status_id = ts.status_id
    INNER JOIN payment_methods pm
        ON pm.payment_method_id = t.payment_method_id
WHERE i.income_invoice_id IS NULL
--and t.payment_method_id = 4
--and t.status_id = 3
AND t.delivery_method_id = 4
;

BEGIN
    dbms_output.put_line(ROUND(dbms_random.value(6, 10)));
END;
/

TRUNCATE TABLE receipts;
ALTER TABLE receipts DROP CONSTRAINT receipts_transaction_un;
ALTER TABLE receipts DROP CONSTRAINT receipts__un;
ALTER TABLE receipts MODIFY receipt_id GENERATED ALWAYS AS IDENTITY (start WITH 1);

TRUNCATE TABLE receipts;
ALTER TABLE receipt_products_lists DROP CONSTRAINT receipt_products_lists__un;
ALTER TABLE receipts DROP CONSTRAINT receipts__un;
ALTER TABLE receipts MODIFY receipt_id GENERATED ALWAYS AS IDENTITY (start WITH 1);

SELECT receipt_id, COUNT(transaction_id)
FROM receipts
--where transaction_id
GROUP BY receipt_id
HAVING COUNT(transaction_id) > 1;
/

SELECT NUMTODSINTERVAL((SYSTIMESTAMP + 1) - SYSTIMESTAMP, 'minute')
FROM dual;

SELECT NUMTODSINTERVAL((SYSDATE + 1) - SYSDATE, 'minute')
FROM dual;

SELECT t.transaction_id, t.start_time, t.end_time, t.status_id
FROM computer_store.transactions T
WHERE t.payment_method_id IN (1, 2 ,3) AND t.delivery_method_id = 4 AND t.status_id != 5
;


ALTER SYSTEM set  "_enable_schema_synonyms" = TRUE SCOPE=SPFILE;

CREATE SCHEMA SYNONYM computer_store;


/* usuwanie null z pola end_time w transakcjach z klientami hurtowymi (faktury) - na dzień dzisiejszy wszystkie transakcje są zakończone*/
SELECT *
FROM clients_loyalty_cards;

SELECT transaction_id
FROM transactions
WHERE delivery_method_id = 3;

SELECT t.transaction_id, t.start_time, t.end_time, t.payment_method_id, ii.wholesale_client_id, wc.loyalty_card_id, (t.end_time - t.start_time)
FROM transactions T
    INNER JOIN income_invoices ii
        ON t.transaction_id = ii.transaction_id
    INNER JOIN wholesale_clients wc
        ON ii.wholesale_client_id = wc.wholesale_client_id
WHERE --t.delivery_method_id = 4
     t.end_time IS NULL
    --and ii.payment_term_id = 4
    --and t.payment_method_id = 4
    --and t.end_time - t.start_time < interval '45' day
    --and t.end_time - t.start_time < interval '1' day
;
/

DECLARE
    v_i             integer := 0;
    v_random_val    TIMESTAMP;
    v_random_val_2  integer;
BEGIN
    FOR trans IN (SELECT t.transaction_id, rpl.receipt_id, r.payment_term_id, t.payment_method_id, t.delivery_method_id, t.start_time, t.end_time, COUNT(rpl.product_id)
FROM receipt_products_lists rpl
    INNER JOIN receipts r
        ON rpl.receipt_id = r.receipt_id
    INNER JOIN transactions T
        ON r.transaction_id = t.transaction_id
WHERE t.end_time IS NULL
GROUP BY t.transaction_id, rpl.receipt_id, r.payment_term_id, t.payment_method_id, t.delivery_method_id, t.start_time, t.end_time
                )
    LOOP
        v_i := v_i + 1;
        v_random_val_2 := dbms_random.value(1, 3);
        v_random_val := trans.start_time + dbms_random.value(v_random_val_2, 7);
        sys.dbms_output.put_line(v_i || '. ' ||v_random_val);
        UPDATE transactions
        set end_time = v_random_val
        WHERE transaction_id = trans.transaction_id;
    END LOOP;
    COMMIT;
END;
/

DECLARE
    v_i             integer;
    v_random_val    TIMESTAMP;
    v_random_val_2  integer;
BEGIN
    FOR trans IN (SELECT  t.transaction_id, t.start_time
                FROM transactions T
                    INNER JOIN income_invoices ii
                        ON t.transaction_id = ii.transaction_id
                WHERE t.delivery_method_id = 1 
                    AND t.end_time IS NULL
                    AND ii.payment_term_id = 3)
    LOOP
        v_random_val_2 := dbms_random.value(1, 14);
        v_random_val := trans.start_time + dbms_random.value(v_random_val_2, 30);
        sys.dbms_output.put_line(v_i || '. ' ||v_random_val);
        UPDATE transactions
        set end_time = v_random_val
        WHERE transaction_id = trans.transaction_id;
    END LOOP;
    COMMIT;
END;
/

/* */
SELECT t.transaction_id, t.start_time, t.end_time, r.payment_term_id, (t.end_time - t.start_time)
FROM transactions T
    INNER JOIN receipts r
        ON t.transaction_id = r.transaction_id
WHERE --t.delivery_method_id = 4
     --t.end_time is null
    --and ii.payment_term_id = 4
    --t.payment_method_id = 4
    --and t.end_time - t.start_time < interval '45' day
     t.end_time - t.start_time < interval '1' DAY
;

SELECT t.transaction_id, rpl.receipt_id, r.payment_term_id, t.payment_method_id, t.delivery_method_id, t.start_time, t.end_time, COUNT(rpl.product_id)
FROM receipt_products_lists rpl
    INNER JOIN receipts r
        ON rpl.receipt_id = r.receipt_id
    INNER JOIN transactions T
        ON r.transaction_id = t.transaction_id
WHERE --t.end_time is null
    t.end_time - t.start_time < interval '1' DAY
    AND t.delivery_method_id = 3
GROUP BY t.transaction_id, rpl.receipt_id, r.payment_term_id, t.payment_method_id, t.delivery_method_id, t.start_time, t.end_time ;

SELECT *
FROM receipt_products_lists;

SELECT *
FROM employee_positions;

SELECT *
FROM employees E
    INNER JOIN employees_contracts ec
        ON e.contract_id = ec.contract_id
    INNER JOIN	employee_positions ep
        ON ec.position_id = ep.position_id
WHERE ec.position_id IN (8, 9);

SELECT *
FROM transactions
WHERE end_time IS NULL;

SELECT income_invoices.income_invoice_no
FROM income_invoices;


























    