SELECT * from Categories;
SELECT * from Customers;
select * from OrderDetails;
select * from orders;
select * from Payments;
select * from Products;
SELECT * from Shipping;


-- غيّر اسم الجدول هنا فقط ⬇️
DECLARE @TableName NVARCHAR(128) = 'shipping'; 

DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = @SQL + 'SUM(CASE WHEN [' + column_name + '] IS NULL THEN 1 ELSE 0 END) AS [' + column_name + '_Nulls], '
FROM information_schema.columns
WHERE table_name = @TableName;

SET @SQL = 'SELECT ' + LEFT(@SQL, LEN(@SQL) - 1) + ' FROM [' + @TableName + ']';

EXEC sp_executesql @SQL;


   SELECT * FROM Shipping
WHERE TrackingNumber = 'Null'
   OR ShippingDate = 'Null';

   DELETE FROM Shipping
WHERE TrackingNumber = 'Null'
   OR ShippingDate = 'Null';



