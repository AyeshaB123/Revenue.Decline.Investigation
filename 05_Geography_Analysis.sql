

/*==============================================================================================================================================
	Project: Sales Performance Analysis
	File:    05_Geography_Analysis.sql
	Author:  Ayesha Batool

	DESCRIPTION
		This script investigates the geographical drivers behind the decline in Quantity Sold
		after applying the filters identified during the business investigation and product analysis.

	Analysis Scope
		Months: Apr, May, Jun, Jul, Oct
		Product Class: Regular
		Product Categories
			- Cameras & Camcorders
			- Cell Phones
			- Computers
			- TV & Video
			- Music, Movies & Audio Books
		Product Subcategories
			- Digital Cameras
			- Digital SLR Cameras
			- Printers, Scanners & Fax
			- Projectors & Screens
			- Movie DVD
			- Touch Screen Phones
			- Home & Office Phones
			- Smart Phones & PDAs
			- Home Theater System

		Investigation Workflow
			1. Continent Analysis
			2. Country Analysis
			3. Store Analysis

================================================================================================================================================*/


USE Sales;
GO


/*=============================================================================================================================================
													3.6. CONTINENT ANALYSIS
===============================================================================================================================================*/


-- Which continents experienced the largest decline in Quantity Sold in affected months, and product segments?

WITH Continent_Comparison AS(
	SELECT Continent,
		COALESCE(
			SUM(CASE
				WHEN Year = 2011 THEN Quantity_Sold
				END), 0) AS [2011_QS],
		COALESCE(SUM(CASE
			WHEN Year = 2012 THEN Quantity_Sold
			END), 0) AS [2012_QS]
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
	GROUP BY Continent
),
Continent_Total_Change AS(
	SELECT SUM([2012_QS] - [2011_QS]) AS Total_Change
	FROM Continent_Comparison
),
Continent_Calculations AS(
	SELECT
		*,
		c.[2012_QS] - c.[2011_QS] AS Change,
		COALESCE(
			CAST((c.[2012_QS] - c.[2011_QS]) * 100.00 / NULLIF(c.[2011_QS],0) AS DECIMAL(10,2)), 0) AS [%YoY],
		CAST(
			(c.[2012_QS] - c.[2011_QS]) * 100.0 / t.Total_Change AS DECIMAL(8,2))
			AS [%Contribution]
	FROM Continent_Comparison AS c
	CROSS JOIN Continent_Total_Change AS t
)
SELECT
	*,
	SUM([%Contribution])
		OVER(ORDER BY [%Contribution] DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
	AS Cumulative_Contribution
FROM Continent_Calculations;
GO

-- Finding:
-- North America accounted for 85.96% of the decline in Quantity Sold within the identified months, product class, categories and 
-- product subcategories.
-- Therefore, the remaining investigation focuses on North America.


/*=============================================================================================================================================
													3.7. COUNTRY ANALYSIS
===============================================================================================================================================*/


-- Which country in North America contributed the largest decline in Quantity Sold in affected months and product segments?

WITH Country_Comparison AS(
	SELECT
		Country,
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
		AND Continent = 'North America'
	GROUP BY Country
),
Country_Total_Change AS(
	SELECT SUM([2012_QS] - [2011_QS]) AS Total_Change
	FROM Country_Comparison
),
Country_Calculations AS(
	SELECT
		*,
		s.[2012_QS] - s.[2011_QS] AS Change,
		COALESCE(
			CAST((s.[2012_QS] - s.[2011_QS]) * 100.00 / NULLIF(s.[2011_QS],0) AS DECIMAL(10,2)), 0)
		AS [%YoY],
		CAST(
			(s.[2012_QS] - s.[2011_QS]) * 100.0 / c.Total_Change AS DECIMAL(8,2)) 
		AS [%Contribution]
	FROM Country_Comparison AS s
	CROSS JOIN Country_Total_Change AS c
)
SELECT
	Country,
	[2011_QS],
	[2012_QS],
	Change,
	[%YoY],
	[%Contribution],
	SUM([%Contribution])
		OVER(ORDER BY [%Contribution] DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
		AS Cumulative_Contribution
FROM Country_Calculations;
GO

-- Finding:
-- The United States accounted for 94.28% of the decline in Quantity Sold within North America during the identified months and product segments.
-- Therefore, the remaining analysis focuses on the United States while keeping the previously identified filters unchanged.


/*=============================================================================================================================================
													3.8. STORE ANALYSIS
===============================================================================================================================================*/


-- Which stores contributed in highest in the decline of Quantity Sold?

WITH Store_Comparison AS(
	SELECT
		Store_Name,
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
		AND Continent = 'North America'
		AND Country = 'United States'
	GROUP BY Store_Name
),
Store_Total_Change AS(
	SELECT SUM([2012_QS] - [2011_QS]) AS Total_Change
	FROM Store_Comparison
),
Store_Calculations AS(
	SELECT
		*,
		s.[2012_QS] - s.[2011_QS] AS Change,
		COALESCE(
			CAST((s.[2012_QS] - s.[2011_QS]) * 100.00 / NULLIF(s.[2011_QS],0) AS DECIMAL(10,2)), 0)
			AS [%YoY],
		CAST(
			(s.[2012_QS] - s.[2011_QS]) * 100.0 / c.Total_Change AS DECIMAL(8,2))
			AS [%Contribution]
	FROM Store_Comparison AS s
	CROSS JOIN Store_Total_Change AS c
)
SELECT
	Store_Name,
	[2011_QS],
	[2012_QS],
	Change,
	[%YoY],
	[%Contribution],
	SUM([%Contribution])
		OVER(ORDER BY [%Contribution] DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
		AS Cumulative_Contribution
FROM Store_Calculations;
GO

-- Finding:
-- No individual store accounted for a disproportionately high decline in Quantity Sold.
-- And the decline was distributed across stores within the identified months, product segments, and geographic segments,
-- indicating that improvement efforts should target all stores in the selected business scope.

-- Most of the products identified in the investigation belong to the Contoso brand.
-- However, brand-level analysis was outside the scope of this investigation.

