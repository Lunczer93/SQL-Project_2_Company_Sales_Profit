/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [Trans_ID]
      ,[Order ID]
      ,[Order Date]
      ,[Ship Date]
      ,[SHP_ID]
      ,[Customer ID]
      ,[SEG_ID]
      ,[LOC_ID]
      ,[Product ID]
      ,[Sales]
      ,[Quantity]
      ,[Discount]
      ,[Profit]
  FROM [Project2].[dbo].[fData]

 SELECT * 
 FROM Project2.dbo.fData

-- 1. Add new column with converted Date for Order Date
-- Create a new column
ALTER TABLE Project2.dbo.fData
Add OrderDateConverted Date
--Convert date and update a new column
Update Project2.dbo.fData
SET OrderDateConverted =  CONVERT(date, [Order Date])
--  Verify if it works properly
SELECT *
FROM Project2.dbo.fData
---


-- 2. Add new column with converted Date for Ship Order
--Create a new column
ALTER TABLE Project2.dbo.fData
Add ShipDateConverted Date
-- Convert date and update a new column
Update Project2.dbo.fData
SET ShipDateConverted = CONVERT(Date, [Ship Date])
--Verify if it works properly
SELECT * 
FROM Project2.dbo.fData
---


--3.  Add a new column for SalesAmount
ALTER TABLE Project2.dbo.fData
ADD SalesAmount int
-- Add new calculations to this column
Update Project2.dbo.fData
SET SalesAmount = CONVERT(int, Sales*Quantity)
-- Verify if it works properly
SELECT * 
FROM Project2.dbo.fData


--4.Returning the year part from Order Date
SELECT YEAR(OrderDateConverted) as YearOfOrder, OrderDateConverted
FROM Project2.dbo.fData
ORDER BY YearOfOrder

--5. Add a new column for Year
ALTER TABLE Project2.dbo.fData
Add YearOfOrder int
-- Convert Date and update this column
UPDATE Project2.dbo.fData
Set YearOfOrder = YEAR(OrderDateConverted)

-- 6. Returning month part from Order Date
SELECT [OrderDateConverted], DATENAME(month, [OrderDateConverted]) as Month
FROM Project2.dbo.fData
-- 7. Add a new column for a month
ALTER TABLE Project2.dbo.fData
ADD Month varchar(10)
-- Convert Month and update this column
UPDATE Project2.dbo.fData
Set Month = DATENAME(month, [OrderDateConverted])

--Verify if all added columns work properly
SELECT * FROM  Project2.dbo.fData

-- 8. Remove Unused columns
Alter TABLE Project2.dbo.fData
DROP COLUMN [Order Date];

Alter TABLE Project2.dbo.fData
DROP COLUMN [Ship Date];

Alter TABLE Project2.dbo.fData
DROP COLUMN [Year], [YearOfOrder]
---


-- 9. The statistical description of the data from fData table
SELECT DISTINCT
		YearOfOrder,
		SUM(SalesAmount) OVER (PARTITION BY YearOfOrder) as TotalSales,
		SUM(SalesAmount) OVER (ORDER BY YearOfOrder ) AS [Running Total Sales],
		CAST(SUM(Profit) OVER (PARTITION BY YearOfOrder) AS DECIMAL(32,2)) as TotalProfit,
		CAST(SUM(Profit) OVER (ORDER BY YearOfOrder ) AS DECIMAL(32,2)) AS [Running Total Profit],
		AVG(SalesAmount) OVER(PARTITION BY YearOfOrder) as AverageSales, 
		CAST(STDEV(SalesAmount) OVER (PARTITION BY YearOfOrder) AS DECIMAL(32,2))  AS [Standard Deviation of Sales],
		CAST(AVG(Profit) OVER(PARTITION BY YearOfOrder) AS DECIMAL(32,2)) as AverageProfit,
		CAST(STDEV(Profit) OVER (PARTITION BY YearOfOrder) AS DECIMAL(32,2))  AS [Standard Deviation of Profit],
		PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY SalesAmount) OVER (PARTITION BY YearOfOrder) as MedianDisc,
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY SalesAmount) OVER (PARTITION BY YearOfOrder) as MedianCont
FROM Project2.dbo.fData
GROUP BY YearOfOrder, SalesAmount, Profit
ORDER BY YearOfOrder DESC
---


