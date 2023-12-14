-- Creating a table to move the CSV file of coffee shop sales and products over to pgAdmin 


CREATE TABLE coffee_shop_sales(
transaction_id INTEGER,
transaction_date TIMESTAMP,
transaction_time TIME,
store_id NUMERIC,
store_location VARCHAR(250),
product_type VARCHAR(250),
product_category VARCHAR(250),
product_detail VARCHAR(250)
)


CREATE TABLE coffee_shop_products(
transaction_id INTEGER,
product_id NUMERIC,
transaction_qty NUMERIC,
unit_price NUMERIC
)


-- Imported 2 Excel(CSV) tables. coffee_shop_products and coffee_shop_sales

SELECT *
FROM coffee_shop_sales
;

SELECT *
FROM coffee_shop_products
;

SELECT coffee_shop_products.transaction_id, transaction_qty, unit_price
FROM coffee_shop_products
;

-- Looking at the transaction_qty and unit_price totals for each transaction_id 

SELECT coffee_shop_products.transaction_id, transaction_qty, unit_price, (unit_price*transaction_qty) AS TotalPricePerQty
FROM coffee_shop_products
;

-- Looking at the average unit_price sold at the coffee shop 

SELECT AVG(unit_price)
FROM coffee_shop_products
;

-- Looking at transaction_qty that has sold more than 5 

SELECT product_id, transaction_qty
FROM coffee_shop_products
WHERE transaction_qty > 5
;

-- Looking at the MAX unit_price that was sold that = 8 

SELECT product_id, transaction_qty, MAX(unit_price) AS MaxUnitsSold
FROM coffee_shop_products
WHERE transaction_qty = 8
GROUP BY product_id, transaction_qty
;

-- Looking at the MIN unit_price that was sold per transcation_qty that = 1 

SELECT transaction_id, product_id, transaction_qty, unit_price, MIN(unit_price) AS MinOfUnitsSold
FROM coffee_shop_products
WHERE transaction_qty = 1
GROUP BY transaction_id, product_id, transaction_qty, unit_price
ORDER BY min_of_units_sold_per_trans 
;

-- Count for each product_id as how many product_id were sold in each 

SELECT product_id, COUNT(*) AS CountForEachProductid
FROM coffee_shop_products
GROUP BY product_id
;

-- Most sold product_id  

SELECT product_id, COUNT(*) AS CountForEachProductid
FROM coffee_shop_products
GROUP BY product_id
ORDER BY count_for_each_productid DESC
LIMIT 1
;

-- Least sold product_id 

SELECT product_id, COUNT(*) AS CountForEachProductid
FROM coffee_shop_products
GROUP BY product_id
ORDER BY count_for_each_productid 
LIMIT 1
;

-- JOIN tables coffee_shop_products and coffee_shop_sales

SELECT *
FROM coffee_shop_products AS prod
JOIN coffee_shop_sales AS sal
	ON prod.transaction_id = sal.transaction_id
;

-- See the SUM of the transaction_qty per product_detail for month of 6/2023

SELECT DISTINCT(sal.product_detail), SUM(prod.transaction_qty)
FROM coffee_shop_products AS prod
JOIN coffee_shop_sales AS sal
	ON prod.transaction_id = sal.transaction_id
WHERE sal.transaction_date BETWEEN '2023-06-01 00:00:00' AND '2023-06-30 00:00:00'
GROUP BY sal.product_detail
;

-- See what product_detail sold the most and least for the month of 6/2023

SELECT DISTINCT(sal.product_detail), SUM(prod.transaction_qty) AS SumOfProductsSold
FROM coffee_shop_products AS prod
JOIN coffee_shop_sales AS sal
	ON prod.transaction_id = sal.transaction_id
WHERE sal.transaction_date BETWEEN '2023-06-01 00:00:00' AND '2023-06-30 00:00:00'
GROUP BY sal.product_detail 
ORDER BY SumOfProductsSold DESC
LIMIT 1;


SELECT DISTINCT(sal.product_detail), SUM(prod.transaction_qty) AS SumOfProductsSold
FROM coffee_shop_products AS prod
JOIN coffee_shop_sales AS sal
	ON prod.transaction_id = sal.transaction_id
