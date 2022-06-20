/*

DATA CLEANING PROJECT WITH SQL

*/


--- Visualized all columns of the HousingData table

select *
from PortfolioProject..HousingData;


/*   Standarize Date format  */


update PortfolioProject..HousingData
set SaleDate= convert(Date, SaleDate)


-- create a new column called SaleDateConverted (This action will set all values of the column to NULL)

alter table PortfolioProject..HousingData
add SaleDateConverted Date;

-- Update the values of the new column SaleDateConverted to SaleDate without time
update PortfolioProject..HousingData
set SaleDateConverted= convert(Date, SaleDate);

-- Check the result
select SaleDateConverted
from PortfolioProject..HousingData;



/*  Populate Property Adress data  */


-- check if there are NULL values in the column PropertyAddress

select *
from PortfolioProject..HousingData
where PropertyAddress is null


select *
from PortfolioProject..HousingData
order by ParcelID

-- When the column PropertyAdress is null replace the null values with those values of PropertyAdress which has the same ParcelID
-- For that, we must follow the following steps:

-- 1. join the HousingData with itself on common ParcelID and different UniqueID 

select a.ParcelID, 
       a.PropertyAddress,
       b.ParcelID,
	   b.PropertyAddress
from PortfolioProject..HousingData a
join PortfolioProject..HousingData b
     on (a.ParcelID=b.ParcelID) and (a.[UniqueID ] <>b.[UniqueID ])
where a.PropertyAddress is null

-- 2  create a new column which take the value of the second PropertyAdress when the first PropertyAdrdress is null

select a.ParcelID, 
       a.PropertyAddress,
       b.ParcelID,
	   b.PropertyAddress,
       isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..HousingData a
join PortfolioProject..HousingData b
     on (a.ParcelID=b.ParcelID) and (a.[UniqueID ] <>b.[UniqueID ])
where a.PropertyAddress is null

-- 3 update the value of PropertyAdress to the value of the above new column

update a
set PropertyAddress= isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..HousingData a
join PortfolioProject..HousingData b
     on (a.ParcelID=b.ParcelID) and (a.[UniqueID ] <>b.[UniqueID ])
where a.PropertyAddress is null


-- 4 check

select PropertyAddress
from PortfolioProject..HousingData
where PropertyAddress is null


/*  Breaking out Address into individual columns (Adress, City, State)   */

-- Take a look of the column PropertyAddress

select PropertyAddress
from PortfolioProject..HousingData


--Use the  functions substring() and charindex() to split the values of PropertyAddress

select PropertyAddress,
     substring(PropertyAddress,1, charindex(',',PropertyAddress)-1) as address, -- charindex(',',PropertyAddress) return the index position
	 substring(PropertyAddress, charindex(',',PropertyAddress)+1, len(PropertyAddress)) as City
from PortfolioProject..HousingData


-- Now we create  new columns on our table

alter table PortfolioProject..HousingData
add PropertySplitAddress nvarchar(255);

update PortfolioProject..HousingData
set PropertySplitAddress=substring(PropertyAddress,1, charindex(',',PropertyAddress)-1);


alter table PortfolioProject..HousingData
add PropertySplitCity nvarchar(255);

update PortfolioProject..HousingData
set PropertySplitCity=substring(PropertyAddress, charindex(',',PropertyAddress)+1, len(PropertyAddress))

-- Check the result

select *
from PortfolioProject..HousingData;

--- We use the function parsename()


select OwnerAddress
from PortfolioProject..HousingData;

select parsename(replace(OwnerAddress, ',','.'),3),
       parsename(replace(OwnerAddress, ',','.'),2),
	   parsename(replace(OwnerAddress, ',','.'),1)
from PortfolioProject..HousingData;


-- Now we create  new columns on our table


--Address
alter table PortfolioProject..HousingData
add OwnerSplitAddress nvarchar(255);

update PortfolioProject..HousingData
set OwnerSplitAddress=parsename(replace(OwnerAddress, ',','.'),3);


--City
alter table PortfolioProject..HousingData
add OwnerSplitCity nvarchar(255);

update PortfolioProject..HousingData
set OwnerSplitCity=parsename(replace(OwnerAddress, ',','.'),2);

--State

alter table PortfolioProject..HousingData
add OwnerSplitState nvarchar(255);

update PortfolioProject..HousingData
set OwnerSplitState=parsename(replace(OwnerAddress, ',','.'),1);


/*   Change Y and N to Yes and No in SoldAsVacant field using Case    */

-- Get distinct values of SoldAsVacant

select distinct(SoldAsVacant),
       count(SoldAsVacant)
from PortfolioProject..HousingData
group by SoldAsVacant
order by 2

-- Replace values in a new column to see how it work

select SoldAsVacant,
case when SoldAsVacant='Y' then 'Yes'
     when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 end
from PortfolioProject..HousingData;

-- update SaleAsVacant

update PortfolioProject..HousingData
set SoldAsVacant=case when SoldAsVacant='Y' then 'Yes'
     when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 end
from PortfolioProject..HousingData;


/*   REMOVE DUPLICATES VALUES */


-- Create a new column called RowNum that count the number of row where ParcelID,PropertyAddress, SaleDate, LegalReference have the same values.


select *,
       row_number() over (
	   partition by ParcelID,
	                PropertyAddress,
					SaleDate,
					LegalReference
					order by 
					      UniqueID) RowNum
from PortfolioProject..HousingData
order by ParcelID;


--  Looking at duplicate rows in the sense that ParcelID,PropertyAddress, SaleDate, LegalReference have the same values

with RowNumCTE as 
(
select *,
       row_number() over (partition by ParcelID,
	                              PropertyAddress,
			               SaleDate,
					LegalReference
					order by UniqueID) RowNum
from PortfolioProject..HousingData
)
select *
from RowNumCTE
where RowNum>1
order by PropertyAddress


--- Delete duplicate row

with RowNumCTE as 
(
select *,
       row_number() over (partition by ParcelID,
	                                PropertyAddress,
					SaleDate,
					LegalReference
					order by UniqueID) RowNum
from PortfolioProject..HousingData
)
delete
from RowNumCTE
where RowNum>1
--order by PropertyAddress;





/*   DELETE UNUSED COLUMN    */



select * 
from PortfolioProject..HousingData;


-- Delete the column OwnerAddress, TaxDistrict, PropertyAddress


alter table PortfolioProject..HousingData
drop column OwnerAddress, TaxDistrict,PropertyAddress



