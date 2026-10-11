--Total Sales By Months

 -- Used VIEW
 CREATE VIEW vs_TotalSalesByMonths AS
SELECT 
    MONTH(o.OrderDate) AS MonthNumber,
    DATENAME(MONTH, o.OrderDate) AS Months,
    CAST(
        SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)) 
    AS DECIMAL(18,2)) AS TotalSales
FROM Orders o
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY 
    MONTH(o.OrderDate),
    DATENAME(MONTH, o.OrderDate);


select * from vs_TotalSalesByMonths
order by MonthNumber;


-- Total Cost by Months

 -- Used VIEW
 CREATE VIEW vs_TotalCostByMonths AS
SELECT 
    MONTH(o.OrderDate) AS MonthNumber,
    DATENAME(MONTH, o.OrderDate) AS Months,
    CAST(
        SUM(od.Quantity * p.CostPrice) 
    AS DECIMAL(18,2)) AS TotalCost
FROM Orders o 
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY 
    MONTH(o.OrderDate), 
    DATENAME(MONTH, o.OrderDate);

select * from vs_TotalCostByMonths
order by MonthNumber;



-- Total Profit By Months

-- Used VIEW
CREATE VIEW vs_TotalProfitByMonths AS
SELECT 
    MONTH(o.OrderDate) AS MonthNumber,
    DATENAME(MONTH, o.OrderDate) AS Months,
    CAST(
        SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)) 
        - SUM(od.Quantity * p.CostPrice) 
    AS DECIMAL(18,2)) AS TotalProfit
FROM Orders o
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY 
    MONTH(o.OrderDate), 
    DATENAME(MONTH, o.OrderDate);

	select * from vs_TotalProfitByMonths
	order by MonthNumber;


-- Total Sales By Categories

	CREATE VIEW vs_TotalSalesByCategory AS
SELECT 
    c.CategoryName,
    CAST(
        SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)) 
    AS DECIMAL(18,2)) AS TotalSales
FROM Products p
JOIN Categories c ON p.CategoryID = c.CategoryID
JOIN OrderDetails od ON od.ProductID = p.ProductID
GROUP BY c.CategoryName;


select * from vs_TotalSalesByCategory
order by TotalSales desc;


-- Total Sales By Products 


CREATE VIEW vs_TotalSalesByProduct AS
SELECT 
    p.ProductName,
    CAST(
        SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)) 
    AS DECIMAL(18,2)) AS TotalSales
FROM Products p
JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY p.ProductName;


SELECT * FROM vs_TotalSalesByProduct 
ORDER BY TotalSales DESC;


-- Customer Segmentation / RFM

CREATE VIEW vs_CustomerSegmentationRFM AS
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
FROM CustomerRFM;



SELECT * 
FROM vs_CustomerSegmentationRFM
ORDER BY Monetary_Value DESC;




-- Returns Analysis 

CREATE VIEW vs_ReturnsAnalysis AS
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




SELECT * FROM vs_ReturnsAnalysis;