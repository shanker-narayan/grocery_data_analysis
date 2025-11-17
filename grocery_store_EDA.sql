USE grocery_store;

-- Number of rows in each table
SELECT 'categories' AS table_name, COUNT(*) FROM products
UNION ALL
SELECT 'cities' AS table_name, COUNT(*) FROM cities
UNION ALL
SELECT 'countries' AS table_name, COUNT(*) FROM countries
UNION ALL
SELECT 'customers' AS table_name, COUNT(*) FROM customers
UNION ALL
SELECT 'employees' AS table_name, COUNT(*) FROM employees
UNION ALL
SELECT 'products' AS table_name, COUNT(*) FROM products
UNION ALL
SELECT 'sales' AS table_name, COUNT(*) FROM sales;

-- 10 most expensive products
DESCRIBE products;

SELECT product_name, price
FROM products
ORDER BY price DESC
LIMIT 10;

-- Number of unique customers: 98,759
SELECT COUNT(DISTINCT customer_id)
FROM customers;

-- Distinct product categories
SELECT DISTINCT category_name
FROM categories
ORDER BY category_name;

SELECT COUNT(DISTINCT category_id)
FROM categories;



-- Let's find the total revenue by product category in 2018 using a CTE --
CREATE INDEX idx_sales_date_product
ON sales (sales_date, product_id);

WITH prod_units_sold AS (SELECT product_id, SUM(quantity) AS total_units
						 FROM sales
						 WHERE sales_date >= '2018-01-01 00:00:00'
							AND sales_date < '2019-01-01 00:00:00'
						 GROUP BY product_id),
	 prod_categories AS (SELECT p.product_id, p.product_name, p.price, 
								p.category_id, c.category_name, 
                                ps.total_units
						 FROM products p
						 INNER JOIN categories c
						 ON p.category_id = c.category_id
                         INNER JOIN prod_units_sold ps
                         ON p.product_id = ps.product_id)
                         
SELECT category_name, (ROUND(SUM(price * total_units), 2))/1000000 AS total_revenue_millions
FROM prod_categories
GROUP BY category_name
ORDER BY total_revenue_millions DESC;



-- Let's look at which 5 cities had the highest NUMBER of sales --
WITH city_sales AS (SELECT s.sales_id, cu.customer_id, cu.city_id, ci.city_name
					FROM sales s
                    JOIN customers cu ON s.customer_id = cu.customer_id
                    JOIN cities ci ON cu.city_id = ci.city_id)
                    
SELECT city_id, city_name, COUNT(sales_id) AS num_sales
FROM city_sales
GROUP BY city_id, city_name
ORDER BY num_sales DESC
LIMIT 5;




-- Let's focus on spending buckets within Tucson, which has the highest number of sales across all cities in our dataset
SELECT 
    CASE 
        WHEN (s.quantity * p.price) < 500 THEN '< $500'
        WHEN (s.quantity * p.price) BETWEEN 500 AND 1000 THEN '$500–$1000'
        WHEN (s.quantity * p.price) BETWEEN 1000 AND 1500 THEN '$1000–$1500'
        WHEN (s.quantity * p.price) BETWEEN 1500 AND 2000 THEN '$1500–$2000'
        WHEN (s.quantity * p.price) BETWEEN 2000 AND 2500 THEN '$2000–$2500'
        ELSE '>= $2500'
    END AS spend_bucket,
    
    COUNT(*) AS num_orders,
    
    ROUND(AVG(s.quantity * p.price), 2) AS avg_order_value
FROM sales s
JOIN products p 
    ON s.product_id = p.product_id
JOIN customers cu 
    ON s.customer_id = cu.customer_id
JOIN cities ci 
    ON cu.city_id = ci.city_id
WHERE ci.city_name = 'Tucson'
GROUP BY spend_bucket
ORDER BY MIN(s.quantity * p.price);



-- Does order volume in Tucson match their total revenue?
CREATE OR REPLACE VIEW city_metrics AS
	WITH city_sales_rev AS (SELECT cu.city_id, ci.city_name, COUNT(s.sales_id) AS num_sales, ROUND(SUM(s.quantity * p.price) / 1000000, 2) AS total_revenue_mil
						FROM sales s
                        JOIN customers cu ON s.customer_id = cu.customer_id
                        JOIN cities ci ON cu.city_id = ci.city_id
                        JOIN products p ON s.product_id = p.product_id
                        GROUP BY cu.city_id, ci.city_name
)
SELECT city_id, city_name,
	   num_sales,
	   ROW_NUMBER() OVER(ORDER BY num_sales DESC) AS sales_rank,
       total_revenue_mil,
       ROW_NUMBER() OVER(ORDER BY total_revenue_mil DESC) AS rev_rank
FROM city_sales_rev;



-- From the query above, let's look for Tucson in the results (96 cities). We can see that it ranks at #1 for both number of sales and total revenue. Let's understand why
SELECT ci.city_name, AVG(p.price) AS average_price
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
JOIN cities ci ON cu.city_id = ci.city_id
JOIN products p ON s.product_id = p.product_id
GROUP BY ci.city_name; -- people in Tucson don't seem to be buying more expensive products compared to other cities, average product prices are b/w $50-$52

SELECT ci.city_name, AVG(s.quantity) AS average_quantity
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
JOIN cities ci ON cu.city_id = ci.city_id
JOIN products p ON s.product_id = p.product_id
GROUP BY ci.city_name; -- same story with quantity, with every city having an average somewhere b/w `12 - 14 units

SELECT ci.city_name, COUNT(cu.customer_id) AS num_customers
FROM customers cu
JOIN cities ci ON cu.city_id = ci.city_id
GROUP BY ci.city_name; -- Tucson has the highest customer count across all cities in the dataset, likely making this the biggest driver of both high sales and revenue



-- Moving on from Tucson, let's now go back to our city_metrics table which contains Sales and Revenue ranks for all 96 cities in our dataset.
-- Let's start by doing a rank divergence analysis   
SELECT city_id, 
	   city_name,
       sales_rank,
       rev_rank,
       CAST(sales_rank AS SIGNED) - CAST(rev_rank AS SIGNED) AS rank_diff
FROM city_metrics
ORDER BY rank_diff; 
-- cities like Richmond, Portland, and Tulsa had the highest negative discrepancy between sales and revenue, meaning their revenue is underperforming relative to sales.
-- this could be due to lower priced products making up the majority of sales, lower quantities purchased, etc.

SELECT city_id, 
	   city_name,
       sales_rank,
       rev_rank,
       sales_rank - rev_rank AS rank_diff
FROM city_metrics
ORDER BY rank_diff DESC;
-- cities like Lubbock, Jacksonville, and Arlington had the highest positive discrepancy between sales and revenue, showing that revenue overperforms relative to sales
-- orders might be larger or comprised of more expensive products on average across these cities

-- Cities like Tucson, Indianapolis, Akron, Newark, Colorado, and Garland had matching sales and revenue ranks, meaning that revenue is aligned with sales volume.
