/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [Product ID]
      ,[Category]
      ,[Sub-Category]
      ,[Product Name]
  FROM [Project2].[dbo].[dProduct]

SELECT *
FROM [Project2].[dbo].[dProduct]



-- 1.Looking at the total quantity of the category
 SELECT DISTINCT
	[Category], COUNT([Category]) as [The Quantity of Category]
FROM [Project2].[dbo].[dProduct]
GROUP BY [Category]
ORDER BY [The Quantity of Category] DESC
---


--2.Looking at  The total quantity of the sub-category 
SELECT [Sub-Category], COUNT([Sub-Category]) as [The Quantity of Sub-Category]
FROM [Project2].[dbo].[dProduct]
GROUP BY [Sub-Category]
ORDER BY [The Quantity of Sub-Category] DESC
---


-- 3. The combination of dProduct, dSegment and fData Tables based on related columns between them using JOIN 
SELECT  *
FROM  [Project2].[dbo].[fData] fd
	LEFT JOIN [Project2].[dbo].[dProduct] p
ON fd.[Product ID] = p.[Product ID]
	LEFT JOIN [Project2].[dbo].[dSegment] s
ON fd.[SEG_ID] = s.[SEG_ID] 
---


-- 4.Looking at Total Sales Amount, Total Profit and Quantity of Products and Year of Order by Furniture
-- 4.a) Creating TEMP TABLE in order to store a subset of data from Tables.
DROP TABLE IF EXISTS #CategoryFurniture
CREATE TABLE #CategoryFurniture
(
Category varchar(50),
YearOfOrder int,
[Total Sales Amount] int,
[Total Profit] decimal(32,2),
[Quantity of Product] int
)
-- 4.b) INSERT NEW RECORDS to TEMP TABLE
INSERT INTO #CategoryFurniture
SELECT 
DISTINCT  d.Category, fd.YearOfOrder, 
	SUM(fd.SalesAmount) OVER (PARTITION BY fd.YearOfOrder) as [Total SalesAmount],
	CAST(SUM(fd.Profit) OVER (PARTITION BY fd.YearOfOrder) AS DECIMAL(32,2)) as [Total Profit],
	COUNT(fd.Quantity) OVER (PARTITION BY fd.YearOfOrder) as [Quantity of Product]
FROM [Project2].[dbo].[fData] fd 
JOIN [Project2].[dbo].[dProduct] d 
	ON (fd.[Product ID] = d.[Product ID])
WHERE d.Category = 'Furniture'
GROUP BY fd.YearOfOrder,d.Category, fd.SalesAmount, fd.Profit, fd.Quantity
ORDER BY fd.YearOfOrder DESC
-- 4.c) The final table of Total Sales Amount, Total Profit and Quantity of Products and Year of Order by Furniture
SELECT DISTINCT *
FROM #CategoryFurniture
ORDER BY YearOfOrder desc
---


-- 5.Looking at Total Sales Amount, Total Profit and Quantity of Products and Year of Order by Office Supplies
-- 5.a) Creating TEMP TABLE in order to store a subset of data from Tables.
DROP TABLE IF EXISTS #CategoryOfficeSupplies
CREATE TABLE #CategoryOfficeSupplies
(
Category varchar(50),
YearOfOrder int,
[Total Sales Amount] int,
[Total Profit] decimal(32,2),
[Quantity of Product]  int
)
-- 5.b) Insert new record to the TEMP TABLE
INSERT INTO #CategoryOfficeSupplies
SELECT DISTINCT  d.Category, fd.YearOfOrder, 
	SUM(fd.SalesAmount) OVER (PARTITION BY fd.YearOfOrder) as [Total SalesAmount],
	CAST(SUM(fd.Profit) OVER (PARTITION BY fd.YearOfOrder) AS DECIMAL(32,2)) as [Total Profit],
	COUNT(fd.Quantity) OVER (PARTITION BY fd.YearOfOrder) as [Quantity of Product]
