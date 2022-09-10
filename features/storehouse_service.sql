/*
    storehouse service
*/

CREATE OR REPLACE	
PACKAGE storehouse_service
IS
    CURSOR find_product_cur(prod_id_in products.product_id%TYPE) RETURN products%ROWTYPE;
END storehouse_service; 
/

CREATE OR REPLACE	
PACKAGE BODY storehouse_service
IS
    CURSOR find_product_cur(prod_id_in products.product_id%TYPE) RETURN products%ROWTYPE IS
           SELECT 
                 product_id
                ,category_id
                ,product_name
                ,unit_price
            FROM 
                products
            WHERE
                product_id = prod_id_in
            FOR UPDATE WAIT 3
            ;
            
    PROCEDURE decrease_prod_qty(product_id_in     products.product_id%TYPE
                                                ,product_qty_in    invoice_products_lists.purchased_product_qty%TYPE
                                                ) 
    IS
        v_product_rec find_product_cur%ROWTYPE;
        is_stationary_sale BOOLEAN := transaction_pkg.v_curr_transact_rec.delivery_method_id = 4;
    BEGIN
        OPEN find_product_cur(product_id_in);
        FETCH find_product_cur INTO v_product_rec;
        IF is_stationary_sale THEN
           
        END IF;
    END update_stock;
END storehouse_service; 
/