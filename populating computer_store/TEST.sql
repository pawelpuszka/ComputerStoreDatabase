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

update employees
set employee_surname = 'Nowakowski'
where employee_id = 1;




    