-- 10. The calculation of the running difference in 2014 for Profit and Sales
-- 10.a)Creating TEMP TABLE in order to store a subset of data from Tables. 
DROP TABLE IF EXISTS #SalesByMonth2014 
CREATE TABLE #SalesByMonth2014  (
[Month Name] varchar(30),
[Number of Month] int,
[Sales Amount] int,
[Profit] int
)
-- 10.b)INSERT NEW RECORDS to TEMP TABLE
INSERT INTO #SalesByMonth2014
	Select DISTINCT
			DateName(month,[OrderDateConverted]) as [Month Name],Month([OrderDateConverted]) as [Number of Month],
			SUM([SalesAmount]) OVER (PARTITION BY Month) as [Sales Amount],
			CAST(SUM([Profit]) OVER (PARTITION BY Month) AS DECIMAL(32,2)) as [Profit]
	FROM Project2.dbo.fData
	WHERE YearOfOrder IN ('2014')
	ORDER BY [Number of Month]  ASC
-- 10.c)The final calculation of the running difference in 2014 by Profit and Sales by using CTE
WITH SalesAmountAndSalesAmountPreviousMonth_CTE AS 
(
	SELECT DISTINCT [Month Name],[Number of Month],
		[Sales Amount], 
		LAG([Sales Amount]) OVER (ORDER BY [Number of Month]) as [Sales Amount previous month],
		[Profit],
		LAG([Profit]) OVER (ORDER BY [Number of Month]) as [Profit previous month]
FROM #SalesByMonth2014
)
SELECT [Month Name],
	([Sales Amount] - [Sales Amount previous month]) as [Sales Running Difference],
	([Profit] - [Profit Previous month]) as [Profit Running Difference]
FROM SalesAmountAndSalesAmountPreviousMonth_CTE
ORDER BY [Number of Month]  ASC
---


--11. The calculation of the running difference in 2015 for Profit and Sales
-- 11.a) Creating TEMP TABLE in order to store a subset of data from Tables. 
DROP TABLE IF EXISTS #SalesByMonth2015 
CREATE TABLE #SalesByMonth2015 (
[Month Name] varchar(30),
[Number of Month] int,
[Sales Amount] int,
[Profit] int
)
-- 11.b) INSERT NEW RECORDS to TEMP TABLE
INSERT INTO #SalesByMonth2015
	Select DISTINCT
			DateName(month,[OrderDateConverted]) as [Month Name],Month([OrderDateConverted]) as [Number of Month],
			SUM([SalesAmount]) OVER (PARTITION BY Month) as [Sales Amount],
			CAST(SUM([Profit]) OVER (PARTITION BY Month) AS DECIMAL(32,2)) as [Profit]
	FROM Project2.dbo.fData
	WHERE YearOfOrder IN ('2015')
	ORDER BY [Number of Month]  ASC
-- 11.c) The final calculation of the running difference in 2015 by Profit and Sales by using CTE
WITH SalesAmountAndSalesAmountPreviousMonth_CTE AS 
(
	SELECT DISTINCT [Month Name],[Number of Month],
		[Sales Amount], 
		LAG([Sales Amount]) OVER (ORDER BY [Number of Month]) as [Sales Amount previous month],
		[Profit],
		LAG([Profit]) OVER (ORDER BY [Number of Month]) as [Profit previous month]
	FROM #SalesByMonth2015
)
SELECT [Month Name],
	([Sales Amount] - [Sales Amount previous month]) as [Sales Running Difference],
	([Profit] - [Profit Previous month]) as [Profit Running Difference]
FROM SalesAmountAndSalesAmountPreviousMonth_CTE
ORDER BY [Number of Month]  ASC
---


--12. The calculation of the running difference in 2016 for Profit and Sales
-- 12a)Creating TEMP TABLE in order to store a subset of data from Tables. 
DROP TABLE IF EXISTS #SalesByMonth2016 
CREATE TABLE #SalesByMonth2016 (
[Month Name] varchar(30),
[Number of Month] int,
[Sales Amount] int,
[Profit] int
)
--12b) INSERT NEW RECORDS to TEMP TABLE
INSERT INTO #SalesByMonth2016
	Select DISTINCT
			DateName(month,[OrderDateConverted]) as [Month Name],Month([OrderDateConverted]) as [Number of Month],
			SUM([SalesAmount]) OVER (PARTITION BY Month) as [Sales Amount],
			CAST(SUM([Profit]) OVER (PARTITION BY Month) AS DECIMAL(32,2)) as [Profit]
	FROM Project2.dbo.fData
	WHERE YearOfOrder IN ('2016')
	ORDER BY [Number of Month]  ASC
-- 12) The final calculation of the running difference in 2016 by Profit and Sales by using CTE
WITH SalesAmountAndSalesAmountPreviousMonth_CTE AS 
(
	SELECT DISTINCT [Month Name],[Number of Month],
			[Sales Amount], 
			LAG([Sales Amount]) OVER (ORDER BY [Number of Month]) as [Sales Amount previous month],
			[Profit],
			LAG([Profit]) OVER (ORDER BY [Number of Month]) as [Profit previous month]
	FROM #SalesByMonth2016
)
SELECT [Month Name],
	([Sales Amount] - [Sales Amount previous month]) as [Sales Running Difference],
	([Profit] - [Profit Previous month]) as [Profit Running Difference]
FROM SalesAmountAndSalesAmountPreviousMonth_CTE
ORDER BY [Number of Month]  ASC
---


-- 13. The calculation of the running difference in 2017 for Profit and Sales
-- 13.a) Creating TEMP TABLE in order to store a subset of data from Tables. 
DROP TABLE IF EXISTS #SalesByMonth2017
CREATE TABLE #SalesByMonth2017 (
[Month Name] varchar(30),
[Number of Month] int,
[Sales Amount] int,
[Profit] int
)
--13b) INSERT NEW RECORDS to TEMP TABLE
INSERT INTO #SalesByMonth2017
	Select DISTINCT
			DateName(month,[OrderDateConverted]) as [Month Name],Month([OrderDateConverted]) as [Number of Month],
			SUM([SalesAmount]) OVER (PARTITION BY Month) as [Sales Amount],
			CAST(SUM([Profit]) OVER (PARTITION BY Month) AS DECIMAL(32,2)) as [Profit]
	FROM Project2.dbo.fData
	WHERE YearOfOrder IN ('2017')
	ORDER BY [Number of Month]  ASC
-- 13c)The final calculation of the running difference in 2017 by Profit and Sales by using CTE
WITH SalesAmountAndSalesAmountPreviousMonth_CTE AS 
(
	SELECT DISTINCT [Month Name],[Number of Month],
		[Sales Amount], 
		LAG([Sales Amount]) OVER (ORDER BY [Number of Month]) as [Sales Amount previous month],
		[Profit],
		LAG([Profit]) OVER (ORDER BY [Number of Month]) as [Profit previous month]
	FROM #SalesByMonth2017

)
SELECT [Month Name],
	([Sales Amount] - [Sales Amount previous month]) as [Sales Running Difference],
	([Profit] - [Profit Previous month]) as [Profit Running Difference]
FROM SalesAmountAndSalesAmountPreviousMonth_CTE
ORDER BY [Number of Month]  ASC
---


-- 14. The combination of fData, dCustomer and dProductTables based on related columns between them using LEFT JOIN 
SELECT  *
FROM [Project2].[dbo].[fData] fd
LEFT JOIN [Project2].[dbo].[dCustomer] c
	ON fd.[Customer ID] = c.[Customer ID]
LEFT JOIN [Project2].[dbo].[dProduct] p
	ON fd.[Product ID] = p.[Product ID]
WHERE (YearOfOrder BETWEEN 2014 and 2017)
---


-- 15. Looking at top10 customer with the highest profit between 2014 and 2017  
--15.a)  Creating a view (a virtual table) based on the result-set of an SQL statement
CREATE VIEW TOP10_customer_with_highest_profit AS 
SELECT DISTINCT TOP 10
	c.[Customer Name],
	CAST(SUM(fd.[Profit]) OVER (Partition by [Customer Name]) as DECIMAL(32,2)) as Profit
FROM [Project2].[dbo].[fData] fd
LEFT JOIN [Project2].[dbo].[dCustomer] c
	ON fd.[Customer ID] = c.[Customer ID]
WHERE (YearOfOrder BETWEEN 2014 and 2017)
GROUP By [Customer Name], [Profit]
ORDER BY Profit DESC
--15.b) The final result of  top10 customers with the highest profit between 2014 and 2017 
SELECT 
	RANK() OVER (ORDER BY [Profit] DESC) as Ranking,
	[Customer Name], 
	[Profit]
