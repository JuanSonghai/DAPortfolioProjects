/*

Cleaning Data in SQL Queries

*/

Select *
From [Portfolio Project1]..NashvilleHousing


---------------------------------------------------------------

--Standerdize Format

Select SaleDateConverted, CONVERT (Date, SaleDate)
From [Portfolio Project1]..NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)






------------------------------------------------------------------------

--Populate Property Address Data

Select PropertyAddress
From [Portfolio Project1]..NashvilleHousing
Where PropertyAddress is null
Order by ParcelID


Select *
From [Portfolio Project1]..NashvilleHousing
-- Where PropertyAddress is null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project1]..NashvilleHousing a
JOIN [Portfolio Project1]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is Null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project1]..NashvilleHousing a
JOIN [Portfolio Project1]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is Null


------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From [Portfolio Project1]..NashvilleHousing

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
From [Portfolio Project1]..NashvilleHousing

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
	SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From [Portfolio Project1]..NashvilleHousing


-- Creating New Column and Updating the info inside for the Address Break outs
ALTER TABLE NashvilleHousing
Add PropertyPhysicalAddress Nvarchar(255);

Update NashvilleHousing
SET PropertyPhysicalAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE NashvilleHousing
Add PropertyCity Nvarchar(255);

Update NashvilleHousing
Set PropertyCity = 	SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))



Select OwnerAddress
From [Portfolio Project1]..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) as PhysicalAddress,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) as City,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) as State
From [Portfolio Project1]..NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerPhysicalAddress Nvarchar(255);

Update NashvilleHousing
SET  OwnerPhysicalAddress= PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)



ALTER TABLE NashvilleHousing
Add OwnerCity Nvarchar(255);

Update NashvilleHousing
Set OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)





ALTER TABLE NashvilleHousing
Add OwnerState Nvarchar(255);

Update NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)




---------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct (SoldAsVacant), Count (SoldAsVacant)
From [Portfolio Project1]..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
,CASE When SoldAsVacant = 'Y' THEN 'YES'
	  When SoldAsVacant = 'N' THEN 'NO'
	  ELSE SoldAsVacant
	  END
From [Portfolio Project1]..NashvilleHousing



Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
			When SoldAsVacant = 'N' THEN 'NO'
			ELSE SoldAsVacant
			END




-----------------------------------------------------------------------------------------

-- Remove Duplicates

---Identifying Duplicates------------------
WITH RowNumCTE  AS(
Select * ,
	ROW_NUMBER () Over(
	PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY
				UniqueID
				) row_num
From [Portfolio Project1]..NashvilleHousing
Order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



------Deleting The Duplicates--------------------
WITH RowNumCTE  AS(
Select * ,
	ROW_NUMBER () Over(
	PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY
				UniqueID
				) row_num
From [Portfolio Project1]..NashvilleHousing

)
DELETE
From RowNumCTE
Where row_num > 1







-----------------------------------------------------------------------------------------------------

-- Delete Unused Columns


ALTER TABLE [Portfolio Project1]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress,SaleDate