FROM [Project2].[dbo].[fData] fd 
JOIN [Project2].[dbo].[dProduct] d 
	ON (fd.[Product ID] = d.[Product ID])
WHERE d.Category LIKE '%Office%'
GROUP BY fd.YearOfOrder,d.Category, fd.SalesAmount, fd.Profit, fd.Quantity
ORDER BY fd.YearOfOrder DESC
--5.c) The final table of Total Sales Amount, Total Profit and Quantity of Products and Year of Order by Office Supplies
SELECT * 
FROM #CategoryOfficeSupplies
ORDER BY YearOfOrder DESC
---


-- 6.Looking at Total Sales Amount, Total Profit and Quantity of Products and Year of Order by Technology
--6.a) Creating TEMP TABLE in order to store a subset of data from Tables.
DROP TABLE IF EXISTS #CategoryTechnology
CREATE TABLE #CategoryTechnology
(
Category varchar(50),
YearOfOrder int,
[Total SalesAmount] int,
[Total Profit] decimal(32,2),
[Quantity of Product] int
)
 -- 6.b) Insert new record to the TEMP TABLE
INSERT INTO #CategoryTechnology
SELECT DISTINCT  d.Category, fd.YearOfOrder, 
	SUM(fd.SalesAmount) OVER (PARTITION BY fd.YearOfOrder) as [Total SalesAmount],
	CAST(SUM(fd.Profit) OVER (PARTITION BY fd.YearOfOrder) AS DECIMAL(32,2)) as [Total Profit],
	COUNT(fd.Quantity) OVER (PARTITION BY fd.YearOfOrder) as [Quantity of Product]
FROM [Project2].[dbo].[fData] fd 
JOIN [Project2].[dbo].[dProduct] d 
	ON (fd.[Product ID] = d.[Product ID])
WHERE d.Category = 'Technology'
GROUP BY fd.YearOfOrder,d.Category, fd.SalesAmount, fd.Profit, fd.Quantity
ORDER BY fd.YearOfOrder DESC
--6.c) The final table of Total Sales Amount, Total Profit and Quantity of Products and Year of Order by Technology
SELECT *
FROM #CategoryTechnology
ORDER BY YearOfOrder DESC
---


-- 7.Looking at the Segment that makes the most profit and quantity of products which belong to each segment for Furniture
--7.a) Creating a view (a virtual table) based on the result-set of an SQL statement
CREATE VIEW ProfitAndQuantityOfSegmenByFurniture AS 
	SELECT DISTINCT s.[Segment], COUNT(p.Category) OVER (PARTITION BY s.[Segment]) as [Quantity of Product], CAST(SUM(PROFIT) OVER (PARTITION BY  s.[Segment]) AS DECIMAL(32,2)) as [Profit]
	FROM  [Project2].[dbo].[fData] fd
	LEFT JOIN [Project2].[dbo].[dProduct] p
	ON fd.[Product ID] = p.[Product ID]
	LEFT JOIN [Project2].[dbo].[dSegment] s
	ON fd.[SEG_ID] = s.[SEG_ID] 
	WHERE p.Category = 'Furniture'
	--ORDER BY [Quantity of Product] DESC
--7.b) The final result of the VIEW for Furniture
SELECT *
FROM ProfitAndQuantityOfSegmenByFurniture
ORDER BY [Quantity of Product] DESC
---


-- 8.Looking at Segment that makes the most profit and the quantity of products which belong to each segment for Technology
--8.a) Creating a view (a virtual table) based on the result-set of an SQL statement
CREATE VIEW ProfitAndQuantityOfSegmenByTechnology AS 
	 SELECT DISTINCT s.[Segment], COUNT(p.Category) OVER (PARTITION BY s.[Segment]) as [Quantity of Product], CAST(SUM(PROFIT) OVER (PARTITION BY  s.[Segment]) AS DECIMAL(32,2)) as [Profit]
	 FROM  [Project2].[dbo].[fData] fd
	 LEFT JOIN [Project2].[dbo].[dProduct] p
	 ON fd.[Product ID] = p.[Product ID]
	 LEFT JOIN [Project2].[dbo].[dSegment] s
	 ON fd.[SEG_ID] = s.[SEG_ID] 
	 WHERE p.Category = 'Technology'
	--ORDER BY [Quantity of Product] DESC
