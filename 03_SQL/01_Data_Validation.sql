

-- THIS SCRIPT PERFORMS IMPORTANT DATA QUALITY CHECKS AND ADD FINANCIAL METRICS

USE Retail_DB
GO

-- Check number of rows and match it with original data count.

SELECT COUNT(Sales_Key) AS Sales_Count
FROM Sales;

SELECT COUNT(Product_Key) AS Product_Count
FROM Product;

SELECT COUNT(Product_Subcategory_Key) AS Product_Subcategory_Count
FROM Product_Subcategory;

SELECT COUNT(Product_Category) AS Product_Category_Count
FROM Product_Category;

SELECT COUNT(Date_Key) AS Calendar_Count
FROM Calendar;

SELECT COUNT(Store_Key) AS Store_Count
FROM Store;

SELECT COUNT(Geography_Key) AS Geography_Count
FROM Geography;


-- Check for any invalid values in numeric columns

SELECT Sales_Quantity
FROM Sales
WHERE Sales_Quantity <= 0;

SELECT Unit_Price
FROM Product
WHERE Unit_Price <= 0;

SELECT Unit_Cost
FROM Product
WHERE Unit_Cost < 0;


/*
-- Calculating Columns, Cost | Revenue | Profit | Profit_Margin
ALTER TABLE Sales
ADD Cost DECIMAL(10,1),
	Revenue DECIMAL(10,1),
	Profit DECIMAL(10,1),
	Profit_Margin DECIMAL(10,1);

UPDATE s
SET Cost = p.Unit_Cost * s.Sales_Quantity, 
	Revenue = p.Unit_Price * s.Sales_Quantity,
	Profit = (p.Unit_Price - p.Unit_Cost) * s.Sales_Quantity,
	Profit_Margin = (p.Unit_Price - p.Unit_Cost) * 100.0/ p.Unit_Price
FROM Sales AS s
INNER JOIN Product AS p
	ON p.Product_Key = s.Product_Key;


OPTIONAL DATA CLEANUP
-- DELETE FROM Geography
-- WHERE Country IS NULL;
*/


