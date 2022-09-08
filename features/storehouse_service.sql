/*
    storehouse service
*/

CREATE OR REPLACE	
PACKAGE storehouse_service
IS

END storehouse_service; 
/

CREATE OR REPLACE	
PACKAGE BODY storehouse_service
IS
    CURSOR find_product_id(prod_id_in products.product_id%TYPE) RETURN products%ROWTYPE IS
           SELECT 
                 product_id
                ,category_id
                ,product_name
                ,unit_price
            FROM 
                products
            ;
END storehouse_service; 
/