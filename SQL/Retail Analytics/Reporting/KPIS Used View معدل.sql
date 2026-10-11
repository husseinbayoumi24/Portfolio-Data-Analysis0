-- 1. Slicer Customers & Cities (يحتوي على CustomerID و City)
CREATE VIEW vs_City AS
SELECT DISTINCT 
    CustomerID,
    City
FROM Customers
WHERE City IS NOT NULL;

SELECT * FROM vs_City;


-- 2. Slicer Products (يحتوي على ProductID و CategoryID)
CREATE VIEW vs_ProductName AS
SELECT 
    ProductID,
    ProductName,
    CategoryID
FROM Products;

SELECT * FROM vs_ProductName;


-- 3. Slicer Orders & Status (يحتوي على OrderID و CustomerID و OrderStatus)
CREATE VIEW vs_OrderStatus AS
SELECT DISTINCT 
    OrderID,
    CustomerID,
    OrderStatus
FROM Orders;

SELECT * FROM vs_OrderStatus;


-- 4. Slicer Date / Year (يحتوي على OrderDate كـ Primary Key للتقويم)
CREATE VIEW vs_Year AS
SELECT DISTINCT 
    OrderDate,
    YEAR(OrderDate) AS Year,
    MONTH(OrderDate) AS MonthNumber,
    DATENAME(MONTH, OrderDate) AS MonthName
FROM Orders;

SELECT * FROM vs_Year ORDER BY OrderDate;



-- Total Customers (مفصل للربط مع العملاء والمدن)
CREATE VIEW vs_TotalCustomers AS
SELECT 
    CustomerID,
    City,
    CustomerName
FROM Customers;

SELECT * FROM vs_TotalCustomers;


-- Total Categories
CREATE VIEW vs_TotalCategories AS
SELECT 
    CategoryID,
    CategoryName
FROM Categories;

SELECT * FROM vs_TotalCategories;


-- Total Products
CREATE VIEW vs_TotalProducts AS
SELECT 
    ProductID,
    ProductName,
    CategoryID,
    UnitPrice,
    CostPrice
FROM Products;

SELECT * FROM vs_TotalProducts;


-- Total Orders (تفاصيل الطلب للربط مع الفلاتر والتقويم)
CREATE VIEW vs_TotalOrders AS
SELECT 
    OrderID,
    CustomerID,
    OrderDate,
    YEAR(OrderDate) AS OrderYear,
    OrderStatus
FROM Orders;

SELECT * FROM vs_TotalOrders;


-- Total Sales (مفصلة على مستوى تفاصيل الطلب للربط مع المنتجات والطلبات)
CREATE VIEW vs_TotalSales AS
SELECT 
    od.OrderID,
    od.ProductID,
    o.CustomerID,
    o.OrderDate,
    YEAR(o.OrderDate) AS SalesYear,
    o.OrderStatus,
    c.City,
    CAST(SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)) AS DECIMAL(18,2)) AS TotalSales
FROM OrderDetails od
JOIN Products p ON od.ProductID = p.ProductID
JOIN Orders o ON od.OrderID = o.OrderID
JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY od.OrderID, od.ProductID, o.CustomerID, o.OrderDate, YEAR(o.OrderDate), o.OrderStatus, c.City;

SELECT * FROM vs_TotalSales;


-- Total Cost (مفصلة للربط مع الأبعاد)
CREATE VIEW vs_TotalCost AS
SELECT 
    od.OrderID,
    od.ProductID,
    o.CustomerID,
    o.OrderDate,
    YEAR(o.OrderDate) AS SalesYear,
    o.OrderStatus,
    c.City,
    CAST(SUM(od.Quantity * p.CostPrice) AS DECIMAL(18,2)) AS TotalCost
FROM OrderDetails od
JOIN Products p ON od.ProductID = p.ProductID
JOIN Orders o ON od.OrderID = o.OrderID
JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY od.OrderID, od.ProductID, o.CustomerID, o.OrderDate, YEAR(o.OrderDate), o.OrderStatus, c.City;

SELECT * FROM vs_TotalCost;


-- Total Profit (مفصل للربط التفاعلي)
CREATE VIEW vs_TotalProfits AS
SELECT 
    od.OrderID,
    od.ProductID,
    o.CustomerID,
    o.OrderDate,
    YEAR(o.OrderDate) AS SalesYear,
    o.OrderStatus,
    c.City,
    CAST(
        SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)) - SUM(od.Quantity * p.CostPrice) 
    AS DECIMAL(18,2)) AS TotalProfits
FROM OrderDetails od
JOIN Products p ON od.ProductID = p.ProductID
JOIN Orders o ON od.OrderID = o.OrderID
JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY od.OrderID, od.ProductID, o.CustomerID, o.OrderDate, YEAR(o.OrderDate), o.OrderStatus, c.City;

SELECT * FROM vs_TotalProfits;


-- Profit Margin (مفصل حسب أبعاد التحليل)
CREATE VIEW vs_ProfitMargin AS
SELECT 
    od.OrderID,
    od.ProductID,
    o.CustomerID,
    o.OrderDate,
    YEAR(o.OrderDate) AS SalesYear,
    o.OrderStatus,
    c.City,
    CAST(
        (
            (SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)) - SUM(od.Quantity * p.CostPrice)) 
            / NULLIF(SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)), 0)
        ) * 100 
    AS DECIMAL(5,2)) AS ProfitMarginPercentage
FROM OrderDetails od
JOIN Products p ON od.ProductID = p.ProductID
JOIN Orders o ON od.OrderID = o.OrderID
JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY od.OrderID, od.ProductID, o.CustomerID, o.OrderDate, YEAR(o.OrderDate), o.OrderStatus, c.City;

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