FROM TOP10_customer_with_highest_profit
---


-- 16. Looking at top10 customer with the highest sales between 2014 and 2017
--16.a) Creating a view (a virtual table) based on the result-set of an SQL statement
CREATE VIEW Top10CustomerWithHighestSales AS 
SELECT TOP 10 [Customer Name],
		SUM([SalesAmount]) OVER (PARTITION BY c.[Customer Name]) as [Sales]
FROM [Project2].[dbo].[fData] fd
LEFT JOIN [Project2].[dbo].[dCustomer] c
	ON fd.[Customer ID] = c.[Customer ID]
WHERE (YearOfOrder BETWEEN 2014 and 2017)
GROUP By [Customer Name], [SalesAmount]
ORDER BY [SalesAmount] DESC;
--16.b) The final result of  top10 customers with the highest sales between 2014 and 2017 
SELECT 
	RANK() OVER (ORDER BY Sales DESC) as Ranking,*
FROM  Top10CustomerWithHighestSales
---


--17.  The ranking of customers generate profit greater than average profit
--17.a) Creating a view (a virtual table) based on the result-set of an SQL statement
CREATE VIEW CustomerWithProfitHigherThanAverageProfit AS
SELECT DISTINCT 
	CAST(SUM(PROFIT) OVER (PARTITION BY c.[Customer Name]) as DECIMAL(32,2)) as Profit,
	c.[Customer Name]
FROM [Project2].[dbo].[fData] fd
LEFT JOIN [Project2].[dbo].[dCustomer] c
	ON fd.[Customer ID] = c.[Customer ID]
LEFT JOIN [Project2].[dbo].[dProduct] p
	ON fd.[Product ID] = p.[Product ID]
WHERE (YearOfOrder BETWEEN 2014 and 2017) and Profit > (SELECT CAST(AVG(Profit) AS DECIMAL(32,2)) FROM [Project2].[dbo].[fData])
--17.b) The final ranking of customers generates profit greater than average profit
SELECT 
	RANK() OVER(ORDER BY [Profit] DESC) as Ranking,
	[Customer Name], [Profit]
FROM CustomerWithProfitHigherThanAverageProfit
ORDER BY Profit DESC
---


-- 18. The list of customers generates profit greater than 1000
--18.a) Creating a view (a virtual table) based on the result-set of an SQL statement
CREATE VIEW CustomerWithProfitGreaterThan1000 AS 
SELECT  CAST(SUM(PROFIT) OVER (PARTITION BY c.[Customer Name]) as DECIMAL(32,2)) as Profit,
	c.[Customer Name]
FROM [Project2].[dbo].[fData] fd
LEFT JOIN [Project2].[dbo].[dCustomer] c
	ON fd.[Customer ID] = c.[Customer ID]
LEFT JOIN [Project2].[dbo].[dProduct] p
	ON fd.[Product ID] = p.[Product ID]
WHERE (YearOfOrder BETWEEN 2014 and 2017)
GROUP BY c.[Customer Name], fd.Profit
HAVING Profit >= 1000
--18.b) The final ranking of customers generates profit greater than 1000
SELECT
	RANK() OVER (ORDER BY Profit DESC) as Ranking,
	[Customer Name], [Profit]
FROM CustomerWithProfitGreaterThan1000
ORDER BY Profit DESC
---


--19. The list of the customers makes sales greater than average sales
--19.a) Creating a view (a virtual table) based on the result-set of an SQL statement
CREATE VIEW CustomerWithGreaterSalesThanAverage AS
SELECT DISTINCT
	c.[Customer Name] as [Customer Name], 
	SUM(SalesAmount) OVER (PARTITION BY c.[Customer Name] ORDER BY c.[Customer Name]) as [SalesAmount]
FROM [Project2].[dbo].[fData] fd
LEFT JOIN [Project2].[dbo].[dCustomer] c
	ON fd.[Customer ID] = c.[Customer ID]
LEFT JOIN [Project2].[dbo].[dProduct] p
	ON fd.[Product ID] = p.[Product ID]
WHERE (YearOfOrder BETWEEN 2014 and 2017) and SalesAmount > (SELECT AVG(SalesAmount) FROM  [Project2].[dbo].[fData])
GROUP BY [Customer Name], [SalesAmount]
--19.b) The final ranking of the customers makes sales greater than average sales
SELECT
	RANK() OVER (ORDER BY SalesAmount DESC) as Ranking,
	[Customer Name], [SalesAmount]
