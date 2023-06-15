CREATE OR REPLACE VIEW VW_EMPLOYEES_WITH_EXPIRING_CONTRACT
AS
    SELECT
        concat(emp.employee_surname || ', ', emp.employee_name) AS  employee_full_name
        ,emp.pesel
        ,concat(addr.street || ', ', addr.city) AS address
        ,concat(emp.email || ', ', addr.phone_number) AS contact_details
        ,sec.section_name
        ,ep.position_name
        ,ec.wages
        ,(SELECT concat(e.employee_surname || ', ', e.employee_name) FROM employees e WHERE ec.manager_id = e.employee_id) AS manager_full_name
        ,ec.hire_date
        ,ec.end_date
        ,months_between(ec.end_date, sysdate) AS remaining_time_to_terminate
    FROM employees emp
         JOIN employees_contracts ec ON emp.contract_id = ec.contract_id
         JOIN employee_positions ep ON ec.position_id = ep.position_id
         JOIN addresses addr ON addr.address_id = emp.address_id
         JOIN sections sec ON ec.section_id = sec.section_id
    WHERE
        months_between(ec.end_date, sysdate) <= 6
    ORDER BY
        remaining_time_to_terminate DESC
    ;

