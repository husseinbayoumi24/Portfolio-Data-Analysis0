select * from Categories;
select * from Customers;
select * from Products;
select * from OrderDetails;
select * from Orders;


select 'customers' as Table_Name , count(*) as Total_Rows from customers
union all 
select 'categories' , count(*) from Categories
union all
select 'proucts' , count(*) from Products
union all
select 'orderdetails' , count(*) from OrderDetails
union all 
select 'orders' , count(*) from orders;



-- كود معالجة وتوحيد النصوص
select UPPER(City) from Customers;

SELECT UPPER(LEFT(TRIM(CITY),1)) + LOWER(SUBSTRING(TRIM(CITY),2,LEN(CITY))) AS CLEAN_CITY
FROM CUSTOMERS;

SELECT UPPER(LEFT(TRIM(OrderStatus
),1)) + LOWER(SUBSTRING(TRIM(OrderStatus),2,LEN(OrderStatus))) AS CLEAN_OrderStatus
FROM Orders;


 -- تحديث البيانات 

 UPDATE Customers
 SET CITY = UPPER(LEFT(TRIM(CITY),1)) + LOWER(SUBSTRING(TRIM(CITY),2,LEN(CITY)))
 WHERE CITY IS NOT NULL ;

 SELECT * FROM CUSTOMERS;


  UPDATE Orders
 SET OrderStatus
 = UPPER(LEFT(TRIM(OrderStatus ),1)) + LOWER(SUBSTRING(TRIM(OrderStatus ),2,LEN(OrderStatus )))
 WHERE OrderStatus IS NOT NULL ;






 SELECT * FROM CUSTOMERS
 WHERE EMAIL IS NULL;


SELECT 
    COUNT(*) - COUNT(CustomerID) AS Null_CUSTOMERID,
    COUNT(*) - COUNT(CustomerName) AS Null_CUSTOMERNAME,
    COUNT(*) - COUNT(Email) AS Null_EMAIL,
    COUNT(*) - COUNT(City) AS Null_CITY,
	COUNT(*) - COUNT(SIGNUPDATE) AS NULL_SIGNUPDATE
FROM Customers;

-- كود استبدال القيم المفقودة بنص 

 SELECT 
    CustomerID,
    CustomerName,
    ISNULL(Email, 'No Email Provided') AS CleanEmail,
    City
FROM Customers;

-- تحديث البيانات 
UPDATE Customers
SET Email = 'No Email Provided'
WHERE Email IS NULL;

SELECT * FROM Customers;


-- كود تنظيف القيم الشاذة والكميات السالبة
SELECT *
FROM OrderDetails
WHERE Quantity > 0 AND Quantity <= 100;


SELECT 
    COUNT(*) AS Total_Outliers,
    SUM(CASE WHEN Quantity <= 0 THEN 1 ELSE 0 END) AS Negative_Or_Zero_Qty,
    SUM(CASE WHEN Quantity > 100 THEN 1 ELSE 0 END) AS Extremely_High_Qty
FROM OrderDetails
WHERE Quantity <= 0 OR Quantity > 100;


SELECT COUNT(*) AS Total_Outliers FROM OrderDetails WHERE Quantity <= 0 OR Quantity > 100;

UPDATE OrderDetails
SET Quantity = CASE 
    -- 1. إذا كانت الكمية أقل من أو تساوي صفر، استبدلها بـ 1
    WHEN Quantity <= 0 THEN 1 
    
    -- 2. إذا كانت الكمية أضخم من الحد المنطقي (أكبر من 100)، اضبطها عند 100
    WHEN Quantity > 100 THEN 100 
    
    -- 3. اترك باقي القيم كما هي
    ELSE Quantity 
END
WHERE Quantity <= 0 OR Quantity > 100;


-- عدد التعارض الزمنى 
SELECT COUNT(*) AS Total_Date_Conflicts
FROM Orders
WHERE ShipDate < OrderDate;

-- عرض التعارض الزمنى
SELECT 
    OrderID,
    CustomerID,
    OrderDate,
    ShipDate,
    OrderDate AS CorrectedShipDate -- جعل تاريخ الشحن مساوياً لتاريخ الطلب كحل منطقي
FROM Orders
WHERE ShipDate < OrderDate;



-- تحديث ييانات التعارض 
UPDATE Orders
SET ShipDate = OrderDate
WHERE ShipDate < OrderDate;



-- كود حذف التكرارات مع الإبقاء على سجل واحد فقط
WITH CTE_Duplicates AS (
    SELECT 
        OrderID,
        CustomerID,
        OrderDate,
        ROW_NUMBER() OVER (PARTITION BY OrderID ORDER BY OrderDate DESC) AS RowNum
    FROM Orders
)
DELETE FROM CTE_Duplicates
WHERE RowNum > 1;




-- معرفة عدد التكرارات
WITH CTE_Duplicates AS (
    SELECT 
        OrderID,
        ROW_NUMBER() OVER (PARTITION BY OrderID ORDER BY OrderDate DESC) AS RowNum
    FROM Orders
)
SELECT COUNT(*) AS Total_Duplicates
FROM CTE_Duplicates
WHERE RowNum > 1;


-- تحديث البيانات 
WITH CTE_Duplicates AS (
    SELECT 
        OrderID,
        CustomerID,
        OrderDate,
        ROW_NUMBER() OVER (PARTITION BY OrderID ORDER BY OrderDate DESC) AS RowNum
    FROM Orders
)
DELETE FROM CTE_Duplicates
WHERE RowNum > 1;




