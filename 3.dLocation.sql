/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [LOC_ID]
      ,[Country]
      ,[Region]
      ,[State]
      ,[City]
      ,[Postal Code]
  FROM [Project2].[dbo].[dLocation]

 


-- 1. Creating a virtual table in order to show show the ranking of the city by Quantity of Product
CREATE VIEW QuantityOfProductByCity AS 
SELECT DISTINCT  
			l.[City], 
			COUNT(c.[Customer Name]) OVER (PARTITION BY l.[City]) as [Quantity of Product]
  FROM [Project2].[dbo].[fData] fd
LEFT JOIN [Project2].[dbo].[dLocation] l
  ON fd.[LOC_ID] = l.[LOC_ID]
LEFT JOIN [Project2].[dbo].[dCustomer] c
 on fd.[Customer ID] = c.[Customer ID]
 GROUP BY c.[Customer Name], l.[City]
 -- 1.a)The final ranking of the city by Quantity of Product
SELECT DENSE_RANK() OVER (ORDER BY [Quantity of Product] DESC) as Ranking, *
FROM QuantityOfProductByCity
ORDER BY [Quantity of Product] DESC
---


 --- 2. CREATE TEMP TABLE in order to calculate the cumulative distrubtion to show top 25% Sales by city by using CTE
--2.a) Creating TEMP TABLE in order to store a subset of data from Tables.
 DROP TABLE IF EXISTS #Top25SalesByCity
 CREATE TABLE #Top25SalesByCity
(
City varchar(40),
Sales int
)
--2.b) Insert records to TEMP TABLE
INSERT INTO #Top25SalesByCity
SELECT DISTINCT  l.[City] as City,
	SUM(SalesAmount) OVER (PARTITION BY l.[City]) as [Sales]
FROM [Project2].[dbo].[fData] fd
	LEFT JOIN [Project2].[dbo].[dLocation] l
ON fd.[LOC_ID] = l.[LOC_ID]
	LEFT JOIN [Project2].[dbo].[dProduct] p
ON fd.[Product ID] = p.[Product ID]
ORDER BY Sales DESC
 -- 2.c) The final result of the Top 25 % Sales by City
 With Top25ProcentSalesByCity_CTE AS 
 (
 SELECT DISTINCT 
		City, 
		Sales,
		CAST(cume_dist() OVER (ORDER BY Sales DESC) * 100 AS DECIMAL(32,2)) as [Cumulative Distribution %]
 FROM #Top25SalesByCity
 )
 SELECT City, [Cumulative Distribution %]
 FROM Top25ProcentSalesByCity_CTE
 WHERE [Cumulative Distribution %] <= 25.00
 ORDER BY Sales DESC
 ---


 --3. CREATE TEMP TABLE in order to compare Sales in Regions between 2014-2017 by Month
 --3.a) Creating TEMP TABLE in order to store a subset of data from Tables.
 DROP TABLE IF EXISTS #SalesofRegionByDate 
 CREATE TABLE #SalesofRegionByDate 
 (
 [Year] int,
 [Month Name] varchar(30),
 [Month] int,
 [Region] varchar(30),
 [Sales Amount] int,
 [Customer Name] varchar(50)
 )
 --3.b) Insert record to TEMP TABLE
INSERT INTO #SalesofRegionByDate 
SELECT DISTINCT 
	fd.[YearOfOrder] ,
	Datename(Month, fd.[OrderDateConverted]) as [Month Name],
	Month(fd.[OrderDateConverted]) as [Month], 
	l.[Region] as [Region], 
	fd.[SalesAmount] as [Sales Amount], 
	c.[Customer Name]
FROM [Project2].[dbo].[fData] fd
	LEFT JOIN [Project2].[dbo].[dLocation] l
		ON fd.[LOC_ID] = l.[LOC_ID]
	LEFT JOIN [Project2].[dbo].[dCustomer] c
		ON fd.[Customer ID] = c.[Customer ID]

