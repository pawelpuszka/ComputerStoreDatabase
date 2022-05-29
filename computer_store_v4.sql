-- Generated by Oracle SQL Developer Data Modeler 21.4.2.059.0838
--   at:        2022-05-23 10:43:18 CEST
--   site:      Oracle Database 12c
--   type:      Oracle Database 12c



-- predefined type, no DDL - MDSYS.SDO_GEOMETRY

-- predefined type, no DDL - XMLTYPE

--ALTER TABLE addresses RENAME COLUMN "street " TO street
--ALTER TABLE addresses DROP COLUMN email;
--DROP TABLE addresses;
--ALTER TABLE addresses MODIFY  postal_code  CHAR(6 CHAR);
--ALTER TABLE addresses MODIFY  phone_number VARCHAR2(12 CHAR);

CREATE TABLE addresses (
    address_id   INTEGER GENERATED ALWAYS AS IDENTITY,
    street       NVARCHAR2(100),
    city         NVARCHAR2(50),
    postal_code  CHAR(6 CHAR),
    phone_number VARCHAR2(11 CHAR),
   
);

COMMENT ON COLUMN addresses.city IS
    'CHECK zawiera tylko litery';

COMMENT ON COLUMN addresses.postal_code IS
    'CHECK zawiera tylko liczby
PL/SQL wpisany jako jeden ci�g znak�w ';

COMMENT ON COLUMN addresses.phone_number IS
    'CHECK zawiera tylko liczby
PL/SQL wpisany jako jeden ci�g znak�w ';

ALTER TABLE addresses ADD CONSTRAINT adresses_pk PRIMARY KEY ( address_id );

CREATE TABLE cost_invoices (
    cost_invoice_id   INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    cost_invoice_nr   NVARCHAR2(30) NOT NULL,
    supplier_id       SMALLINT NOT NULL,
    tota_net_price    NUMBER(12, 2),
    total_tax         NUMBER(12, 2),
    is_paid           NUMBER,
    cost_invoice_date DATE
);

ALTER TABLE cost_invoices ADD CONSTRAINT costinvoices_pk PRIMARY KEY ( cost_invoice_id );

ALTER TABLE cost_invoices ADD CONSTRAINT costinvoices__un UNIQUE ( cost_invoice_nr );

CREATE TABLE delivery_methods (
    delivery_method_id   SMALLINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    delivery_method_name SMALLINT
);

ALTER TABLE delivery_methods ADD CONSTRAINT sales_pk PRIMARY KEY ( delivery_method_id );

CREATE TABLE employee_positions (
    position_id   SMALLINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    position_name NVARCHAR2(40) NOT NULL
);

ALTER TABLE employee_positions ADD CONSTRAINT employeepositions_pk PRIMARY KEY ( position_id );

ALTER TABLE employee_positions ADD CONSTRAINT employeepositions__un UNIQUE ( position_name );

--DROP TABLE employees;
CREATE TABLE employees (
    employee_id         INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    employee_name    NVARCHAR2(20) NOT NULL,
    employee_surname NVARCHAR2(30) NOT NULL,
    pesel            VARCHAR2(11),
    email           VARCHAR2(50 CHAR),
    address_id          INTEGER,
    contract_id         SMALLINT
);

COMMENT ON COLUMN employees.pesel IS
    'identyfikator pesel pracownika';

COMMENT ON COLUMN employees.address_id IS
    'id adresu zamieszkania pracownika, klucz obcy powi�zany z tabel� Addresses';

COMMENT ON COLUMN employees.contract_id IS
    'id rodzaju umowy pracownika, klucy obcz powizany z tabel� EmployeeContracts';

ALTER TABLE employees ADD CONSTRAINT employees_pk PRIMARY KEY ( employee_id );

--DROP TABLE employees_contracts;
CREATE TABLE employees_contracts (
    contract_id INTEGER GENERATED ALWAYS AS IDENTITY,
    wages       NUMBER(8, 2),
    section_id  SMALLINT,
    position_id SMALLINT,
    hire_date   DATE,
    end_date    DATE
);

COMMENT ON COLUMN employees_contracts."wages " IS
    'PL/SQL: musi zawiera� si� pomi�dzy wide�kami p�acowymi okre�lonymi dla ka�dego stanowiska w tabeli PayScales';

COMMENT ON COLUMN employees_contracts."end_date " IS
    'NULL - oznaczenie umowy na czas nieokre�lony';