FROM CustomerWithGreaterSalesThanAverage
ORDER BY [SalesAmount] DESC
---


--20. The list of customers which generates sales  greather than 20000
--20.a) Creating a view (a virtual table) based on the result-set of an SQL statement
CREATE VIEW CustomerWIthSalesGreaterThan20000 AS 
SELECT DISTINCT
	c.[Customer Name] as [Customer Name], 
	SUM(SalesAmount) OVER (PARTITION BY c.[Customer Name] ORDER BY c.[Customer Name]) as [SalesAmount]
FROM [Project2].[dbo].[fData] fd
LEFT JOIN [Project2].[dbo].[dCustomer] c
	ON fd.[Customer ID] = c.[Customer ID]
LEFT JOIN [Project2].[dbo].[dProduct] p
	ON fd.[Product ID] = p.[Product ID]
WHERE (YearOfOrder BETWEEN 2014 and 2017)
GROUP BY [Customer Name], [SalesAmount]
HAVING SalesAmount > 20000
--20.b) The final ranking of the customers makes sales greater than than 20000
SELECT RANK() OVER (ORDER BY [SalesAmount] DESC) as Ranking,
	[Customer Name], [SalesAmount]
FROM CustomerWIthSalesGreaterThan20000
ORDER BY [SalesAmount] DESC
---


 --21. Looking at customers possess the highest and lowest sales between 2014 and 2017 by Furniture
--21.a)  Creating TEMP TABLE in order to store a subset of data from Tables.
DROP TABLE IF EXISTS #TheRankingofCustomerByFurniture
CREATE TABLE #TheRankingofCustomerByFurniture
(
[Customer Name] varchar(50),
[Category] varchar(50),
[Total Sales by Category] int
)
 -- 21.b) Insert new record to the TEMP TABLE
INSERT INTO #TheRankingofCustomerByFurniture
 SELECT DISTINCT
	c.[Customer Name],
	p.[Category] as Category,
	SUM(fd.[SalesAmount]) OVER (PARTITION BY c.[Customer Name]) as [Total Sales by Category]
FROM [Project2].[dbo].[fData] fd
LEFT JOIN [Project2].[dbo].[dCustomer] c
	ON fd.[Customer ID] = c.[Customer ID]
LEFT JOIN [Project2].[dbo].[dProduct] p
	ON fd.[Product ID] = p.[Product ID]
WHERE (fd.YearOfOrder BETWEEN 2014 and 2017 and p.[Category] = 'Furniture')
ORDER BY [Total Sales by Category]  DESC
--21.c) The final table of Customers with the highest and lowest sales by Furniture
SELECT DISTINCT
	FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Category] ORDER BY [Total Sales by Category] DESC) as [Customer with the highest sales],
	LAST_VALUE([Customer Name]) OVER (PARTITION BY [Category] ORDER BY [Total Sales by Category] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest sales]
FROM #TheRankingofCustomerByFurniture
---


-- 22. Looking at customers possess the highest and lowest sales between 2014 and 2017 by Office Supplies
--22.a) Creating TEMP TABLE in order to store a subset of data from Tables.
DROP TABLE IF EXISTS #TheRankingofCustomerByOfficeSupplies
CREATE TABLE #TheRankingofCustomerByOfficeSupplies
(
[Customer Name] varchar(50),
[Category] varchar(50),
[Total Sales by Category] int
)
 -- 22.b) Insert new record to the TEMP TABLE
INSERT INTO #TheRankingofCustomerByOfficeSupplies
 SELECT DISTINCT
	c.[Customer Name],
	p.[Category] as Category,
	SUM(fd.[SalesAmount]) OVER (PARTITION BY c.[Customer Name]) as [Total Sales by Category]
FROM [Project2].[dbo].[fData] fd
LEFT JOIN [Project2].[dbo].[dCustomer] c
	ON fd.[Customer ID] = c.[Customer ID]
LEFT JOIN [Project2].[dbo].[dProduct] p
	ON fd.[Product ID] = p.[Product ID]
WHERE (fd.YearOfOrder BETWEEN 2014 and 2017 and p.[Category] = 'Office Supplies')
ORDER BY [Total Sales by Category]  DESC
--22.c) The final table of Customers with the highest and lowest sales by Office Supplies
SELECT DISTINCT
	FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Category] ORDER BY [Total Sales by Category] DESC) as [Customer with the highest sales],
	LAST_VALUE([Customer Name]) OVER (PARTITION BY [Category] ORDER BY [Total Sales by Category] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest sales]
