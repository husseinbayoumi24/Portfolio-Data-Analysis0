-- 1. إنشاء قاعدة البيانات
CREATE DATABASE ECommerceDB;

-- 2. البدء في استخدامها
USE ECommerceDB;



-- 1. جدول الفئات
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX)
);

-- 2. جدول العملاء
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE,
    Phone NVARCHAR(20),
    Address NVARCHAR(255),
    City NVARCHAR(50),
    JoinDate DATE
);

-- 3. جدول المنتجات
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(100) NOT NULL,
    CategoryID INT,
    Price DECIMAL(10, 2),
    StockQuantity INT,
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryID) 
        REFERENCES Categories(CategoryID) ON DELETE SET NULL
);

-- 4. جدول الطلبات
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT,
    OrderDate DATE,
    TotalAmount DECIMAL(10, 2),
    Status NVARCHAR(20),
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID) 
        REFERENCES Customers(CustomerID) ON DELETE CASCADE
);

-- 5. جدول تفاصيل الطلب
CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT,
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(10, 2),
    CONSTRAINT FK_Details_Orders FOREIGN KEY (OrderID) 
        REFERENCES Orders(OrderID) ON DELETE CASCADE,
    CONSTRAINT FK_Details_Products FOREIGN KEY (ProductID) 
        REFERENCES Products(ProductID) ON DELETE CASCADE
);

-- 6. جدول المدفوعات
CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT,
    PaymentDate DATE,
    Amount DECIMAL(10, 2),
    PaymentMethod NVARCHAR(50),
    CONSTRAINT FK_Payments_Orders FOREIGN KEY (OrderID) 
        REFERENCES Orders(OrderID) ON DELETE CASCADE
);

-- 7. جدول الشحن
CREATE TABLE Shipping (
    ShippingID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT,
    ShippingDate DATE,
    TrackingNumber NVARCHAR(100),
    Carrier NVARCHAR(50),
    ShippingStatus NVARCHAR(20),
    CONSTRAINT FK_Shipping_Orders FOREIGN KEY (OrderID) 
        REFERENCES Orders(OrderID) ON DELETE CASCADE
);
GO