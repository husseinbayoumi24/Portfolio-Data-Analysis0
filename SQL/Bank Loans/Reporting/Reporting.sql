USE Bank_Loan_DB;

SELECT * FROM CreditAuditLogs;
SELECT * FROM Customers;
SELECT * FROM LoanProducts;
SELECT * FROM Loans;
SELECT * FROM Transactions;



-- KPIS

-- Total Customers 
Select Count(distinct CustomerID) AS TotalCustomers 
from Customers;

-- Total Services
Select Count(productName) As Total_Services
From LoanProducts;


-- Total Loans
Select 
CAST(
Sum(LoanAmount) As decimal(18,2)) As TotalLoans
from Loans;

-- Total Paids
Select 
CAST(
SUM(AmountPaid) As decimal(18,2)) AS TotalPaids
from Transactions;


-- Total Deficiencies
Select 
CAST(
( Sum(L.LoanAmount) - Sum(T.AmountPaid)) AS decimal(18,2)) AS TotalDeficiencies
from Loans L
join Transactions T on L.LoanID = T.LoanID;

-- Average Loans
Select
AVG(LoanAmount) AS AVG_Loans
from Loans;


-- Analysis 
-- Total Loans By Products
Select 
LP.ProductID,
LP.ProductName,
CAST(
SUM(L.LoanAmount) AS decimal(18,2)) As TotalLoans
From LoanProducts LP
join Loans L on LP.ProductID = L.ProductID
group by LP.ProductName , LP.ProductID
order by TotalLoans DESC;

-- Top 10 customers By Loans And Risk
Select Top 10
C.CustomerID, 
C.fullName,
cast(
SUM(L.LoanAmount) as decimal(18,2)) As TotalLoans
from Customers C 
join Loans L on C.CustomerID = L.CustomerID 
group by c.CustomerID,c.FullName 
order by TotalLoans DESC;


-- Total Customers By Status
Select 
COUNT(C.CustomerID) As Total_Customers,
L.Status
From Customers C
join Loans L on C.CustomerID = L.CustomerID
group By L.Status
order by Total_Customers Desc;


-- Total Paids by PaymentMethod
Select 
PaymentMethod,
CAST(
SUM(AmountPaid) as decimal(18,2)) As TotalPaids
From Transactions
group by PaymentMethod
order by TotalPaids DESC;


-- Divide Customers By Loans
Select 
LoanAmount,
Case
when LoanAmount >34000 then 'VIP'
when LoanAmount = 34000 then 'Active'
else 'lowValue'
ENd As CustomerSegment
from Loans;



Select 
C.CustomerID,
C.FullName,
L.LoanAmount,
Case
when L.LoanAmount >34000 then 'VIP'
when L.LoanAmount = 34000 then 'Active'
else 'lowValue'
ENd As CustomerSegment
from Loans L
join Customers C on L.CustomerID = C.CustomerID
order By L.LoanAmount DESC;