--8.b) The final result of the VIEW for Technology
SELECT *
FROM ProfitAndQuantityOfSegmenByTechnology
ORDER BY [Quantity of Product] DESC
---


--9. Looking at Segment that makes the most profit and the quantity of products which belong to each segment for Office Supplies
--9.a) Creating a view (a virtual table) based on the result-set of an SQL statement
CREATE VIEW ProfitAndQuantityOfSegmenByOfficeSupplies AS 
	SELECT DISTINCT s.[Segment], COUNT(p.Category) OVER (PARTITION BY s.[Segment]) as [Quantity of Product], CAST(SUM(PROFIT) OVER (PARTITION BY  s.[Segment]) AS DECIMAL(32,2)) as [Profit]
	FROM  [Project2].[dbo].[fData] fd
	LEFT JOIN [Project2].[dbo].[dProduct] p
	ON fd.[Product ID] = p.[Product ID]
	LEFT JOIN [Project2].[dbo].[dSegment] s
	ON fd.[SEG_ID] = s.[SEG_ID] 
	WHERE p.Category LIKE '%Office%'
	--ORDER BY [Quantity of Product] DESC
--9.b) The final result of the VIEW for Office Supplies 
SELECT *
FROM ProfitAndQuantityOfSegmenByOfficeSupplies
ORDER BY [Quantity of Product] DESC
---


-- 10.Looking at the quantity of orders, the total sales and profit by months for Consumer segment using CTE
--10.a) Creating Common Table Expression in order to insert records in a temporary result set.
WITH QuantityofOrderForConsumerAndMonth_CTE AS (
	SELECT DISTINCT 
	DateName(month,fd.OrderDateConverted) as [Month],
	Month(fd.OrderDateConverted) as [The Number of Month],
	s.Segment, 
	COUNT(*) OVER (PARTITION BY fd.Month) as [Quantity of Orders],
	CAST(SUM(Profit) OVER (PARTITION BY fd.Month) AS DECIMAL(32,2)) as [Profit],
	CAST(SUM(Sales) OVER (PARTITION BY fd.Month) AS DECIMAL(32,2)) as [Sales]
	 FROM  [Project2].[dbo].[fData] fd
	 LEFT JOIN [Project2].[dbo].[dProduct] p
	 ON fd.[Product ID] = p.[Product ID]
	 LEFT JOIN [Project2].[dbo].[dSegment] s
	 ON fd.[SEG_ID] = s.[SEG_ID]
	WHERE (fd.YearofOrder BETWEEN 2014 and 2017 AND s.Segment = 'Consumer')
)
-- 10.b)The final result of the quantity of orders, the total sales and profit by months for Consumer Segment
SELECT [Month], [Quantity of Orders], [Sales], [Profit]
FROM QuantityofOrderForConsumerAndMonth_CTE
ORDER BY [The Number of Month] ASC
---


-- 11.Looking at the quantity of orders, the total sales and profit by months for Corporate segment using CTE
--11.a) Creating Common Table Expression in order to insert records in a temporary result set.
WITH QuantityofOrderForCorporateAndMonth_CTE AS (
	SELECT DISTINCT 
	DateName(month,fd.OrderDateConverted) as [Month],
	Month(fd.OrderDateConverted) as [The Number of Month],
	s.Segment, 
	COUNT(*) OVER (PARTITION BY fd.Month) as [Quantity of Orders],
	CAST(SUM(Profit) OVER (PARTITION BY fd.Month) AS DECIMAL(32,2)) as [Profit],
	CAST(SUM(Sales) OVER (PARTITION BY fd.Month) AS DECIMAL(32,2)) as [Sales]
	 FROM  [Project2].[dbo].[fData] fd
	 LEFT JOIN [Project2].[dbo].[dProduct] p
	 ON fd.[Product ID] = p.[Product ID]
	 LEFT JOIN [Project2].[dbo].[dSegment] s
	 ON fd.[SEG_ID] = s.[SEG_ID]
	WHERE (fd.YearofOrder BETWEEN 2014 and 2017 AND s.Segment = 'Corporate')
)
-- 11.b) The final result of the quantity of orders, the total sales and profit by months for Corporate Segment
SELECT [Month], [Quantity of Orders], [Sales], [Profit]
FROM QuantityofOrderForCorporateAndMonth_CTE
ORDER BY [The Number of Month] ASC
---


