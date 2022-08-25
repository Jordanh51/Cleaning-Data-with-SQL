/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM PortifolioProject.dbo.NashvilleHousing

--edit sales date


 ALTER TABLE NashvilleHousing
  ADD SaleDateConverted DATE;
 
 Update NashvilleHousing
 SET SaleDateConverted=CONVERT(Date,SaleDate)

 SELECT SaleDateConverted,CONVERT(Date,SaleDate)
  FROM PortifolioProject.dbo.NashvilleHousing



--Populate Property Address Data

SELECT PropertyAddress
  FROM PortifolioProject.dbo.NashvilleHousing
  WHERE PropertyAddress is null

  SELECT *
  FROM PortifolioProject.dbo.NashvilleHousing
 order by ParcelID --duplicate ParcelID's found

 --where the parcel ID is the same we want to populate the address where it is null
   SELECT a.ParcelID, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
  FROM PortifolioProject.dbo.NashvilleHousing a
  INNER JOIN PortifolioProject.dbo.NashvilleHousing b ON 
  a.ParcelID=b.ParcelID
  AND a.UniqueID<> b.UniqueID
  where a.PropertyAddress is null

  Update a
  SET PropertyAddress=ISNULL(a.PropertyAddress, b.PropertyAddress)
  FROM PortifolioProject.dbo.NashvilleHousing a
  JOIN PortifolioProject.dbo.NashvilleHousing b
  ON a.ParcelID=b.ParcelID
  AND a.UniqueID<>b.UniqueID
  where a.PropertyAddress is null

  --Breaking out Address into Individual Columns (Address, City,State)
  Select PropertyAddress FROM PortifolioProject.dbo.NashvilleHousing

  Select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address 
  FROM PortifolioProject.dbo.NashvilleHousing --grab everything from beginning of address to right before where comma begins

  Select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address,
  SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as city
  FROM PortifolioProject.dbo.NashvilleHousing --grabs first section of address and also the city

  --Create two columns and add the above query results in the columns
  
  ALTER TABLE NashvilleHousing
  ADD PropertySplitAddress NVARCHAR(255)
 
 Update NashvilleHousing
 SET PropertySplitAddress= SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

 ALTER TABLE NashvilleHousing
  ADD PropertySplitCity NVARCHAR(255);
 
 Update NashvilleHousing
 SET PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


 --Split OwnerAddress using PARSENAME()
 Select OwnerAddress  FROM PortifolioProject.dbo.NashvilleHousing 

 select OwnerAddress,PARSENAME(REPLACE(OwnerAddress, ',','.'),1),
 PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
 PARSENAME(REPLACE(OwnerAddress, ',','.'),3)  
 FROM PortifolioProject.dbo.NashvilleHousing 
 --this will replace the comma with a period and starts from the right and moves left to find period and grab everything from the period to the end of the string\
 --copy code above to see the example

 --Reorder the numbers to start left to right
  select PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
 PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
 PARSENAME(REPLACE(OwnerAddress, ',','.'),1)  
 FROM PortifolioProject.dbo.NashvilleHousing 

 --Add new queries above to table

  ALTER TABLE NashvilleHousing
  ADD OwnerSplitAddress NVARCHAR(255);
 
 Update NashvilleHousing
 SET OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress, ',','.'),3)


  ALTER TABLE NashvilleHousing
  ADD OwnerSplitCity NVARCHAR(255);
 
 Update NashvilleHousing
 SET OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress, ',','.'),2)


  ALTER TABLE NashvilleHousing
  ADD OwnerSplitState NVARCHAR(255);
 
 Update NashvilleHousing
 SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress, ',','.'),1) 


 --Change 'Y' and 'N' to Yes and No found in query below using CASE
 select Distinct(SoldAsVacant), COUNT(SoldAsVacant) FROM PortifolioProject.dbo.NashvilleHousing 
 GROUP BY SoldASVacant
 order by 2
 
SELECT SoldAsVacant, CASE WHEN SoldAsVacant='Y' Then 'Yes'
WHEN SoldAsVacant='N' Then 'No'
Else SoldAsVacant
END
FROM PortifolioProject.dbo.NashvilleHousing 

Update NashvilleHousing
SET SoldAsVacant=CASE WHEN SoldAsVacant='Y' Then 'Yes'
WHEN SoldAsVacant='N' Then 'No'
Else SoldAsVacant
END

--Remove Duplicates

Select *
FROM PortifolioProject.dbo.NashvilleHousing

WITH RowNumCTE AS(
Select *, ROW_NUMBER()OVER(
PARTITION BY
ParcelID,
PropertyAddress, SalePrice,SaleDate, LegalReference
ORDER BY UniqueID) row_num
FROM PortifolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)

Select * from RowNumCTE
Where row_num>1
Order by PropertyAddress
--above query finds duplicates by creating a partition and CTE (tempTable) 


WITH RowNumCTE AS(
Select *, ROW_NUMBER()OVER(
PARTITION BY
ParcelID,
PropertyAddress, SalePrice,SaleDate, LegalReference
ORDER BY UniqueID) row_num
FROM PortifolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE 
from RowNumCTE
Where row_num>1
--Order by PropertyAddress
--Above query deletes the duplicates


--Delete Unused Columns
Select * FROM PortifolioProject.dbo.NashvilleHousing
 
 ALTER TABLE PortifolioProject.dbo.NashvilleHousing
 DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
 
  
