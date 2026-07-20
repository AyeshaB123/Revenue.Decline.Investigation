

/*===========================================================================================================================================

	Project: Sales Performance Analysis
	File:    01_Data_Validation.sql
	Author:  Ayesha Batool

	DESCRIPTION:
	This script prepares the database for analysis by:
	1. Creating foreign key constraints
	2. Performing data quality validation
	3. Adding financial metrics (Revenue, Cost, Profit, Profit Margin)

============================================================================================================================================== */


USE Sales
GO


/*=============================================================================================================================================
												1. CREATE FOREIGN KEY CONSTRAINTS
=============================================================================================================================================== */


-- Establish relationships between fact and dimension tables to enforce referential integrity throughout the data model.

-- Fact Table Relationships

ALTER TABLE Sales
ADD CONSTRAINT FK_Sales_Calendar
FOREIGN KEY (Date_Key)
REFERENCES Calendar(Date_Key);
GO

ALTER TABLE Sales
ADD CONSTRAINT FK_Sales_Product
FOREIGN KEY (Product_Key)
REFERENCES Product(Product_Key);
GO

ALTER TABLE Sales
ADD CONSTRAINT FK_Sales_Store
FOREIGN KEY (Store_Key)
REFERENCES Store(Store_Key);
GO

-- Snowflake Dimension Relationships

ALTER TABLE Store
ADD CONSTRAINT FK_Store_Geography
FOREIGN KEY (Geography_Key)
REFERENCES Geography(Geography_Key);
GO

ALTER TABLE Product
ADD CONSTRAINT FK_Product_ProductSubcategory
FOREIGN KEY (Product_Subcategory_Key)
REFERENCES Product_Subcategory(Product_Subcategory_Key);
GO

ALTER TABLE Product_Subcategory
ADD CONSTRAINT FK_ProductSubcategory_ProductCategory
FOREIGN KEY (Product_Category_Key)
REFERENCES Product_Category(Product_Category_Key);
GO


/*=============================================================================================================================================
													2. DATA QUALITY VALIDATION
=============================================================================================================================================== */


-- Verify imported row counts

SELECT COUNT(*) AS Sales_Count
FROM Sales;

SELECT COUNT(*) AS Product_Count
FROM Product;

SELECT COUNT(*) AS Product_Subcategory_Count
FROM Product_Subcategory;

SELECT COUNT(*) AS Product_Category_Count
FROM Product_Category;

SELECT COUNT(*) AS Calendar_Count
FROM Calendar;

SELECT COUNT(*) AS Store_Count
FROM Store;

SELECT COUNT(*) AS Geography_Count
FROM Geography;

-- Check for invalid sales quantities

SELECT *
FROM Sales
WHERE Sales_Quantity <= 0;

-- Check for invalid product price

SELECT *
FROM Product
WHERE Unit_Price <= 0;

-- Check for invalid product cost

SELECT *
FROM Product
WHERE Unit_Cost < 0;


/*=============================================================================================================================================
													3. ADD CALCULATED COLUMNS
===============================================================================================================================================*/


-- Add financial metrics

ALTER TABLE Sales
ADD Cost DECIMAL(10,2),
	Revenue DECIMAL(10,2),
	Profit DECIMAL(10,2),
	Profit_Margin DECIMAL(10,2);

UPDATE s
SET Cost			= p.Unit_Cost * s.Sales_Quantity, 
	Revenue			= p.Unit_Price * s.Sales_Quantity,
	Profit			= (p.Unit_Price - p.Unit_Cost) * s.Sales_Quantity,
	Profit_Margin	= (p.Unit_Price - p.Unit_Cost) * 100.0/ p.Unit_Price
FROM Sales AS s
INNER JOIN Product AS p
	ON p.Product_Key = s.Product_Key;

-- Verify financial metrics populated successfully.
SELECT TOP 10 *
FROM Sales;
GO


/*=============================================================================================================================================
													OPTIONAL DATA CLEANUP
===============================================================================================================================================*/

-- DELETE FROM Geography
-- WHERE Country IS NULL;

