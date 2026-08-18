

-- This script analyzes the Financial impact by understanding Profitability trend among specific products & countries0

USE Retail_DB;
GO

-- What is the Gross Profit in 2011 & 2012?
WITH c_Previous AS(
	SELECT
		Year,
		Total_Gross_Profit,
		LAG(Total_Gross_Profit) OVER(ORDER BY Year) AS Prev_Total_Gross_Profit
	FROM vw_Yearly_Metrics
)
SELECT
	Year,
	CAST(Total_Gross_Profit / 1000000 AS DECIMAL(8, 1)) AS [($) Gross Profit],
	CAST(COALESCE(Prev_Total_Gross_Profit, 0) / 1000000 AS DECIMAL(8,1))
		AS [($) Prev. Gross Profit],
	CAST(COALESCE(Total_Gross_Profit - Prev_Total_Gross_Profit, 0) / 1000000 AS DECIMAL(8, 1)) AS [($) Change],
	COALESCE(
		CAST((Total_Gross_Profit - Prev_Total_Gross_Profit) * 100.0 / Prev_Total_Gross_Profit AS DECIMAL(8, 1)), 0)
		AS [%YoY]
FROM c_Previous
GO
-- Finding: %YoY shows Gross Profit declined to 43.7% aligning with 43.1% decline in revenue.
-- This indicates sales volume has a direct impact on Gross Profit



-- Gross Profit by Product Class
WITH c_Product_Class_Comparison AS(
	SELECT
		Product_Class,
		COALESCE(
			SUM(CASE
				WHEN Year = 2011 THEN Gross_Profit
				END),
		0) AS [2011_QS],
		COALESCE(
			SUM(CASE
				WHEN Year = 2012 THEN Gross_Profit
				END),
		0) AS [2012_QS]
	FROM vw_Sales_Analysis
	WHERE Month IN (4,5,6,7,10)     
	GROUP BY Product_Class
),
c_Calculate_Total_Change AS(
	SELECT SUM([2012_QS] - [2011_QS]) AS Total_Change
	FROM c_Product_Class_Comparison
),
c_Calculations AS(
	SELECT
		p.Product_Class,
		p.[2011_QS], p.[2012_QS],
		p.[2012_QS] - [2011_QS] AS Change,
		COALESCE(
			CAST((p.[2012_QS] - p.[2011_QS]) * 100.00/NULLIF(p.[2011_QS], 0) AS DECIMAL(10,1)), 0)
		AS [%YoY],
	CAST((p.[2012_QS] - p.[2011_QS]) * 100.0/ c.Total_Change AS DECIMAL(6,1)) AS [%Contribution]
	FROM c_Product_Class_Comparison AS p
	CROSS JOIN c_Calculate_Total_Change AS c
)
SELECT
	Product_Class,
	CAST([2011_QS] / 1000000 AS DECIMAL(8,1)) AS [($M) 2011 Gross Profit],
	CAST([2012_QS] / 1000000 AS DECIMAL(8,1)) AS [($M) 2012 Gross Profit],
	CAST(Change / 1000000 AS DECIMAL(8,1)) AS [($M) Change],
	[%YoY],
	[%Contribution],                  
	SUM([%Contribution])
		OVER(ORDER BY [%Contribution] DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
	AS [%Cumulative Contribution]
FROM c_Calculations;
GO
-- Finding:
-- %Contribution shows that Regular Class contributed in 78.6% of the overall gross profit decline during the effected months (Apr, May, Jun, Jul & Oct)
-- Since, %Cumulative Contribution accounts highest in Regular Class.



-- Gross Profit by 9 Product Subcategories
WITH c_Product_Comparison AS(
	SELECT
		Product_Subcategory,
		Product_Category,
		COALESCE(
			SUM(CASE WHEN Year = 2011 THEN Gross_Profit END),
			0) AS [2011_GP],
		COALESCE(
			SUM(CASE WHEN Year = 2012 THEN Gross_Profit END)
			,0) AS [2012_GP]
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
	GROUP BY Product_Subcategory, Product_Category
),
c_Product_Total_Change AS(
	SELECT SUM([2012_GP] - [2011_GP]) AS Total_Change
	FROM c_Product_Comparison
),
c_Product_Calculations AS(
	SELECT
		s.Product_Subcategory, s.Product_Category,
		s.[2011_GP], s.[2012_GP],
		s.[2012_GP] - s.[2011_GP] AS Change,
		COALESCE(
			CAST((s.[2012_GP] - s.[2011_GP]) * 100.00 / NULLIF(s.[2011_GP], 0) AS DECIMAL(5,1)), 0)
			AS [%YoY],
		CAST(
			(s.[2012_GP] - s.[2011_GP]) * 100.0 / c.Total_Change AS DECIMAL(5,1))
			AS [%Contribution]
	FROM c_Product_Comparison AS s
	CROSS JOIN c_Product_Total_Change AS c
)
SELECT
	Product_Subcategory AS [Product Subcategory],
	Product_Category AS [Product Category],
	CAST([2011_GP] / 1000000 AS DECIMAL(8,1)) AS [($M) 2011 Gross Profit],
	CAST([2012_GP] / 1000000 AS DECIMAL(8,1)) AS [($M) 2012 Gross Profit],
	CAST(Change / 1000000 AS DECIMAL(8,1)) AS [($M) Change],
	[%YoY],
	[%Contribution],
	SUM([%Contribution])
		OVER(ORDER BY [%Contribution] DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
	AS [%Cumulative Contribution]
FROM c_Product_Calculations;
GO


-- Gross Profit by Countries
WITH c_Country_Comparison AS(
	SELECT
		Country,
		COALESCE(
			SUM(CASE WHEN Year = 2011 THEN Gross_Profit END),
			0) AS [2011_GP],
		COALESCE(
			SUM(CASE WHEN Year = 2012 THEN Gross_Profit END)
			,0) AS [2012_GP]
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
	SELECT SUM([2012_GP] - [2011_GP]) AS Total_Change
	FROM c_Country_Comparison
),
c_Country_Calculations AS(
	SELECT
		s.Country, s.[2011_GP], s.[2012_GP], c.Total_Change, 
		s.[2012_GP] - s.[2011_GP] AS Change,
		COALESCE(
			CAST((s.[2012_GP] - s.[2011_GP]) * 100.00 / NULLIF(s.[2011_GP],0) AS DECIMAL(10,1)), 0)
		AS [%YoY],
		CAST(
			(s.[2012_GP] - s.[2011_GP]) * 100.0 / c.Total_Change AS DECIMAL(8,1)) 
		AS [%Contribution]
	FROM c_Country_Comparison AS s
	CROSS JOIN c_Country_Total_Change AS c
)
SELECT
	Country,
	CAST([2011_GP] / 1000000 AS DECIMAL(6, 1)) AS [($M) 2011 Gross Profit],
	CAST([2012_GP] / 1000000 AS DECIMAL(6, 1)) AS [($M) 2012 Gross Profit],
	CAST(Change / 1000000 AS DECIMAL(6, 1)) AS [($M) Change],
	[%YoY],
	[%Contribution],
	SUM([%Contribution])
		OVER(ORDER BY [%Contribution] DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
		AS [%Cumulative Contribution]
FROM c_Country_Calculations;
GO
-- Finding:
-- The US %Contribution is 94.6% YoY of the Gross Profit across North America in filtered product subcategories and months where the decline occured
-- This aligns with Quantity Sold analysis where the US accounted for 94.28%.












