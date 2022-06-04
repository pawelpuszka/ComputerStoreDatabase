SET SERVEROUTPUT ON;

GRANT EXECUTE ON DBMS_CLOUD TO computer_store;
BEGIN
    DBMS_CLOUD.create_credential(
         crdential_name => 'object_store_credential'
        ,username => 'pawel.puszka@gmail.com'
        ,password => 'SsnIR;]7Yq<nFt6MmF7<'
    );
END;