--3.d) the combination of the whole  Regions, Sales and Quantity of Customer in 2017 in one Table using CTE
WITH CentralRegion AS (
			SELECT DISTINCT 
			[Month],
			[Month Name],
			SUM([Sales Amount]) OVER (PARTITION BY [Month Name]) as [Sales Amount], 
			COUNT([Customer Name]) OVER (PARTITION BY [Month Name]) as [Quantity of Customer]
			FROM #SalesofRegionByDate
			WHERE Region = 'Central' and [Year] IN ('2017')
), EastRegion AS (
			SELECT DISTINCT 
			[Month],
			[Month Name],
			SUM([Sales Amount]) OVER (PARTITION BY [Month Name]) as [Sales Amount], 
			COUNT([Customer Name]) OVER (PARTITION BY [Month Name]) as [Quantity of Customer]
			FROM #SalesofRegionByDate
			WHERE Region = 'East' and [Year] IN ('2017')

), SouthRegion AS (
	SELECT DISTINCT 
			[Month],
			[Month Name],
			SUM([Sales Amount]) OVER (PARTITION BY [Month Name]) as [Sales Amount], 
			COUNT([Customer Name]) OVER (PARTITION BY [Month Name]) as [Quantity of Customer]
			FROM #SalesofRegionByDate
			WHERE Region = 'South' and [Year] IN ('2017')
	
), WestRegion AS (
			SELECT DISTINCT 
			[Month],
			[Month Name],
			SUM([Sales Amount]) OVER (PARTITION BY [Month Name]) as [Sales Amount], 
			COUNT([Customer Name]) OVER (PARTITION BY [Month Name]) as [Quantity of Customer]
			FROM #SalesofRegionByDate
			WHERE Region = 'West' and [Year] IN ('2017')
	
), month AS (
	SELECT DISTINCT [Month Name], [Month]
	FROM #SalesofRegionByDate
)
SELECT  
	m.[Month Name] as [Date],
	cr.[Sales Amount] as [Central Region Sales 2017], 
	cr.[Quantity of Customer] as [Central Region Customer 2017],
	er.[Sales Amount] as [East Region Sales 2017],
	er.[Quantity of Customer] as [East Region Customer 2017],
	sr.[Sales Amount] as [South Region Sales 2017] ,
	sr.[Quantity of Customer] as [South Region Customer 2017],
	wr.[Sales Amount] as [West Region Customer 2017],
	wr.[Quantity of Customer] as [South Region Customer 2017]
FROM month m
LEFT JOIN   CentralRegion cr 
	ON cr.[Month Name] = m.[Month Name]
LEFT JOIN  EastRegion er
	on er.[Month Name] = m.[Month Name]
LEFT JOIN  SouthRegion sr
	on sr.[Month Name] = m.[Month Name]
LEFT JOIN   WestRegion wr
	on wr.[Month Name] = m.[Month Name]
ORDER BY m.[Month]

