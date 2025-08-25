/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouseAnalytics' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, this script creates a schema called gold
	
WARNING:
    Running this script will drop the entire 'DataWarehouseAnalytics' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'DataWarehouseAnalytics' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouseAnalytics')
BEGIN
    ALTER DATABASE DataWarehouseAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouseAnalytics;
END;
GO

-- Create the 'DataWarehouseAnalytics' database
CREATE DATABASE DataWarehouseAnalytics;
GO

USE DataWarehouseAnalytics;
GO

-- Create Schemas

CREATE SCHEMA gold;
GO

CREATE TABLE gold.dim_customers(
	customer_key int,
	customer_id int,
	customer_number nvarchar(50),
	first_name nvarchar(50),
	last_name nvarchar(50),
	country nvarchar(50),
	marital_status nvarchar(50),
	gender nvarchar(50),
	birthdate date,
	create_date date
);
GO

CREATE TABLE gold.dim_products(
	product_key int ,
	product_id int ,
	product_number nvarchar(50) ,
	product_name nvarchar(50) ,
	category_id nvarchar(50) ,
	category nvarchar(50) ,
	subcategory nvarchar(50) ,
	maintenance nvarchar(50) ,
	cost int,
	product_line nvarchar(50),
	start_date date 
);
GO

CREATE TABLE gold.fact_sales(
	order_number nvarchar(50),
	product_key int,
	customer_key int,
	order_date date,
	shipping_date date,
	due_date date,
	sales_amount int,
	quantity tinyint,
	price int 
);
GO

TRUNCATE TABLE gold.dim_customers;
GO

BULK INSERT gold.dim_customers
FROM 'C:\Users\markh.000\Documents\sql-data\sql-data-analytics-project\datasets\csv-files\gold.dim_customers.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

TRUNCATE TABLE gold.dim_products;
GO

BULK INSERT gold.dim_products
FROM 'C:\Users\markh.000\Documents\sql-data\sql-data-analytics-project\datasets\csv-files\gold.dim_products.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

TRUNCATE TABLE gold.fact_sales;
GO

BULK INSERT gold.fact_sales
FROM 'C:\Users\markh.000\Documents\sql-data\sql-data-analytics-project\datasets\csv-files\gold.fact_sales.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO
-- Sales by Year and Month

/*SELECT
YEAR(order_date) as order_year,
MONTH(order_date) as order_month,
SUM(sales_amount) as total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date)
*/
SELECT
datetrunc(month, order_date) as order_date,
SUM(sales_amount) as total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY datetrunc(month, order_date)
ORDER BY datetrunc(month, order_date)
/*
SELECT
FORMAT(order_date, 'yyyy_MMM') as order_date,
SUM(sales_amount) as total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy_MMM')
ORDER BY FORMAT(order_date, 'yyyy_MMM')
*/

-- Cumulative Sales

SELECT
order_date,
total_sales,
SUM(total_sales) over (PARTITION BY YEAR(order_date) ORDER BY order_date) as running_total_sales,
AVG(avg_price) over (ORDER BY order_date) as moving_avg
FROM(
SELECT
DATETRUNC(month, order_date) as order_date,
SUM(sales_amount) as total_sales,
AVG(price) as avg_price
FROM gold.fact_sales
WHERE order_date is not null
GROUP BY DATETRUNC(month, order_date)
) t

-- Performance Analysis

WITH yearly_product_sales as (
SELECT 
YEAR(f.order_date) as order_date,
p.product_name,
SUM(f.sales_amount) as current_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE order_date is not null
GROUP BY YEAR(f.order_date),
p.product_name
) 

SELECT
order_date,
product_name,
current_sales,
AVG(current_sales) OVER (PARTITION BY product_name) avg_sales,
current_sales - AVG(current_sales) OVER (PARTITION BY product_name) as diff_avg,
CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above AVG'
	 WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below AVG'
	 ELSE 'AVG'
END avg_change,
-- Year-over-year analysis
LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_date) py_sales,
current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_date) as diff_py,
CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_date) > 0 THEN 'Increasing'
	 WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_date) < 0 THEN 'Decreasing'
	 ELSE 'No Change'
END py_change
FROM yearly_product_sales
ORDER BY product_name, order_date

-- Which category contributes the most to overall sales?

WITH category_sales as(
Select 
category,
SUM(sales_amount) as total_sales
From gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY category)

SELECT 
category,
total_sales,
SUM(total_sales) OVER () overall_sales,
CONCAT(ROUND((CAST (total_sales as FLOAT)/SUM(total_sales) OVER ())*100, 2), '%') as percentage_of_total
FROM category_sales
ORDER BY total_sales DESC

