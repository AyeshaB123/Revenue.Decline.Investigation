

/*=============================================================================================================================================
	
	Project: Sales Performance Analysis
	File:    03_Business_EDA.sql
	Author:  Ayesha Batool

	DESCRIPTION:
	This script investigates a business problem: 
								"Why did revenue decline by 43% between 2011 and 2012?".

	Investigation Workflow:

	1. Revenue Validation
	2. Average Selling Price (ASP) Validation
	3. Quantity Sold Investigation
		3.1 Monthly Pattern Analysis
		3.2 Product Class Analysis

===============================================================================================================================================*/


USE Sales;
GO


/*=============================================================================================================================================
													1. REVENUE VALIDATION
================================================================================================================================================*/


WITH Previous AS(
	SELECT
		Year,
		Total_Revenue,
		LAG(Total_Revenue) OVER(ORDER BY Year) AS Prev_Total_Revenue
	FROM vw_Yearly_Metrics
)
SELECT
	Year,
	Total_Revenue,
	Prev_Total_Revenue,
	Total_Revenue - Prev_Total_Revenue AS Change,
	CAST((Total_Revenue - Prev_Total_Revenue) * 100.0 / Prev_Total_Revenue AS DECIMAL(8, 2))
	AS [%YoY]
FROM Previous
WHERE Year = 2012;
GO

-- Finding:
-- Revenue declined by 43.1% between 2011 and 2012, confirming the reported business problem.


/*=============================================================================================================================================
											2. AVERAGE SELLING PRICE (ASP) VALIDATION
===============================================================================================================================================*/


WITH Previous AS(
	SELECT
		Year,
		Average_Selling_Price,
		LAG(Average_Selling_Price) OVER(ORDER BY Year) AS Prev_Average_Selling_Price
	FROM vw_Yearly_Metrics
)
SELECT
	Year,
	Average_Selling_Price,
	Prev_Average_Selling_Price,
	Average_Selling_Price - Prev_Average_Selling_Price AS Change,
	CAST(
		(Average_Selling_Price - Prev_Average_Selling_Price) * 100.0 / Prev_Average_Selling_Price AS DECIMAL(8, 2))
	AS [%YoY]
FROM Previous
WHERE Year = 2012;
GO

-- Finding:
-- Average Selling Price (ASP) declined by only 2.2% YoY.
-- Therefore, pricing was not the primary driver of the revenue decline.


/*=============================================================================================================================================
												3. QUANTITY SOLD INVESTGATION
===============================================================================================================================================*/


WITH Previous AS(
	SELECT
		Year,
		Total_Quantity_Sold,
		LAG(Total_Quantity_Sold) OVER(ORDER BY Year) AS Prev_Total_Quantity_Sold
	FROM vw_Yearly_Metrics
	)
SELECT
	Year,
	Total_Quantity_Sold,
	Prev_Total_Quantity_Sold,
	Total_Quantity_Sold - Prev_Total_Quantity_Sold AS Change,
	CAST(
		(Total_Quantity_Sold - Prev_Total_Quantity_Sold) * 100.0 / Prev_Total_Quantity_Sold AS DECIMAL(8, 2))
	AS [%YoY]
FROM Previous
WHERE Year = 2012;
GO

-- Finding:
-- Quantity Sold declined by 41.9% YoY.
-- Since the Average Selling Price remained relatively stable, the decline in Quantity Sold was identified as the primary driver of
-- the revenue loss.
-- Therefore, the subsequent analysis focuses on Quantity Sold.


/*=============================================================================================================================================
													3.1 MONTHLY PATTERN
================================================================================================================================================*/


-- Did Quantity Sold decline throughout the year, or was there a seasonal pattern?

WITH Monthly_Quantity_Sold AS(
	SELECT
		c.Year,
		c.Month_Name			AS Month,
		c.Month_Of_Year			AS Month_Number,
		SUM(s.Sales_Quantity)	AS Total_Quantity_Sold
	FROM Calendar AS c
	LEFT JOIN Sales AS s
		ON s.Date_Key = c.Date_Key
	GROUP BY
		c.Year,
		c.Month_Name,
		c.Month_Of_Year
),
Monthly_Comparison AS(
	SELECT Month_Number, Month,
		COALESCE(
			SUM(CASE
				WHEN Year = 2011 THEN Total_Quantity_Sold
			END), 0) AS [2011_QS],
		COALESCE(
			SUM(CASE
				WHEN Year = 2012 THEN Total_Quantity_Sold
			END), 0) AS [2012_QS]
	FROM Monthly_Quantity_Sold
	GROUP BY Month_Number, Month
),
Calculate_Total_Change AS(
	SELECT SUM([2012_QS] - [2011_QS]) AS Total_Change
	FROM Monthly_Comparison
),
Calculations AS(
	SELECT
		m.Month,
		m.[2011_QS],
		m.[2012_QS],
		m.[2012_QS] - m.[2011_QS] AS Change,
		COALESCE(CAST(
				(m.[2012_QS] - m.[2011_QS]) * 100.0/ NULLIF(m.[2011_QS], 0) AS DECIMAL(10,2)), 0)
		AS [%YOY],
		CAST(
			(m.[2012_QS] - m.[2011_QS]) * 100.0 / c.Total_Change AS DECIMAL(6,2))
		AS [%Contribution]
	FROM Monthly_Comparison AS m
	CROSS JOIN Calculate_Total_Change AS c
)
SELECT
	*,
	SUM([%Contribution])
		OVER(ORDER BY [%Contribution] DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
		AS Cumulative_Contribution
FROM Calculations;
GO

-- Finding:
-- The decline was not spread evenly across the year.
-- It was concentrated in Apr, May, Jun, Jul and Oct with total contribution of 102.08%.
-- Therefore, the subsequent analysis focuses on these months only.


/*=============================================================================================================================================
													3.2 PRODUCT CLASS ANALYSIS
================================================================================================================================================*/


-- Which Product Class contributed most to the decline in Quantity Sold during the affected months?

WITH Product_Class_Comparison AS(
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
Calculate_Total_Change AS(
	SELECT SUM([2012_QS] - [2011_QS]) AS Total_Change
	FROM Product_Class_Comparison
),
Calculations AS(
	SELECT
		p.Product_Class,
		p.[2011_QS],
		p.[2012_QS],
		p.[2012_QS] - [2011_QS] AS Change,
		COALESCE(
			CAST((p.[2012_QS] - p.[2011_QS]) * 100.00/NULLIF(p.[2011_QS], 0) AS DECIMAL(10,2)), 0)
		AS [%YoY],
	CAST(
		(p.[2012_QS] - p.[2011_QS]) * 100.0/ 
		c.Total_Change AS DECIMAL(6,2)
		) AS [%Contribution]
	FROM Product_Class_Comparison AS p
	CROSS JOIN Calculate_Total_Change AS c
)
SELECT
	*,
	SUM([%Contribution]) OVER(ORDER BY [%Contribution] DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Cumulative_Contribution
FROM Calculations;
GO

-- Finding:
-- The decline was concentrated in the Regular Product Class accounted for 103.02%.
-- Therefore, the remaining analysis is limited to:
	-- Product Class: Regular
	-- Months: Apr, May, Jun, Jul and Oct