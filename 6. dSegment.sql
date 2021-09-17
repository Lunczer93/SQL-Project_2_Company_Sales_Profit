/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [SEG_ID]
      ,[Segment]
  FROM [Project2].[dbo].[dSegment]

--1. Looking at data to find a related column in order to combine this table with another tables by using JOIN
SELECT *
FROM [Project2].[dbo].[dSegment]

-- I used this Table for another queries in my project. 