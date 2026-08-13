
-- This script is focused on Revenue Validation, Average Selling Price (ASP) Validation AND Quantity Sold Investigation.
-- Quantity Sold is further investigated among two dimensions, Monthly Pattern & Product Class Analysis

USE Retail_DB;
GO

-- Problem Validation
WITH c_Previous AS(
	SELECT
		Year,
		Total_Revenue,
		LAG(Total_Revenue) OVER(ORDER BY Year) AS Prev_Total_Revenue
	FROM vw_Yearly_Metrics
)
SELECT
	Year,
	CAST(Total_Revenue/1000000 AS DECIMAL(5, 1)) AS [($M) Total Revenue],
	CAST(
		COALESCE(Prev_Total_Revenue, 0) / 1000000 AS DECIMAL(5, 1)
		) AS [($M) Prev Total Revenue],
	CAST(
		COALESCE(Total_Revenue - Prev_Total_Revenue, 0)/ 1000000 AS DECIMAL(5, 1)
		) AS [($M) Change],
	COALESCE(
		CAST((Total_Revenue - Prev_Total_Revenue) * 100.0 / Prev_Total_Revenue AS DECIMAL(8, 1)), 0
		) AS [%YoY]
FROM c_Previous;
GO
-- Finding: Revenue declined by 43.1% between 2011 and 2012, confirming the reported business problem.


-- Average Selling Price (ASP) Investigation
WITH c_Previous AS(
	SELECT
		Year,
		Average_Selling_Price,
		LAG(Average_Selling_Price) OVER(ORDER BY Year) AS Prev_Average_Selling_Price
	FROM vw_Yearly_Metrics
)
SELECT
	Year,
	COALESCE(Prev_Average_Selling_Price, 0) AS [($) Avg. Selling Price],
	COALESCE(Average_Selling_Price - Prev_Average_Selling_Price, 0) AS [($) Change],
	COALESCE(
		CAST((Average_Selling_Price - Prev_Average_Selling_Price) * 100.0 / Prev_Average_Selling_Price AS DECIMAL(8, 1)), 0
		)
		AS [%YoY]
FROM c_Previous
GO
-- Finding: Average Selling Price (ASP) declined by only 2.2% YoY.
-- Therefore, pricing was not the primary driver of the revenue decline.



-- Quantity Sold Investigation
WITH c_Previous AS(
	SELECT
		Year,
		Total_Quantity_Sold,
		LAG(Total_Quantity_Sold) OVER(ORDER BY Year) AS Prev_Total_Quantity_Sold
	FROM vw_Yearly_Metrics
	)
SELECT
	Year,
	COALESCE(Total_Quantity_Sold, 0) / 1000 AS [(K) Quantity Sold],
	COALESCE(Prev_Total_Quantity_Sold, 0) / 1000 AS [(K) Prev. Quantity Sold],
	COALESCE(Total_Quantity_Sold - Prev_Total_Quantity_Sold, 0) / 1000 AS [(K) Change],
	COALESCE(
		CAST((Total_Quantity_Sold - Prev_Total_Quantity_Sold) * 100.0 / Prev_Total_Quantity_Sold AS DECIMAL(8, 1))
		, 0) AS [%YoY]
FROM c_Previous
ORDER BY Year
GO
-- Finding: Quantity Sold declined by 41.9% YoY.
-- Since the Average Selling Price remained relatively stable, the decline in Quantity Sold was identified as the primary driver of
-- the revenue loss. Therefore, the subsequent analysis focuses on Quantity Sold.


