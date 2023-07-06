Select *
From [portproj1.1]..NashvilleHousing

--Standardize date format
Select SaleDateConverted
From [portproj1.1]..NashvilleHousing


alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = convert(date, SaleDate)

--Populate property Address Data

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
From [portproj1.1]..NashvilleHousing a
join [portproj1.1]..NashvilleHousing b
on a.ParcelID = b.ParcelID 
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
From [portproj1.1]..NashvilleHousing a
join [portproj1.1]..NashvilleHousing b
on a.ParcelID = b.ParcelID 
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--breaking out address into individual columns
Select propertyaddress
from [portproj1.1]..NashvilleHousing

select
substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1 ) as address,
substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress) ) as address
from [portproj1.1]..NashvilleHousing

alter table NashvilleHousing
add propertysplitaddress nvarchar(255);

update NashvilleHousing
set propertysplitaddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1 )

alter table NashvilleHousing
add propertysplitcity nvarchar(255);

update NashvilleHousing
set propertysplitcity = substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress) )

select propertysplitaddress, propertysplitcity
from [portproj1.1]..NashvilleHousing

--parsename change owneraddress
select 
parsename(replace(OwnerAddress, ',', '.'), 3)
,parsename(replace(OwnerAddress, ',', '.'), 2)
,parsename(replace(OwnerAddress, ',', '.'), 1)
from [portproj1.1]..NashvilleHousing

alter table NashvilleHousing
add ownersplitaddress nvarchar(255);

update NashvilleHousing
set ownersplitaddress = parsename(replace(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add ownersplitcity nvarchar(255);

update NashvilleHousing
set ownersplitcity = parsename(replace(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add ownersplitstate nvarchar(255);

update NashvilleHousing
set ownersplitstate = parsename(replace(OwnerAddress, ',', '.'), 1)

-- change Y and N to yes or no in 'sold vacant field'

select distinct(SoldAsVacant), count(SoldAsVacant)
from [portproj1.1]..NashvilleHousing
group by SoldAsVacant

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   END
from [portproj1.1]..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   END

-- remove duplicate
with rownumcte as (
select *,
	row_number() over( partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
						order by UniqueID) row_num
from [portproj1.1]..NashvilleHousing
)

select *
from rownumcte
where row_num > 1

--delete unused column

alter table [portproj1.1]..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table [portproj1.1]..NashvilleHousing
drop column SaleDate