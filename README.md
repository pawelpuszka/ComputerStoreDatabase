# COMPUTER STORE

![lang](https://img.shields.io/static/v1?label=lang&message=PL/SQL&color=blue)
![lang](https://img.shields.io/static/v1?label=lang&message=SQL&color=blue)
![engine](https://img.shields.io/static/v1?label=engine&message=Oracle&color=green)
![engine-ver](https://img.shields.io/static/v1?label=version&message=19c&color=green)
![environment](https://img.shields.io/static/v1?label=env&message=cloud&color=red)

---

### This project is still tested and in progress.

## About
    
It is a project of transactional database for stationary and online store which sells computer hardware. 

The main goals of this project are:

1. Learning how to design a database.
2. Learning how to code and solve problems in Oracle database environment using PL/SQL.
3. Use it to get hired as a developer.

## Built with
    
Oracle technology is used to design, populate and deploy main features.
    
### Tools:

* `Autonomous Database (ATP)` `ver.19c` 
* `PL/SQL`
* `SQL`
* `Java`
* `Data Modeler`
* `SQL Developer`

## Getting started

### Prerequisites

1. `SQL Developer` is a Oracle's cross-platform client application designed for working with databases. You can download it [here](https://www.oracle.com/database/sqldeveloper/technologies/download/) from Oracle's website.  
It's important to work with tool which can present basic graphical table schema of database. You can use Oracle's text-based SQLPlus but I don't recommend it for the reason above.  
There are many other IDEs such as Toad, PL/SQL Developer or DataGrip but if You want to use it You will have to find out how to connect with Oracle's Autonomous Database on your own.

2. Download client [credentials]() (Wallet). It's needed to authorize your client application.

### Installing SQL Developer on Windows

Process of instalation is quite simple, but if You would have a problem [here](https://docs.oracle.com/en/database/oracle/sql-developer/22.2/rptug/sql-developer-concepts-usage.html#GUID-156BEBA3-2F9B-4CE0-8E91-728581FF46AB) is documentation on the subject. 

### Installing SQL Developer on Linux

I have found a very good explained process of instalation for Ubuntu on that website https://dev.to/ishakantony/how-to-install-oracle-sql-developer-on-ubuntu-20-04-3jpd

And that website demonstrates installation process for rpm-based distributions 
https://www.oracleknowhow.com/install-sql-developer-on-rpm-linux/

### Connecting to database

I have created a user with restricted privileges and with password on subjected database 
* user: cs_test
* password: passwd123

1. Run SQL Developer
2. At the left side of the window You should see the field named 'Connections'. 

![field_conn_sqldev](https://github.com/pawelpuszka/pawelpuszka.github.io/blob/76ce12fc8b375518f02a7f76b3a9b2ccc68b799c/conn_field_sqldev.png)

If not, click option 'View' on main option bar then choose 'Connections' from the menu.

![view_conn_sqldev](https://github.com/pawelpuszka/pawelpuszka.github.io/blob/66b8c3a970160cb94cc22cacb0d1d9ce5377a8eb/view_conn_sqldev.png)


### What can You do

### 

## How project is progressing

This project is still tested and in progress.
  
### Designing database

I've spent a lot of time to design this database according to best practices. In most cases it meets requirements of the third normal form.

It contains data, dictionary and linking tables, moreover there are defined relations between tables to keep consistency and integrity of data. 

Whole structure is designed to make sure there is possibility to deploy business processes and information flow.

Link to [database schema](https://pawelpuszka.github.io).

### Populating database

First step was to prepare .csv files with data for tables:
* Addresses
* Employees
* Products
* Transactions
* Clients
  
In this case `Java` with extra libraries was very helpful
* [`Jsoup`](https://jsoup.org) was very helpful to get some data from random websites
* [`OpenCSV`](https://www.geeksforgeeks.org/reading-csv-file-java-using-opencsv/?ref=lbp) to manipulate .csv files
* [`Faker`](https://github.com/DiUS/java-faker) to generate some data
  
Next steps were pretty similar. I had to write scripts, using PL/SQL, for every table in database to populate it with consistent data.

The best way to show this process is an example of filling **Transactions** table.

![transactions](https://github.com/pawelpuszka/pawelpuszka.github.io/blob/f626cc0c104af520fa648c0d946f1c0d8f21af38/transactions_table.png)


I need to mention that I widely use:
* `DBMS_RANDOM` package and its `value()` function, which returns a random number from a defined range
* `associative array` collection (aka index-by table)
* `stored procedures` which are divided into subprograms (procedures and functions)


1. **transaction_id** is increased automatically by database engine while the data is copied from collection into table. 
2. Setting **delivery_method_id**. There are four possibilities to deliver a product to customer. So numbers in 1 to 4 range are randomly assigned.
	* I had to set **delivery_method_id** as a first because it divided transactions into online and stationary. It was very important.
3. Setting **payment_method_id**. There are also four possibilities to randomly assign the value, but there are some restrictions.
	* While I was setting **payment_method_id** I knew if transaction was stationary then it couldn't be paid with bank transfer. 
	* If transaction was online it couldn't be paid with cash.
4. Setting **employee_id** to associate salesman with transaction.
	* There are two types of salesmen: those operating in stationary store (assigned only to stationary transactions) and those operating online (assigned only when        products have to be deliver by post office or courier). 
5. Setting transaction's **status_id**. 
	* Stationary sale is fast so **status_id** is set to **finished** regardless of how the customer paid in this transaction.
	* Online transactions depends on **payment_method_id**.
	* When it was paid with card or blik then status of transaction should be set as cancelled or finished because such kind of sales are also fast.
	* When it was paid with bank transfer then status of transaction should be set as new, pending, cancelled or finished since money could not be posted yet or several other reasons.
6. Generating dates - start and end of transaction. This is kinda complicated because I needed to consider many cases which one of the most important was that       transaction cannot be carried out by an employee whose date of employment is later then start date of transaction.

Take a look at the [code](https://github.com/pawelpuszka/ComputerStoreDatabase/blob/e1f8632ab00134c82cecb8099c6296f24ae98c3c/populating%20computer_store/transactions/script_add_data_to_transactions.sql) for more information.
 
### Features

1. Adding new employee. -*not implemented yet*

2. Adding new transaction. -*not implemented yet*

3. Checking the stock for each product. -*not implemented yet*

4. Checking the status of transaction and change it when needed. -*not implemented yet*

5. Looking for employees' contracts which end date is shorter then 3 months. -*not implemented yet* 




     
### solved problems
      
### not solved problems
      