-- 12) Looking at the quantity of orders, the total sales and profit by months for Home Office segment using CTE
--12.a) Creating Common Table Expression in order to insert records in a temporary result set.
WITH QuantityofOrderForHomeOfficeAndMonth_CTE AS (
	SELECT DISTINCT 
	DateName(month,fd.OrderDateConverted) as [Month],
	Month(fd.OrderDateConverted) as [The Number of Month],
	s.Segment, 
	COUNT(*) OVER (PARTITION BY fd.Month) as [Quantity of Orders],
		CAST(SUM(Profit) OVER (PARTITION BY fd.Month) AS DECIMAL(32,2)) as [Profit],
	CAST(SUM(Sales) OVER (PARTITION BY fd.Month) AS DECIMAL(32,2)) as [Sales]
	 FROM  [Project2].[dbo].[fData] fd
	 LEFT JOIN [Project2].[dbo].[dProduct] p
	 ON fd.[Product ID] = p.[Product ID]
	 LEFT JOIN [Project2].[dbo].[dSegment] s
	 ON fd.[SEG_ID] = s.[SEG_ID]
	WHERE (fd.YearofOrder BETWEEN 2014 and 2017 AND s.Segment LIKE '%Home%')
)
-- 12.b) The final result of the quantity of orders, the total sales and profit by months for Home Office  Segment
SELECT [Month], [Quantity of Orders], [Sales], [Profit]
FROM QuantityofOrderForHomeOfficeAndMonth_CTE
ORDER BY [The Number of Month] ASC
---


--13. The ranking of products by sales
--13.a) Creating a virtual table in order to to prepare the ranking of products by Sales
CREATE VIEW TheRankingOfProduct AS 
SELECT  DISTINCT
	p.[Sub-Category],
	p.[Product Name],
	SUM(fd.[SalesAmount]) OVER (PARTITION BY p.[Product Name]) as Sales
FROM [Project2].[dbo].[fData] fd
LEFT JOIN [Project2].[dbo].[dProduct] p
ON fd.[Product ID] = p.[Product ID]
GROUP BY [SalesAmount], [Sub-Category], p.[Product Name], p.[Category], Sales
--ORDER BY  p.[Sub-Category], Sales DESC

--13.b) Creating a virtual table in order to prepare the ranking of products by Sales in Sub-Category and find the highest and lowest sales by products
CREATE VIEW Ranking AS
SELECT		
	DENSE_RANK() OVER (PARTITION BY [Sub-Category] ORDER BY Sales DESC) as [Ranking],
	*,
	FIRST_VALUE([Product Name]) OVER (PARTITION BY [Sub-Category] ORDER BY Sales DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The Product Name of The Highest Sales],
	LAST_VALUE([Product Name]) OVER (PARTITION BY [Sub-Category] ORDER BY Sales DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The Product Name of The Lowest Sales]
FROM TheRankingOfProduct

-- 13.c) The final ranking of the products in the sub-category by sales
SELECT [Ranking],[Sub-Category], [Product Name], [Sales]
FROM Ranking
ORDER BY [Sub-Category], Sales DESC
-- 13.d) Looking at The highest and the lowest sales of Products by Sub Category
SELECT DISTINCT [Sub-Category], [The Product Name of The Highest Sales], [The Product Name of The Lowest Sales]
FROM Ranking
WHERE [Ranking] = 1
ORDER BY [Sub-Category] ASC
---


