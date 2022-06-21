SELECT a.diff_between_dates, COUNT(*) AS number_of_transactions
FROM (SELECT i.transaction_id, CASE 
                            WHEN t.end_time - t.start_time > INTERVAL '46' DAY THEN 'over 46 days'
                            WHEN t.end_time - t.start_time = INTERVAL '46' DAY THEN '46 days'
                            WHEN t.end_time - t.start_time < INTERVAL '46' DAY THEN 'under 46 days'
                         END AS diff_between_dates
FROM transactions t
    INNER JOIN income_invoices i
        ON t.transaction_id = i.transaction_id
WHERE t.status_id = 3
    AND 
    i.payment_term_id = 4) a
GROUP BY a.diff_between_dates
UNION ALL
SELECT a.diff_between_dates, COUNT(*)
FROM (SELECT i.transaction_id, CASE 
                            WHEN t.end_time - t.start_time > INTERVAL '31' DAY THEN 'over 31 days'
                            WHEN t.end_time - t.start_time = INTERVAL '31' DAY THEN '31 days'
                            WHEN t.end_time - t.start_time < INTERVAL '31' DAY THEN 'under 31 days'
                         END AS diff_between_dates
FROM transactions t
    INNER JOIN income_invoices i
        ON t.transaction_id = i.transaction_id
WHERE t.status_id = 3
    AND 
    i.payment_term_id = 3) a
GROUP BY a.diff_between_dates
UNION ALL
SELECT a.diff_between_dates, COUNT(*)
FROM (SELECT i.transaction_id, CASE 
                            WHEN t.end_time - t.start_time > INTERVAL '15' DAY THEN 'over 15 days'
                            WHEN t.end_time - t.start_time = INTERVAL '15' DAY THEN '15 days'
                            WHEN t.end_time - t.start_time < INTERVAL '15' DAY THEN 'under 15 days'
                         END AS diff_between_dates
FROM transactions t
    INNER JOIN income_invoices i
        ON t.transaction_id = i.transaction_id
WHERE t.status_id = 3
    AND 
    i.payment_term_id = 2) a
GROUP BY a.diff_between_dates
UNION ALL
SELECT a.diff_between_dates, COUNT(*)
FROM (select i.transaction_id, CASE 
                            WHEN t.end_time - t.start_time > INTERVAL '8' DAY THEN 'over 8 days'
                            WHEN t.end_time - t.start_time = INTERVAL '8' DAY THEN '8 days'
                            WHEN t.end_time - t.start_time < INTERVAL '8' DAY THEN 'under 8 days'
                         END AS diff_between_dates
FROM transactions t
    INNER JOIN income_invoices i
        ON t.transaction_id = i.transaction_id
WHERE t.status_id = 3
    AND 
    i.payment_term_id = 1) a
GROUP BY a.diff_between_dates
;


select count(i.transaction_id)
FROM transactions t
    INNER JOIN income_invoices i
        ON t.transaction_id = i.transaction_id
WHERE t.status_id = 3
    AND 
    i.payment_term_id in (1, 2, 3, 4)
;