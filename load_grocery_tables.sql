CREATE DATABASE grocery_store;
USE grocery_store;

CREATE TABLE countries(
	country_id INT PRIMARY KEY,
    country_name VARCHAR(255),
    country_code CHAR(2));
    
CREATE TABLE cities(
	city_id INT PRIMARY KEY,
    city_name VARCHAR (50),
    zip_code VARCHAR (10),
    country_id INT,
    FOREIGN KEY (country_id) REFERENCES countries(country_id));
    
CREATE TABLE employees(
	employee_id INT PRIMARY KEY,
    first_name VARCHAR (50),
    middle_initial CHAR(1),
    last_name VARCHAR (50),
    dob DATE, -- When I load the csv, I need to convert the csv column into DATE()
    gender CHAR(1),
    city_id INT,
    hire_date DATETIME,
    FOREIGN KEY(city_id) REFERENCES cities(city_id));
    
CREATE TABLE customers(
	customer_id INT PRIMARY KEY,
    first_name VARCHAR (50),
    middle_initial CHAR(1),
    last_name VARCHAR (50),
    city_id INT,
    address VARCHAR (150),
    FOREIGN KEY (city_id) REFERENCES cities(city_id));
    
    
CREATE TABLE categories (
	category_id INT PRIMARY KEY,
    category_name VARCHAR (255)
);

CREATE TABLE products (
	product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    price DECIMAL (10,2),
    category_id INT,
    class VARCHAR (100),
    modify_date DATETIME,
    resistant VARCHAR (100),
    is_allergic VARCHAR (100),
    vitality_days DECIMAL (10,1),
    FOREIGN KEY (category_id) REFERENCES categories(category_id));
    
CREATE TABLE sales(
	sales_id INT PRIMARY KEY,
    salesperson_id INT,
    customer_id INT, -- foreign key
    product_id INT, -- foreign key
    quantity INT,
    discount DECIMAL (10,2),
    total_price DECIMAL (10,2),
    sales_date DATETIME,
    transaction_number VARCHAR(55),
    FOREIGN KEY(customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY(product_id) REFERENCES products(product_id));

-- Had to load in data via the terminal b/c Workbench doesn't support MySQL Server 8.3, could not enable LOCAL INFILE. See 'README.md' for steps.

SELECT * FROM countries LIMIT 5;
SELECT * FROM categories LIMIT 5;
SELECT * FROM cities LIMIT 5;
SELECT * FROM customers LIMIT 5;
SELECT * FROM employees LIMIT 5;
SELECT * FROM products LIMIT 5;
SELECT * FROM sales LIMIT 5;

	
