/* Cleaning Data in SQL Queries 
*/

SELECT *
FROM housing_data_cleaning


-- Standardize Date

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM housing_data_cleaning


/* ALTER TABLE housing_data_cleaning
ADD rundateConverted DATE; */

UPDATE housing_data_cleaning
SET SaleDate = CONVERT(Date, SaleDate) 

-------------------------------------------------------------------------------------

/* Populate Property Address data and check for NULL's
*/

SELECT *
FROM housing_data_cleaning
-- WHERE PropertyAddress is NULL
ORDER BY ParcelID


SELECT house1.ParcelID, house1.PropertyAddress, house2.ParcelID, house2.PropertyAddress, ISNULL(house1.PropertyAddress, house2.PropertyAddress) 
FROM housing_data_cleaning house1
JOIN housing_data_cleaning house2
	ON house1.ParcelID = house2.ParcelID AND house1.UniqueID <> house2.UniqueID
WHERE house1.PropertyAddress is NULL


UPDATE house1
SET PropertyAddress = ISNULL(house1.PropertyAddress, house2.PropertyAddress) 
FROM housing_data_cleaning house1
JOIN housing_data_cleaning house2
	ON house1.ParcelID = house2.ParcelID AND house1.UniqueID <> house2.UniqueID
WHERE house1.PropertyAddress is NULL


-- Breaking out Address into indvidual colimns (Address, City, State)

SELECT PropertyAddress
FROM housing_data_cleaning
-- WHERE PropertyAddress is NULL
-- ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS address
FROM housing_data_cleaning


ALTER TABLE housing_data_cleaning
ADD PropertySPlitAddress NVARCHAR(250); 

UPDATE housing_data_cleaning
SET PropertySPlitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE housing_data_cleaning
ADD PropertySPlitCity NVARCHAR(250); 

UPDATE housing_data_cleaning
SET PropertySPlitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) 



SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
FROM housing_data_cleaning



ALTER TABLE housing_data_cleaning
ADD OwnerSPlitAddress NVARCHAR(250); 

UPDATE housing_data_cleaning
SET OwnerSPlitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)


ALTER TABLE housing_data_cleaning
ADD OwnerSPlitCity NVARCHAR(250); 

UPDATE housing_data_cleaning
SET OwnerSPlitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)


ALTER TABLE housing_data_cleaning
ADD OwnerSPlitState NVARCHAR(250); 

UPDATE housing_data_cleaning
SET OwnerSPlitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)


-- Change 0 and 1 to Yes and No in "Sold as Vacant' field 0 = No 1 = Yes

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM housing_data_cleaning
GROUP BY SoldAsVacant


SELECT SoldAsVacant
, CASE
	WHEN SoldAsVacant = 1 THEN 'Yes'
	WHEN SoldAsVacant = 0 THEN 'No'
END
FROM housing_data_cleaning


ALTER TABLE housing_data_cleaning
ALTER COLUMN SoldAsVacant VARCHAR(3);


UPDATE housing_data_cleaning
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 1 THEN 'Yes'
	WHEN SoldAsVacant = 0 THEN 'No'
END


-- Remove Duplicates Using CTE

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueId) row_num
FROM housing_data_cleaning
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1



-- Delete Unused Columns

SELECT *
FROM housing_data_cleaning

ALTER TABLE housing_data_cleaning
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE housing_data_cleaning
DROP COLUMN SaleDate