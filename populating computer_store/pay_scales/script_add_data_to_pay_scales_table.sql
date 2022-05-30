INSERT INTO pay_scales(
     min_wages
    ,max_wages
)
SELECT
     set_min_wages(ep.position_id)
    ,set_max_wages(ep.position_id)
FROM employee_positions ep
;

DROP FUNCTION set_min_wages;
CREATE OR REPLACE 
FUNCTION set_min_wages(in_position_id pay_scales.position_id%TYPE) RETURN pay_scales.min_wages%TYPE
IS
    v_min_wages pay_scales.min_wages%TYPE;
BEGIN
    CASE
        WHEN in_position_id = 1 THEN v_min_wages := 10000;
        WHEN in_position_id = 2 THEN v_min_wages := 7000;
        WHEN in_position_id = 3 THEN v_min_wages := 7000;
        WHEN in_position_id = 4 THEN v_min_wages := 7000;
        WHEN in_position_id = 5 THEN v_min_wages := 7000;
        WHEN in_position_id = 6 THEN v_min_wages := 7000;
        WHEN in_position_id = 7 THEN v_min_wages := 7000;
        WHEN in_position_id = 8 THEN v_min_wages := 2500;
        WHEN in_position_id = 9 THEN v_min_wages := 2500;
        WHEN in_position_id = 10 THEN v_min_wages := 2500;
        WHEN in_position_id = 11 THEN v_min_wages := 2500;
        WHEN in_position_id = 12 THEN v_min_wages := 3000;
        WHEN in_position_id = 13 THEN v_min_wages := 3000;
    END CASE;
    
    RETURN v_min_wages;
END set_min_wages;
/

DROP FUNCTION set_max_wages;
CREATE OR REPLACE 
FUNCTION set_max_wages(in_position_id pay_scales.position_id%TYPE) RETURN pay_scales.max_wages%TYPE
IS
    v_max_wages pay_scales.max_wages%TYPE;
BEGIN
    CASE
        WHEN in_position_id = 1 THEN v_max_wages := 20000;
        WHEN in_position_id = 2 THEN v_max_wages := 12000;
        WHEN in_position_id = 3 THEN v_max_wages := 12000;
        WHEN in_position_id = 4 THEN v_max_wages := 12000;
        WHEN in_position_id = 5 THEN v_max_wages := 12000;
        WHEN in_position_id = 6 THEN v_max_wages := 12000;
        WHEN in_position_id = 7 THEN v_max_wages := 12000;
        WHEN in_position_id = 8 THEN v_max_wages := 4500;
        WHEN in_position_id = 9 THEN v_max_wages := 5500;
        WHEN in_position_id = 10 THEN v_max_wages := 4500;
        WHEN in_position_id = 11 THEN v_max_wages := 4500;
        WHEN in_position_id = 12 THEN v_max_wages := 6000;
        WHEN in_position_id = 13 THEN v_max_wages := 5000;
    END CASE;
    
    RETURN v_max_wages;
END set_max_wages;
/