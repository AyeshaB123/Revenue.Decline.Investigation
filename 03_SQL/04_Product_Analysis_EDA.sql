
-- Analysis Scope
	-- Months: Apr, May, Jun, Jul, Oct | Product Class: Regular
-- Investigation Workflow
	-- Product Category Analysis | Product Subcategory Analysis | Product Analysis

USE Retail_DB;
GO

-- Product Category Analysis
-- Which product categories contributed the most to the Quantity Sold decline within the identified months and product class?
WITH c_Category_Comparison AS(
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
c_Category_Total_Change AS(
	SELECT SUM([2012_QS] - [2011_QS]) AS Total_Change
	FROM c_Category_Comparison
),
c_Category_Calculations AS(
	SELECT
		y.Product_Category,
		y.[2011_QS], y.[2012_QS],
		y.[2012_QS] - y.[2011_QS] AS Change,
		COALESCE(
			CAST(([2012_QS] - [2011_QS]) * 100.00 / NULLIF([2011_QS], 0) AS DECIMAL(10,1)), 0) AS [%YoY],
		CAST((y.[2012_QS] - y.[2011_QS]) * 100.0 / t.Total_Change AS DECIMAL(8,1))
		AS [%Contribution]
	FROM c_Category_Comparison AS y
	CROSS JOIN c_Category_Total_Change AS t
)
SELECT
	Product_Category,
	CAST([2011_QS] / 1000 AS DECIMAL(6, 0)) AS [(K) 2011 Quantity Sold],
	CAST([2012_QS] / 1000 AS DECIMAL(6, 0)) AS [(K) 2012 Quantity Sold],
	CAST([Change] / 1000 AS DECIMAL(6, 0)) AS [(K) Change],
	[%YoY],
	[%Contribution],
	SUM([%Contribution])
		OVER(ORDER BY [%Contribution] DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
	AS [%Cumulative Contribution]
FROM c_Category_Calculations;
GO
-- Finding: The top five product categories accounted for 98.9% of the decline in Quantity Sold.
-- Audio contributed only 1.2% and was excluded from further investigation.
-- The remaining analysis focuses on these five high-impact categories.


-- Product Subcategory Analysis
-- Which Product Subcategories had a highest negative growth in affected months, product class and categories?
WITH c_Subcategory_Comparison AS(
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
c_Subcategory_Total_Change AS(
	SELECT SUM([2012_QS] - [2011_QS]) AS Total_Change
	FROM c_Subcategory_Comparison
),
c_Subcategory_Calculations AS(
	SELECT
		s.Product_Subcategory, s.Product_Category,
		s.[2011_QS], s.[2012_QS],
		s.[2012_QS] - s.[2011_QS] AS Change,
		COALESCE(
			CAST((s.[2012_QS] - s.[2011_QS]) * 100.00 / NULLIF(s.[2011_QS],0) AS DECIMAL(10,1)), 0)
		AS [%YoY],
		CAST(
			(s.[2012_QS] - s.[2011_QS]) * 100.0 / c.Total_Change AS DECIMAL(8,1))
		AS [%Contribution]
	FROM c_Subcategory_Comparison AS s
	CROSS JOIN c_Subcategory_Total_Change AS c
)
SELECT
	Product_Subcategory AS [Product Subcategory],
	Product_Category AS [Product Category],
	CAST([2011_QS] / 1000 AS DECIMAL(6, 0)) AS [(K) 2011 Quantity Sold],
	CAST([2012_QS] / 1000 AS DECIMAL(6, 0)) AS [(K) 2012 Quantity Sold],
	CAST(Change / 1000 AS DECIMAL(6, 0)) AS [(K) Change],
	[%YoY],
	[%Contribution],
	SUM([%Contribution])
		OVER(ORDER BY [%Contribution] DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
	AS [%Cumulative Contribution]
FROM c_Subcategory_Calculations;
GO
-- Finding: Nine product subcategories explained 86.7% of the Quantity Sold decline.
-- Further investigation focuses on these subcategories to identify the specific products responsible.


-- Product Analysis
-- Which Products had a highest negative growth in affected months, product class, categories & subcategories?
WITH c_Product_Comparison AS(
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
c_Product_Total_Change AS(
	SELECT SUM([2012_QS] - [2011_QS]) AS Total_Change
	FROM c_Product_Comparison
),
c_Product_Calculations AS(
	SELECT
		s.Product_Subcategory, s.Product_Name,
		s.[2011_QS], s.[2012_QS],
		s.[2012_QS] - s.[2011_QS] AS Change,
		COALESCE(
			CAST((s.[2012_QS] - s.[2011_QS]) * 100.00 / NULLIF(s.[2011_QS], 0) AS DECIMAL(5,1)), 0)
			AS [%YoY],
		CAST(
			(s.[2012_QS] - s.[2011_QS]) * 100.0 / c.Total_Change AS DECIMAL(5,1))
			AS [%Contribution]
	FROM c_Product_Comparison AS s
	CROSS JOIN c_Product_Total_Change AS c
)
SELECT
	Product_Subcategory AS [Product Subcategory],
	Product_Name AS [Product Name],
	[2011_QS] AS [2011 Quantity Sold], [2012_QS] AS [2012 Quantity Sold],
	Change, [%YoY], [%Contribution],
	SUM([%Contribution])
		OVER(ORDER BY [%Contribution] DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
	AS [%Cumulative Contribution]
FROM c_Product_Calculations;
GO


-- Finding: The decline in Quantity Sold was spread across many products within the selected subcategories.
-- Only a few products showed a slight positive
-- Hence, we will continue our analysis for product categories only.

