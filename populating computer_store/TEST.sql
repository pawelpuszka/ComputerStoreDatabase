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

select PAYMENT_METHOD_ID
from transactions
where DELIVERY_METHOD_ID = 1;

select 
     wc.WHOLESALE_CLIENT_NAME
    ,wc.LOYALTY_CARD_ID
from 
    wholesale_clients wc
    inner join income_invoices i
        on wc.WHOLESALE_CLIENT_ID = i.WHOLESALE_CLIENT_ID
where
    i.TRANSACTION_ID = 822
;

select i.transaction_id, case 
                            when t.end_time - t.start_time > interval '31' day then 'zle'
                            when t.end_time - t.start_time = interval '31' day then 'ok'
                            when t.end_time - t.start_time < interval '31' day then 'zle'
                         end as roznica_dat
from transactions t
    inner join income_invoices i
        on t.transaction_id = i.transaction_id
where t.status_id = 3
    and 
    i.payment_term_id = 3;

select i.transaction_id, (t.end_time - t.start_time) as roznica_dat
from transactions t
    inner join income_invoices i
        on t.transaction_id = i.transaction_id
where t.status_id = 3
    and 
    i.payment_term_id = 3
;


