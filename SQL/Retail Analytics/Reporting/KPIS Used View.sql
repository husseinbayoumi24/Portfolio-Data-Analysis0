use RetailAnalyticsDB;

select * from Categories;
Select * from Customers;
select * from orders;
select * from OrderDetails;
select * from Products;


-- Slicer Year
create VIEW vs_Year as
Select distinct Year( OrderDate) as Year
from orders;

Select * from vs_Year;


-- Slicer City
Create VIEW vs_City AS
Select Distinct city 
From Customers;

Select * from vs_City;


-- Slicer Order Status
Create VIEW vs_OrderStatus AS
Select Distinct OrderStatus
from Orders;

select * From vs_OrderStatus;


--Slicer Products
Create VIEW vs_ProductName AS
Select ProductName 
From Products;

Select * From vs_ProductName;




-- KPIS

-- Total Customers
CREATE VIEW vs_TotalCustomers AS
SELECT COUNT(*) AS TotalCustomers 
FROM Customers;

SELECT * FROM vs_TotalCustomers;

-- Total Categories
CREATE VIEW vs_TotalCategories AS
SELECT COUNT(*) AS TotalCategories 
FROM Categories;

SELECT * FROM vs_TotalCategories;

-- Total Products
CREATE VIEW vs_TotalProducts AS
SELECT COUNT(*) AS TotalProducts 
FROM Products;

SELECT * FROM vs_TotalProducts;


-- Total Orders
CREATE VIEW vs_TotalOrders AS
SELECT COUNT(OrderID) AS TotalOrders 
FROM Orders;

SELECT * FROM vs_TotalOrders;


-- Total Sales
CREATE VIEW vs_TotalSales AS
SELECT 
    CAST(SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)) AS DECIMAL(18,2)) AS TotalSales
FROM OrderDetails od
JOIN Products p ON od.ProductID = p.ProductID;

SELECT * FROM vs_TotalSales;


-- Total Cost
CREATE VIEW vs_TotalCost AS
SELECT 
    CAST(SUM(od.Quantity * p.CostPrice) AS DECIMAL(18,2)) AS TotalCost
FROM Products p
JOIN OrderDetails od ON p.ProductID = od.ProductID;

SELECT * FROM vs_TotalCost;


-- Total Profit
CREATE VIEW vs_TotalProfits AS
SELECT 
    CAST(
        SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)) - SUM(od.Quantity * p.CostPrice) 
    AS DECIMAL(18,2)) AS TotalProfits
FROM Products p
JOIN OrderDetails od ON p.ProductID = od.ProductID;

SELECT * FROM vs_TotalProfits;


-- Profit Margin
CREATE VIEW vs_ProfitMargin AS
SELECT 
    CAST(
        (
            (SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)) - SUM(od.Quantity * p.CostPrice)) 
            / NULLIF(SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)), 0)
        ) * 100 
    AS DECIMAL(5,2)) AS ProfitMarginPercentage
FROM OrderDetails od
JOIN Products p ON od.ProductID = p.ProductID;

SELECT * FROM vs_ProfitMargin;




-- PY Sales
CREATE VIEW vs_PYSales AS
WITH YearlySales AS (
    SELECT 
        YEAR(o.OrderDate) AS SalesYear,
        SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)) AS CurrentYearSales
    FROM Orders o
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
    GROUP BY YEAR(o.OrderDate)
)
SELECT 
    SalesYear,
    CAST(CurrentYearSales AS DECIMAL(18,2)) AS CurrentYearSales,
    CAST(LAG(CurrentYearSales, 1) OVER (ORDER BY SalesYear) AS DECIMAL(18,2)) AS PYSales
FROM YearlySales;


SELECT * FROM vs_PYSales ORDER BY SalesYear;


-- YOY Sales
CREATE VIEW vs_YOYSales AS
WITH YearlySales AS (
    SELECT 
        YEAR(o.OrderDate) AS SalesYear,
        SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)) AS CurrentYearSales
    FROM Orders o
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
    GROUP BY YEAR(o.OrderDate)
),
SalesWithPY AS (
    SELECT 
        SalesYear,
        CurrentYearSales,
        LAG(CurrentYearSales, 1) OVER (ORDER BY SalesYear) AS PYSales
    FROM YearlySales
)
SELECT 
    SalesYear,
    CAST(CurrentYearSales AS DECIMAL(18,2)) AS CY_Sales,
    CAST(PYSales AS DECIMAL(18,2)) AS PY_Sales,
    CAST(
        ((CurrentYearSales - PYSales) / NULLIF(PYSales, 0)) * 100 
    AS DECIMAL(5,2)) AS YoY_Sales_Growth_Percentage
FROM SalesWithPY;


SELECT * FROM vs_YOYSales ORDER BY SalesYear;