FROM #TheRankingofCustomerByOfficeSupplies
---



 -- 23.Looking at customers possess the highest and lowest sales between 2014 and 2017 by Technology
--23.a) Creating TEMP TABLE in order to store a subset of data from Tables.
DROP TABLE IF EXISTS #TheRankingofCustomerByTechnology
CREATE TABLE #TheRankingofCustomerByTechnology
(
[Customer Name] varchar(50),
[Category] varchar(50),
[Total Sales by Category] int
)
 -- 23.b) Insert new record to the TEMP TABLE
INSERT INTO #TheRankingofCustomerByTechnology
 SELECT DISTINCT
	c.[Customer Name],
	p.[Category] as Category,
	SUM(fd.[SalesAmount]) OVER (PARTITION BY c.[Customer Name]) as [Total Sales by Category]
FROM [Project2].[dbo].[fData] fd
LEFT JOIN [Project2].[dbo].[dCustomer] c
	ON fd.[Customer ID] = c.[Customer ID]
LEFT JOIN [Project2].[dbo].[dProduct] p
	ON fd.[Product ID] = p.[Product ID]
WHERE (fd.YearOfOrder BETWEEN 2014 and 2017 and p.[Category] = 'Technology')
ORDER BY [Total Sales by Category]  DESC
--23.c) The final table of Customers with the highest and lowest sales by Technology
SELECT DISTINCT
	FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Category] ORDER BY [Total Sales by Category] DESC) as [Customer with the highest sales],
	LAST_VALUE([Customer Name]) OVER (PARTITION BY [Category] ORDER BY [Total Sales by Category] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest sales]
FROM #TheRankingofCustomerByTechnology
---


-- 24. Creating a virtual table in order to show the top 25 % Customer by Sales in Furniture by the cumulative distrubtion by using CTE
CREATE VIEW CumulativeDistributionFurniture AS
	 SELECT DISTINCT
		c.[Customer Name],
		p.[Category] as Category,
		CAST(SUM(fd.[SalesAmount]) OVER (PARTITION BY c.[Customer Name]) AS INT) as [Total Sales by Category]
	FROM [Project2].[dbo].[fData] fd
	LEFT JOIN [Project2].[dbo].[dCustomer] c
		ON fd.[Customer ID] = c.[Customer ID]
	LEFT JOIN [Project2].[dbo].[dProduct] p
		ON fd.[Product ID] = p.[Product ID]
	WHERE (fd.YearOfOrder BETWEEN 2014 and 2017 and p.[Category] = 'Furniture')

-- 24.a) The final table of top25 Customers by Sales in Furniture
WITH Top25SalesCustomerByFurniture AS 
(
    SELECT [Customer Name], [Total Sales by Category],
	CAST(CUME_DIST() OVER (ORDER BY [Total Sales by Category] DESC) * 100 AS DECIMAL(32,2))  as [Cumulative Distribution %]
	FROM CumulativeDistributionFurniture
)
SELECT *
FROM Top25SalesCustomerByFurniture
WHERE [Cumulative Distribution %] <= 25.00
---


-- 25. Creating a virtual table in order to show the top 25 % Customer by Sales in Office Supplies  by the cumulative distrubtion by using CTE
CREATE VIEW CumulativeDistributionOfficeSupplies AS
	 SELECT DISTINCT
		c.[Customer Name],
		p.[Category] as Category,
		SUM(fd.[SalesAmount]) OVER (PARTITION BY c.[Customer Name]) as [Total Sales by Category]
	FROM [Project2].[dbo].[fData] fd
	LEFT JOIN [Project2].[dbo].[dCustomer] c
		ON fd.[Customer ID] = c.[Customer ID]
	LEFT JOIN [Project2].[dbo].[dProduct] p
		ON fd.[Product ID] = p.[Product ID]
	WHERE (fd.YearOfOrder BETWEEN 2014 and 2017 and p.[Category] = 'Office Supplies')
