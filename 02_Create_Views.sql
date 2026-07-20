

/*=============================================================================================================================================
	Project: Sales Performance Analysis
	File:    02_Create_Views.sql
	Author:  Ayesha Batool

	DESCRIPTION:
	This script creates reusable analytical views that simplify business analysis and eliminate repeated joins and aggregations
	throughout the project.

	1. vw_Yearly_Metrics
		- Annual Revenue.
		- Annual Quantity Sold.
		- Average Selling Price (ASP).

	2. vw_Sales_Analysis
		- Product hierarchy.
		- Geography hierarchy.
		- Store information.
		- Time dimensions.
		- Aggregated sales metrics (Quantity Sold and Revenue).

==============================================================================================================================================*/


USE Sales;
GO


/*============================================================================================================================================
												1. CREATE YEARLY METRICS VIEW
===============================================================================================================================================*/

-- This view is reused for yearly KPI validation.

CREATE VIEW vw_Yearly_Metrics AS
	SELECT
		YEAR(Date_Key)		AS Year,
		SUM(Revenue)		AS Total_Revenue,
		SUM(Sales_Quantity) AS Total_Quantity_Sold,
		CAST(
			SUM(Revenue) * 1.0 / SUM(Sales_Quantity) AS DECIMAL(10, 2)
		) AS Average_Selling_Price
	FROM Sales
	GROUP BY YEAR(Date_Key);
GO


/*=============================================================================================================================================
												YEARLY METRICS - VIEW VALIDATION
===============================================================================================================================================*/


SELECT *
FROM vw_Yearly_Metrics;
GO


/*==============================================================================================================================================
												2. CREATE SALES ANALYSIS VIEW
================================================================================================================================================*/


-- This view is reused across all business investigation queries.

CREATE VIEW vw_Sales_Analysis AS
	SELECT
		YEAR(s.Date_Key)		 AS Year,
		MONTH(s.Date_Key)		 AS Month,
		p.Product_Name,
		pc.Product_Category,			
		ps.Product_Subcategory,		
		p.Class_Name			 AS Product_Class,
		st.Store_Name,
		st.Store_Type,
		st.Status				 AS Store_Status,
		g.Continent_Name		 AS Continent,
		g.Country,
		SUM(s.Sales_Quantity)	 AS Quantity_Sold,
		SUM(s.Revenue)			 AS Revenue
	FROM Sales AS s
	JOIN Product AS p
		ON p.Product_Key = s.Product_Key
	JOIN Product_Subcategory AS ps
		ON ps.Product_Subcategory_Key = p.Product_Subcategory_Key
	JOIN Product_Category AS pc
		ON pc.Product_Category_Key = ps.Product_Category_Key
	JOIN Store AS st
		ON st.Store_Key = s.Store_Key
	JOIN Geography AS g
		ON g.Geography_Key = st.Geography_Key
	GROUP BY
		YEAR(s.Date_Key),
		MONTH(s.Date_Key),
		p.Product_Name,
		pc.Product_Category,
		ps.Product_Subcategory,
		p.Class_Name,
		st.Store_Name,
		st.Store_Type,
		st.Status,
		g.Continent_Name,
		g.Country;
GO


/*=============================================================================================================================================
												SALES ANALYSIS - VIEW VALIDATION 
===============================================================================================================================================*/


SELECT TOP (10) *
FROM vw_Sales_Analysis;
GO
