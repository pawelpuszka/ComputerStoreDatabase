CREATE OR REPLACE PROCEDURE add_manager_id
IS
    CURSOR cur_contracts IS
        SELECT
             contract_id
            ,position_id
            ,manager_id
        FROM
            employees_contracts;

    TYPE nt_positions_type IS TABLE OF cur_contracts%ROWTYPE;

    v_positions_nt nt_positions_type := nt_positions_type();
    i PLS_INTEGER;

BEGIN
    OPEN cur_contracts;
    FETCH cur_contracts BULK COLLECT INTO v_positions_nt;
    CLOSE cur_contracts;

    i := v_positions_nt.first;

    LOOP
        EXIT WHEN i IS NULL;
        CASE v_positions_nt(i).position_id
            WHEN 1 THEN v_positions_nt(i).manager_id := NULL;
            WHEN 2 THEN v_positions_nt(i).manager_id := 1;
            WHEN 3 THEN v_positions_nt(i).manager_id := 1;
            WHEN 4 THEN v_positions_nt(i).manager_id := 1;
            WHEN 6 THEN v_positions_nt(i).manager_id := 1;
            WHEN 7 THEN v_positions_nt(i).manager_id := 1;
            WHEN 5 THEN v_positions_nt(i).manager_id := 4;
            WHEN 8 THEN v_positions_nt(i).manager_id := 2;
            WHEN 9 THEN v_positions_nt(i).manager_id := 3;
            WHEN 10 THEN v_positions_nt(i).manager_id := 4;
            WHEN 11 THEN v_positions_nt(i).manager_id := 6;
            WHEN 12 THEN v_positions_nt(i).manager_id := 7;
        END CASE;
        i := v_positions_nt.next(i);
    END LOOP;

    BEGIN
        FOR i IN v_positions_nt.first .. v_positions_nt.last
        LOOP
            UPDATE employees_contracts
            SET manager_id = v_positions_nt(i).manager_id
            WHERE position_id = v_positions_nt(i).position_id;
            COMMIT ;
        END LOOP;
        --COMMIT ;
    END;

END;
/

