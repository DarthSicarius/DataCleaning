/*

CLeaning Data in SQL Queries

*/

select *
from PortfolioProject..housingData

----------------------------------------------------------------------------------------------------------------

--Standardize Date Format

select SalesDateConverted, CONVERT(date, SaleDate)
from PortfolioProject..housingData

alter table housingData
add SalesDateConverted Date;

update housingData
 set SalesDateConverted = CONVERT(date, SaleDate)

 ----------------------------------------------------------------------------------------------------------------

 --Populate Property Address Data

select *
from PortfolioProject..housingData
--where PropertyAddress is null
order by ParcelID

select fir.ParcelID, fir.PropertyAddress, sec.ParcelID, sec.PropertyAddress, isnull(fir.PropertyAddress, sec.PropertyAddress)
from PortfolioProject..housingData fir
join PortfolioProject..housingData sec
	on fir.ParcelID = sec.ParcelID
	and fir.[UniqueID ] <> sec.[UniqueID ]
where fir.PropertyAddress is null

update fir
set PropertyAddress = isnull(fir.PropertyAddress, sec.PropertyAddress)
from PortfolioProject..housingData fir
join PortfolioProject..housingData sec
	on fir.ParcelID = sec.ParcelID
	and fir.[UniqueID ] <> sec.[UniqueID ]
where fir.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------------------------------------

-- Separating Address into Individual Columns(Address, City, State)

select PropertyAddress
from PortfolioProject..housingData

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as City

From PortfolioProject..housingData

alter table housingData
add NewPropetyAddress Nvarchar(255);

update housingData
 set NewPropetyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table housingData
add NewPropertyCity Nvarchar(255);

update housingData
 set NewPropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

select*
from PortfolioProject..housingData

select OwnerAddress
from PortfolioProject..housingData

select
PARSENAME(replace(OwnerAddress, ',' , '.'), 3)
,PARSENAME(replace(OwnerAddress, ',' , '.'), 2)
,PARSENAME(replace(OwnerAddress, ',' , '.'), 1)
from PortfolioProject..housingData

alter table housingData
add NewOwnerPropetyAddress Nvarchar(255);

update housingData
 set NewOwnerPropetyAddress = PARSENAME(replace(OwnerAddress, ',' , '.'), 3)

alter table housingData
add NewOwnerPropertyCity Nvarchar(255);

update housingData
 set NewOwnerPropertyCity = PARSENAME(replace(OwnerAddress, ',' , '.'), 2)

 alter table housingData
add NewOwnerPropertyState Nvarchar(255);

update housingData
 set NewOwnerPropertyState = PARSENAME(replace(OwnerAddress, ',' , '.'), 1)

 select*
 from PortfolioProject..housingData
--------------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No under "Sold as Vacant" column

 select SoldAsVacant
	case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		 end
 from PortfolioProject..housingData

 update housingData
 set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		 end

select Distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject..housingData
group by SoldAsVacant
order by 2

--------------------------------------------------------------------------------------------------------------------------------------------------------

--Removing Duplicates

with RowNumCTE as(
select*,

	ROW_NUMBER() over(
	Partition by ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
					UniqueID
					) row_num
			 
from PortfolioProject..housingData
--order by ParcelID
)
delete
from RowNumCTE
where row_num > 1
order by PropertyAddress


--------------------------------------------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns

select *
from PortfolioProject..housingData

alter table PortfolioProject..housingData
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate