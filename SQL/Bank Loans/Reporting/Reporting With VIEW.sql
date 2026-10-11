USE Bank_Loan_DB;

SELECT * FROM CreditAuditLogs;
SELECT * FROM Customers;
SELECT * FROM LoanProducts;
SELECT * FROM Loans;
SELECT * FROM Transactions;



-- KPIS

-- Total Customers 
Create VIEW vs_customers AS
Select distinct
CustomerID ,FullName 
from Customers;

select * from vs_customers;

-- Total Services
Create VIEW vs_Products AS
Select ProductID,
productName ,
InterestRate
From LoanProducts;

****************************************************
-- Total Loans
Create VIEW vs_Loans AS
Select 
customerID,
loanID,
ProductID,
LoanAmount,
YEAR(StartDate) As YEAR
from Loans;

-- Total Paids
create VIEW vs_Transactions AS 
Select 
TransactionID,
loanID,
AmountPaid,
year(paymentDate) AS Year,
month(PaymentDate) AS Months
from Transactions;


-- Total Deficiencies
Create VIEW vs_TotalDeficiencies AS
Select 
L.LoanID,
T.TransactionID,
CAST(
( (L.LoanAmount) - (T.AmountPaid)) AS decimal(18,2)) AS AmountDeficiencies
from Loans L
join Transactions T on L.LoanID = T.LoanID;

-- Average Loans
Create VIEW vs_AVG_Loans AS
Select
loanID,
LoanAmount
from Loans;


-- Analysis 
-- Total Loans By Years
Create VIEW vs_TotalLoans_BY_Years As
Select 
LoanID,
CustomerID,
LoanAmount As TotalLoans ,
year(StartDate) As Years
from Loans;


-- Total Loans By Products
Create VIEW vs_TotalLoans_By_Products AS
Select 
L.LoanID,
L.CustomerID,
LP.ProductID,
LP.ProductName,
CAST(
(L.LoanAmount) AS decimal(18,2)) AS TotalLoans
From Loans L
join LoanProducts LP on L.ProductID = LP.ProductID;


-- Top 10 customers By Loans And Risk
create VIEW vs_Top10Customers_ByLoans_AndRisk AS
Select 
C.CustomerID, 
C.fullName,
L.LoanID,
cast(
(L.LoanAmount) as decimal(18,2)) As TotalLoans
from Customers C 
join Loans L on C.CustomerID = L.CustomerID;

-- Total Customers By Status
Create VIEW vs_TotalCustomers_By_Status AS
Select 
C.CustomerID,
L.LoanID,
L.Status
From Customers C
join Loans L on C.CustomerID = L.CustomerID


-- Total Paids by PaymentMethod
Create VIEW vs_TotalPaids_By_PaymentMethod AS
Select 
TransactionID,
loanID,
PaymentMethod,
CAST(
(AmountPaid) as decimal(18,2)) As TotalPaids
From Transactions;


-- Divide Customers By Loans
Create VIEW vs_DivideCustomers_By_Loans AS
Select 
LoanID,
CustomerID,
LoanAmount,
Case
when LoanAmount >34000 then 'VIP'
when LoanAmount = 34000 then 'Active'
else 'lowValue'
ENd As CustomerSegment
from Loans;


--Divide Customers By Loans
Create VIEW vs_Divide_Customers_By_Loans AS
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