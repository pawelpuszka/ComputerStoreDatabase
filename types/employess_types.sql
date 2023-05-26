CREATE OR REPLACE TYPE rec_emp_num_type IS OBJECT (
         emp_num        NUMBER
        ,section_name   VARCHAR2(100)
                                    );

CREATE OR REPLACE TYPE nt_emp_num_type IS TABLE OF rec_emp_num_type;