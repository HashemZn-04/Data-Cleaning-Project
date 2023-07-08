-- Overview of the dataset

SELECT *
FROM DataCleaning_Project..NashvilleHousing



-- Standardizing sale date format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM DataCleaning_Project..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)



-- Populate property address date

SELECT *
FROM DataCleaning_Project..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

/* ParcelID directly corresponds to PropertyAddress */

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM DataCleaning_Project..NashvilleHousing as A
JOIN DataCleaning_Project..NashvilleHousing as B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM DataCleaning_Project..NashvilleHousing as A
JOIN DataCleaning_Project..NashvilleHousing as B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL



-- Breaking Address columns into individual columns respective to location (Address, city and state)

/* PropertyAddress */

SELECT PropertyAddress
FROM DataCleaning_Project..NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
FROM DataCleaning_Project..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


SELECT *
FROM DataCleaning_Project..NashvilleHousing


/* OwnerAddress */

SELECT OwnerAddress
FROM DataCleaning_Project..NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM DataCleaning_Project..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



SELECT *
FROM DataCleaning_Project..NashvilleHousing



-- Changing sold as vacant field to Y/N for consistency

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM DataCleaning_Project..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Yes' THEN 'Y'
	   WHEN SoldAsVacant = 'No' THEN 'N'
	   ELSE SoldAsVacant
	   END
FROM DataCleaning_Project..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Yes' THEN 'Y'
	   WHEN SoldAsVacant = 'No' THEN 'N'
	   ELSE SoldAsVacant
	   END



-- Removing duplicates

WITH RowNumCTE as(
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

FROM DataCleaning_Project..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1



-- Deleting unusable columns

SELECT *
FROM DataCleaning_Project..NashvilleHousing

ALTER TABLE DataCleaning_Project..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