WITH product_segments as(
SELECT 
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
	 WHEN cost BETWEEN 100 and 500 THEN '100-500'
	 WHEN cost BETWEEN 500 and 1000 THEN '500-1000'
	 ELSE 'Above 1000'
END cost_range
FROM gold.dim_products)

SELECT 
cost_range,
COUNT(product_key) as total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC

WITH customer_spending as(
SELECT
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(order_date) as first_order,
MAX(order_date) as last_order,
DATEDIFF (month,MIN(order_date), MAX(order_date)) as lifespan
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key)

SELECT
customer_segment,
COUNT(customer_key) AS total_customers
FROM(
SELECT
customer_key,
CASE WHEN lifespan >= 12 and total_spending > 5000 THEN 'VIP'
	 WHEN lifespan >= 12 and total_spending < 5000 THEN 'Regular'
	 Else 'NEW'
END customer_segment
FROM customer_spending) t
GROUP BY customer_segment
ORDER BY total_customers DESC

CREATE VIEW gold.report_customers AS
WITH base_query as(
SELECT
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name, ' ', c.last_name) as customer_name,
DATEDIFF(year, c.birthdate,GETDATE()) age
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
WHERE order_date is not null)

,customer_aggregation as(
SELECT
customer_key,
customer_number,
customer_name,
age,
COUNT(DISTINCT order_number) as total_orders,
SUM(sales_amount) as total_sales,
SUM(quantity) as total_quantity,
COUNT(DISTINCT product_key) as total_prodcts,
MAX(order_date) as last_order_date,
DATEDIFF (month,MIN(order_date), MAX(order_date)) as lifespan
FROM base_query
GROUP BY
	customer_key,
	customer_number,
	customer_name,
	age)

SELECT
customer_key,
customer_number,
customer_name,
age,
CASE WHEN age < 20 THEN 'Under 20'
	 WHEN age between 20 and 29 then '20-29'
	 WHEN age between 30 and 39 then '30-39'
	 WHEN age between 40 and 49 then '40-49'
	 ELSE '50 and above'
END as age_group,
CASE WHEN lifespan >= 12 and total_sales > 5000 THEN 'VIP'
	 WHEN lifespan >= 12 and total_sales < 5000 THEN 'Regular'
	 Else 'NEW'
END customer_segment,
last_order_date,
DATEDIFF(month, last_order_date, GETDATE()) as recency,
total_orders,
total_sales,
total_quantity,
total_prodcts,
lifespan,
-- COMPUTE AVG ORDER VALUE
CASE WHEN total_orders = 0 then 0
	 ELSE total_sales/total_orders
END as avg_order_value,
-- COMPUTE AVG monthly spend
CASE WHEN lifespan = 0 THEN total_sales
	 ELSE total_sales / lifespan
END as monthly_avg
FROM customer_aggregation

SELECT * FROM gold.report_customers

WITH base_q AS (
SELECT
f.order_number,
f.order_date,
f.customer_key,
f.sales_amount,
f.quantity,
f.product_key,
p.product_name,
p.category,
p.subcategory,
p.cost
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE order_date is not null
)

,product_aggregation AS(
SELECT
product_key,
product_name,
category,
subcategory,
cost,
DATEDIFF (month,MIN(order_date), MAX(order_date)) as lifespan,
MAX(order_date) as last_sale_date,
SUM(sales_amount) as total_sales,
SUM(quantity) as total_quantity,
COUNT(DISTINCT order_number) as total_orders,
COUNT(DISTINCT customer_key) as total_customers,
ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price
FROM base_q
GROUP BY 
	product_key,
	product_name,
	category,
	subcategory,
	cost
)

SELECT
product_key,
product_name,
category,
subcategory,
cost,
lifespan,
last_sale_date,
DATEDIFF(month, last_sale_date, GETDATE()) as recency_in_month,
CASE WHEN total_sales > 50000 THEN 'High-Performer'
	 WHEN total_sales >= 10000 THEN 'Mid-Range'
	 ELSE 'Low-Performer'
END as product_segment,
total_sales,
total_quantity,
total_orders,
total_customers,
avg_selling_price
CASE WHEN total_orders = 0 THEN 0
	 ELSE total_sales/total_orders
END avg_order_rev
CASE WHEN lifespan = 0 THEN total_sales
	 ELSE total_sales / lifespan
END avg_monthly_rev
FROM product_aggregation







