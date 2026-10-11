USE Bank_Loan_DB;

SELECT * FROM CreditAuditLogs;
SELECT * FROM Customers;
SELECT * FROM LoanProducts;
SELECT * FROM Loans;
SELECT * FROM Transactions;


-- توحيد الحروف 
select UPPER(riskcategory) from creditauditlogs;

update CreditAuditLogs
set RiskCategory = UPPER(RiskCategory);




-- معرفة النلل وعددهم 

DECLARE @TableName NVARCHAR(128) = 'Customers'; 

DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = @SQL + 'SUM(CASE WHEN [' + column_name + '] IS NULL THEN 1 ELSE 0 END) AS [' + column_name + '_Nulls], '
FROM information_schema.columns
WHERE table_name = @TableName;

SET @SQL = 'SELECT ' + LEFT(@SQL, LEN(@SQL) - 1) + ' FROM [' + @TableName + ']';

EXEC sp_executesql @SQL;


-- تنظيف الفراغات 
Update Customers
set FullName = TRIM(FullName)
where FullName is not null;

-- تنظيف ال Null
UPDATE Customers
SET FullName = 'Unknown Customer'
WHERE FullName IS NULL OR FullName = '';

-- معرفة ال null
select * 
from Customers
where AnnualIncome is null;

--  تحديث البيانات

update Customers
set AnnualIncome = '0'
where AnnualIncome is null;




-- 1. اكتشاف الأيتام وتحديثها برقم عميل افتراضي (مثلاً العميل رقم 1 المخصص للحالات غير المعروفة)
-- سنفترض وجود عميل عام باسم Unknown
IF NOT EXISTS (SELECT 1 FROM Customers WHERE CustomerID = -1)
BEGIN
    INSERT INTO Customers (CustomerID, FullName, NationalID, BirthDate, AnnualIncome, CreditScore, CreatedAt)
    VALUES (-1, 'System Unmapped Customer', '00000000000000', '1900-01-01', 0, 300, GETDATE());
END

UPDATE Loans
SET CustomerID = -1
WHERE CustomerID NOT IN (SELECT CustomerID FROM Customers);




-- تصحيح الدخل السنوي السالب بتحويله لموجب (لو كان خطأ إدخال) أو وضع قيمة الوسيط
UPDATE Customers
SET AnnualIncome = ABS(AnnualIncome)
WHERE AnnualIncome < 0;

-- معالجة درجات الائتمان الـ Outliers
UPDATE Customers
SET CreditScore = 300 WHERE CreditScore < 300;

UPDATE Customers
SET CreditScore = 850 WHERE CreditScore > 850;

-- تصحيح مدة القرض السلبية
UPDATE Loans
SET TermMonths = ABS(TermMonths)
WHERE TermMonths < 0;




UPDATE Loans
SET Status = UPPER(TRIM(Status));

UPDATE Loans
SET Status = 'ACTIVE'
WHERE Status IN ('ACTIVE', 'ACTIVE ');


-- حظر أو تصحيح تواريخ المعاملات التي تمت قبل بدء القرض نفسه
DELETE T
FROM Transactions T
INNER JOIN Loans L ON T.LoanID = L.LoanID
WHERE T.PaymentDate < L.StartDate;


