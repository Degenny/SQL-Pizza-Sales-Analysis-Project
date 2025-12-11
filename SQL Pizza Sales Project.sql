create database pizza_sales;
USE pizza_sales;

CREATE TABLE order_details (
order_details_id INT PRIMARY KEY,
order_id INT,
pizza_id INT,
quantity INT
);

CREATE TABLE orders (
order_id INT PRIMARY KEY,
order_date DATE,
customer_id INT
);


CREATE TABLE pizzas (
pizza_id INT PRIMARY KEY,
name VARCHAR(100),
size VARCHAR(20),
price DECIMAL(5,2)
);

CREATE TABLE customers (
customer_id INT PRIMARY KEY,
name VARCHAR(100),
phone VARCHAR(20)
);

SELECT *
FROM pizza_sales;

-- Data Overview --
DESCRIBE pizza_sales;

-- Check for NULL --
SELECT 
SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
SUM(CASE WHEN pizza_name_id IS NULL THEN 1 ELSE 0 END) AS null_pizza_name_id,
SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS null_quantity,
SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
SUM(CASE WHEN order_time IS NULL THEN 1 ELSE 0 END) AS null_order_time,
SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) AS null_unit_price,
SUM(CASE WHEN total_price IS NULL THEN 1 ELSE 0 END) AS null_total_price,
SUM(CASE WHEN pizza_size IS NULL THEN 1 ELSE 0 END) AS null_pizza_size,
SUM(CASE WHEN pizza_category IS NULL THEN 1 ELSE 0 END) AS null_pizza_category,
SUM(CASE WHEN pizza_ingredients IS NULL THEN 1 ELSE 0 END) AS null_pizza_ingredients,
SUM(CASE WHEN pizza_name IS NULL THEN 1 ELSE 0 END) AS null_pizza_name
FROM pizza_sales;
-- As Result none of the rows has nulls --

-- Convert Date/Time --
ALTER TABLE pizza_sales
MODIFY order_date date
;
SELECT order_date
FROM pizza_sales;

describe pizza_sales;

SELECT DISTINCT order_date
FROM pizza_sales;

ALTER TABLE pizza_sales
ADD COLUMN clean_order_date DATE;

-- To change Date format --
UPDATE pizza_sales
set clean_order_date = str_to_date(order_date, '%d/%m/%Y')
WHERE order_date LIKE '%/%';

UPDATE pizza_sales
set clean_order_date = str_to_date(order_date, '%d-%m-%Y')
WHERE order_date LIKE '%-%';

SELECT order_date, clean_order_date
FROM pizza_sales;
-- Now all the Date are in the same format (2015-01-07) --

-- Remove the wrong column --
ALTER TABLE pizza_sales
DROP COLUMN order_date;

ALTER TABLE pizza_sales
CHANGE clean_order_date order_date DATE;

SELECT order_date
FROM pizza_sales;

-- Verify if there are values that have not been converted --
SELECT *
FROM pizza_sales
WHERE clean_order_date IS NULL;

-- To know what type of data format we are dealing with --
SELECT DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'pizza_sales';

-- Checking hour format
SELECT DISTINCT order_time 
FROM pizza_sales;
-- Modify the Type
ALTER TABLE pizza_sales
MODIFY COLUMN order_time TIME;
-- Check is all correctly changed
DESCRIBE pizza_sales;
SHOW COLUMNS 
FROM pizza_sales LIKE 'order_time';

-- Check for anomalies
SELECT DISTINCT pizza_name_id
FROM pizza_sales;

SELECT DISTINCT quantity
FROM pizza_sales;

SELECT DISTINCT unit_price
FROM pizza_sales;

SELECT DISTINCT pizza_size
FROM pizza_sales;

SELECT DISTINCT pizza_category
FROM pizza_sales;

SELECT DISTINCT pizza_ingredients
FROM pizza_sales;

SELECT DISTINCT pizza_name
FROM pizza_sales;

-- Check for special characters --
-- Use ESCAPE for character that will otherwise be recognise as string ('%'(any character), '_'(any sequence of character)) --
SELECT DISTINCT pizza_name
FROM pizza_sales
WHERE pizza_name LIKE '%+%'
OR pizza_name LIKE '%/%'
OR pizza_name LIKE '%-%'
OR pizza_name LIKE '%%%' ESCAPE '%'
OR pizza_name LIKE '%#%'
OR pizza_name LIKE '%@%'
OR pizza_name LIKE '%_%' ESCAPE '_';

-- Get rid of extra spaces --
UPDATE pizza_sales
SET pizza_name = TRIM(pizza_name);

-- Set all names in Capital letters --
UPDATE pizza_sales
SET pizza_name = ucase(pizza_name);

SELECT REGEXP_REPLACE(
           LOWER(pizza_name),
           '(^| )([a-z])',
           CONCAT('\\1', UPPER('\\2'))
           ) AS formatted_name
           FROM pizza_sales; -- This didn`t work we need to install this function --
           
-- Install formula in MySQL-- CleanString
DELIMITER $$

CREATE FUNCTION CleanString (input TEXT)
RETURNS TEXT
DETERMINISTIC
BEGIN 
     DECLARE cleaned TEXT;
     -- Remove extra-space --
SET cleaned = TRIM(input);
  -- Multiple spaces replace with a single one --
SET cleaned = REPLACE (cleaned, '  ', ' ');
  -- Convert special characters in space --
SET cleaned = REPLACE(cleaned, '+', ' + ');
  -- Trim extra spaces created from previous formulas --
SET cleaned = REPLACE(cleaned, '   ', ' ');

RETURN cleaned;
END $$
DELIMITER;

-- Update table with cleaned values --
SELECT pizza_name, 
CleanString(pizza_name) AS Cleaned_PizzaName
FROM pizza_sales;

UPDATE pizza_sales
SET pizza_name = CleanString(pizza_name);
           
-- Save the table, Backup --
CREATE TABLE pizza_sales_backup
AS SELECT * 
FROM pizza_sales;

SELECT pizza_name
FROM pizza_sales;

-- Dataset Business Questions --
-- 1- Which Pizza type generate the highest sales? --
-- 2- What are the peak ordering hours during the day? --
-- 3- Which days of the week are the most profitable? --
-- 4- Are there specific days in the month when pizza sales peak? --
-- 5- Do customers prefer certain pizza size or categories? --

-- 1 --
SELECT pizza_name,
SUM(quantity) AS Total_pizzas
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_pizzas DESC;
-- As a result the Classic Deluxe Pizza has the highest sale with 2453 
-- the second one is the Barbecue chicken pizza with 2432 very close with the Hawaiian and the Pepperoni Pizzas for only few points --

-- 2- To answer the second question we need to extract the hour from the timestamp
-- In MySQL: HOUR(order_time) gives 0-23 -- Group by the hour -- Count the number of pizza per hour --
SELECT HOUR(order_time) AS Order_hour,
SUM(quantity) AS Total_pizzas
FROM pizza_sales
ORDER BY Order_hour
GROUP BY Total_pizzas DESC;