-- Monthly Pattern
-- Did Quantity Sold decline throughout the year, or was there a seasonal pattern?
WITH c_Monthly_Quantity_Sold AS(
	SELECT
		c.Year,
		c.Month_Name AS Month,
		c.Month_Of_Year AS Month_Number,
		SUM(s.Sales_Quantity) AS Total_Quantity_Sold
	FROM Calendar AS c
	LEFT JOIN Sales AS s
		ON s.Date_Key = c.Date_Key
	GROUP BY
		c.Year,
		c.Month_Name,
		c.Month_Of_Year
),
c_Monthly_Comparison AS(
	SELECT Month_Number, Month,
		COALESCE(
			SUM(CASE
				WHEN Year = 2011 THEN Total_Quantity_Sold
			END), 0) AS [2011_QS],
		COALESCE(
			SUM(CASE
				WHEN Year = 2012 THEN Total_Quantity_Sold
			END), 0) AS [2012_QS]
	FROM c_Monthly_Quantity_Sold
	GROUP BY Month_Number, Month
),
c_Calculate_Total_Change AS(
	SELECT SUM([2012_QS] - [2011_QS]) AS Total_Change
	FROM c_Monthly_Comparison
),
c_Calculations AS(
	SELECT
		m.Month,
		m.[2011_QS],m.[2012_QS],
		m.[2012_QS] - m.[2011_QS] AS Change,
		COALESCE(CAST(
				(m.[2012_QS] - m.[2011_QS]) * 100.0/ NULLIF(m.[2011_QS], 0) AS DECIMAL(10,1)), 0)
		AS [%YOY],
		CAST(
			(m.[2012_QS] - m.[2011_QS]) * 100.0 / c.Total_Change AS DECIMAL(6,1))
		AS [%Contribution]
	FROM c_Monthly_Comparison AS m
	CROSS JOIN c_Calculate_Total_Change AS c
)
SELECT
	Month,
	CAST([2011_QS] / 1000 AS DECIMAL(6,0)) AS [(K) 2011 Quantity Sold],
	CAST([2012_QS] / 1000  AS DECIMAL(6,0)) AS [(K) 2012 Quantity Sold],
	CAST([Change] / 1000 AS DECIMAL(6,0)) AS [(K) Change],
	[%YoY],
	[%Contribution],
	SUM([%Contribution])
		OVER(ORDER BY [%Contribution] DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
		AS [%Cumulative Contribution]
FROM c_Calculations;
GO

-- Finding: The decline was not spread evenly across the year.
-- It was concentrated in Apr-4, May-5, Jun-6, Jul-7 and Oct-10 with total contribution of 102.1%.
-- Therefore, the subsequent analysis focuses on these months only.


-- Product Class Analysis
-- Which Product Class contributed most to the decline in Quantity Sold during the affected months?
WITH c_Product_Class_Comparison AS(
	SELECT
		Product_Class,
		COALESCE(
			SUM(CASE
				WHEN Year = 2011 THEN Quantity_Sold
				END),
		0) AS [2011_QS],
		COALESCE(
			SUM(CASE
				WHEN Year = 2012 THEN Quantity_Sold
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
	CAST(
		(p.[2012_QS] - p.[2011_QS]) * 100.0/ 
		c.Total_Change AS DECIMAL(6,1)
		) AS [%Contribution]
	FROM c_Product_Class_Comparison AS p
	CROSS JOIN c_Calculate_Total_Change AS c
)
SELECT
	Product_Class,
	CAST([2011_QS] / 1000 AS DECIMAL(6,0)) AS [(K) 2011 Quantity Sold],
	CAST([2012_QS] / 1000 AS DECIMAL(6,0)) AS [(K) 2012 Quantity Sold],
	CAST(Change / 1000 AS DECIMAL(6,0)) AS [(K) Change],
	[%YoY],
	[%Contribution],                  
	SUM([%Contribution])
		OVER(ORDER BY [%Contribution] DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
	AS [%Cumulative Contribution]
FROM c_Calculations;
GO
-- Finding: The decline was concentrated in the Regular Product Class accounted for 103.02%.
-- Therefore, the remaining analysis is limited to Product Class - Regular & specific months (Apr, May, Jun, Jul and Oct).