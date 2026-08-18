

USE Retail_DB;
GO

-- REVENUE RECOVERY
WITH c_Recovered_Revenue AS(
	SELECT
		Year,
		SUM(Revenue) AS [Total Revenue]
	FROM vw_Sales_Analysis
	WHERE Month IN (8, 9)
	GROUP BY Year
),
c_Previous_Recovered_Revenue AS(
	SELECT
		Year,
		[Total Revenue],
		LAG([Total Revenue]) OVER(ORDER BY Year) AS [Prev Total Revenue]
	FROM c_Recovered_Revenue
),
c_Previous_Total_Revenue AS(
	SELECT
		Year,
		[Total_Revenue],
		LAG([Total_Revenue]) OVER(ORDER BY Year) AS [Prev Total Revenue]
	FROM vw_Yearly_Metrics
)
SELECT
	a.Year,
	FORMAT(COALESCE(a.[Total Revenue] - a.[Prev Total Revenue], 0), 'N0') AS [Filtered Revenue Change],
	FORMAT(COALESCE(b.[Total_Revenue] - b.[Prev Total Revenue], 0), 'N0') AS [Total Revenue Change],
	COALESCE(
	CAST(
		(a.[Total Revenue] - a.[Prev Total Revenue]) * 100.0 / (b.[Total_Revenue] - b.[Prev Total Revenue]) AS DECIMAL(8, 2)), 0)
		 AS [%Revenue Recovery]
FROM c_Previous_Recovered_Revenue AS a
INNER JOIN c_Previous_Total_Revenue AS b
	ON a.Year = b.Year;


-- QUANTITY RECOVERY
WITH c_Recovered_Quantity AS(
	SELECT Year, SUM(Quantity_Sold) AS [Total Quantity Sold]
	FROM vw_Sales_Analysis
	WHERE Month IN (8, 9)
	GROUP BY Year
),
c_Previous_Recovered_Quantity AS(
	SELECT
		Year,
		[Total Quantity Sold],
		LAG([Total Quantity Sold]) OVER(ORDER BY Year) AS [Prev Quantity Sold]
	FROM c_Recovered_Quantity
),
c_Previous_Total_Quantity AS(
	SELECT
		Year,
		[Total_Quantity_Sold],
		LAG([Total_Quantity_Sold]) OVER(ORDER BY Year) AS [Prev Quantity Sold]
	FROM vw_Yearly_Metrics
)

-- CAST([2011_QS] / 1000 AS DECIMAL(6, 0)) 
SELECT
	a.Year,
	COALESCE(
		CAST((a.[Total Quantity Sold] - a.[Prev Quantity Sold])/1000 AS DECIMAL(6,0)), 0) AS [(K) Filtered Quantity Change],
	COALESCE(
		CAST((b.[Total_Quantity_Sold] - b.[Prev Quantity Sold])/1000 AS DECIMAL(6, 0)), 0) AS [(K) Total Quantity Change],
	COALESCE(
		CAST(
			(a.[Total Quantity Sold] - a.[Prev Quantity Sold]) * 100.0 / (b.[Total_Quantity_Sold] - b.[Prev Quantity Sold]) AS DECIMAL(8, 1)
		), 0) AS [%Quantity Recovery]
FROM c_Previous_Recovered_Quantity AS a
INNER JOIN c_Previous_Total_Quantity AS b
	ON a.Year = b.Year;