-- 25.a) The final table of top25 Customers by Sales in Office Supplies
WITH Top25SalesCustomerByOfficeSupplies AS 
(
	SELECT [Customer Name], [Total Sales by Category], 
	CAST(CUME_DIST() OVER (ORDER BY [Total Sales by Category] DESC) * 100 AS DECIMAL(32,2)) as [Cumulative Distribution %]
	FROM CumulativeDistributionOfficeSupplies
)
SELECT *
FROM Top25SalesCustomerByOfficeSupplies
WHERE [Cumulative Distribution %] <= 25.00
---


-- 26. Creating a virtual table in order to show the top 25 % Customer by Sales in Technology  by the cumulative distrubtion by using CTE
CREATE VIEW CumulativeDistributionTechnology AS
	 SELECT DISTINCT
		c.[Customer Name],
		p.[Category] as Category,
		SUM(fd.[SalesAmount]) OVER (PARTITION BY c.[Customer Name]) as [Total Sales by Category]
	FROM [Project2].[dbo].[fData] fd
	LEFT JOIN [Project2].[dbo].[dCustomer] c
		ON fd.[Customer ID] = c.[Customer ID]
	LEFT JOIN [Project2].[dbo].[dProduct] p
		ON fd.[Product ID] = p.[Product ID]
	WHERE (fd.YearOfOrder BETWEEN 2014 and 2017 and p.[Category] = 'Technology')
-- 26.a) The final table of top25 Customers by Sales in Office Supplies
WITH Top25SalesCustomerByOfficeTechnology AS (
	SELECT [Customer Name], [Total Sales by Category], 
	CAST(CUME_DIST() OVER (ORDER BY [Total Sales by Category] DESC) * 100 AS DECIMAL(6,2)) as [Cumulative Distribution %]
	FROM CumulativeDistributionTechnology
)
SELECT *
FROM Top25SalesCustomerByOfficeTechnology
WHERE [Cumulative Distribution %] <= 25.00
---


-- 27. Creating a virtual table in order to show the sales percentile for Customer  by Furniture
CREATE VIEW PercentageRankOfFurniture AS
	 SELECT DISTINCT
		c.[Customer Name],
		p.[Category] as Category,
		SUM(fd.[SalesAmount]) OVER (PARTITION BY c.[Customer Name]) as [Total Sales by Category]
	FROM [Project2].[dbo].[fData] fd
	LEFT JOIN [Project2].[dbo].[dCustomer] c
		ON fd.[Customer ID] = c.[Customer ID]
	LEFT JOIN [Project2].[dbo].[dProduct] p
		ON fd.[Product ID] = p.[Product ID]
	WHERE (fd.YearOfOrder BETWEEN 2014 and 2017 and p.[Category] = 'Furniture')
-- 27.a) The final table of the sales percentile for Customer  by Furniture
SELECT 
	[Customer Name],
	[Total Sales by Category], 
	CAST(PERCENT_RANK() OVER (ORDER BY [Total Sales by Category]) * 100 AS DECIMAL(6,2)) as [Percentage Rank %]
FROM PercentageRankOfFurniture
---


-- 28. Creating a virtual table in order to show the sales percentile for Customer  by Office Supplies
CREATE VIEW PercentageRankOfOfficeSupplies AS
	 SELECT DISTINCT
		c.[Customer Name],
		p.[Category] as Category,
		SUM(fd.[SalesAmount]) OVER (PARTITION BY c.[Customer Name]) as [Total Sales by Category]
	FROM [Project2].[dbo].[fData] fd
	LEFT JOIN [Project2].[dbo].[dCustomer] c
		ON fd.[Customer ID] = c.[Customer ID]
	LEFT JOIN [Project2].[dbo].[dProduct] p
		ON fd.[Product ID] = p.[Product ID]
	WHERE (fd.YearOfOrder BETWEEN 2014 and 2017 and p.[Category] = 'Office Supplies')
-- 28.a) The final table of the sales percentile for Customer by Office Supplies
SELECT [Customer Name], [Total Sales by Category], 
	CAST(PERCENT_RANK() OVER (ORDER BY [Total Sales by Category]) * 100 AS DECIMAL(6,2)) as [Percentage Rank %]
FROM PercentageRankOfOfficeSupplies
---