ALTER TABLE employees_contracts ADD CONSTRAINT employeecontracts_pk PRIMARY KEY ( contract_id );

ALTER TABLE employees_contracts ADD CONSTRAINT employees_contracts__un UNIQUE ( position_id );

CREATE TABLE income_invoices (
    income_invoice_id   INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    income_invoice_nr   NVARCHAR2(20) NOT NULL,
    wholesale_client_id INTEGER NOT NULL,
    net_amount          NUMBER(10, 2) NOT NULL,
    tax_amount          NUMBER(10, 2) NOT NULL,
    income_invoice_date TIMESTAMP
);

COMMENT ON COLUMN income_invoices.net_amount IS
    'kwota netto transakcji';

ALTER TABLE income_invoices ADD CONSTRAINT invoices_pk PRIMARY KEY ( income_invoice_id );

ALTER TABLE income_invoices ADD CONSTRAINT incomeinvoices__un UNIQUE ( income_invoice_nr );

CREATE TABLE invoice_products_lists (
    invoice_list_id       INTEGER GENERATED ALWAYS AS IDENTITY
        CONSTRAINT nnc_rec_prod_lists_rec_list_id NOT NULL,
    income_invoice_id     INTEGER NOT NULL,
    product_id            INTEGER NOT NULL,
    purchased_product_qty SMALLINT
);

ALTER TABLE invoice_products_lists ADD CONSTRAINT invoice_products_lists_pk PRIMARY KEY ( invoice_list_id,
                                                                                          income_invoice_id );

ALTER TABLE invoice_products_lists ADD CONSTRAINT invoice_products_lists__un UNIQUE ( income_invoice_id );

CREATE TABLE online_storehouse (
    product_id         INTEGER NOT NULL,
    online_product_qty INTEGER DEFAULT 0 NOT NULL,
    deficit_alert      SMALLINT
);

COMMENT ON COLUMN online_storehouse.online_product_qty IS
    'pl/sql: kolumna modyfikowana w oparciu o kolumn� productInCartQuantity z tabeli Carts (zmniejszenie stanu ilo�ciowego produktu w zwi�zku ze sprzeda��) 
Stan ilo�ciowy jest zmniejszany w momencie umieszczenia produktu w koszyku zakupowym (Carts).
Podczas procesu biznesowego zapada decyzja o ile zwi�kszy� stan ilo�ciowy produktu poniewa� ilo�� produktu na zam�wieniu (tabela Orders kolumna onlineStoreQty)  nie musi si� zgadza� z ilo�ci� produktu dostarczonego.';

ALTER TABLE online_storehouse ADD CONSTRAINT stationarystorehousev1_pk PRIMARY KEY ( product_id );

CREATE TABLE ordered_products_lists (
    order_id             INTEGER NOT NULL,
    product_id           INTEGER NOT NULL,
    stationary_store_qty SMALLINT,
    online_store_qty     SMALLINT
);

COMMENT ON COLUMN ordered_products_lists.stationary_store_qty IS
    'Quantity of products reported from stationary storehouse.';

COMMENT ON COLUMN ordered_products_lists.online_store_qty IS
    'Quantity of products reported from online storehouse.';

ALTER TABLE ordered_products_lists ADD CONSTRAINT orderedproductslist_pk PRIMARY KEY ( order_id,
                                                                                       product_id );

CREATE TABLE orders (
    order_id        INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    order_nr        NVARCHAR2(20),
    supplier_id     SMALLINT NOT NULL,
    order_send_date DATE
);

ALTER TABLE orders ADD CONSTRAINT orders_pk PRIMARY KEY ( order_id );

ALTER TABLE orders ADD CONSTRAINT orders__un UNIQUE ( order_nr );

CREATE TABLE pay_scales (
    position_id SMALLINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    min_wages   NUMBER(8, 2) NOT NULL,
    max_wages   NUMBER(8, 2) NOT NULL
);

ALTER TABLE pay_scales ADD CONSTRAINT payscales_pk PRIMARY KEY ( position_id );

CREATE TABLE payment_methods (
    payment_method_id   SMALLINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    payment_method_name NVARCHAR2(50) NOT NULL
);

ALTER TABLE payment_methods ADD CONSTRAINT paymentmethods_pk PRIMARY KEY ( payment_method_id );

ALTER TABLE payment_methods ADD CONSTRAINT paymentmethods__un UNIQUE ( payment_method_name );

CREATE TABLE product_categories (
    category_id   SMALLINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    category_name NVARCHAR2(30) NOT NULL
);

