SELECT COUNT(a.address_id), e.employee_id
FROM 
    addresses a
    LEFT JOIN employees e
        ON a.address_id = e.address_id
WHERE
    e.employee_id IS NULL
GROUP BY e.employee_id
;

SELECT a.address_id, a.street, a.city, a.phone_number, e.employee_id
FROM 
    addresses a
    LEFT JOIN employees e
        ON a.address_id = e.address_id
WHERE
    e.employee_id IS NULL
ORDER BY a.address_id
;


select *
from sections;

SELECT * FROM employees;

SELECT 
     e.employee_id
    ,e.employee_name
    ,e.employee_surname
    ,ep.position_name
    ,s.section_name
    ,ec.wages
FROM 
    employees e
    INNER JOIN employees_contracts ec
        ON ec.contract_id = e.contract_id
    INNER JOIN employee_positions ep
        ON ep.position_id = ec.position_id
    INNER JOIN sections s
        ON s.section_id = ec.section_id
;

update product_categories
set CATEGORY_NAME = 'karty muzyczne'
where category_id = 3;


ALTER TABLE employees_contracts drop constraint employee_contracts_check;
ALTER TABLE employees_contracts ADD CONSTRAINT emp_contracts_dates_check CHECK(hire_date + 183 < end_date);
insert into employees_contracts (wages, section_id, position_id, hire_date, end_date)
values(4500, 7, 13, sysdate, to_date('2022-05-15'));

create table products_copy
AS
(select * from products)
;

select p.product_id, pr.product_id
from products p
inner join products pr
on
 p.product_name = pr.product_name
 and p.product_id != pr.product_id;