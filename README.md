# grocery_data_analysis
A relational database project built in MySQL, including schema design, large-scale CSV imports, and SQL queries for exploratory data analysis.

**--- Loading CSV data into tables**
  
When importing large CSVs into MySQL Server 8.3, the Workbench data-import wizard may fail because recent MySQL Server versions are not fully supported by Workbench. If the import appears to hang or doesn’t complete, use the MySQL CLI with LOAD DATA INFILE. Refer to the code below for loading CSV's using CLI

**Open Terminal**
**Establish MySQL Connection**: mysql -u root -p --local-infile=1.
**Select database**: USE grocery_store;
**Execute this line**: SET GLOBAL local_infile = 1;
**Load csv data into tables (example with sales.csv below)**
LOAD DATA LOCAL INFILE (file/path/Documents/Grocery_Store_Database/sales.csv)
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(sales_id, salesperson_id, customer_id, product_id, quantity, discount, total_price, sales_date, transaction_number);

      
**--- Calculating spending bins: definining "orders" and other data structure notes**

This dataset does not contain an order_id field.
After inspecting the sales table, I confirmed that each record represents a single transaction rather than a line-item within a multi-product order.

Evidence for this:

- Each sales_id value is unique and appears only once.

- When multiple purchases occur on the same day for the same customer, the timestamps are several hours apart — not seconds or minutes apart, which would indicate multiple items inside one order.

- There is no grouping variable (e.g., order number, basket ID, receipt ID) that links multiple products together.

Therefore, for all spending analyses in this project, I treat each row in sales as one distinct order.
Order-level revenue is computed using: **quantity** (from sales.csv) * **price** (from products.csv)
