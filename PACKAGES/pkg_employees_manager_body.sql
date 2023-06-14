CREATE OR REPLACE PACKAGE BODY pkg_employees_manager
IS

    /***** PRIVATE *******/

    v_object_name   VARCHAR2(100);

    FUNCTION get_section_for(in_position_id EMPLOYEES_CONTRACTS.POSITION_ID%TYPE) RETURN SECTIONS.SECTION_ID%TYPE
    IS
        v_sec_id NUMBER;
    BEGIN
        CASE
            WHEN in_position_id IS NULL THEN v_sec_id := NULL;
            WHEN in_position_id = 1 THEN v_sec_id := 1;
            WHEN in_position_id IN (2, 6) THEN v_sec_id := 2;
            WHEN in_position_id = 7 THEN v_sec_id := 6;
            WHEN in_position_id IN (8, 9) THEN v_sec_id := 3;
            WHEN in_position_id = 10 THEN v_sec_id := 4;
            WHEN in_position_id = 11 THEN v_sec_id := 5;
            WHEN in_position_id = 12 THEN v_sec_id := 6;
            WHEN in_position_id = 13 THEN v_sec_id := 7;
            ELSE RAISE CASE_NOT_FOUND;
            END CASE;

        RETURN v_sec_id;

    EXCEPTION
        WHEN CASE_NOT_FOUND THEN
            v_object_name := 'pkg_employees_manager.get_section_for';
            RAISE_APPLICATION_ERROR(-20015, 'Wrong position name. No possibility of adjusting the position to section');

    END get_section_for;



    FUNCTION get_position_for(in_employee_id employees.employee_id%type) RETURN  EMPLOYEES_CONTRACTS.POSITION_ID%TYPE
    IS
        v_position EMPLOYEES_CONTRACTS.POSITION_ID%TYPE;
    BEGIN
        v_object_name := 'pkg_employees_manager.get_position_for';

        SELECT position_id
        INTO v_position
        FROM employees_contracts
        WHERE contract_id = (SELECT contract_id FROM employees WHERE employee_id = in_employee_id);

        RETURN v_position;

    EXCEPTION
        WHEN no_data_found THEN
            raise_application_error(-20200, 'The employee with id ' || in_employee_id || ' does not exist.');
        WHEN too_many_rows THEN
            raise_application_error(-20210, 'CRITICAL ERROR!! There are more than one employee with id ' || in_employee_id);

    END get_position_for;



    FUNCTION get_wages_of(in_employee_id employees.employee_id%type) RETURN employees_contracts.wages%TYPE
    IS
        v_wages employees_contracts.wages%TYPE;
    BEGIN
        v_object_name := 'pkg_employees_manager.get_wages_of';

        SELECT wages
        INTO v_wages
        FROM employees_contracts
        WHERE contract_id = (SELECT contract_id FROM employees WHERE employee_id = in_employee_id);

        RETURN v_wages;

    EXCEPTION
        WHEN no_data_found THEN
            raise_application_error(-20200, 'The employee with id ' || in_employee_id || ' does not exist.');
        WHEN too_many_rows THEN
            raise_application_error(-20210, 'CRITICAL ERROR!! There are more than one employee with id ' || in_employee_id);
    END get_wages_of;



    FUNCTION wages_in_pay_scale( in_wages IN EMPLOYEES_CONTRACTS.WAGES%TYPE
                                ,in_position_id IN EMPLOYEES_CONTRACTS.POSITION_ID%TYPE) RETURN BOOLEAN
    IS
        CURSOR cur_wages IS
            SELECT 1
            FROM pay_scales
            WHERE position_id = in_position_id
              AND in_wages BETWEEN min_wages AND max_wages;

        v_tmp   NUMBER;
        ret_val BOOLEAN;

    BEGIN
        v_object_name := 'pkg_employees_manager.wages_in_pay_scale';
    
        OPEN cur_wages;
        FETCH cur_wages INTO v_tmp;
        ret_val := cur_wages%FOUND;
        CLOSE cur_wages;

        RETURN ret_val;
    
    EXCEPTION
        WHEN OTHERS THEN
            RAISE;

    END wages_in_pay_scale;




    /***** PUBLIC *******/

    FUNCTION employees_number_in_section RETURN nt_emp_num_type
    IS
        emp_num_nt nt_emp_num_type := nt_emp_num_type();
    BEGIN
        v_object_name := 'pkg_employees_manager.employees_number_in_section';
        
        SELECT
            REC_EMP_NUM_TYPE(count(*), s.section_name)
        BULK COLLECT INTO
            emp_num_nt
        FROM
            employees e
                JOIN employees_contracts ec ON e.contract_id = ec.contract_id
                JOIN sections s ON s.section_id = ec.section_id
        GROUP BY
            s.section_name
        ;
        RETURN emp_num_nt;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE ;
            
    END employees_number_in_section;



    FUNCTION get_emp_with_salary_above_avg(in_section_id IN sections.section_id%type) RETURN nt_emp_basic_type
    IS
        nt_employees    nt_emp_basic_type := nt_emp_basic_type();
    BEGIN
         v_object_name := 'pkg_employees_manager.get_emp_with_salary_above_avg';
            
        SELECT
             employee_id
            ,employee_name
            ,employee_surname
        BULK COLLECT INTO nt_employees
        FROM employees e
            JOIN employees_contracts ec ON e.contract_id = ec.contract_id
        WHERE ec.wages > (SELECT avg(ec2.wages) FROM employees_contracts ec2
                            WHERE ec2.section_id = ec.section_id
                            GROUP BY ec2.section_id)
            AND ec.section_id = in_section_id;

        IF (nt_employees IS NULL ) THEN
            RAISE_APPLICATION_ERROR(-20010, 'There are no employees in section ' || in_section_id );
        END IF;

        RETURN nt_employees;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE ;
    END get_emp_with_salary_above_avg;



    PROCEDURE add_employee(in_name          IN EMPLOYEES.EMPLOYEE_NAME%TYPE
                          ,in_surname       IN EMPLOYEES.EMPLOYEE_SURNAME%TYPE
                          ,in_pesel         IN EMPLOYEES.PESEL%TYPE
                          ,in_email         IN EMPLOYEES.EMAIL%TYPE
                          ,in_wages         IN EMPLOYEES_CONTRACTS.WAGES%TYPE
                          ,in_position_id   IN EMPLOYEES_CONTRACTS.POSITION_ID%TYPE
                          ,in_street        IN ADDRESSES.STREET%TYPE
                          ,in_city          IN ADDRESSES.CITY%TYPE
                          ,in_postal_code   IN ADDRESSES.POSTAL_CODE%TYPE   --validation in the future
                          ,in_phone_no      IN ADDRESSES.PHONE_NUMBER%TYPE) --validation in the future
    IS

        v_section_id    SECTIONS.SECTION_ID%TYPE;
        v_contract_id   EMPLOYEES_CONTRACTS.CONTRACT_ID%TYPE;
        v_address_id    ADDRESSES.ADDRESS_ID%TYPE;

            FUNCTION position_exists(in_position_id IN EMPLOYEES_CONTRACTS.POSITION_ID%TYPE) RETURN BOOLEAN
            IS
                v_tmp       NUMBER;
            BEGIN
                v_object_name := 'pkg_employees_manager.add_employee.position_exists';

                SELECT 1
                INTO v_tmp
                FROM employee_positions
                WHERE position_id = in_position_id;

                RETURN SQL%FOUND;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RETURN FALSE;
                WHEN TOO_MANY_ROWS THEN
                    RAISE_APPLICATION_ERROR(-20100, 'Inconsistent data in EMPLOYEE_POSITION. Doubled position in table.');

            END position_exists;


            PROCEDURE insert_contract_data IS
            BEGIN
                INSERT INTO employees_contracts (WAGES, SECTION_ID, POSITION_ID, HIRE_DATE, END_DATE)
                VALUES (in_wages, v_section_id, in_position_id, sysdate, NULL)
                RETURNING contract_id INTO v_contract_id;

            EXCEPTION
            WHEN VALUE_ERROR THEN
                v_object_name := 'pkg_employees_manager.add_employee.insert_contract_data';
                RAISE_APPLICATION_ERROR(-20030, 'Something is wrong with CONTRACT data inserted into database');

            END insert_contract_data;


            PROCEDURE insert_address_data IS
            BEGIN
                INSERT INTO addresses(street, city, postal_code, phone_number)
                VALUES (in_street, in_city, in_postal_code, in_phone_no)
                RETURNING address_id INTO v_address_id;

            EXCEPTION
                WHEN VALUE_ERROR THEN
                    v_object_name := 'pkg_employees_manager.add_employee.insert_address_data';
                    RAISE_APPLICATION_ERROR(-20035, 'Something is wrong with ADDRESS data inserted into database');

            END insert_address_data;


            PROCEDURE insert_employee_data IS
            BEGIN
                INSERT INTO employees(employee_name, employee_surname, pesel, email, address_id, contract_id)
                VALUES (in_name, in_surname, in_pesel, in_email, v_address_id, v_contract_id);

            EXCEPTION
                WHEN VALUE_ERROR THEN
                    v_object_name := 'pkg_employees_manager.add_employee.insert_employee_data';
                    RAISE_APPLICATION_ERROR(-20040, 'Something is wrong with EMPLOYEE data inserted into database');

            END insert_employee_data;


    BEGIN
        v_object_name := 'pkg_employees_manager.add_employee';
         
        IF (NOT position_exists(in_position_id)) THEN
            RAISE_APPLICATION_ERROR(-20020, 'Wrong position id: ' || in_position_id);
        END IF;

        IF (NOT wages_in_pay_scale( in_wages, in_position_id)) THEN
            RAISE_APPLICATION_ERROR(-20025, 'Wages ' || in_wages || ' beyond the scale for this position: ' || in_position_id);
        END IF;

        v_section_id := get_section_for(in_position_id);
        insert_contract_data();

        --pesel validation - has to have 11 signs
        insert_address_data();

        IF (in_name IS NULL ) THEN
            RAISE_APPLICATION_ERROR(-20005, 'The name field can not be empty.');
        END IF;

        IF (in_surname IS NULL ) THEN
            RAISE_APPLICATION_ERROR(-20010, 'The surname field can not be empty.');
        END IF;

        insert_employee_data();

        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            pkg_exception_handling.LOG_EXCEPTION(sqlcode
                                                ,sqlerrm
                                                ,'pkg_employees_manager.add_employee'
                                                ,sysdate);
            ROLLBACK ;
            RAISE ;

    END add_employee;



    PROCEDURE update_employee_data(in_employee_id   IN EMPLOYEES.employee_id%TYPE
                                  ,in_email         IN EMPLOYEES.EMAIL%TYPE DEFAULT NULL
                                  ,in_wages         IN EMPLOYEES_CONTRACTS.WAGES%TYPE DEFAULT NULL
                                  ,in_position_id   IN EMPLOYEES_CONTRACTS.POSITION_ID%TYPE DEFAULT NULL
                                  ,in_end_date      IN employees_contracts.hire_date%type DEFAULT NULL
                                  ,in_street        IN ADDRESSES.STREET%TYPE DEFAULT NULL
                                  ,in_city          IN ADDRESSES.CITY%TYPE DEFAULT NULL
                                  ,in_postal_code   IN ADDRESSES.POSTAL_CODE%TYPE DEFAULT NULL
                                  ,in_phone_no      IN ADDRESSES.PHONE_NUMBER%TYPE DEFAULT NULL)
    IS

            FUNCTION fields_empty RETURN BOOLEAN
            IS
                v_ret_val BOOLEAN := FALSE;
            BEGIN
                IF (in_email IS NULL AND
                    in_wages IS NULL AND
                    in_position_id IS NULL AND
                    in_street IS NULL AND
                    in_city IS NULL AND
                    in_postal_code IS NULL AND
                    in_phone_no IS NULL ) THEN

                    v_ret_val := TRUE;
                END IF;
                RETURN v_ret_val;
            END fields_empty;


            PROCEDURE update_email IS
            BEGIN
                v_object_name := 'pkg_employees_manager.update_employee_data.update_email';

                UPDATE employees
                SET email = coalesce(in_email, email)
                WHERE employee_id = in_employee_id;

                IF (SQL%ROWCOUNT = 0) THEN
                   
                    raise_application_error(20110, 'The employee with id ' || in_employee_id || ' does not exist');
                END IF;
                
            EXCEPTION
                WHEN OTHERS THEN
                    RAISE;
                    
            END update_email;


            PROCEDURE update_contract
            IS
                v_section_id    employees_contracts.section_id%TYPE;
                v_position_id   employees_contracts.position_id%TYPE;
                v_wages         EMPLOYEES_CONTRACTS.WAGES%TYPE;
            BEGIN
                v_object_name := 'pkg_employees_manager.update_employee_data.update_contract';
                v_section_id    := get_section_for(in_position_id);
                v_position_id   := get_position_for(in_employee_id);
                v_wages         := get_wages_of(in_employee_id);

                IF (NOT wages_in_pay_scale( nvl(in_wages, v_wages), v_position_id)) THEN
                    RAISE_APPLICATION_ERROR(-20025, 'Wages ' || in_wages || ' beyond the scale for this position: ' || in_position_id);
                END IF;

                UPDATE employees_contracts
                SET  wages = coalesce(in_wages, wages)
                    ,position_id = coalesce(in_position_id, position_id)
                    ,section_id = coalesce(v_section_id, section_id)
                    ,end_date = coalesce(in_end_date, end_date)
                WHERE contract_id = (SELECT contract_id FROM employees WHERE employee_id = in_employee_id);

                IF (SQL%ROWCOUNT = 0) THEN
                    raise_application_error(20115, 'The employee with id ' || in_employee_id || ' does''t have a contract.');
                END IF;

            EXCEPTION
                WHEN OTHERS THEN
                    RAISE;
                    
            END update_contract;


            PROCEDURE update_address IS
            BEGIN
                v_object_name := 'pkg_employees_manager.update_employee_data.update_address';

                UPDATE addresses
                SET street = coalesce(in_street, street)
                    ,city = coalesce(in_city, city)
                    ,postal_code = coalesce(in_postal_code, postal_code)
                    ,phone_number = coalesce(in_phone_no, phone_number)
                WHERE address_id = (SELECT address_id FROM employees WHERE employee_id = in_employee_id);

                IF (SQL%ROWCOUNT = 0) THEN
                    raise_application_error(20120, 'The employee with id ' || in_employee_id || ' does''t have an address.');
                END IF;
                
            EXCEPTION
                WHEN OTHERS THEN
                    RAISE;
                    
            END update_address;

    BEGIN
        
        v_object_name := 'pkg_employees_manager.update_employee_data';
  
        IF (fields_empty()) THEN
            raise_application_error(-20100, 'Every field in the form is empty. There have to be at least one filled.' );
        END IF;

        update_email();
        update_contract();
        update_address();

        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            pkg_exception_handling.LOG_EXCEPTION(sqlcode
                                                ,sqlerrm
                                                ,v_object_name
                                                ,sysdate);
            ROLLBACK;
            RAISE;

    END update_employee_data;



    --
    FUNCTION get_employees_with_expiring_contract(in_employee_id IN EMPLOYEES.employee_id%TYPE) RETURN SYS_REFCURSOR
    IS
        v_emps_expiring_cotracts    SYS_REFCURSOR;
        const_months_remaining      CONSTANT PLS_INTEGER := 6;
    BEGIN
        v_object_name := 'pkg_employees_manager.get_employees_with_expiring_contract';

        OPEN v_emps_expiring_cotracts FOR
            SELECT
                 concat(emp.employee_surname, ', ', emp.employee_name) AS  employee_full_name
                ,emp.pesel
                ,concat(addr.street, ', ', addr.city) AS address
                ,concat(emp.email, ', ', addr.phone_number) AS contact_details
                ,sec.section_name
                ,ep.position_name
                ,ec.wages
                ,(SELECT concat(e.employee_surname, ', ', e.employee_name) FROM employees e WHERE ec.manager_id = e.employee_id) AS manager_full_name
                ,ec.hire_date
                ,ec.end_date
                ,(ec.end_date, sysdate) AS remaining_time_to_terminate
            FROM employees emp
                JOIN employees_contracts ec ON emp.contract_id = ec.contract_id
                JOIN employee_positions ep ON ec.position_id = ep.position_id
                JOIN addresses addr ON addr.address_id = emp.address_id
                JOIN sections sec ON ec.section_id = sec.section_id
            WHERE
                emp.employee_id = in_employee_id
                AND (ec.end_date, sysdate) <= const_months_remaining
        ;

        RETURN v_emps_expiring_cotracts;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END get_employees_with_expiring_contract;

END pkg_employees_manager;