-- 29. Creating a virtual table in order to show the sales percentile for Customer by  Technology
CREATE VIEW PercentageRankOfTechnology AS
	 SELECT DISTINCT
		c.[Customer Name],
		p.[Category] as Category,
		SUM(fd.[SalesAmount]) OVER (PARTITION BY c.[Customer Name]) as [Total Sales by Category]
	FROM [Project2].[dbo].[fData] fd
	LEFT JOIN [Project2].[dbo].[dCustomer] c
		ON fd.[Customer ID] = c.[Customer ID]
	LEFT JOIN [Project2].[dbo].[dProduct] p
		ON fd.[Product ID] = p.[Product ID]
	WHERE (fd.YearOfOrder BETWEEN 2014 and 2017 and p.[Category] = 'Technology')
-- 29.a) The final table of the sales percentile for Customer by Technology
SELECT [Customer Name], [Total Sales by Category], 
	CAST(PERCENT_RANK() OVER (ORDER BY [Total Sales by Category]) * 100 AS DECIMAL(6,2)) as [Percentage Rank %]
FROM PercentageRankOfTechnology
---


-- 30. The classification of the whole customers in all categories by sales  as the level of the sales by three group using CTE.
--30. a)Creating TEMP TABLE in order to store a subset of data from Tables.
DROP TABLE IF EXISTS #GroupOfCustomerBySales 
CREATE TABLE #GroupOfCustomerBySales (
[Customer Name]  varchar(50),
[Total Sales by Category] int)
 -- 30.b) Insert new record to the TEMP TABLE
INSERT INTO #GroupOfCustomerBySales
SELECT DISTINCT
	c.[Customer Name],
	SUM(fd.[SalesAmount]) OVER (PARTITION BY c.[Customer Name]) as [Total Sales by Category]
FROM [Project2].[dbo].[fData] fd
	LEFT JOIN [Project2].[dbo].[dCustomer] c
		ON fd.[Customer ID] = c.[Customer ID]
	LEFT JOIN [Project2].[dbo].[dProduct] p
		ON fd.[Product ID] = p.[Product ID]
WHERE (fd.YearOfOrder BETWEEN 2014 and 2017)
ORDER BY [Total Sales by Category] DESC
--30.c) The final classification of customers as three groups (high, mid, low) of sales
WITH GroupOfCustomer_CTE AS 
(
	SELECT *,
		NTILE(3) OVER (ORDER BY [Total Sales by Category] DESC) as Buckets
	FROM #GroupOfCustomerBySales
)
SELECT [Customer Name],
	CASE 
		WHEN [Buckets] = 1 THEN 'High Sales'
		WHEN [Buckets] = 2 THEN 'Mid Sales'
		ELSE 'Low Sales'
END AS [Level of Sales]
FROM GroupOfCustomer_CTE
ORDER BY [Total Sales by Category] DESC
---


-- 31. The classification of the whole customers in all categories by profit  as the level of the sales by three group using CTE.
--31.a) Creating TEMP TABLE in order to store a subset of data from Tables.
DROP TABLE IF EXISTS #GroupOfCustomerByProfit
CREATE TABLE #GroupOfCustomerByProfit (
[Customer Name]  varchar(50),
[Total Profit by Category] int)
 -- 31.b) Insert new record to the TEMP TABLE
INSERT INTO #GroupOfCustomerByProfit
 SELECT DISTINCT
	c.[Customer Name],
	--p.[Category] as Category,
	CAST(SUM(fd.[Profit]) OVER (PARTITION BY c.[Customer Name]) AS DECIMAL (32,2)) as [Total Profit]
FROM [Project2].[dbo].[fData] fd
LEFT JOIN [Project2].[dbo].[dCustomer] c
	ON fd.[Customer ID] = c.[Customer ID]
LEFT JOIN [Project2].[dbo].[dProduct] p
	ON fd.[Product ID] = p.[Product ID]
WHERE (fd.YearOfOrder BETWEEN 2014 and 2017)
ORDER BY [Total Profit]  DESC
--31c) The final classification of customers as three groups (high, mid, low) of Profit
WITH GroupOfCustomerSales_CTE AS 
(
	SELECT *,
		NTILE(3) OVER (ORDER BY [Total Profit by Category] DESC) as Buckets
	FROM #GroupOfCustomerByProfit
	WHERE [Total Profit by Category] >=1 
)
SELECT [Customer Name],
	CASE 
		WHEN [Buckets] = 1 THEN 'High Profit'
		WHEN [Buckets] = 2 THEN 'Mid Profit'	
		WHEN [Buckets] = 3 THEN 'Low Profit'
END AS [Level of Profit]
FROM GroupOfCustomerSales_CTE


