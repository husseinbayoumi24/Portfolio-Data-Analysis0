use RetailAnalyticsDB;

select * from Categories;
Select * from Customers;
select * from orders;
select * from OrderDetails;
select * from Products;

-- Total Sales By Months 
 select MONTH(o.OrderDate) AS MonthNumber,
 DATENAME(month, o.orderdate) As months,
FORMAT(
 SUM(od.quantity * p.unitprice * (1- od.discount)),'N2') as TotalSales
 from Orders o
 join OrderDetails od on o.OrderID = od.OrderID
 join Products p on od.ProductID = p.ProductID
 group by MONTH(o.OrderDate),
 DATENAME(month, o.orderdate)
 order by MonthNumber;


 -- Total Cost By Months
 select MONTH(o.orderdate) as MonthNumber,
 DATENAME(MONTH, o.orderdate) as Months,
 FORMAT(
 SUM(od.quantity * p.CostPrice),'N2') As TotalCost
 from Orders o 
 join OrderDetails od on o.OrderID = od.OrderID
 join Products p on od.ProductID = p.ProductID
 group by MONTH(o.orderdate), DATENAME(Month, o.orderdate)
 order by MonthNumber;


 -- Total Profit by Months
 Select 
 MONTH(o.orderdate) as MonthNumber,
 DATENAME(MONTH, o.orderdate) as Months,
 FORMAT( SUM(od.quantity * p.unitprice * (1- od.discount)) 
 - SUM(od.quantity * p.CostPrice),'N2') AS TotalProfit
 from Orders o
 join OrderDetails od on o.OrderID = od.OrderID
 join Products p on od.ProductID = p.ProductID
group by MONTH(o.orderdate), DATENAME(Month, o.orderdate)
 order by MonthNumber;



-- Total Sales By Categories
select
c.CategoryName,
FORMAT(
 SUM(od.quantity * p.unitprice * (1- od.discount)),'N2') as TotalSales
 from Products p
 join Categories c on p.CategoryID = c.CategoryID
 join OrderDetails od on od.ProductID = p.ProductID
 group by c.CategoryName 
 order by TotalSales desc;

 -- Total Sales By Products
 select p.productName,
FORMAT(
 SUM(od.quantity * p.unitprice * (1- od.discount)),'N2') as TotalSales
from Products p
join OrderDetails od on p.ProductID = od.ProductID
group by p.ProductName
order By TotalSales desc;

-- Customer Segmentation / RFM
WITH CustomerRFM AS (
    SELECT 
        o.CustomerID,
        DATEDIFF(DAY, MAX(o.OrderDate), (SELECT MAX(OrderDate) FROM Orders)) AS Recency_Days,
        COUNT(DISTINCT o.OrderID) AS Frequency_Orders,
        CAST(SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)) AS DECIMAL(18,2)) AS Monetary_Value
    FROM Orders o
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
    WHERE o.OrderStatus NOT IN ('Cancelled', 'Returned')
    GROUP BY o.CustomerID
)
SELECT 
    CustomerID,
    Recency_Days,
    Frequency_Orders,
    Monetary_Value,
    CASE 
        WHEN Monetary_Value >= 10000 AND Frequency_Orders >= 5 THEN 'VIP / Champions'
        WHEN Recency_Days <= 30 THEN 'Active Customers'
        WHEN Recency_Days > 180 THEN 'At Risk / Churned'
        ELSE 'Regular Customers'
    END AS CustomerSegment
FROM CustomerRFM
ORDER BY Monetary_Value DESC;


-- Returns Analysis 
SELECT 
    COUNT(DISTINCT o.OrderID) AS TotalAllOrders,
    COUNT(DISTINCT CASE WHEN o.OrderStatus = 'Returned' THEN o.OrderID END) AS ReturnedOrdersCount,
    CAST(
        SUM(CASE WHEN o.OrderStatus = 'Returned' THEN od.Quantity * p.UnitPrice * (1 - od.Discount) ELSE 0 END) 
    AS DECIMAL(18,2)) AS LostRevenueDueToReturns,
    CAST(
        (COUNT(DISTINCT CASE WHEN o.OrderStatus = 'Returned' THEN o.OrderID END) * 100.0 / NULLIF(COUNT(DISTINCT o.OrderID), 0)) 
    AS DECIMAL(5,2)) AS ReturnRatePercentage
FROM Orders o
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID;
