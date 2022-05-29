SET SERVEROUTPUT ON;



DROP TABLE transform_employees_contracts;
CREATE TABLE transform_employees_contracts(
    contract_id INTEGER GENERATED ALWAYS AS IDENTITY,
    wages       NUMBER(8, 2),
    section_id  SMALLINT,
    position_id SMALLINT,
    hire_date   DATE,
    end_date    DATE
);

SELECT *
FROM transform_employees_contracts
;