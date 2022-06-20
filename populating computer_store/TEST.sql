SET SERVEROUTPUT ON;

alter table transactions modify transaction_id GENERATED ALWAYS AS IDENTITY (START WITH 1);
SELECT count(*)
FROM transactions
;
truncate TABLE transactions;

INSERT INTO payment_terms(payment_term_name, days_to_payment)
VALUES('zerowy', 0);

alter table WHOLESALE_CLIENTS add loyalty_card_id INTEGER;

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

       