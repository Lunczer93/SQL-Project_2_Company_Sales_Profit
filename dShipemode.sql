/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [SHP_ID]
      ,[Ship Mode]
  FROM [Project2].[dbo].[dShipMode]


  SELECT * 
  FROM [Project2].[dbo].[dShipMode] 

 --1.Create TEMP TABLE in order to create one Table with information regarding Ship Mode, Sales, Profit, Customer Name, Product, City and Segment
 --1.a) Creating TEMP TABLE in order to store a subset of data from Tables.
 DROP TABLE IF EXISTS #SalesByShipModeandDate 
 CREATE TABLE #SalesByShipModeandDate 
 (
 [Order Date] Date,
 [Ship Mode] varchar(50),
 [SalesAmount] int,
 [Profit] int,
 [Customer Name] varchar(50),
 [Sub Category] varchar(50),
 [City] varchar(50),
 [Segment] varchar(50)
 )
 --1.b) INSERT NEW RECORD TO THE TEMP TABLE
 INSERT INTO #SalesByShipModeandDate
SELECT	fd.[OrderDateConverted], 
		s.[Ship Mode],
		fd.[SalesAmount],
		fd.[Profit], 
		c.[Customer Name],
		p.[Sub-Category], 
		l.City, 
		seg.Segment
FROM [Project2].[dbo].[fData] fd
	LEFT JOIN [Project2].[dbo].[dShipMode] s
		ON fd.[SHP_ID] = s.SHP_ID
LEFT JOIN [Project2].[dbo].[dCustomer] c
		ON fd.[Customer ID] = c.[Customer ID]
LEFT JOIN [Project2].[dbo].[dProduct] p
		ON fd.[Product ID] = p.[Product ID]
LEFT JOIN [Project2].[dbo].[dLocation] l
		ON fd.[LOC_ID] = l.LOC_ID
LEFT JOIN [Project2].[dbo].[dSegment] seg
		ON fd.[SEG_ID] = seg.[SEG_ID]
 --1.c) The final table
 SELECT *
 FROM #SalesByShipModeandDate
 -- 1.d)The combination of Ship Mode, Sales, Profit, Customer, Category, City and Segment by using CTE and UNION
 WITH First_Class AS
 (
		 SELECT  FORMAT([Order Date], 'MMM dd yyyy') as [Order Date], [Ship Mode], [SalesAmount] as [Sales], Profit, [Customer Name], [Sub Category] as Category, [City], [Segment]
		 FROM #SalesByShipModeandDate
		 WHERE  [Ship Mode] = 'First Class' 
 ), Same_Day AS (
		 SELECT  FORMAT([Order Date], 'MMM dd yyyy') as [Order Date], [Ship Mode], [SalesAmount] as [Sales], Profit, [Customer Name], [Sub Category] as Category, [City], [Segment]
		 FROM #SalesByShipModeandDate
		 WHERE  [Ship Mode] = 'Same Day'
 ), Second_Class AS (
		 SELECT  FORMAT([Order Date], 'MMM dd yyyy') as [Order Date], [Ship Mode], [SalesAmount] as [Sales], Profit, [Customer Name], [Sub Category] as Category, [City], [Segment]
		 FROM #SalesByShipModeandDate
		 WHERE  [Ship Mode] = 'Second Class'
 ), Standard_Class AS (
		 SELECT  FORMAT([Order Date], 'MMM dd yyyy') as [Order Date], [Ship Mode], [SalesAmount] as [Sales], Profit, [Customer Name], [Sub Category] as Category, [City], [Segment]
		 FROM #SalesByShipModeandDate
		 WHERE  [Ship Mode] = 'Standard Class'
 )
SELECT *
FROM First_Class
UNION
SELECT *
FROM Same_Day
UNION
SELECT *
FROM Second_Class
UNION
SELECT *
FROM Standard_Class
ORDER BY [Ship Mode]
---


-- 2. Looking at the the whole quantity of shipmode by  customer 
SELECT  DISTINCT 
	s.[Ship Mode], 
	COUNT(c.[Customer Name]) OVER (Partition by s.[Ship Mode]) as [Quantity of Customer]
