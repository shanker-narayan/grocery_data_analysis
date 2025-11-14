# grocery_data_analysis
A relational database project built in MySQL, including schema design, large-scale CSV imports, and SQL queries for exploratory data analysis.

When importing large CSVs into MySQL Server 8.3, the Workbench data-import wizard may fail because recent MySQL Server versions are not fully supported by Workbench. If the import appears to hang or doesn’t complete, use the MySQL CLI with LOAD DATA INFILE. Refer to the code below for loading CSV's using CLI

**-- Open Terminal**
**-- Establish MySQL Connection**
      
mysql -u root -p --local-infile=1.

**-- Select database**

USE grocery_store;

**-- Execute this line**

SET GLOBAL local_infile = 1;

**-- Load csv data into tables (example with sales.csv below)**

LOAD DATA LOCAL INFILE (file/path/Documents/Grocery_Store_Database/sales.csv)
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(sales_id, salesperson_id, customer_id, product_id, quantity, discount, total_price, sales_date, transaction_number);
      