--3.e) the combination of the whole  Regions, Sales and Quantity of Customer in 2016 in one Table using CTE
WITH CentralRegion AS (
			SELECT DISTINCT 
			[Month],
			[Month Name],
			SUM([Sales Amount]) OVER (PARTITION BY [Month Name]) as [Sales Amount], 
			COUNT([Customer Name]) OVER (PARTITION BY [Month Name]) as [Quantity of Customer]
			FROM #SalesofRegionByDate
			WHERE Region = 'Central' and [Year] IN ('2016')
), EastRegion AS (
			SELECT DISTINCT 
			[Month],
			[Month Name],
			SUM([Sales Amount]) OVER (PARTITION BY [Month Name]) as [Sales Amount], 
			COUNT([Customer Name]) OVER (PARTITION BY [Month Name]) as [Quantity of Customer]
			FROM #SalesofRegionByDate
			WHERE Region = 'East' and [Year] IN ('2016')

), SouthRegion AS (
			SELECT DISTINCT 
			[Month],
			[Month Name],
			SUM([Sales Amount]) OVER (PARTITION BY [Month Name]) as [Sales Amount], 
			COUNT([Customer Name]) OVER (PARTITION BY [Month Name]) as [Quantity of Customer]
			FROM #SalesofRegionByDate
			WHERE Region = 'South' and [Year] IN ('2016')
	
), WestRegion AS (
			SELECT DISTINCT 
			[Month],
			[Month Name],
			SUM([Sales Amount]) OVER (PARTITION BY [Month Name]) as [Sales Amount], 
			COUNT([Customer Name]) OVER (PARTITION BY [Month Name]) as [Quantity of Customer]
			FROM #SalesofRegionByDate
			WHERE Region = 'West' and [Year] IN ('2016')
	
), month AS (
			SELECT DISTINCT [Month Name], [Month]
			FROM #SalesofRegionByDate
)
SELECT  
	m.[Month Name] as [Date],
	cr.[Sales Amount] as [Central Region Sales 2016], 
	cr.[Quantity of Customer] as [Central Region Customer 2016],
	er.[Sales Amount] as [East Region Sales 2016],
	er.[Quantity of Customer] as [East Region Customer 2016],
	sr.[Sales Amount] as [South Region Sales 2016] ,
	sr.[Quantity of Customer] as [South Region Customer 2016],
	wr.[Sales Amount] as [West Region Customer 2016],
	wr.[Quantity of Customer] as [South Region Customer 2016]
FROM month m
LEFT JOIN   CentralRegion cr 
	ON cr.[Month Name] = m.[Month Name]
LEFT JOIN  EastRegion er
	on er.[Month Name] = m.[Month Name]
LEFT JOIN  SouthRegion sr
	on sr.[Month Name] = m.[Month Name]
LEFT JOIN   WestRegion wr
	on wr.[Month Name] = m.[Month Name]
ORDER BY m.[Month]



--3.f) The combination of the whole  Regions, Sales and Quantity of Customer in 2015 in one Table using CTE
WITH CentralRegion AS (
			SELECT DISTINCT 
			[Month],
			[Month Name],
			SUM([Sales Amount]) OVER (PARTITION BY [Month Name]) as [Sales Amount], 
			COUNT([Customer Name]) OVER (PARTITION BY [Month Name]) as [Quantity of Customer]
			FROM #SalesofRegionByDate
			WHERE Region = 'Central' and [Year] IN ('2015')
), EastRegion AS (
			SELECT DISTINCT 
			[Month],
			[Month Name],
			SUM([Sales Amount]) OVER (PARTITION BY [Month Name]) as [Sales Amount], 
			COUNT([Customer Name]) OVER (PARTITION BY [Month Name]) as [Quantity of Customer]
			FROM #SalesofRegionByDate
			WHERE Region = 'East' and [Year] IN ('2015')

), SouthRegion AS (
	SELECT DISTINCT 
			[Month],
			[Month Name],
			SUM([Sales Amount]) OVER (PARTITION BY [Month Name]) as [Sales Amount], 
			COUNT([Customer Name]) OVER (PARTITION BY [Month Name]) as [Quantity of Customer]
			FROM #SalesofRegionByDate
			WHERE Region = 'South' and [Year] IN ('2015')
	
), WestRegion AS (
			SELECT DISTINCT 
			[Month],
			[Month Name],
			SUM([Sales Amount]) OVER (PARTITION BY [Month Name]) as [Sales Amount], 
			COUNT([Customer Name]) OVER (PARTITION BY [Month Name]) as [Quantity of Customer]
			FROM #SalesofRegionByDate
			WHERE Region = 'West' and [Year] IN ('2015')
	
), month AS (
	SELECT DISTINCT [Month Name], [Month]
	FROM #SalesofRegionByDate
)
SELECT  
	m.[Month Name] as [Date],
	cr.[Sales Amount] as [Central Region Sales 2015], 
	cr.[Quantity of Customer] as [Central Region Customer 2015],
	er.[Sales Amount] as [East Region Sales 2015],
	er.[Quantity of Customer] as [East Region Customer 2015],
	sr.[Sales Amount] as [South Region Sales 2015] ,
	sr.[Quantity of Customer] as [South Region Customer 2015],
	wr.[Sales Amount] as [West Region Customer 2015],
	wr.[Quantity of Customer] as [South Region Customer 2015]
