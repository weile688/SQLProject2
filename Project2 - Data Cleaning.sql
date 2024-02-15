-- Cleaning data in SQL queries

SELECT *
FROM PortfolioProject..NashvilleHousing

-- Standardize date format
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvilleHousing

-- Populate Property Address data
-- ParcelID has fixed address
-- Fill up NULL property address based on ParcelID
SELECT *
FROM PortfolioProject..NashvilleHousing
ORDER BY ParcelID

SELECT Join1.ParcelID, Join1.PropertyAddress, Join2.ParcelID, Join2.PropertyAddress, ISNULL(Join1.PropertyAddress, Join2.PropertyAddress)
FROM PortfolioProject..NashvilleHousing Join1
JOIN PortfolioProject..NashvilleHousing Join2
	ON Join1.ParcelID = Join2.ParcelID 
	AND Join1.[UniqueID ] <> Join2.[UniqueID ]

UPDATE Join1
SET PropertyAddress = ISNULL(Join1.PropertyAddress, Join2.PropertyAddress)
FROM PortfolioProject..NashvilleHousing Join1
JOIN PortfolioProject..NashvilleHousing Join2
	ON Join1.ParcelID = Join2.ParcelID 
	AND Join1.[UniqueID ] <> Join2.[UniqueID ]
WHERE Join1.PropertyAddress IS NULL

-- Breaking out address into individual columns (Address, City, States) 
-- Using Substring
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address, -- Minus 1 to remove comma
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address2 --Plus 1 to remove comma
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT PropertySplitAddress, PropertySplitCity
FROM PortfolioProject..NashvilleHousing

--Using Parsename
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing -- Parsename index works in different direction

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

SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM PortfolioProject..NashvilleHousing

-- Change Y and N to Yes and No in 'Sold as Vacant' field
SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	END
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	END

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

-- Remove Duplicates
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	ORDER BY UniqueID
	) row_num
FROM PortfolioProject..NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE row_num > 1

SELECT *
FROM RowNumCTE
WHERE row_num > 1 -- Put on above delete after delete

-- Delete unused columns
SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress,SaleDate
