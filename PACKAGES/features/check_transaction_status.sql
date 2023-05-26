/*
    Package checks and changes transaction status if necessary. Is run every 3 hours by job.
    Find all new transactions
        if transaction is online and is paid with cash, card or blik
        then check what kind of customer
        and check his loyalty card
        and check how long lasts this transaction
*/


SET SERVEROUTPUT ON;