-- 14) Creating a virtual table in order to create:
-- a) the cumulative distrubtion of products by sales,
-- b) the percent rank of products by sales,
-- c) the classification of products by three groups by sales
CREATE VIEW [Culmulative Distriubtion of Products] AS 
SELECT  DISTINCT
	p.[Product Name],
	SUM(fd.[SalesAmount]) OVER (PARTITION BY p.[Product Name]) as Sales
FROM [Project2].[dbo].[fData] fd
LEFT JOIN [Project2].[dbo].[dProduct] p
ON fd.[Product ID] = p.[Product ID]
GROUP BY p.[Product Name], Sales, fd.[SalesAmount]
ORDER BY  Sales DESC

-- 14.a) The cumulative distrubtion of products by sales
SELECT *,
	CAST(CUME_DIST() OVER (ORDER BY Sales DESC) * 100 AS DECIMAL(32,2)) as [Cumulative Distrubtion %]
FROM [Culmulative Distriubtion of Products]
ORDER BY Sales DESC

-- 14.b) The percentage rank of products by sales
SELECT
	RANK() OVER (ORDER BY Sales) as Ranking,
	*,
	CAST(PERCENT_RANK() OVER (ORDER BY Sales ASC) * 100 AS DECIMAL(32,2)) as [Percentage Rank %]
FROM [Culmulative Distriubtion of Products]

-- 14.c) The classification of products by three groups (high, mid and low sales) by using CTE by sales
WITH [The Classification of three groups CTE] AS
(
SELECT *,
	NTILE(3) over (ORDER BY Sales DESC) as Buckets
FROM [Culmulative Distriubtion of Products]
)
SELECT [Product Name],
	CASE 
		WHEN [Buckets] = 1 THEN 'High Sales'
		WHEN [Buckets] = 2 THEN 'Mid Sales'
		WHEN [Buckets] = 3 THEN 'Low Sales'
END AS [The Level of Sales]
FROM [The Classification of three groups CTE]
---


-- 15.The ranking of products by profit
--15.a) Creating a virtual table in order to to prepare the ranking of products by profit
CREATE VIEW ProductsByProfit AS 
SELECT DISTINCT
	p.[Sub-Category],
	p.[Product Name],
	CAST(SUM(fd.[Profit]) OVER (PARTITION BY p.[Product Name]) AS DECIMAL (32,2)) as Profit
FROM [Project2].[dbo].[fData] fd
LEFT JOIN [Project2].[dbo].[dProduct] p
ON fd.[Product ID] = p.[Product ID]
GROUP BY [SalesAmount], [Sub-Category], p.[Product Name], p.[Category], Profit
HAVING Profit > 1

--15.b) Creating a virtual table in order to prepare the ranking of products by Profit in Sub-Category and find the highest and lowest profit by products
CREATE VIEW RankingOfProductsByProfit AS
SELECT		
	DENSE_RANK() OVER (PARTITION BY [Sub-Category] ORDER BY Profit DESC) as [Ranking],
	*,
	FIRST_VALUE([Product Name]) OVER (PARTITION BY [Sub-Category] ORDER BY Profit DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The Product Name of The Highest Profit],
	LAST_VALUE([Product Name]) OVER (PARTITION BY [Sub-Category] ORDER BY Profit DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The Product Name of The Lowest Profit]
FROM ProductsByProfit

-- 15.c) The final ranking of the products in the sub-category by Profit
SELECT [Ranking],[Sub-Category], [Product Name], [Profit]
FROM RankingOfProductsByProfit
ORDER BY [Sub-Category], Profit DESC

-- 15.c) Looking at The highest and the lowest Profit of Products by Sub Category
SELECT DISTINCT [Sub-Category], [The Product Name of The Highest Profit], [The Product Name of The Lowest Profit]
FROM RankingOfProductsByProfit
WHERE [Ranking] = 1
ORDER BY [Sub-Category] ASC
---