FROM month m
LEFT JOIN   CentralRegion cr 
	ON cr.[Month Name] = m.[Month Name]
LEFT JOIN  EastRegion er
	on er.[Month Name] = m.[Month Name]
LEFT JOIN  SouthRegion sr
	on sr.[Month Name] = m.[Month Name]
LEFT JOIN   WestRegion wr
	on wr.[Month Name] = m.[Month Name]
ORDER BY m.[Month]



--3.g) The combination of the whole  Regions, Sales and Quantity of Customer in 2014 in one Table using CTE
WITH CentralRegion AS (
			SELECT DISTINCT 
			[Month],
			[Month Name],
			SUM([Sales Amount]) OVER (PARTITION BY [Month Name]) as [Sales Amount], 
			COUNT([Customer Name]) OVER (PARTITION BY [Month Name]) as [Quantity of Customer]
			FROM #SalesofRegionByDate
			WHERE Region = 'Central' and [Year] IN ('2014')
), EastRegion AS (
			SELECT DISTINCT 
			[Month],
			[Month Name],
			SUM([Sales Amount]) OVER (PARTITION BY [Month Name]) as [Sales Amount], 
			COUNT([Customer Name]) OVER (PARTITION BY [Month Name]) as [Quantity of Customer]
			FROM #SalesofRegionByDate
			WHERE Region = 'East' and [Year] IN ('2014')

), SouthRegion AS (
	SELECT DISTINCT 
			[Month],
			[Month Name],
			SUM([Sales Amount]) OVER (PARTITION BY [Month Name]) as [Sales Amount], 
			COUNT([Customer Name]) OVER (PARTITION BY [Month Name]) as [Quantity of Customer]
			FROM #SalesofRegionByDate
			WHERE Region = 'South' and [Year] IN ('2014')
	
), WestRegion AS (
			SELECT DISTINCT 
			[Month],
			[Month Name],
			SUM([Sales Amount]) OVER (PARTITION BY [Month Name]) as [Sales Amount], 
			COUNT([Customer Name]) OVER (PARTITION BY [Month Name]) as [Quantity of Customer]
			FROM #SalesofRegionByDate
			WHERE Region = 'West' and [Year] IN ('2014')
	
), month AS (
			SELECT DISTINCT [Month Name], [Month]
			FROM #SalesofRegionByDate
)
SELECT  
	m.[Month Name] as [Date],
	cr.[Sales Amount] as [Central Region Sales 2014], 
	cr.[Quantity of Customer] as [Central Region Customer 2014],
	er.[Sales Amount] as [East Region Sales 2014],
	er.[Quantity of Customer] as [East Region Customer 2014],
	sr.[Sales Amount] as [South Region Sales 2014] ,
	sr.[Quantity of Customer] as [South Region Customer 2014],
	wr.[Sales Amount] as [West Region Customer 2014],
	wr.[Quantity of Customer] as [South Region Customer 2014]
FROM month m
LEFT JOIN   CentralRegion cr 
	ON cr.[Month Name] = m.[Month Name]
LEFT JOIN  EastRegion er
	ON er.[Month Name] = m.[Month Name]
LEFT JOIN  SouthRegion sr
	ON sr.[Month Name] = m.[Month Name]
LEFT JOIN   WestRegion wr
	ON wr.[Month Name] = m.[Month Name]
ORDER BY m.[Month]
