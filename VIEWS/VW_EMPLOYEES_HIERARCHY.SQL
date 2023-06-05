CREATE OR REPLACE VIEW VW_EMPLOYEES_HIERARCHY
AS
    SELECT
        e.employee_name
      ,e.employee_surname
      ,(SELECT ep.position_name FROM employee_positions ep WHERE ec.position_id = ep.position_id) AS position
      ,mgr.employee_name      AS manager_name
      ,mgr.employee_surname   AS manager_surname
      ,level AS level_of_hierarchy
    FROM
        employees_contracts ec
            JOIN employees e ON ec.contract_id = e.contract_id
            left JOIN employees mgr ON mgr.employee_id =  ec.manager_id
    START WITH e.employee_id = 1
    CONNECT BY PRIOR e.employee_id = ec.manager_id
    ORDER BY level ASC
;