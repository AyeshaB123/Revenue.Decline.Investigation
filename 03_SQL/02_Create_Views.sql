
-- This script creates analytical views that will be used in EDA
-- vw_Yearly_Metrics
	-- Annual Revenue | Annual Quantity Sold | Average Selling Price (ASP)
-- vw_Sales_Analysis
	-- Product hierarchy | Geography hierarchy | Store information | Time dimensions | Sales Metrics (Quantity Sold & Revenue)

--------------------

USE Retail_DB;
GO

--------------------

-- Yearly Metrics View

CREATE VIEW vw_Yearly_Metrics AS
	SELECT
		YEAR(Date_Key) AS Year,
		CAST(SUM(Revenue) AS DECIMAL(15, 1)) AS Total_Revenue,
		SUM(Sales_Quantity) AS Total_Quantity_Sold,
		SUM(Profit) AS Total_Gross_Profit,
		COALESCE(
			CAST(
				SUM(Revenue) * 1.0 / NULLIF(SUM(Sales_Quantity), 0) AS DECIMAL(10, 1)
			), 0) AS Average_Selling_Price
	FROM Sales
	WHERE Date_Key IS NOT NULL
	GROUP BY YEAR(Date_Key)
GO


SELECT
	Year,
	Average_Selling_Price AS [($) Average Selling Price],
	CAST(Total_Quantity_Sold / 1000 AS DECIMAL(8, 0)) AS [(K) Total Quantity Sold],
	CAST(Total_Revenue / 1000000 AS DECIMAL(8, 0)) AS [($M) Total Revenue],
	CAST(Total_Gross_Profit / 1000000 AS DECIMAL(8, 0)) AS [($M) Total Gross Profit]
FROM vw_Yearly_Metrics
ORDER BY Year;
GO

-----------------------


-- Sales Analysis View

CREATE VIEW vw_Sales_Analysis AS
	SELECT
		YEAR(s.Date_Key) AS Year, MONTH(s.Date_Key) AS Month,
		p.Product_Name, pc.Product_Category, ps.Product_Subcategory, p.Class_Name AS Product_Class,
		st.Store_Name, st.Store_Type, st.Status AS Store_Status,
		g.Continent_Name AS Continent, g.Country,
		COALESCE(SUM(s.Sales_Quantity), 0) AS Quantity_Sold,
		COALESCE(SUM(s.Revenue), 0) AS Revenue,
		COALESCE(SUM(s.Profit), 0) AS Gross_Profit
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
		YEAR(s.Date_Key), MONTH(s.Date_Key),
		p.Product_Name, pc.Product_Category, ps.Product_Subcategory, p.Class_Name,
		st.Store_Name, st.Store_Type, st.Status,
		g.Continent_Name, g.Country
GO


SELECT TOP (10)
		Year, Month,
		Product_Name, Product_Category,	Product_Subcategory, Product_Class,
		Store_Name, Store_Type, Store_Status,
		Continent, Country,
		Quantity_Sold,
		FORMAT(Revenue, 'N0') AS [($) Revenue],
		FORMAT(Gross_Profit, 'N0') AS [$ Gross Profit]
FROM vw_Sales_Analysis
ORDER BY Revenue DESC;
GO
