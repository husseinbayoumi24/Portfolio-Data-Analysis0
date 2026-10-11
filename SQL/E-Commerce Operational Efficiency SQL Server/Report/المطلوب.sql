SELECT * from sqlite_sequence;
SELECT * from Categories;
SELECT * from Customers;
select * from OrderDetails;
select * from orders;
select * from Payments;
select * from Products;
SELECT * from Shipping;

 -- Total Sales
select sum(totalamount) AS Total_Revenue
from orders; 

-- Orders Count
select count(orderid) As Orders_Count
from orders;




















