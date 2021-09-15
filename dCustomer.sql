/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [Customer ID]
      ,[Customer Name]
  FROM [Project2].[dbo].[dCustomer]

SELECT *
FROM [Project2].[dbo].[dCustomer]
--1. Spliting the Customer Name column in two columns in order to obtain First Name and Second Name.
 SELECT 
	[Customer ID],
	[Customer Name],
	--CHARINDEX(' ', [Customer Name]) as [The number of the position of the name till space],
	LEFT([Customer Name], CHARINDEX(' ', [Customer Name])) as [First Name],
	--RIGHT([Customer Name],LEN([Customer Name])-CHARINDEX(' ',[Customer Name])) as Surname1,
	--CHARINDEX(' ', REVERSE([Customer Name])) as [The reversed number of the position of the name till space],
	RIGHT([Customer Name], CHARINDEX(' ', REVERSE([Customer Name]))) AS [Second Name]
FROM [Project2].[dbo].[dCustomer]
---

--2. Creating TEMP TABLE in order to store a subset of data regarding split Customer Name in two columns
DROP TABLE IF EXISTS #Temp_Customer 
CREATE TABLE #Temp_Customer (
[Customer ID] varchar(50),
[Customer Name] varchar(50),
[First Name] varchar(50),
[Second Name] varchar(50)
)
--2.a) Insert records into TEMP Table
INSERT INTO #Temp_Customer
SELECT
[Customer ID],
[Customer Name],
LEFT([Customer Name], CHARINDEX(' ', [Customer Name])) as [First Name],
RIGHT([Customer Name], CHARINDEX(' ', REVERSE([Customer Name]))) AS [Second Name]
FROM [Project2].[dbo].[dCustomer]
--2.c) The final result of the split Customer Name
SELECT [Customer ID], [First Name], [Second Name]
FROM #Temp_Customer
---

-- 3. Looking at Customers which Sales Amount is higher than 12000 using Subquery
SELECT [Project2].[dbo].[dCustomer].[Customer Name]
FROM [Project2].[dbo].[dCustomer] 
WHERE [Project2].[dbo].[dCustomer].[Customer ID] 
	IN 
(
	SELECT [Project2].[dbo].[fData].[Customer ID]
	FROM [Project2].[dbo].[fData] 
	WHERE [Project2].[dbo].[fData].[SalesAmount] > 12000
)



