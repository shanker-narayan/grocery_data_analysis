**Grocery Store SQL Analysis**

I used MySQL to analyze a synthetic grocery store database that I downloaded from Kaggle. I explored revenue drivers across different markets, city-level performance patterns, and customer behavior dynamics. This project demonstrates my ability to work with large relational datasets and write production-quality SQL.

**Skills Demonstrated**

1. SQL (MySQL): CTEs, window functions, views, case statements, grouping, indexing

2. Data schema understanding across multi-table retail data

3. Exploratory data analysis: revenue drivers, customer behavior, city performance

4. Narrative data storytelling: identifying patterns, examining the “why” behind the numbers

5. Business insight generation: connecting SQL findings to real-world implications

**Project Overview**

Goal: develop a framework to understand what drives sales and revenue across cities, and identify why certain markets outperform others.

All SQL queries used in this project can be found in:
grocery_store_EDA.sql and load_grocery_tables.sql

NOTE: If you are unable to load the CSV data into your tables via MySQL Workbench, use MySQL CLI and LOCAL INFILE command.

**Dataset & Schema**

The database includes the following core tables:

1. customers – demographic and city-level customer info

2. cities – 96 cities mapped to customers (customers.city_id)

3. products – product attributes including name, price, category_id, and vitality days

4. categories – product category names

5. sales – ~18 years of transaction-level data (sales date, discount, quantity, transaction number)

6. employees – information about grocery store employees (not used)

7. countries - country names and codes

**Key Analytical Questions & Insights**

Below are the three major insights that, together, form the core story of this analysis.

**1️. Understanding Sales vs. Revenue Performance Across Cities**

To compare how cities perform relative to each other, I calculated:

Sales Rank (sales_rank) — ranking cities by number of individual sales

Revenue Rank (rev_rank) — ranking cities by total dollar revenue (SUM(quantity × price))

This was done using a VIEW (city_metrics) containing:

ROW_NUMBER() OVER (ORDER BY num_sales DESC) AS sales_rank,
ROW_NUMBER() OVER (ORDER BY total_revenue_mil DESC) AS rev_rank

Insight

I wanted to focus on cities that fell within the following three categories
- The sales rank was significantly higher than their revenue rank (sales_rank > rev_rank)
- The revenue rank was significantly higher than the sales rank (sales_rank < rev_rank)
- The sales rank and revenue rank were exacly the same (sales_rank = rev_rank)

A city that I inspected further was Tucson, which ranked #1 for both number of sales and total revenue.

**Tucson: Why It Dominates Both Sales and Revenue**

To understand why Tucson showed up at #1 across both metrics, I tested three hypotheses:

Hypothesis A → Are Tucson customers buying more expensive products?

→ No. Tucson’s average product price is middle of the pack (Range: $50–$52).

Hypothesis B → Are they buying higher quantities per order?

→ No. Average quantity is consistent across all cities (Range: 12–14 units).

Hypothesis C → Does Tucson simply have more customers?

→ Yes — Tucson also ranked #1 for number of customers in this dataset (Range: 952 - 1104)

Tucson has the highest customer count of all 96 cities, which directly explains its top rankings. This illustrates how a strong customer-base can explain revenue dominance — even when pricing and order habits are identical to peers.

**Rank Divergence Analysis: Which Cities Overperform or Underperform Expectations?**

Using the difference between revenue rank and sales rank:

rank_diff = sales_rank - rev_rank


I was able to identify:

1. Cities where revenue underperforms relative to sales: **Richmond, Portland, Tulsa**

These cities generate many orders, but lower-than-expected revenue, suggesting:

cheaper product mixes, smaller order sizes, customer base skewed toward lower-value items.

2. Cities where revenue overperforms relative to sales: **Lubbock, Jacksonville, Arlington**

These cities produce fewer orders, but higher-than-expected revenue, suggesting:

pricier product categories dominate, customers buy higher quantities

3. High-Level Insight

Rank divergence reveals hidden performance patterns that raw sales counts miss — allowing businesses to identify cities that punch above or below their weight.

**How to Reproduce**

1. Clone the repository

2. Import the CSVs into MySQL (through Workbench or CLI)

3. Run the provided SQL scripts in order:

4. load_data.sql

5. grocery_store_EDA.sql

6. Query the city_metrics view and other exploratory queries

**Next Steps**

If I were expanding this analysis, I would explore:

1. Cohort analysis (repeat customers vs. one-time buyers)

2. Time-series revenue trends over 18 years

3. Basket analysis

4. Identifying seasonal or promotional spikes
