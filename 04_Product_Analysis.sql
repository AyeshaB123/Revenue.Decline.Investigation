

/*==============================================================================================================================================
	Project: Sales Performance Analysis
	File:    04_Product_Analysis.sql
	Author:  Ayesha Batool

	DESCRIPTION
		This script identifies the products responsible for the decline in Quantity Sold after applying the filters identified during
		the business investigation.

	Analysis Scope
		Months: Apr, May, Jun, Jul, Oct
		Product Class: Regular

    Investigation Workflow
        . Product Category Analysis
        2. Product Subcategory Analysis
        3. Product Analysis

================================================================================================================================================*/



USE Sales;
GO


/*==============================================================================================================================================
												3.3. PRODUCT CATEGORY ANALYSIS
================================================================================================================================================*/


-- Which product categories contributed the most to the Quantity Sold decline within the identified months and product class?

WITH Category_Comparison AS(
	SELECT Product_Category,
		COALESCE(
			SUM(CASE
				WHEN Year = 2011 THEN Quantity_Sold
			END),
		0) AS [2011_QS],
		COALESCE(SUM(CASE
			WHEN Year = 2012 THEN Quantity_Sold
			END),
		0) AS [2012_QS]
	FROM vw_Sales_Analysis
	WHERE
		Month IN (4,5,6,7,10)
		AND Product_Class = 'Regular'
	GROUP BY Product_Category
),
Category_Total_Change AS(
	SELECT SUM([2012_QS] - [2011_QS]) AS Total_Change
	FROM Category_Comparison
),
Category_Calculations AS(
	SELECT
		y.Product_Category,
		y.[2011_QS],
		y.[2012_QS],
		y.[2012_QS] - y.[2011_QS] AS Change,
		COALESCE(
			CAST(([2012_QS] - [2011_QS]) * 100.00 / NULLIF([2011_QS], 0) AS DECIMAL(10,2)), 0) AS [%YoY],
		CAST((y.[2012_QS] - y.[2011_QS]) * 100.0 / t.Total_Change AS DECIMAL(8,2))
		AS [%Contribution]
	FROM Category_Comparison AS y
	CROSS JOIN Category_Total_Change AS t
)
SELECT
	*,
	SUM([%Contribution])
		OVER(ORDER BY [%Contribution] DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
	AS Cumulative_Contribution
FROM Category_Calculations;
GO

-- Finding
-- The top five product categories accounted for 98.9% of the decline in Quantity Sold.
-- Audio contributed only 1.2% and was excluded from further investigation.
-- The remaining analysis focuses on these five high-impact categories.


/*===============================================================================================================================================
												3.4. PRODUCT SUBCATEGORY ANALYSIS
================================================================================================================================================*/


-- Which Product Subcategories had a highest negative growth in affected months, product class and categories?


WITH Subcategory_Comparison AS(
	SELECT Product_Subcategory, Product_Category,
		COALESCE(
			SUM(CASE WHEN Year = 2011 THEN Quantity_Sold END),
			0) AS [2011_QS],
		COALESCE(
			SUM(CASE WHEN Year = 2012 THEN Quantity_Sold END)
			,0) AS [2012_QS]
	FROM vw_Sales_Analysis
	WHERE
		MONTH IN (4,5,6,7,10)     
		AND Product_Class = 'Regular'
		AND Product_Category IN (
			'Cameras & Camcorders',
			'Cell Phones',
			'Computers',
			'TV & Video',
			'Music, Movies & Audio Books'
			)
	GROUP BY Product_Subcategory, Product_Category
),
Subcategory_Total_Change AS(
	SELECT SUM([2012_QS] - [2011_QS]) AS Total_Change
	FROM Subcategory_Comparison
),
Subcategory_Calculations AS(
	SELECT
		s.Product_Subcategory,
		s.Product_Category,
		s.[2011_QS],
		s.[2012_QS],
		s.[2012_QS] - s.[2011_QS] AS Change,
		COALESCE(
			CAST((s.[2012_QS] - s.[2011_QS]) * 100.00 / NULLIF(s.[2011_QS],0) AS DECIMAL(10,2)), 0)
		AS [%YoY],
		CAST(
			(s.[2012_QS] - s.[2011_QS]) * 100.0 / c.Total_Change AS DECIMAL(8,2))
		AS [%Contribution]
	FROM Subcategory_Comparison AS s
	CROSS JOIN Subcategory_Total_Change AS c
)
SELECT
	*,
	SUM([%Contribution])
		OVER(ORDER BY [%Contribution] DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
	AS Cumulative_Contribution
FROM Subcategory_Calculations;
GO

-- Finding
-- Nine product subcategories explained 86.7% of the Quantity Sold decline.
-- Further investigation focuses on these subcategories to identify the specific products responsible.


/*=============================================================================================================================================
													3.5. PRODUCT ANALYSIS
===============================================================================================================================================*/


-- Which Products had a highest negative growth in affected months, product class, categories & subcategories?


WITH Product_Comparison AS(
	SELECT
		Product_Subcategory,
		Product_Name,
		COALESCE(
			SUM(CASE WHEN Year = 2011 THEN Quantity_Sold END),
			0) AS [2011_QS],
		COALESCE(
			SUM(CASE WHEN Year = 2012 THEN Quantity_Sold END)
			,0) AS [2012_QS]
	FROM vw_Sales_Analysis
	WHERE
		MONTH IN (4,5,6,7,10)     
		AND Product_Class = 'Regular'
		AND Product_Subcategory IN (
			'Digital Cameras',
			'Digital SLR Cameras',
			'Printers, Scanners & Fax',
			'Projectors & Screens',
			'Movie DVD',
			'Touch Screen Phones',
			'Home & Office Phones',
			'Smart phones & PDAs',
			'Home Theater System'
			)
	GROUP BY Product_Subcategory, Product_Name
),
Product_Total_Change AS(
	SELECT SUM([2012_QS] - [2011_QS]) AS Total_Change
	FROM Product_Comparison
),
Product_Calculations AS(
	SELECT
		s.Product_Subcategory,
		s.Product_Name,
		s.[2011_QS],
		s.[2012_QS],
		s.[2012_QS] - s.[2011_QS] AS Change,
		COALESCE(
			CAST((s.[2012_QS] - s.[2011_QS]) * 100.00 / NULLIF(s.[2011_QS],0) AS DECIMAL(10,2)), 0)
			AS [%YoY],
		CAST(
			(s.[2012_QS] - s.[2011_QS]) * 100.0 / c.Total_Change AS DECIMAL(8,2))
			AS [%Contribution]
	FROM Product_Comparison AS s
	CROSS JOIN Product_Total_Change AS c
)
SELECT
	*,
	SUM([%Contribution])
		OVER(ORDER BY [%Contribution] DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
	AS Cumulative_Contribution
FROM Product_Calculations;
GO

-- Finding:
-- The decline in Quantity Sold was spread across many products within the selected subcategories.
-- Only a few products showed a slight positive
-- hence we will continue our analysis for product categories only.
-- Contribution, partially offsetting the overall decline.