/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [SEG_ID]
      ,[Segment]
  FROM [Project2].[dbo].[dSegment]

--1. Looking at data
SELECT *
FROM [Project2].[dbo].[dSegment]
