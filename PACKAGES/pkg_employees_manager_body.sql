CREATE OR REPLACE PACKAGE BODY pkg_employees_manager
IS

    FUNCTION employees_number_in_section RETURN nt_emp_num_type
    IS
        emp_num_nt nt_emp_num_type := nt_emp_num_type();
    BEGIN
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




    FUNCTION get_emp_with_salary_above_avg(in_section_id IN sections.section_id%type) RETURN nt_emp_type
    IS
        nt_employees    nt_emp_type := nt_emp_type();
        first_index     CONSTANT PLS_INTEGER := 1;
    BEGIN
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

        IF (NOT nt_employees.exists(first_index)) THEN
            RAISE_APPLICATION_ERROR(-20010, 'There are no employees with salary above average in section ' || in_section_id );
        END IF;

        RETURN nt_employees;

    EXCEPTION
        WHEN OTHERS THEN
            pkg_exception_handling.LOG_EXCEPTION(sqlcode
                                                ,sqlerrm
                                                ,'pkg_employees_manager.get_emp_with_salary_above_avg'
                                                ,sysdate);
            RAISE ;
    END get_emp_with_salary_above_avg;




    PROCEDURE add_employee(in_name          IN EMPLOYEES.EMPLOYEE_NAME%TYPE
                          ,in_surname       IN EMPLOYEES.EMPLOYEE_SURNAME%TYPE
                          ,in_pesel         IN EMPLOYEES.PESEL%TYPE
                          ,in_email         IN EMPLOYEES.EMAIL%TYPE
                          ,in_wages         IN EMPLOYEES_CONTRACTS.WAGES%TYPE
                          --,in_section_id    IN EMPLOYEES_CONTRACTS.SECTION_ID%TYPE
                          ,in_position_id   IN EMPLOYEES_CONTRACTS.POSITION_ID%TYPE
                          ,in_street        IN ADDRESSES.STREET%TYPE
                          ,in_city          IN ADDRESSES.CITY%TYPE
                          ,in_postal_code   IN ADDRESSES.POSTAL_CODE%TYPE   --validation in the future
                          ,in_phone_no      IN ADDRESSES.PHONE_NUMBER%TYPE) --validation in the future
    IS

        v_object_name   VARCHAR2(100);
        v_section_id    SECTIONS.SECTION_ID%TYPE;
        v_contract_id   EMPLOYEES_CONTRACTS.CONTRACT_ID%TYPE;
        v_address_id    ADDRESSES.ADDRESS_ID%TYPE;

            FUNCTION get_section_for(in_position_id EMPLOYEES_CONTRACTS.POSITION_ID%TYPE) RETURN SECTIONS.SECTION_ID%TYPE
            IS
                v_sec_id NUMBER;
            BEGIN
                CASE
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
                    v_object_name := 'pkg_employees_manager.add_employee.get_section_for';
                    RAISE_APPLICATION_ERROR(-20015, 'Wrong position name. No possibility of adjusting the position to section');

            END get_section_for;


            FUNCTION position_exists(in_position_id IN EMPLOYEES_CONTRACTS.POSITION_ID%TYPE) RETURN BOOLEAN
            IS
                v_tmp       NUMBER;
            BEGIN
                SELECT 1
                INTO v_tmp
                FROM employee_positions
                WHERE position_id = in_position_id;

                RETURN SQL%FOUND;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RETURN FALSE;
                WHEN TOO_MANY_ROWS THEN
                    v_object_name := 'pkg_employees_manager.add_employee.position_exists';
                    RAISE_APPLICATION_ERROR(-20100, 'Inconsistent data in EMPLOYEE_POSITION. Doubled position in table.');

            END position_exists;


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
                OPEN cur_wages;
                FETCH cur_wages INTO v_tmp;
                ret_val := cur_wages%FOUND;
                CLOSE cur_wages;

                RETURN ret_val;

            END wages_in_pay_scale;


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

        IF (NOT position_exists(in_position_id)) THEN
            v_object_name := 'pkg_employees_manager.add_employee';
            RAISE_APPLICATION_ERROR(-20020, 'Wrong position id: ' || in_position_id);
        END IF;

        IF (NOT wages_in_pay_scale( in_wages, in_position_id)) THEN
            v_object_name := 'pkg_employees_manager.add_employee';
            RAISE_APPLICATION_ERROR(-20025, 'Wages ' || in_wages || ' beyond the scale for this position: ' || in_position_id);
        END IF;

        v_section_id := get_section_for(in_position_id);
        insert_contract_data();

        --pesel validation - has to have 11 signs
        insert_address_data();

        IF (in_name IS NULL ) THEN
            v_object_name := 'pkg_employees_manager.add_employee';
            RAISE_APPLICATION_ERROR(-20005, 'The name field can not be empty.');
        END IF;

        IF (in_surname IS NULL ) THEN
            v_object_name := 'pkg_employees_manager.add_employee';
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


END pkg_employees_manager;