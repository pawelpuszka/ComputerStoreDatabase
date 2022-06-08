SET SERVEROUTPUT ON;

SELECT
    hire_date,
    end_date,
    position_id
FROM
    employees_contracts 
where position_id in (8,9)
    ;

select employee_id
from transactions;

SELECT t.employee_id
FROM transactions t
INNER JOIN employees e
    ON t.employee_id = e.employee_id
INNER JOIN employees_contracts ec
    ON e.contract_id = ec.contract_id
WHERE 
    CAST(t.start_time AS DATE) > ec.hire_date;
    
--daty zatrudnienia pracowników którzy obsugują transakcje
