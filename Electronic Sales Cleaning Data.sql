-- DATA cleaning for Electronic Sales


SELECT *
FROM electronic_sales


-- Separate out the address, city, state-zip

SELECT 
PARSENAME(REPLACE(purchase_address, ',', '.') ,3)
, PARSENAME(REPLACE(purchase_address, ',', '.') ,2)
, PARSENAME(REPLACE(purchase_address, ',', '.') ,1)
FROM electronic_sales


ALTER TABLE electronic_sales
ADD p_address NVARCHAR(250); 

UPDATE electronic_sales
SET p_address = PARSENAME(REPLACE(purchase_address, ',', '.') ,3)


ALTER TABLE electronic_sales
ADD purchase_city NVARCHAR(250); 

UPDATE electronic_sales
SET purchase_city = PARSENAME(REPLACE(purchase_address, ',', '.') ,2)


SELECT
    TRIM(LEFT(purchase_state_zip, 3)) AS state
FROM electronic_sales;

ALTER TABLE electronic_sales
ADD state NVARCHAR(250); 

UPDATE electronic_sales
SET state = TRIM(LEFT(purchase_state_zip, 3)) 


ALTER TABLE electronic_sales
ADD ZipCode NVARCHAR(250);

UPDATE electronic_sales
SET ZipCode = CASE
    WHEN purchase_state_zip IS NOT NULL AND PATINDEX('%[0-9]%', purchase_state_zip) > 0
    THEN SUBSTRING(purchase_state_zip, PATINDEX('%[0-9]%', purchase_state_zip), LEN(purchase_state_zip))
    ELSE NULL  -- Handle cases where there are no numeric values or purchase_state_zip is NULL
END;


-- Remove the time from the order_date Column

SELECT order_date_new, CONVERT(Date, order_date)
FROM electronic_sales

ALTER TABLE electronic_sales
ADD order_date_new DATE; 

UPDATE electronic_sales
SET order_date_new = CONVERT(Date, order_date)


-- Fix price_each column to display correct dolalr amount

SELECT CONVERT(DECIMAL(10, 2), price_each) AS price_per_prod
FROM electronic_sales;

UPDATE electronic_sales
SET price_each = CONVERT(DECIMAL(10, 2), price_each) 


-- Rename Columns

EXEC sp_rename 'electronic_sales.p_address', 'purchase_address', 'COLUMN';

EXEC sp_rename 'electronic_sales.order_date_new', 'purchase_date', 'COLUMN';

-- Delete unused columns

SELECT *
FROM electronic_sales

ALTER TABLE electronic_sales
DROP COLUMN order_date, purchase_address, OwnerSPlitState, order_date_converted

ALTER TABLE electronic_sales
DROP COLUMN purchase_state_zip