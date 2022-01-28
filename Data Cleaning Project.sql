/*

Cleaning Data with SQL Queries
Using Functions: Convert, Alter Table(Add, Set, Drop Column, Update), Joins, Substrings, Parsename, Distinct, Count, Case When, Partition By, and Creating a CTE 

*/

BEGIN -- Checking that data is imported correctly

Select *
From PortfolioProject..NashvilleHousing

END--------------------------------------------------------------------------------------------------------------------------------------------

BEGIN -- Standardizing Date Format
-- Removing Unnessasary Time Data and updating Table

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject..NashvilleHousing

--Update PortfolioProject..NashvilleHousing
--SET SaleDate = CONVERT(Date,SaleDate)

-- Above line did not update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

END--------------------------------------------------------------------------------------------------------------------------------------------


BEGIN -- Populate Null Property Address Data

Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

-- ParcelID's shows that house addresses are null when there are repeat sales recorded
-- Use a self-join on ParcelID and UniqueID to update the NULL data

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

END--------------------------------------------------------------------------------------------------------------------------------------------


BEGIN -- Seperate Address into Individual Columns (Address, City, State)
--Property Address Split and Update using Substrings

Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1 , LEN(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add NewAddress Nvarchar (255),
	NewCity Nvarchar (255);

Update NashvilleHousing
SET NewAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1),
	NewCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1 , LEN(PropertyAddress));


--Owner Address Split and Update using PARSENAME


Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress,',','.') , 3) as Address,
PARSENAME(REPLACE(OwnerAddress,',','.') , 2) as City,
PARSENAME(REPLACE(OwnerAddress,',','.') , 1) as State
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add NewOwnerAddress Nvarchar (255),
	NewOwnerCity Nvarchar (255),
	NewOwnerState Nvarchar (255);

Update NashvilleHousing
SET NewOwnerAddress = PARSENAME(REPLACE(OwnerAddress,',','.') , 3),
	NewOwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.') , 2),
	NewOwnerState = PARSENAME(REPLACE(OwnerAddress,',','.') , 1);

END--------------------------------------------------------------------------------------------------------------------------------------------


BEGIN -- Change Y and N to Yes and No in 'Sold as Vacant' field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = 
CASE When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
From PortfolioProject..NashvilleHousing

END--------------------------------------------------------------------------------------------------------------------------------------------
 

BEGIN -- Remove Duplicates

WITH RowNUMCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDateConverted,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject..NashvilleHousing
)

DELETE
From RowNUMCTE
Where row_num > 1

-- Check to make sure all duplicates are removed 

WITH RowNUMCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDateConverted,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject..NashvilleHousing
)
Select *
From RowNUMCTE
Where row_num > 1

END--------------------------------------------------------------------------------------------------------------------------------------------


BEGIN -- Delete Unused Columns

Select *
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

END--------------------------------------------------------------------------------------------------------------------------------------------

