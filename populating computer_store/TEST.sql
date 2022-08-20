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

create schema synonym computer_store;


/* usuwanie NULL z pola end_time w transakcjach z klientami hurtowymi (faktury) - na dzień dzisiejszy wszystkie transakcje są zakończone*/
select *
from clients_loyalty_cards;

select transaction_id
from transactions
where delivery_method_id = 3;

select t.transaction_id, t.start_time, t.end_time, t.PAYMENT_METHOD_ID, ii.wholesale_client_id, wc.LOYALTY_CARD_ID, (t.end_time - t.start_time)
from transactions t
    inner join income_invoices ii
        on t.transaction_id = ii.transaction_id
    inner join wholesale_clients wc
        on ii.WHOLESALE_CLIENT_ID = wc.WHOLESALE_CLIENT_ID
where --t.delivery_method_id = 4
     t.end_time is null
    --and ii.payment_term_id = 4
    --and t.PAYMENT_METHOD_ID = 4
    --and t.end_time - t.start_time < interval '45' day
    --and t.end_time - t.start_time < interval '1' day
;
/

declare
    v_i             integer := 0;
    v_random_val    timestamp;
    v_random_val_2  integer;
begin
    for trans in (select t.transaction_id, rpl.receipt_id, r.PAYMENT_term_ID, t.PAYMENT_METHOD_ID, t.delivery_method_id, t.start_time, t.end_time, count(rpl.product_id)
from receipt_products_lists rpl
    inner join receipts r
        on rpl.receipt_id = r.receipt_id
    inner join transactions t
        on r.transaction_id = t.transaction_id
where t.end_time is null
group by t.transaction_id, rpl.receipt_id, r.PAYMENT_term_ID, t.PAYMENT_METHOD_ID, t.delivery_method_id, t.start_time, t.end_time
                )
    loop
        v_i := v_i + 1;
        v_random_val_2 := dbms_random.value(1, 3);
        v_random_val := trans.start_time + dbms_random.value(v_random_val_2, 7);
        SYS.dbms_output.put_line(v_i || '. ' ||v_random_val);
        update transactions
        set end_time = v_random_val
        where transaction_id = trans.transaction_id;
    end loop;
    commit;
end;
/

declare
    v_i             integer;
    v_random_val    timestamp;
    v_random_val_2  integer;
begin
    for trans in (select  t.TRANSACTION_ID, t.start_time
                from transactions t
                    inner join income_invoices ii
                        on t.transaction_id = ii.transaction_id
                where t.delivery_method_id = 1 
                    and t.end_time is null
                    and ii.payment_term_id = 3)
    loop
        v_random_val_2 := dbms_random.value(1, 14);
        v_random_val := trans.start_time + dbms_random.value(v_random_val_2, 30);
        SYS.dbms_output.put_line(v_i || '. ' ||v_random_val);
        update transactions
        set end_time = v_random_val
        where transaction_id = trans.transaction_id;
    end loop;
    commit;
end;
/

/* */
select t.transaction_id, t.start_time, t.end_time, r.PAYMENT_term_ID, (t.end_time - t.start_time)
from transactions t
    inner join receipts r
        on t.transaction_id = r.transaction_id
where --t.delivery_method_id = 4
     --t.end_time is null
    --and ii.payment_term_id = 4
    --t.PAYMENT_METHOD_ID = 4
    --and t.end_time - t.start_time < interval '45' day
     t.end_time - t.start_time < interval '1' day
;

select t.transaction_id, rpl.receipt_id, r.PAYMENT_term_ID, t.PAYMENT_METHOD_ID, t.delivery_method_id, t.start_time, t.end_time, count(rpl.product_id)
from receipt_products_lists rpl
    inner join receipts r
        on rpl.receipt_id = r.receipt_id
    inner join transactions t
        on r.transaction_id = t.transaction_id
where --t.end_time is null
    t.end_time - t.start_time < interval '1' day
    and t.delivery_method_id = 3
group by t.transaction_id, rpl.receipt_id, r.PAYMENT_term_ID, t.PAYMENT_METHOD_ID, t.delivery_method_id, t.start_time, t.end_time ;

select *
from receipt_products_lists;

select *
from EMPLOYEE_POSITIONS;

select *
from employees e
    inner join employees_contracts ec
        on e.contract_id = ec.contract_id
where ec.position_id in (8, 9);

select *
from transactions
where end_time is null;
























    