WHERE sal.transaction_date BETWEEN '2023-06-01 00:00:00' AND '2023-06-30 00:00:00'
GROUP BY sal.product_detail 
ORDER BY SumOfProductsSold
LIMIT 1;

--Look for AVG products sold for 6/2023

SELECT ROUND(AVG(SumOfProductsSold), 2) AS AverageProductsSold
FROM (
    SELECT sal.product_detail, SUM(prod.transaction_qty) AS SumOfProductsSold
    FROM coffee_shop_products AS prod
    JOIN coffee_shop_sales AS sal
        ON prod.transaction_id = sal.transaction_id
    WHERE sal.transaction_date BETWEEN '2023-06-01 00:00:00' AND '2023-06-30 00:00:00'
    GROUP BY sal.product_detail
);
	
	
-- Checking for 2 top sold products for 6/2023

SELECT sal.product_category, COUNT(product_category) AS ProductCount
FROM coffee_shop_products AS prod
JOIN coffee_shop_sales AS sal
	ON prod.transaction_id = sal.transaction_id
GROUP BY sal.product_category 
ORDER BY COUNT(product_category) DESC
LIMIT 2
;

-- Rank the product_category from most to least using PARTITION BY

SELECT
  product_category,
  COUNT(product_category) AS ProductCount,
  RANK() OVER (ORDER BY COUNT(product_category) DESC) AS CategoryRank
FROM coffee_shop_products AS prod
JOIN coffee_shop_sales AS sal
  ON prod.transaction_id = sal.transaction_id
GROUP BY product_category
ORDER BY ProductCount DESC
;
	
-- Use CTE 	

WITH ProdCatAndProdCount AS (
	SELECT
        product_category,
        transaction_qty,
        unit_price,
        transaction_date,
		transaction_time,
        COUNT(product_category) AS ProductCount,
        RANK() OVER (PARTITION BY product_category ORDER BY COUNT(product_category) DESC) AS CategoryRank
    FROM
        coffee_shop_products AS prod
        JOIN coffee_shop_sales AS sal ON prod.transaction_id = sal.transaction_id
    GROUP BY
        product_category, transaction_qty, unit_price, transaction_date, transaction_time
	ORDER BY transaction_date, transaction_time
)

SELECT *, (transaction_qty * unit_price) AS TotalSalesPerTrans
FROM ProdCatAndProdCount;



-- TEMP Table

DROP TABLE IF EXISTS TotalSalesPerTrans
CREATE TABLE TotalSalesPerTrans
(
	product_category VARCHAR(250),
	transaction_qty NUMERIC,
	unit_price NUMERIC,
	transaction_date TIMESTAMP,
	transaction_time TIME,
	CategoryRank NUMERIC
)

INSERT INTO TotalSalesPerTrans (
    product_category,
    transaction_qty,
    unit_price,
    transaction_date,
    transaction_time,
    CategoryRank
)
SELECT
    product_category,
    transaction_qty,
    unit_price,
    transaction_date,
    transaction_time,
    RANK() OVER (PARTITION BY product_category ORDER BY COUNT(product_category) DESC) AS CategoryRank
FROM coffee_shop_products AS prod
JOIN coffee_shop_sales AS sal 
	ON prod.transaction_id = sal.transaction_id
GROUP BY product_category, transaction_qty, unit_price, transaction_date, transaction_time
ORDER BY transaction_date, transaction_time;

SELECT *, (transaction_qty * unit_price) AS TotalSales
FROM TotalSalesPerTrans;


-- Creating View to store data for later visulizations

CREATE VIEW RankCategory AS
SELECT
  product_category,
  COUNT(product_category) AS ProductCount,
  RANK() OVER (ORDER BY COUNT(product_category) DESC) AS CategoryRank
FROM coffee_shop_products AS prod
JOIN coffee_shop_sales AS sal
  ON prod.transaction_id = sal.transaction_id
GROUP BY product_category
ORDER BY ProductCount DESC
;



