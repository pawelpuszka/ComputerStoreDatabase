SET SERVEROUTPUT ON;

CREATE TABLE wholesale_clients_copy
AS
(SELECT * FROM wholesale_clients);

select * 
from wholesale_clients_copy;

alter table wholesale_clients_copy drop CONSTRAINT SYS_C0036080;

DROP PROCEDURE add_address_id;
CREATE OR REPLACE
PROCEDURE add_address_id 
IS  
    TYPE address_id_type IS TABLE OF addresses.address_id%TYPE INDEX BY PLS_INTEGER;
    at_address_ids address_id_type;
    
    v_i INTEGER := 1;

BEGIN
    SELECT a.address_id
    BULK COLLECT INTO at_address_ids
    FROM addresses a
        LEFT JOIN employees e
            ON a.address_id = e.address_id
    WHERE e.employee_id IS NULL
    ;
    
    FOR id IN at_address_ids.FIRST..at_address_ids.LAST
    LOOP
        UPDATE wholesale_clients_copy
        SET address_id = at_address_ids(id)
        WHERE wholesale_client_id = id
        ;
        COMMIT;
    END LOOP;
END add_address_id;
/
BEGIN
    add_address_id();
END;
/

    SELECT count(a.address_id)
    FROM addresses a
        LEFT JOIN employees e
            ON a.address_id = e.address_id
    WHERE e.employee_id IS NULL
    ;