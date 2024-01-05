--I will be cleaning the data in SQL queries
--*/

Select SaleDate
From PortfolioProject..NashvilleHousing

--Change the Date Format
Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

ALTER table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)
------------------------------------------------------

--Populate property Address Data
Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null	
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress) 
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress =  ISNULL(a.propertyaddress, b.PropertyAddress) 
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]

-----------------------------------------------------------------------
--Breaking the Address into individual colums (address, city,state)
--Splitting PropertyAddress using a substring and charindex

Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select 
SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress)- 1) as Address
, SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress)+ 1, Len(PropertyAddress)) as Address

From PortfolioProject..NashvilleHousing

ALTER table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress)- 1)

ALTER table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress)+ 1, Len(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing

--Splitting OwnerAddress using parsename and replace

Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select 
PARSENAME(Replace(OwnerAddress,',', '.'),3)
, PARSENAME(Replace(OwnerAddress,',', '.'),2)
, PARSENAME(Replace(OwnerAddress,',', '.'),1)
From PortfolioProject..NashvilleHousing

ALTER table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',', '.'),3)



ALTER table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnersplitCity =  PARSENAME(Replace(OwnerAddress,',', '.'),2)



ALTER table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',', '.'),1)


----------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" Field

select distinct(soldasvacant), count(soldasvacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2


Select Soldasvacant
, Case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		Else SoldAsVacant
		End
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		Else SoldAsVacant
		End
	-----------------------------------------------------------------------------------

	--Remove Duplicates 
WITH RowNumCTE AS(
	Select *,
		Row_Number() Over (
		Partition By ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order by
						UniqueID
						) row_num

	From PortfolioProject..NashvilleHousing
	--order by ParcelID
	)
	Delete
	From RowNumCTE
	Where row_num > 1 
	---------------------------------------------------------------------------------------
	--Delete Unused Columns


	Alter table portfolioproject..nashvillehousing
	drop column OwnerAddress, TaxDistrict, PropertyAddress

	Alter table portfolioproject..nashvillehousing
	drop column SaleDate

	Select *
	From PortfolioProject..NashvilleHousing