ALTER TABLE product_categories ADD CONSTRAINT productcategories_pk PRIMARY KEY ( category_id );

ALTER TABLE product_categories ADD CONSTRAINT productcategories__un UNIQUE ( category_name );

CREATE TABLE PRODUCTS 
    (
    product_id    INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    category_id   SMALLINT,
    product_name  NVARCHAR2(100) NOT NULL,
    serial_number NVARCHAR2(50) DEFAULT ON NULL NULL,
    unit_price    NUMBER(8, 2) DEFAULT ON NULL 0,0 
    ) 
;
COMMENT ON COLUMN products.product_name IS
    'nazwa produktu	';

COMMENT ON COLUMN products.serial_number IS
    'numer seryjny/identyfikacyjny produktu';

COMMENT ON COLUMN products.unit_price IS
    'cena netto produktu (cena w sklepie)';

ALTER TABLE products ADD CONSTRAINT products_pk PRIMARY KEY ( product_id );

CREATE TABLE receipt_products_lists (
    receipt_list_id       INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    receipt_id            INTEGER NOT NULL,
    product_id            INTEGER NOT NULL,
    purchased_product_qty SMALLINT
);

ALTER TABLE receipt_products_lists ADD CONSTRAINT purchasedproductslist_pk PRIMARY KEY ( receipt_list_id,
                                                                                         receipt_id );

ALTER TABLE receipt_products_lists ADD CONSTRAINT receipt_products_lists__un UNIQUE ( receipt_id );

CREATE TABLE receipts (
    receipt_id    INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    "receipt_no " NVARCHAR2(20) NOT NULL,
    net_amount    NUMBER(10, 2) NOT NULL,
    tax_amount    NUMBER(10, 2) NOT NULL,
    receipt_date  TIMESTAMP
);

COMMENT ON COLUMN receipts.net_amount IS
    'kwota netto transakcji';

ALTER TABLE receipts ADD CONSTRAINT receipts_pk PRIMARY KEY ( receipt_id );

ALTER TABLE receipts ADD CONSTRAINT receipts__un UNIQUE ( "receipt_no " );

CREATE TABLE sections (
    section_id   SMALLINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    section_name VARCHAR2(100 CHAR) NOT NULL
);

ALTER TABLE sections ADD CONSTRAINT sections_pk PRIMARY KEY ( section_id );

ALTER TABLE sections ADD CONSTRAINT sections__un UNIQUE ( section_name );

CREATE TABLE stationary_storehouse (
    product_id       INTEGER NOT NULL,
    product_quantity INTEGER DEFAULT 1 NOT NULL,
    deficit_alert    SMALLINT
);

COMMENT ON COLUMN stationary_storehouse.product_quantity IS
    'pl/sql: kolumna modyfikowana w oparciu o kolumn� productInCartQuantity z tabeli Carts (zmniejszenie stanu ilo�ciowego produktu w zwi�zku ze sprzeda��) 
Stan ilo�ciowy jest zmniejszany w momencie rozpocz�cia transakcji.
Podczas procesu biznesowego zapada decyzja o ile zwi�kszy� stan ilo�ciowy produktu poniewa� ilo�� produktu na zam�wieniu (tabela Orders kolumna stationaryStoreQty)  nie musi si� zgadza� z ilo�ci� produktu dostarczonego.';

ALTER TABLE stationary_storehouse ADD CONSTRAINT storehouse_pk PRIMARY KEY ( product_id );

CREATE TABLE supplied_products_lists (
    supply_id         INTEGER NOT NULL,
    product_id        INTEGER NOT NULL,
    product_net_price NUMBER(10, 2),
    tax               NUMBER(3, 2),
    quantity          SMALLINT
);

COMMENT ON COLUMN supplied_products_lists.product_net_price IS
    'cena netto produktu dostarczonego
cena netto na fakturze VAT';

COMMENT ON COLUMN supplied_products_lists.tax IS
    'podatek VAT wyrazony w liczbie dziesi�tnej';

ALTER TABLE supplied_products_lists ADD CONSTRAINT suppliedproductlist_pk PRIMARY KEY ( supply_id,
                                                                                        product_id );

ALTER TABLE supplied_products_lists ADD CONSTRAINT supp_prod_lists_supplies_un UNIQUE ( supply_id );

CREATE TABLE suppliers (
    supplier_id      SMALLINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    "supplier_name " NVARCHAR2(100) NOT NULL,
    address_id       INTEGER,
    nip              NVARCHAR2(10) NOT NULL
);

