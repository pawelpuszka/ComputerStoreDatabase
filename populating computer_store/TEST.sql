SET SERVEROUTPUT ON;

alter table RECEIPTS modify RECEIPT_ID GENERATED ALWAYS AS IDENTITY (START WITH 1);
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
ALTER TABLE INVOICE_PRODUCTS_LISTS DROP CONSTRAINT INVOICE_PRODUCTS_LISTS__UN;
INVOICE_PRODUCTS_LISTS__UN

CREATE TABLE clients_loyalty_cards (
    loyalty_card_id	    INTEGER GENERATED ALWAYS AS IDENTITY,
    loyalty_card_label  VARCHAR2 (15 CHAR),
    CONSTRAINT loyalty_card_PK PRIMARY KEY (loyalty_card_id)
);

update payment_terms
set PAYMENT_TERM_NAME = 'short'
where PAYMENT_TERM_ID = 1;
update payment_terms
set PAYMENT_TERM_NAME = 'long'
where PAYMENT_TERM_ID = 3;
update payment_terms
set PAYMENT_TERM_NAME = 'regular client'
where PAYMENT_TERM_ID = 4;
update payment_terms
set PAYMENT_TERM_NAME = 'none'
where PAYMENT_TERM_ID = 5;    

alter table receipts add payment_term_id INTEGER;
ALTER TABLE receipts 
    ADD CONSTRAINT receipts_payment_terms_fk FOREIGN KEY (payment_term_id)
    REFERENCES payment_terms (payment_term_id);

SELECT *
FROM TRANSACTIONS T
    INNER JOIN INCOME_INVOICES I
    ON T.TRANSACTION_ID = I.TRANSACTION_ID
WHERE T.PAYMENT_METHOD_ID = 1
AND T.DELIVERY_METHOD_ID = 2;

SELECT 
     t.transaction_id
    ,t.start_time
    ,t.end_time
    ,ts.status_name
    ,pm.PAYMENT_METHOD_NAME
FROM transactions t
    LEFT JOIN income_invoices i
        ON t.transaction_id = i.transaction_id
    inner join transaction_statuses ts
        on t.STATUS_ID = ts.STATUS_ID
    inner join payment_methods pm
        on pm.PAYMENT_METHOD_ID = t.payment_method_id
WHERE i.income_invoice_id IS NULL
--and T.PAYMENT_METHOD_ID = 4
--and t.STATUS_ID = 3
and t.delivery_method_id = 4
;

begin
    DBMS_OUTPUT.put_line(ROUND(dbms_random.value(6, 10)));
end;
/

truncate table receipts;
ALTER TABLE receipts DROP CONSTRAINT RECEIPTS_TRANSACTION_UN;
ALTER TABLE receipts DROP CONSTRAINT RECEIPTS__UN;
alter table RECEIPTS modify RECEIPT_ID GENERATED ALWAYS AS IDENTITY (START WITH 1);

truncate table receipts;
ALTER TABLE receipt_products_lists DROP CONSTRAINT RECEIPT_PRODUCTS_LISTS__UN;
ALTER TABLE receipts DROP CONSTRAINT RECEIPTS__UN;
alter table RECEIPTS modify RECEIPT_ID GENERATED ALWAYS AS IDENTITY (START WITH 1);

select RECEIPT_ID, count(TRANSACTION_ID)
from receipts
--where TRANSACTION_ID
group by RECEIPT_ID
having count(TRANSACTION_ID) > 1;
/

select numtodsinterval((systimestamp + 1) - systimestamp, 'minute')
from dual;

select numtodsinterval((sysdate + 1) - sysdate, 'minute')
from dual;

select t.TRANSACTION_ID, t.START_TIME, t.END_TIME, t.STATUS_ID
from computer_store.transactions t
where t.PAYMENT_METHOD_ID in (1, 2 ,3) and t.DELIVERY_METHOD_ID = 4 and t.STATUS_ID != 5
;


ALTER SYSTEM SET  "_enable_schema_synonyms" = true SCOPE=SPFILE;

create schema synonym computer_store





























    