SET SERVEROUTPUT ON;

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

        SELECT
             transaction_id
            ,payment_method_id 
            ,delivery_method_id
            ,status_id
            ,start_time
            ,end_time
        FROM 
            transactions
        WHERE 
            (status_id = 5 OR status_id = 2)
            AND
            (delivery_method_id != 3 OR delivery_method_id != 4);