COMMENT ON COLUMN suppliers."supplier_name " IS
    'nazwa dostawcy';

ALTER TABLE suppliers ADD CONSTRAINT suppliers_pkv2 PRIMARY KEY ( supplier_id );

CREATE TABLE supplies (
    supply_id        INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    order_nr         NVARCHAR2(20) NOT NULL,
    cost_invoice_id  INTEGER NOT NULL,
    "delivery_date " DATE NOT NULL
);

ALTER TABLE supplies ADD CONSTRAINT suppliers_pk PRIMARY KEY ( supply_id );

CREATE TABLE transaction_statuses (
    status_id   SMALLINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    status_name NVARCHAR2(30)
);

ALTER TABLE transaction_statuses ADD CONSTRAINT transactionstatus_pk PRIMARY KEY ( status_id );

ALTER TABLE transaction_statuses ADD CONSTRAINT transactionstatus__un UNIQUE ( status_name );

CREATE TABLE transactions (
    transaction_id     INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    invoice_id         INTEGER,
    receipt_id         INTEGER,
    product_id         INTEGER,
    employee_id        SMALLINT,
    payment_method_id  SMALLINT DEFAULT card NOT NULL,
    delivery_method_id SMALLINT NOT NULL,
    status_id          SMALLINT NOT NULL,
    is_paid            NUMBER,
    start_time         TIMESTAMP,
    end_time           TIMESTAMP
);

ALTER TABLE transactions ADD CONSTRAINT transactions_pk PRIMARY KEY ( transaction_id );

ALTER TABLE transactions ADD CONSTRAINT transactions__un_invoice UNIQUE ( invoice_id );

ALTER TABLE transactions ADD CONSTRAINT transactions__un_receipt UNIQUE ( receipt_id );

--DROP TABLE wholesale_clients;
CREATE TABLE wholesale_clients (
    wholesale_client_id   INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    wholesale_client_name NVARCHAR2(100) NOT NULL,
    address_id            INTEGER,
    nip                   VARCHAR2(10 CHAR),
    regon                 VARCHAR2(9 BYTE)
);

COMMENT ON COLUMN wholesale_clients.wholesale_client_name IS
    'informacje o klientach hurtowych';

ALTER TABLE wholesale_clients ADD CONSTRAINT clients_pk PRIMARY KEY ( wholesale_client_id );

--ALTER TABLE wholesale_clients ADD regon VARCHAR2(9 BYTE);
ALTER TABLE wholesale_clients ADD CONSTRAINT wholesale_clients_regon_un UNIQUE ( regon );

ALTER TABLE wholesale_clients ADD CONSTRAINT wholesale_clients_nip_un UNIQUE ( nip );

ALTER TABLE wholesale_clients
    ADD CONSTRAINT clients_adresses_fk FOREIGN KEY ( address_id )
        REFERENCES addresses ( address_id );

ALTER TABLE cost_invoices
    ADD CONSTRAINT costinvoices_suppliers_fk FOREIGN KEY ( supplier_id )
        REFERENCES suppliers ( supplier_id );

ALTER TABLE employees_contracts
    ADD CONSTRAINT empcontracts_emppositions_fk FOREIGN KEY ( position_id )
        REFERENCES employee_positions ( position_id );

ALTER TABLE employees_contracts
    ADD CONSTRAINT employeecontracts_sections_fk FOREIGN KEY ( section_id )
        REFERENCES sections ( section_id );

ALTER TABLE employees
    ADD CONSTRAINT employees_adresses_fk FOREIGN KEY ( address_id )
        REFERENCES addresses ( address_id );

ALTER TABLE employees
    ADD CONSTRAINT employees_employeecontracts_fk FOREIGN KEY ( contract_id )
        REFERENCES employees_contracts ( contract_id );

ALTER TABLE income_invoices
    ADD CONSTRAINT ininvoices_wholesaleclients_fk FOREIGN KEY ( wholesale_client_id )
        REFERENCES wholesale_clients ( wholesale_client_id );

ALTER TABLE invoice_products_lists
    ADD CONSTRAINT invoice_lists_income__fk FOREIGN KEY ( income_invoice_id )
        REFERENCES income_invoices ( income_invoice_id );

ALTER TABLE invoice_products_lists
    ADD CONSTRAINT invoice_products_lists__fk FOREIGN KEY ( product_id )
        REFERENCES products ( product_id );

