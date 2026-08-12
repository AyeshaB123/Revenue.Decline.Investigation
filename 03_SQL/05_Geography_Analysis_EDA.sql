

-- Analysis Scope
	-- Months: Apr, May, Jun, Jul, Oct
	-- Product Class: Regular
	-- Product Categories
		-- Cameras & Camcorders | Cell Phones | Computers | TV & Video | Music, Movies & Audio Books
	-- Product Subcategories
		-- Digital Cameras | Digital SLR Cameras | Printers, Scanners & Fax | Projectors & Screens | Movie DVD
		-- Touch Screen Phones | Home & Office Phones | Smart Phones & PDAs | Home Theater System
-- Workflow
-- Continent Analysis | Country Analysis | Store Analysis

USE Retail_DB;
GO

-- Continent Analysis
-- Which continents experienced the largest decline in Quantity Sold in affected months, and product segments?
WITH c_Continent_Comparison AS(
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
c_Continent_Total_Change AS(
	SELECT SUM([2012_QS] - [2011_QS]) AS Total_Change
	FROM c_Continent_Comparison
),
c_Continent_Calculations AS(
	SELECT
		c.Continent,
		c.[2011_QS], c.[2012_QS],
		t.Total_Change,
		c.[2012_QS] - c.[2011_QS] AS Change,
		COALESCE(
			CAST((c.[2012_QS] - c.[2011_QS]) * 100.00 / NULLIF(c.[2011_QS],0) AS DECIMAL(10,1)), 0) AS [%YoY],
		CAST(
			(c.[2012_QS] - c.[2011_QS]) * 100.0 / t.Total_Change AS DECIMAL(8,1))
			AS [%Contribution]
	FROM c_Continent_Comparison AS c
	CROSS JOIN c_Continent_Total_Change AS t
)
SELECT
	Continent,
	CAST([2011_QS] / 1000 AS DECIMAL(6, 0)) AS [(K) 2011 Quanity Sold],
	CAST([2012_QS] / 1000 AS DECIMAL(6, 0)) AS [(K) 2012 Quanity Sold],
	CAST(Change / 1000 AS DECIMAL(6, 0)) AS [(K) Change],
	[%YoY],
	[%Contribution],
	SUM([%Contribution])
		OVER(ORDER BY [%Contribution] DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
	AS [%Cumulative Contribution]
FROM c_Continent_Calculations;
GO
-- Finding: North America accounted for 85.96% of the decline in Quantity Sold within the identified months, product class, categories and 
-- product subcategories.
-- Therefore, the remaining investigation focuses on North America.


-- Country Analysis
-- Which country in North America contributed the largest decline in Quantity Sold in affected months and product segments?
WITH c_Country_Comparison AS(
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
c_Country_Total_Change AS(
	SELECT SUM([2012_QS] - [2011_QS]) AS Total_Change
	FROM c_Country_Comparison
),
c_Country_Calculations AS(
	SELECT
		s.Country, s.[2011_QS], s.[2012_QS], c.Total_Change, 
		s.[2012_QS] - s.[2011_QS] AS Change,
		COALESCE(
			CAST((s.[2012_QS] - s.[2011_QS]) * 100.00 / NULLIF(s.[2011_QS],0) AS DECIMAL(10,1)), 0)
		AS [%YoY],
		CAST(
			(s.[2012_QS] - s.[2011_QS]) * 100.0 / c.Total_Change AS DECIMAL(8,1)) 
		AS [%Contribution]
	FROM c_Country_Comparison AS s
	CROSS JOIN c_Country_Total_Change AS c
)
SELECT
	Country,
	CAST([2011_QS] / 1000 AS DECIMAL(6, 0)) AS [(K) 2011 Quanity Sold],
	CAST([2012_QS] / 1000 AS DECIMAL(6, 0)) AS [(K) 2012 Quanity Sold],
	CAST(Change / 1000 AS DECIMAL(6, 0)) AS [(K) Change],
	[%YoY],
	[%Contribution],
	SUM([%Contribution])
		OVER(ORDER BY [%Contribution] DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
		AS [%Cumulative Contribution]
FROM c_Country_Calculations;
GO
-- Finding:
-- The United States accounted for 94.28% of the decline in Quantity Sold within North America during the identified months and product segments.
-- Therefore, the remaining analysis focuses on the United States while keeping the previously identified filters unchanged.


-- Store Analysis
-- Which stores contributed in highest in the decline of Quantity Sold?
WITH c_Store_Comparison AS(
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
c_Store_Total_Change AS(
	SELECT SUM([2012_QS] - [2011_QS]) AS Total_Change
	FROM c_Store_Comparison
),
c_Store_Calculations AS(
	SELECT
		s.Store_Name, s.[2011_QS], s.[2012_QS], c.Total_Change,
		s.[2012_QS] - s.[2011_QS] AS Change,
		COALESCE(
			CAST((s.[2012_QS] - s.[2011_QS]) * 100.00 / NULLIF(s.[2011_QS],0) AS DECIMAL(10,1)), 0)
			AS [%YoY],
		CAST(
			(s.[2012_QS] - s.[2011_QS]) * 100.0 / c.Total_Change AS DECIMAL(8,1))
			AS [%Contribution]
	FROM c_Store_Comparison AS s
	CROSS JOIN c_Store_Total_Change AS c
)
SELECT
	Store_Name AS [Store Name],
	[2011_QS] AS [2011 Quanity Sold],
	[2012_QS] AS [2012 Quanity Sold],
	Change, [%YoY], [%Contribution],
	SUM([%Contribution])
		OVER(ORDER BY [%Contribution] DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
		AS [%Cumulative Contribution]
FROM c_Store_Calculations;
GO

-- Finding:
-- No individual store accounted for a disproportionately high decline in Quantity Sold.
-- And the decline was distributed across stores within the identified months, product segments, and geographic segments,
-- indicating that improvement efforts should target all stores in the selected business scope.

-- Most of the products identified in the investigation belong to the Contoso brand.
-- However, brand-level analysis was outside the scope of this investigation.

