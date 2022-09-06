/*
    The main purpose of this package is to provide a help while developing features for Computer_Store database.
    ver.: 1.0
    author: Pawe³ Puszka
    contact: pawel.puszka@gmail.com
    
    ChangeLog
        6.09.2022
        get_payment_term_id - utility fixes badly designed connection between  CLIENT_LOYALTY_CARDS and PAYMENT_TERMS tables. While creating new invoice there is payment_term_id needed based 
                                         on customer's loyalty_card_id. It can't be connected through SQL statement because  payment_term_id doesn't exist yet in INCOME_INVOICES table.
*/
CREATE OR REPLACE
PACKAGE computer_store_db_utils 
IS
    FUNCTION get_payment_term_id(loy_card_id_in wholesale_clients.loyalty_card_id%TYPE) RETURN payment_terms.payment_term_id%TYPE;
END  computer_store_db_utils;
/


CREATE OR REPLACE
PACKAGE BODY computer_store_db_utils 
IS
    FUNCTION get_payment_term_id(loy_card_id_in wholesale_clients.loyalty_card_id%TYPE) RETURN payment_terms.payment_term_id%TYPE
    IS
        paymnt_term_id payment_terms.payment_term_id%TYPE;
    BEGIN
        CASE loy_card_id_in
             WHEN 1 THEN paymnt_term_id := 4;
             WHEN 2 THEN paymnt_term_id := 3;
             WHEN 3 THEN paymnt_term_id := 2;
             ELSE paymnt_term_id := 1;
        END CASE;
        RETURN	paymnt_term_id;
    END get_payment_term_id;
    
END  computer_store_db_utils;
/