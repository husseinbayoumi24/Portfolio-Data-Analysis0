Use ECommerce_DB;

SELECT * from Categories;
SELECT * from Customers;
select * from OrderDetails;
select * from orders;
select * from Payments;
select * from Products;
SELECT * from Shipping;

-- indexs
create index idx_Quantity_UnitPrice 
on orderdetails (quantity , UnitPrice);


-- KPIS
--Total Customers
select Count(customerid) as Total_Customers 
from Customers;

-- Total Sales 
select SUM( quantity * unitprice) as Total_Revenue
from OrderDetails;

select sum(TotalAmount) as Total_Revenue
from Orders;

-- Total Orders
Select distinct count(orderid) as Total_Orders
from orders;

-- Average Sales
Select AVG(TotalAmount) As AVG_Sales
from orders;

-- Total Products
Select Count(productname) as Total_Products
from Products;


-- عرض المنتجات الاكثر مبيعا
select top 10
p.productname, c.categoryname,
SUM(p.stockquantity * p.price) AS Total_Revenue
from products p
join categories c on p.CategoryID = c.CategoryID
group by p.ProductName , c.CategoryName
order by Total_Revenue desc;

-- العملاء التى لم يقومون بأى طلب
select firstname, lastname, email, city
from customers
where CustomerID not in(select CustomerID from orders);

-- ملخص العملاء لكل مدينة
select city, count(customerid) as Total_Customers
from customers
group by city
order by total_customers desc;

-- ملخص الطلبات لكل مدينة
select c.city, count(c.customerid) as Total_Customers , 
COUNT(o.orderid) As Total_Orders , SUM(o.TotalAmount) As Total_Revenue
from Orders o 
join customers c on o.CustomerID = c.CustomerID
group by c.City
order by Total_Revenue desc;

-- Total Sales By city
create view Total_Sales_By_City as
select c.city, sum(o.totalamount) As Total_Sales
from customers c
join orders o on c.CustomerID = o.CustomerID
group by c.city;
GO

select * from Total_Sales_By_city order by Total_Sales;

-- Monthly Revenue
create view Monthly_Revenue as
select 
format(orderdate, 'yyyy-MM') as Month,
count(orderid) as TotalOrders,
sum(totalamount) as MonthlyRevenue
from orders
group by format(orderdate, 'yyyy-MM');
GO

select * from Monthly_Revenue order by month desc;

-- Sales By category
create view SalesByCategory as
select 
c.categoryname,
sum(od.Quantity) as UnitsSold,
sum(od.quantity * od.unitprice) as CategoryRevenue
from orderdetails od
join products p on od.ProductID = p.ProductID
join categories c on p.CategoryID = c.CategoryID
group by c.CategoryName;
GO

select * from SalesByCategory order by CategoryRevenue desc;

-- حالة الشحن والطلبات المتاخرة
select ShippingStatus,
count(shippingid) As TotalPackets,
Carrier
from shipping
group by ShippingStatus, Carrier;

-- تصنيف العملاء على حسب الانفاق
with customerSpending As (
select 
(c.firstname + ' ' + c.lastname) AS CustomerName,
sum(o.TotalAmount) AS TotalSpent
from customers c 
join orders o on c.CustomerID = o.CustomerID
group by c.FirstName, c.LastName
)
select
CustomerName, 
TotalSpent,
Case
when TotalSpent > 2000 Then 'VIP Cuatomer'
when TotalSpent between 1000 and 2000 Then 'Loyal Customer'
Else 'Regular Customer'
End As CustomerSegment
From CustomerSpending
order by TotalSpent desc;