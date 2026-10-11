use RetailAnalyticsDB;

select * from Categories;
Select * from Customers;
select * from orders;
select * from OrderDetails;
select * from Products;

-- KPIS

-- Total Customers
select COUNT(*) As TotalCustomers 
from Customers;

-- Total Categories
select COUNT(*) as TotalCategories
from Categories;

-- Total Products
select COUNT(*) as TotalProducts
from Products;

-- Total Orders
select COUNT(OrderID) as TotalOrders
from orders;
-- Total Sales
select cast(sum(od.quantity * p.unitPrice * (1- od.discount)) as decimal(18,2)) as TotalSales
from OrderDetails od
join Products p on od.ProductID = p.ProductID
;

-- Total Cost
select cast( sum(od.quantity * p.costprice ) as decimal(18,2)) as TotalCost
from products p
join OrderDetails od on p.ProductID = od.ProductID;


-- Total Profits
select cast(
sum(od.quantity * p.unitPrice * (1- od.discount)) 
- sum(od.quantity * p.costprice ) as decimal(18,2)) as TotalProfits
from products p
join OrderDetails od on p.ProductID = od.ProductID;

-- Profit Margin
SELECT 
    CAST(
        (
            (SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)) - SUM(od.Quantity * p.CostPrice)) 
            / NULLIF(SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)), 0)
        ) * 100 
    AS DECIMAL(5,2)) AS ProfitMarginPercentage
FROM OrderDetails od
JOIN Products p ON od.ProductID = p.ProductID;

-- PY Sales
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
    -- دالة LAG تجلب قيمة السنة السابقة
    CAST(LAG(CurrentYearSales, 1) OVER (ORDER BY SalesYear) AS DECIMAL(18,2)) AS PYSales
FROM YearlySales;

-- YOY Sales
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


