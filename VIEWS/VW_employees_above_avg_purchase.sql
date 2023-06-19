CREATE OR REPLACE VIEW VW_employees_above_avg_purchase
AS
WITH avg_invoice_value_in_year AS (
    SELECT
        a.*
    FROM (
             SELECT
                 calc.income_invoice_id
               ,y.year
               ,avg(calc.product_purchase_value) OVER ( PARTITION BY y.year) AS avg_invoice_val
               ,row_number() OVER (PARTITION BY y.year, calc.income_invoice_id ORDER BY y.year) AS row_num
             FROM (SELECT
                       ipl.income_invoice_id
                     ,sum(ipl.purchased_product_qty * p.unit_price) AS product_purchase_value
                   FROM
                       invoice_products_lists ipl
                           INNER JOIN products p ON ipl.product_id = p.product_id
                   GROUP BY
                       ipl.income_invoice_id) calc
                      INNER JOIN (SELECT
                                      extract(YEAR FROM start_time) AS year
                                    ,i.income_invoice_id
                                  FROM transactions t
                                           INNER JOIN income_invoices i ON t.transaction_id = i.transaction_id ) y
                                 ON y.income_invoice_id = calc.income_invoice_id
         ) a
    WHERE
            a.row_num = 1
)
SELECT
    e.EMPLOYEE_NAME
  ,e.EMPLOYEE_SURNAME
  ,ec.contract_id
  ,ep.position_name
  ,(SELECT concat(a.city || ' ', 'ul.' || a.street) FROM addresses a WHERE a.address_id = e.address_id) AS address
  ,trans.year
  ,trans.total_invoice_value
  ,trans.payment_method
  ,trans.transaction_status
FROM
    employees e
        INNER JOIN employees_contracts ec ON e.contract_id = ec.contract_id
        INNER JOIN employee_positions ep ON ec.position_id = ep.position_id
        LEFT JOIN
        (
            SELECT
                t.transaction_id
              ,t.employee_id
              ,(SELECT pm.payment_method_name FROM payment_methods pm WHERE pm.payment_method_id = t.payment_method_id) payment_method
              ,(SELECT ts.status_name FROM transaction_statuses ts WHERE ts.status_id = t.status_id) transaction_status
              ,extract(YEAR FROM t.start_time) AS year
              ,tot_val.total_invoice_value
            FROM
                transactions t
                    INNER JOIN
                    (
                        SELECT
                            ipl.income_invoice_id
                          ,ii.transaction_id
                          ,sum(ipl.purchased_product_qty * p.product_id) AS total_invoice_value
                        FROM
                            invoice_products_lists ipl
                                INNER JOIN products p ON ipl.product_id = p.product_id
                                INNER JOIN income_invoices ii ON ii.income_invoice_id = ipl.income_invoice_id
                        GROUP BY
                            ipl.income_invoice_id
                          ,ii.transaction_id
                    ) tot_val ON tot_val.transaction_id = t.transaction_id
                    INNER JOIN avg_invoice_value_in_year cte ON tot_val.income_invoice_id = cte.income_invoice_id
            WHERE tot_val.total_invoice_value >= cte.avg_invoice_val
        ) trans ON e.employee_id = trans.employee_id
WHERE ec.position_id IN (8, 9) --AND year = 2020
ORDER BY employee_name ASC
;