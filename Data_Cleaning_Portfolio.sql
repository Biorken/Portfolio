/*

-- CLEANING DATA IN SQL QUERIES

*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;

--------------------------------------------------------------------------------------------------------------------------------------

-- STANDARDIZE DATA FORMAT


UPDATE NashvilleHousing
SET saledate = CONVERT(DATE,saledate);

-- IF IT DOESN'T UPDATE PROPERLY

ALTER TABLE nashvillehousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE,saledate);


--------------------------------------------------------------------------------------------------------------------------------------

--POPULATE PROPERTY ADDRESS DATA


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress,b.PropertyAddress)
FROM portfolioproject.dbo.NashvilleHousing a
JOIN portfolioproject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[uniqueid ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.propertyaddress,b.PropertyAddress)
FROM portfolioproject.dbo.NashvilleHousing a
JOIN portfolioproject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[uniqueid ]
WHERE a.PropertyAddress IS NULL;


--------------------------------------------------------------------------------------------------------------------------------------


-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)


SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL
--ORDER BY ParcelID;

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 ) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) AS City
FROM portfolioproject.dbo.NashvilleHousing;


ALTER TABLE nashvillehousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1);


ALTER TABLE nashvillehousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress));


--------------------------------------------------------------------------------------------------------------------------------------


-- BREAKING OUT OWNERADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing;

SELECT
PARSENAME(replace(owneraddress, ',', '.'), 3)
, PARSENAME(replace(owneraddress, ',', '.'), 2)
, PARSENAME(replace(owneraddress, ',', '.'), 1)
FROM portfolioproject.dbo.NashvilleHousing;


ALTER TABLE nashvillehousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(owneraddress, ',', '.'), 3);


ALTER TABLE nashvillehousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(owneraddress, ',', '.'), 2);


ALTER TABLE nashvillehousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(owneraddress, ',', '.'), 1);


--------------------------------------------------------------------------------------------------------------------------------------


--CHANGE 'Y' AND 'N' TO 'YES' AND 'NO' IN 'SOLD AS VACANT' FIELD


SELECT DISTINCT(SoldAsVacant), COUNT(soldasvacant)
FROM portfolioproject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM portfolioproject.dbo.NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant =  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM portfolioproject.dbo.NashvilleHousing;


--------------------------------------------------------------------------------------------------------------------------------------


--REMOVE DUPLICATES


WITH Row_NumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM portfolioproject.dbo.NashvilleHousing
)
SELECT *
FROM Row_NumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

DELETE
FROM Row_NumCTE
WHERE row_num > 1;


--DELETE UNUSED COLUMNS

ALTER TABLE portfolioproject.dbo.NashvilleHousing
DROP COLUMN owneraddress, taxdistrict, propertyaddress;

ALTER TABLE portfolioproject.dbo.NashvilleHousing
DROP COLUMN saledate;