-- 16.Creating a TEMP TABLE in order to create:
-- a) the cumulative distrubtion of products by profit,
-- b) the percent rank of products by profit,
-- c) the classification of products by three groups by profit
DROP TABLE IF EXISTS #CulmulativeDistriubtionofProducts
CREATE TABLE #CulmulativeDistriubtionofProducts (
[Product Name] varchar(2000),
[Profit] int
)
 -- 16.a) Insert new record to the TEMP TABLE
INSERT INTO #CulmulativeDistriubtionofProducts
SELECT  DISTINCT
	p.[Product Name],
	CAST(SUM(fd.[Profit]) OVER (PARTITION BY p.[Product Name]) AS DECIMAL(32,2)) as Profit
FROM [Project2].[dbo].[fData] fd
LEFT JOIN [Project2].[dbo].[dProduct] p
ON fd.[Product ID] = p.[Product ID]
GROUP BY p.[Product Name], Profit, fd.[SalesAmount]
HAVING Profit > 1
ORDER BY  Profit DESC
-- 16.b) The cumulative distrubtion of products by Profit
SELECT *,
	CAST(CUME_DIST() OVER (ORDER BY Profit DESC) * 100 AS DECIMAL(32,2)) as [Cumulative Distrubtion %]
FROM #CulmulativeDistriubtionofProducts
ORDER BY Profit DESC
-- 16c). The percentage rank of products by Profit
SELECT
	RANK() OVER (ORDER BY Profit) as Ranking,
	*,
	CAST(PERCENT_RANK() OVER (ORDER BY Profit ASC) * 100 AS DECIMAL(32,2)) as [Percentage Rank %]
FROM #CulmulativeDistriubtionofProducts
-- 16d). The classification of products by three groups (high, mid and low profit) by using CTE by profit
WITH [The Classification of three groups CTE] AS
(
	SELECT *,
	NTILE(3) over (ORDER BY Profit DESC) as Buckets
	FROM #CulmulativeDistriubtionofProducts
)
SELECT [Product Name],
	CASE 
		WHEN [Buckets] = 1 THEN 'High Profit'
		WHEN [Buckets] = 2 THEN 'Mid Profit'
		WHEN [Buckets] = 3 THEN 'Low Profit'
END AS [The Level of Profit]
FROM [The Classification of three groups CTE]
---


--17) Looking at products, which do not generate profit.
--17.a) Creating TEMP TABLE to store a subset of data
DROP TABLE IF EXISTS #NoProfitProduct
CREATE TABLE #NoProfitProduct (
	[Product Name] varchar(2000),
	[Profit] int
)
--17.b) Insert records to TEMP Table
INSERT INTO #NoProfitProduct
SELECT  DISTINCT
	p.[Product Name],
	CAST(SUM(fd.[Profit]) OVER (PARTITION BY p.[Product Name]) AS DECIMAL(32,2)) as Profit
FROM [Project2].[dbo].[fData] fd
LEFT JOIN [Project2].[dbo].[dProduct] p
ON fd.[Product ID] = p.[Product ID]
GROUP BY p.[Product Name], Profit, fd.[SalesAmount] 
ORDER BY  Profit DESC

-- 17.c) The cumulative distrubtion of products, which do not generate profits in comparison to the whole data by using  CTE
WITH TheCumeDistOfNoProfitProducts AS 
(
		SELECT *,
		CAST(CUME_DIST() OVER (ORDER BY Profit DESC) * 100 AS DECIMAL(32,2)) as [Cumulative Distrubtion %]
		FROM #NoProfitProduct
)
SELECT *
FROM TheCumeDistOfNoProfitProducts
WHERE Profit < 0

-- 17.d) The percentage rank of products which do not generate profits in comparison to the whole data by using  CTE
WITH ThePercentOfNoProfitProducts AS 
(
SELECT
	*,
	CAST(PERCENT_RANK() OVER (ORDER BY Profit ASC) * 100 AS DECIMAL(32,2)) as [Percentage Rank %]
FROM #NoProfitProduct
)
SELECT *
FROM ThePercentOfNoProfitProducts
WHERE Profit < 0