SELECT 
    *
FROM
    Categories;
SELECT 
    *
FROM
    Customers;
SELECT 
    *
FROM
    OrderDetails;
SELECT 
    *
FROM
    orders;
SELECT 
    *
FROM
    Payments;
SELECT 
    *
FROM
    Products;
SELECT 
    *
FROM
    Shipping;

-- Products Price of big to small
SELECT 
    ProductName, Price
FROM
    Products
ORDER BY price DESC;

-- Products Max > 500
SELECT 
    *
FROM
    products
WHERE
    price > 500
ORDER BY price DESC;

 -- Today Income Certain
 SELECT 
    SUM(TotalAmount) AS Total_Sales
FROM
    orders
WHERE
    OrderDate = '2024-05-01';
 
 -- لمعرفة كل طلب مين العميل اللى عمله
SELECT 
    o.orderid, c.firstname, o.TotalAmount
FROM
    orders o
        JOIN
    customers c ON o.CustomerID = c.CustomerID
ORDER BY TotalAmount DESC; 

-- استخراج قائمة بريدية للعملاء فى مدينة القاهرة 
SELECT 
    firstname, lastname, email, city
FROM
    customers
WHERE
    city = 'cairo';
 
 -- معرفة المنتجات التى على وشك الانتهاء (اقل من 10 قطع )
 select productname, stockQuantity
 from products
 where StockQuantity < 10
 order by StockQuantity asc;
 
 -- عرض المنتج ( ايفون ) الموجود فى المنتجات 
 select Productname, price 
 from products 
 where ProductName like '%iphone%'
 and CategoryID =1 ;
 
 -- عرض اخر 10 عملاء سجلو فى الموقع
 select top 10
 firstname, lastname, joindate
 from customers
 order by joindate desc;
 
 
-- indexing
create index idx_TotalAmount
on orders(TotalAmount);

create index idx_city_first_last_Name
on customers(firstname, lastname, city);

 -- Total Sales
SELECT 
    SUM(totalamount) AS Total_Revenue
FROM
    orders;

-- Orders Count
SELECT 
    COUNT(orderid) AS Orders_Count
FROM
    orders;

 -- Products Count
SELECT 
    COUNT(DISJOINT(productname)) AS Products_Count
FROM
    Products;
 
 