-- PRODUCT RECOVERY
-- Quantity Sold by Product Category in Recovery Months (Aug & Sep)
WITH c_Country_Comparison AS(
	SELECT
		Product_Category,
		COALESCE(
			SUM(CASE WHEN Year = 2011 THEN Quantity_Sold END),
			0) AS [2011_QS],
		COALESCE(
			SUM(CASE WHEN Year = 2012 THEN Quantity_Sold END)
			,0) AS [2012_QS]
	FROM vw_Sales_Analysis
	WHERE
		MONTH IN (8, 9)     
	GROUP BY Product_Category
),
c_Country_Total_Change AS(
	SELECT SUM([2012_QS] - [2011_QS]) AS Total_Change
	FROM c_Country_Comparison
),
c_Country_Calculations AS(
	SELECT
		s.Product_Category,
		s.[2011_QS], s.[2012_QS],
		c.Total_Change, 
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
	Product_Category,
	FORMAT([2011_QS], 'N0') AS [ 2011 Quantity Sold],
	FORMAT([2012_QS], 'N0') AS [ 2012 Quantity Sold],
	FORMAT(Change, 'N0') AS [Change],
	[%YoY],
	[%Contribution],
	SUM([%Contribution])
		OVER(ORDER BY [%Contribution] DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
		AS [%Cumulative Contribution]
FROM c_Country_Calculations;
GO
-- Finding
-- Computers shows a positive contribution of 55.4% in Aug & Sep.
-- TV & Vide, Cameras & Camcorders, Music, Movies & Audio Book and Cell Phones all contributed positively.
-- However, Audio had a decline of 3.4%.

-- How much of the decline was offset? 
WITH c_Previous AS(
	SELECT
		Year,
		Total_Quantity_Sold,
		LAG(Total_Quantity_Sold) OVER(ORDER BY Year) AS Prev_Total_Quantity_Sold
	FROM vw_Yearly_Metrics
),
c_Change AS(
	SELECT
		Year,
		Total_Quantity_Sold,
		Prev_Total_Quantity_Sold,
		Total_Quantity_Sold - Prev_Total_Quantity_Sold AS Change
	FROM c_Previous
),
c_Quantity_Sold AS(
	SELECT Year, SUM(Quantity_Sold) AS Quantity_Sold
	FROM vw_Sales_Analysis
	WHERE Month IN (8, 9)
	GROUP BY Year
),
c_Recovered_Quantity_Sold AS(
	SELECT
		Year,
		Quantity_Sold,
		LAG(Quantity_Sold) OVER(ORDER BY Year) AS Prev_Quantity_Sold,
		Quantity_Sold - LAG(Quantity_Sold) OVER(ORDER BY Year) AS Change
	FROM c_Quantity_Sold
)
SELECT
	c.Year,
	CAST(c.Total_Quantity_Sold / 1000 AS DECIMAL(8, 0)) AS [(K) Quantity Sold],
	CAST(COALESCE(c.Prev_Total_Quantity_Sold, 0) / 1000 AS DECIMAL(8,0)) AS [(K) Prev. Quantity Sold],
	CAST(COALESCE(c.Change, 0) / 1000 AS DECIMAL(8,0)) AS [(K) Change],
	COALESCE(CAST(r.Change / 1000 AS DECIMAL(8, 0)), 0) AS [(K) Recovered Quantity Sold],
	COALESCE(CAST( r.Change * 100.0 / c.Change AS DECIMAL(8,1)), 0) AS [%Recovery]
FROM c_Change AS c
JOIN c_Recovered_Quantity_Sold AS r
	ON c.Year = r.Year;
-- Finding
-- This indicates that only 2.1% of the total quantity sold decline was recovered in Aug & Sep.


-- STORE RECOVERY
-- Which stores during the 2 months drove recovery?
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
	WHERE MONTH IN (8, 9)     
	GROUP BY Store_Name
),
c_Calculate_Total_Change AS(
	SELECT SUM([2012_QS] - [2011_QS]) AS Total_Change
	FROM c_Store_Comparison
),
c_Store_Calculations AS(
	SELECT
		s.Store_Name,
		s.[2011_QS], s.[2012_QS],
		s.[2012_QS] - s.[2011_QS] AS Change,
		CAST((s.[2012_QS] - s.[2011_QS]) * 100.0 / r.Total_Change AS DECIMAL(6, 1)) AS [%Contribution]
	FROM c_Store_Comparison AS s
	CROSS JOIN c_Calculate_Total_Change AS r
)
SELECT
	Store_Name AS [Store Name],
	[2011_QS] AS [2011 Quantity Sold],
	[2012_QS] AS [2012 Quantity Sold],
	Change,
	[%Contribution]
FROM c_Store_Calculations
ORDER BY [%Contribution] DESC;
GO

-- Finding
-- Top 25 stores recorded positive changes in Quantity Sold during the recovery months (Aug & Sep), contributing to the overall recovery.


