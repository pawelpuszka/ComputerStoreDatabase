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
ALTER TABLE INVOICE_PRODUCTS_LISTS DROP CONSTRAINT INVOICE_PRODUCTS_LISTS__UN;
INVOICE_PRODUCTS_LISTS__UN

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

TRUNCATE TABLE INVOICE_PRODUCTS_LISTS;
alter table invoice_products_lists modify invoice_list_id GENERATED ALWAYS AS IDENTITY (START WITH 1);
EXEC sys.DBMS_SESSION.free_unused_user_memory;

select  count(distinct ipl.INCOME_INVOICE_ID), wc.WHOLESALE_CLIENT_NAME
from wholesale_clients wc
    inner join income_invoices i
        on wc.WHOLESALE_CLIENT_ID = i.WHOLESALE_CLIENT_ID
    inner join invoice_products_lists ipl
        on i.INCOME_INVOICE_ID = ipl.INCOME_INVOICE_ID
where i.payment_term_id = 1
group by wc.WHOLESALE_CLIENT_NAME;

select count(*)
from income_invoices;



    