ALTER TABLE online_storehouse
    ADD CONSTRAINT onlinestorehouse_products_fk FOREIGN KEY ( product_id )
        REFERENCES products ( product_id );

ALTER TABLE ordered_products_lists
    ADD CONSTRAINT orderedprodlist_orders_fk FOREIGN KEY ( order_id )
        REFERENCES orders ( order_id );

ALTER TABLE ordered_products_lists
    ADD CONSTRAINT orderedprodlist_products_fk FOREIGN KEY ( product_id )
        REFERENCES products ( product_id );

ALTER TABLE orders
    ADD CONSTRAINT orders_suppliers_fk FOREIGN KEY ( supplier_id )
        REFERENCES suppliers ( supplier_id );

ALTER TABLE pay_scales
    ADD CONSTRAINT payscales_employeepositions_fk FOREIGN KEY ( position_id )
        REFERENCES employee_positions ( position_id );

ALTER TABLE products
    ADD CONSTRAINT products_productcategories_fk FOREIGN KEY ( category_id )
        REFERENCES product_categories ( category_id );

ALTER TABLE receipt_products_lists
    ADD CONSTRAINT purchasedlist_products_fk FOREIGN KEY ( product_id )
        REFERENCES products ( product_id );

--  ERROR: FK name length exceeds maximum allowed length(30) 
ALTER TABLE receipt_products_lists
    ADD CONSTRAINT receipt_products_lists_receipts_fk FOREIGN KEY ( receipt_id )
        REFERENCES receipts ( receipt_id );

ALTER TABLE stationary_storehouse
    ADD CONSTRAINT stationstorehouse_products_fk FOREIGN KEY ( product_id )
        REFERENCES products ( product_id );

ALTER TABLE supplied_products_lists
    ADD CONSTRAINT suppliedprodlist_products_fk FOREIGN KEY ( product_id )
        REFERENCES products ( product_id );

ALTER TABLE supplied_products_lists
    ADD CONSTRAINT suppliedprodlist_supplies_fk FOREIGN KEY ( supply_id )
        REFERENCES supplies ( supply_id );

ALTER TABLE suppliers
    ADD CONSTRAINT suppliers_adresses_fk FOREIGN KEY ( address_id )
        REFERENCES addresses ( address_id );

ALTER TABLE supplies
    ADD CONSTRAINT supplies_cost_invoices_fk FOREIGN KEY ( cost_invoice_id )
        REFERENCES cost_invoices ( cost_invoice_id );

ALTER TABLE transactions
    ADD CONSTRAINT trans_delivery_meth_fk FOREIGN KEY ( delivery_method_id )
        REFERENCES delivery_methods ( delivery_method_id );

ALTER TABLE transactions
    ADD CONSTRAINT transactions_employees_fk FOREIGN KEY ( employee_id )
        REFERENCES employees ( employee_id );

ALTER TABLE transactions
    ADD CONSTRAINT trans_in_invoices_fk FOREIGN KEY ( invoice_id )
        REFERENCES income_invoices ( income_invoice_id );

ALTER TABLE transactions
    ADD CONSTRAINT transactions_paymentmethods_fk FOREIGN KEY ( payment_method_id )
        REFERENCES payment_methods ( payment_method_id );

ALTER TABLE transactions
    ADD CONSTRAINT transactions_receipts_fk FOREIGN KEY ( receipt_id )
        REFERENCES receipts ( receipt_id );

ALTER TABLE transactions
    ADD CONSTRAINT transactions_transtatus_fk FOREIGN KEY ( status_id )
        REFERENCES transaction_statuses ( status_id );

CREATE SEQUENCE PRODUCTS_product_ID_SEQ 
START WITH 1 
    NOCACHE 
    ORDER ;

CREATE OR REPLACE TRIGGER PRODUCTS_product_ID_TRG 
BEFORE INSERT ON PRODUCTS 
FOR EACH ROW 
WHEN (NEW.product_ID IS NULL) 
BEGIN
:new.product_id := products_product_id_seq.nextval;

end;
/



-- Oracle SQL Developer Data Modeler Summary Report: 
-- 
-- CREATE TABLE                            25
-- CREATE INDEX                             0
-- ALTER TABLE                             69
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           1
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                          1
-- CREATE MATERIALIZED VIEW                 0
-- CREATE MATERIALIZED VIEW LOG             0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- TSDP POLICY                              0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   4
-- WARNINGS                                 0
