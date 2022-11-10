-- cleaning data

select *
from NashvilleHousing


-- STANDARDIZING DATE FORMAT ON SALDATE --

select ConvertedSaleDate,convert(date,SaleDate)
from NashvilleHousing



alter table nashvillehousing
add ConvertedSaleDate Date;

update NashvilleHousing
set ConvertedSaleDate = convert(date,SaleDate)
--changed succesfully.



-- POPULATING PROPERTY ADDRESS --

select PropertyAddress
from NashvilleHousing


select nas.ParcelID, nas.PropertyAddress, nash.ParcelID, nash.PropertyAddress, isnull(nas.PropertyAddress, nash.PropertyAddress)
from NashvilleHousing as nas
join NashvilleHousing as nash
	on nas.ParcelID = nash.ParcelID
	and nas.[UniqueID ] <> nash.[UniqueID ]
where nas.PropertyAddress is null

update nas
set PropertyAddress = isnull(nas.PropertyAddress, nash.PropertyAddress)
from NashvilleHousing as nas
join NashvilleHousing as nash
	on nas.ParcelID = nash.ParcelID
	and nas.[UniqueID ] <> nash.[UniqueID ]
--populated succesfully.


-- SEPERATING ADRESS INTO SEPERATE(Address,City,State) --

select PropertyAddress
from NashvilleHousing

select
substring(propertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
substring(propertyAddress, CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as Address
from NashvilleHousing


alter table nashvillehousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(propertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

alter table nashvillehousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(propertyAddress, CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))


select *
from NashvilleHousing

select
parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
from NashvilleHousing


alter table nashvillehousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress,',','.'),3)

alter table nashvillehousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress,',','.'),2)

alter table nashvillehousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress,',','.'),1)
--seperated succesfully.




-- Changing 'N and Y' to 'Yes and No'

select distinct(SoldAsVacant),
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from NashvilleHousing

update NashvilleHousing
set  SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
--changed Succesfully



-- REMOVING DUPLICATES --

with RowNumCTE as(
select *,
	row_number() over(
	partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by
				uniqueID
				) row_num


from NashvilleHousing
)
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress

with RowNumCTE as(
select *,
	row_number() over(
	partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by
				uniqueID
				) row_num


from NashvilleHousing
)
delete
from RowNumCTE
where row_num > 1

--removed succesfully.


-- REMOVING UNUSED COLUMNS --


select *
from NashvilleHousing
order by [UniqueID ]

alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate