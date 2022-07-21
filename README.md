# COMPUTER STORE

![lang](https://img.shields.io/static/v1?label=lang&message=PL/SQL&color=blue)
![lang](https://img.shields.io/static/v1?label=lang&message=SQL&color=blue)
![engine](https://img.shields.io/static/v1?label=engine&message=Oracle&color=green)
![engine-ver](https://img.shields.io/static/v1?label=version&message=19c&color=green)
![environment](https://img.shields.io/static/v1?label=env&message=cloud&color=red)

---

### This project is still in progress.

## About
    
  It is a project of transactional database for stationary and online store which sells computer hardware. 

  The main goals of this project are:

  1. Learning how to design a database.
  2. Learning how to code and solve problems in Oracle database environment using PL/SQL.
  3. Use it to get hired as a developer.

### Built with
    
  Oracle technology is used to design, populate and deploy main features.
    
  Tools:

  * `Autonomous Database (ATP)` `ver.19c` 
  * `PL/SQL`
  * `SQL`
  * `Java`
  * `Data Modeler`
  * `SQL Developer`
  
## Designing database

  I've spent a lot of time to design this database according to best practices. In most cases it meets requirements of the third normal form.

  It contains data, dictionary and linking tables, moreover there are defined relations between tables to keep consistency and integrity of data. 

  Whole structure is designed to make sure there is possibility to deploy business processes and information flow.

  Link to [database schema](https://pawelpuszka.github.io).

## Populating database

First step was to prepare .csv files with data for tables:
* Addresses
* Employees
* Products
* Transactions
* Clients
  
In this case `Java` with `Jsoup` was very helpful to get some data from random websites.
  
Next steps were pretty similar. I had to write scripts, using PL/SQL, for every table in database to populate it with consistent data.

The best way to show this process is an example of filling **Transactions** table.

![transactions](https://github.com/pawelpuszka/pawelpuszka.github.io/blob/f626cc0c104af520fa648c0d946f1c0d8f21af38/transactions_table.png)


I need to mention that I widely use:
* `DBMS_RANDOM` package and its `value()` function, which returns a random number from a defined range.
* `associative array` collection

1. Setting **delivery_method_id**. There are four possibilities to deliver a product to customer. So numbers in 1 to 4 range are randomly assigned.
    * I had to set **delivery_method_id** as a first because it divided transactions into online and stationary. It was very important.
2. Setting **payment_method_id**. There are also four possibilities to randomly assign the value, but there are some restrictions.
    * While I was setting **payment_method_id** I knew if transaction was stationary then it couldn't be paid with bank transfer. 
    * If was online it couldn't be paid with cash.
3. Setting **employee_id** to associate salesman with transaction.
    * There are two types of salesmen: those operating in stationary store (assigned only to stationary transactions) and those operating online (assigned only when        products have to be deliver by post office or courier). 
4. Setting transaction's **status_id**. 
    * Stationary sale is fast so **status_id** is set to **finished** no matter how customer paid in that transaction.
    * Online transactions depends on **payment_method_id**.
        * When it's paid with card or blik then status of transaction should be set as cancelled or finished because that kind of sale is also fast.
        * When it's paid with bank transfer then status of transaction could be set as new, pending, cancelled or finished.
 


my database project

## populating database
  
### main process
     
### solved problems
      
### not solved problems
      
## Features
  
    feat 1
      
    feat 2
      
    ...
