CREATE TABLE exception_logs(
     id             NUMBER GENERATED ALWAYS AS IDENTITY
    ,code           NUMBER
    ,message        VARCHAR2(4000)
    ,object_name    VARCHAR2(200)
    ,ex_date        DATE
);