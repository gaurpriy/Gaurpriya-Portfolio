select *
from [Nashville Housing]

-- Standardizing Date

select saledatec
from [Nashville Housing]

alter table [Nashville Housing]
add saledatecon date

update [Nashville Housing]
set saledatec = convert(date, saledate)

-- Populated Property Address

select PropertyAddress
from [Nashville Housing]
--where PropertyAddress is null
order by ParcelID



select o.ParcelID , o.PropertyAddress, d.ParcelID , d.PropertyAddress, isnull(o.PropertyAddress , d.PropertyAddress)
from [Nashville Housing] o
join [Nashville Housing] d
    on o.ParcelID = d.ParcelID
	and o.[UniqueID ] <> d.[UniqueID ]
where o.PropertyAddress is null

Update o
set PropertyAddress = isnull(o.PropertyAddress , d.PropertyAddress)
from [Nashville Housing] o
join [Nashville Housing] d
    on o.ParcelID = d.ParcelID
	and o.[UniqueID ] <> d.[UniqueID ]
where o.PropertyAddress is null

-- Breakdown of Property Address
-- CHARINDEX helps us to find a particular elemant in the query and seperate it.

select PropertyAddress
from [Nashville Housing]

select 
SUBSTRING(PropertyAddress , 1, CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress , CHARINDEX(',',PropertyAddress)+1 ,len(PropertyAddress)) as Address
from [Nashville Housing]

alter table [Nashville Housing]
add PropertySplitAddress nvarchar(255)

update [Nashville Housing]
set PropertySplitAddress = SUBSTRING(PropertyAddress , 1, CHARINDEX(',',PropertyAddress)-1) 

alter table [Nashville Housing]
add PropertySplitCity nvarchar(255)

update [Nashville Housing]
set PropertySplitCity= SUBSTRING(PropertyAddress , CHARINDEX(',',PropertyAddress)+1 ,len(PropertyAddress))

select *
from [Nashville Housing]

-- OwnersAddress

select OwnerAddress
from [Nashville Housing]
where OwnerAddress is not null

select 
SUBSTRING(OwnerAddress ,1, CHARINDEX(',' , OwnerAddress)-1) as o_address
, SUBSTRING(OwnerAddress , CHARINDEX(',' , OwnerAddress)+1,CHARINDEX(',' , OwnerAddress)-1)  as o_address
from [Nashville Housing]
where OwnerAddress is not null

-- or we use parsename
-- parsename only works on period and not on comma

select
PARSENAME(replace(OwnerAddress, ',', '.'),3),
PARSENAME(replace(OwnerAddress, ',', '.'),2),
PARSENAME(replace(OwnerAddress, ',', '.'),1)
from [Nashville Housing]


alter table [Nashville Housing]
add OwnerSplitAddress nvarchar(255)

update [Nashville Housing]
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'),3) 

alter table [Nashville Housing]
add OwnerSplitCity nvarchar(255)

update [Nashville Housing]
set OwnerSplitCity=Parsename(replace(OwnerAddress, ',', '.'),2)

alter table [Nashville Housing]
add OwnerSplitState nvarchar(255)

update [Nashville Housing]
set OwnerSplitState=Parsename(replace(OwnerAddress, ',', '.'),1)

-- Change Y, N to Yes and No

select distinct(SoldAsVacant), count(SoldAsVacant)
from [Nashville Housing]
group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from [Nashville Housing]

update [Nashville Housing]
set SoldAsVacant =
case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end

select *
from [Nashville Housing]

-- Remove Duplicates

WITH rowduplicateCTE as(
select*,
      Row_Number() over(
      Partition By ParcelId,
	               PropertyAddress,
				   SaleDate,
				   SalePrice,
				   LegalReference
				   order by UniqueId) row_num
from [Nashville Housing]
)
delete
from rowduplicateCTE
where row_num >1
--order by PropertyAddress


WITH rowduplicateCTE as(
select*,
      Row_Number() over(
      Partition By ParcelId,
	               PropertyAddress,
				   SaleDate,
				   SalePrice,
				   LegalReference
				   order by UniqueId) row_num
from [Nashville Housing]
)
select*
from rowduplicateCTE
where row_num >1
order by PropertyAddress


-- Delete Unused columns

select*
from [Nashville Housing]

alter table [Nashville Housing]
drop column OwnerAddress, propertyaddress, saledate, taxdistrict, saledatecon