FROM [Project2].[dbo].[fData] fd
LEFT JOIN [Project2].[dbo].[dShipMode] s
	ON fd.[SHP_ID] = s.SHP_ID
LEFT JOIN [Project2].[dbo].[dCustomer] c
	ON fd.[Customer ID] = c.[Customer ID]
ORDER BY [Quantity of Customer] DESC
---


 -- 3.Looking at the quantity of ship mode, profit and sales in 2014 by customer
SELECT  DISTINCT
	s.[Ship Mode], COUNT(c.[Customer Name]) OVER (Partition by s.[Ship Mode]) as [Quantity of Customer],
	SUM(fd.[SalesAmount]) OVER (PARTITION BY s.[Ship Mode]) as Sales,
	CAST(SUM(fd.[Profit]) OVER (PARTITION BY s.[Ship Mode]) AS DECIMAL(32,2)) as Profit
FROM [Project2].[dbo].[fData] fd
	LEFT JOIN [Project2].[dbo].[dShipMode] s
		ON fd.[SHP_ID] = s.SHP_ID
	LEFT JOIN [Project2].[dbo].[dCustomer] c
		ON fd.[Customer ID] = c.[Customer ID]
WHERE fd.[YearOfOrder] IN ('2014')
ORDER BY Sales DESC
---


 -- 4. Looking at the quantity of ship mode, profit and sales in 2015 by customer
 SELECT  DISTINCT
	s.[Ship Mode], COUNT(c.[Customer Name]) OVER (Partition by s.[Ship Mode]) as [Quantity of Customer],
	SUM(fd.[SalesAmount]) OVER (PARTITION BY s.[Ship Mode]) as Sales,
	CAST(SUM(fd.[Profit]) OVER (PARTITION BY s.[Ship Mode]) AS DECIMAL(32,2)) as Profit
FROM [Project2].[dbo].[fData] fd
	LEFT JOIN [Project2].[dbo].[dShipMode] s
		ON fd.[SHP_ID] = s.SHP_ID
	LEFT JOIN [Project2].[dbo].[dCustomer] c
		ON fd.[Customer ID] = c.[Customer ID]
WHERE fd.[YearOfOrder] IN ('2015')
ORDER BY Sales DESC
---


-- 5. Looking at the quantity of ship mode, profit and sales in 2016 by customer
 SELECT  DISTINCT
	s.[Ship Mode], COUNT(c.[Customer Name]) OVER (Partition by s.[Ship Mode]) as [Quantity of Customer],
	SUM(fd.[SalesAmount]) OVER (PARTITION BY s.[Ship Mode]) as Sales,
	CAST(SUM(fd.[Profit]) OVER (PARTITION BY s.[Ship Mode]) AS DECIMAL(32,2)) as Profit
FROM [Project2].[dbo].[fData] fd
	LEFT JOIN [Project2].[dbo].[dShipMode] s
		 ON fd.[SHP_ID] = s.SHP_ID
	LEFT JOIN [Project2].[dbo].[dCustomer] c
		ON fd.[Customer ID] = c.[Customer ID]
WHERE fd.[YearOfOrder] IN ('2016')
ORDER BY Sales DESC
---


-- 6. Looking at the quantity of ship mode, profit and sales in 2017 by customer
 SELECT  DISTINCT
	s.[Ship Mode], COUNT(c.[Customer Name]) OVER (Partition by s.[Ship Mode]) as [Quantity of Customer],
	SUM(fd.[SalesAmount]) OVER (PARTITION BY s.[Ship Mode]) as Sales,
	CAST(SUM(fd.[Profit]) OVER (PARTITION BY s.[Ship Mode]) AS DECIMAL(32,2)) as Profit
FROM [Project2].[dbo].[fData] fd
	LEFT JOIN [Project2].[dbo].[dShipMode] s
		ON fd.[SHP_ID] = s.SHP_ID
	LEFT JOIN [Project2].[dbo].[dCustomer] c
		ON fd.[Customer ID] = c.[Customer ID]
 WHERE fd.[YearOfOrder] IN ('2017')
 ORDER BY Sales DESC



