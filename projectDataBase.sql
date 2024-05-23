USE master;
GO

CREATE DATABASE projectAW2017;
GO

USE projectAW2017;
GO

CREATE TABLE SalesOrderHeader
(
SalesOrderID INT NOT NULL
CONSTRAINT projectAW2017_SalesOrderID_PK PRIMARY KEY (SalesOrderID),
RevisionNumber TINYINT NOT NULL
CONSTRAINT projectAW2017_RevisionNum_DE DEFAULT 0,
OrderDate DATETIME NOT NULL
CONSTRAINT projectAW2017_OrderDate_DE DEFAULT (getdate()),
DueDate DATETIME NOT NULL,
ShipDate DATETIME,
Status TINYINT NOT NULL
CONSTRAINT projectAW2017_Status_DE DEFAULT 1,
OnlineOrderFlag BIT NOT NULL
CONSTRAINT projectAW2017_OnlineOrderFlag_DE DEFAULT 1,
SalesOrderNumber AS ISNULL(N'SO' + CONVERT(NVARCHAR(23), SalesOrderID), N'*** ERROR ***'),
PurchaseOrderNumber NVARCHAR(25),
AccountNumber NVARCHAR(15),
CustomerId INT NOT NULL,
SalesPersonID INT,
TerritoryID INT,
BillToAddressID INT NOT NULL,
ShipToAddressID INT NOT NULL,
ShipMethodID INT NOT NULL,
CreditCardID INT,
CreditCardApprovalCode VARCHAR(15),
CurrencyRateID INT,
SubTotal MONEY NOT NULL
CONSTRAINT projectAW2017_SubTotal_DE DEFAULT 0.00,
TaxAmt MONEY NOT NULL
CONSTRAINT projectAW2017_TaxAmt_DE DEFAULT 0.00,
Freight MONEY NOT NULL
CONSTRAINT projectAW2017_Freight_DE DEFAULT 0.00
);
GO

INSERT INTO SalesOrderHeader
(
SalesOrderID, RevisionNumber, 
OrderDate, DueDate, ShipDate,
Status, OnlineOrderFlag, PurchaseOrderNumber, AccountNumber,
CustomerId, SalesPersonID, TerritoryID, 
BillToAddressID, ShipToAddressID, ShipMethodID,
CreditCardID, CreditCardApprovalCode, 
CurrencyRateID, SubTotal, TaxAmt, Freight
)
SELECT TOP 20
SalesOrderID, RevisionNumber, 
OrderDate, DueDate, ShipDate,
Status, OnlineOrderFlag, PurchaseOrderNumber, AccountNumber,
CustomerId, SalesPersonID, TerritoryID, 
BillToAddressID, ShipToAddressID, ShipMethodID,
CreditCardID, CreditCardApprovalCode, 
CurrencyRateID, SubTotal, TaxAmt, Freight
FROM AdventureWorks2017.Sales.SalesOrderHeader
ORDER BY SalesOrderID;
GO


CREATE TABLE SalesOrderDetail
(
SalesOrderID INT NOT NULL 
CONSTRAINT projectAW2017_SalesOrderID_FK FOREIGN KEY (SalesOrderID) REFERENCES SalesOrderHeader(SalesOrderID),
SalesOrderDetailID INT NOT NULL
CONSTRAINT projectAW2017_SalesOrderDetID_PK PRIMARY KEY (SalesOrderID, SalesOrderDetailID),
CarrierTrackingNumber NVARCHAR(25),
OrderQty SMALLINT NOT NULL,
ProductID INT NOT NULL,
SpecialOfferID INT NOT NULL,
UnitPrice MONEY NOT NULL, 
UnitPriceDiscount MONEY NOT NULL
CONSTRAINT projectAW2017_UnitPriceDiscount_DE DEFAULT 0,
LineTotal AS ISNULL((UnitPrice * (1.0 - UnitPriceDiscount)) * OrderQty, 0.0),
rowguid UNIQUEIDENTIFIER NOT NULL 
CONSTRAINT projectAW2017_rowguid_DE DEFAULT (newid()),
ModifiedDate DATETIME NOT NULL 
CONSTRAINT projectAW2017_ModifiedDate_DE DEFAULT (getdate())
);
GO

INSERT INTO SalesOrderDetail 
(
SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber, OrderQty, ProductID, 
SpecialOfferID, UnitPrice, UnitPriceDiscount, rowguid, ModifiedDate
)
SELECT TOP 20
SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber, OrderQty, ProductID, 
SpecialOfferID, UnitPrice, UnitPriceDiscount, rowguid, ModifiedDate
FROM AdventureWorks2017.Sales.SalesOrderDetail
ORDER BY SalesOrderID;
GO

CREATE TABLE SpecialOfferProduct
(
SpecialOfferID INT NOT NULL,
ProductID INT NOT NULL,
rowguid UNIQUEIDENTIFIER NOT NULL
CONSTRAINT projectAW2017_rowguidSpecialOfferProduct_DE DEFAULT (NEWID()),
ModifiedDate DATETIME NOT NULL
CONSTRAINT projectAW2017_ModifiedDateSpecialOfferProduct_DE DEFAULT (GETDATE()) 
CONSTRAINT projectAW2017_SpecialOfferProduct_PK PRIMARY KEY (SpecialOfferID, ProductID)
);

INSERT INTO SpecialOfferProduct 
(SpecialOfferID, ProductID, rowguid, ModifiedDate)
SELECT TOP 20
SpecialOfferID, ProductID, NEWID(), GETDATE()
FROM AdventureWorks2017.Sales.SpecialOfferProduct
ORDER BY SpecialOfferID;
GO

CREATE TABLE CreditCard
(
CreditCardID INT NOT NULL
CONSTRAINT projectAW2017_CreditCardID_PK PRIMARY KEY (CreditCardID),
CardType NVARCHAR(50) NOT NULL,
CardNumber NVARCHAR(25) NOT NULL,
ExpMonth TINYINT NOT NULL,
ExpYear SMALLINT NOT NULL,
ModifiedDate DATETIME NOT NULL
CONSTRAINT projectAW2017_ModifiedDateCreditCard_DE DEFAULT (GETDATE())
);
GO

INSERT INTO CreditCard (CreditCardID, CardType, CardNumber, ExpMonth, ExpYear, ModifiedDate)
SELECT TOP 20
CreditCardID, CardType, CardNumber, ExpMonth, ExpYear, ModifiedDate
FROM AdventureWorks2017.Sales.CreditCard
ORDER BY CreditCardID;
GO

CREATE TABLE SalesTerritory
(
TerritoryID INT NOT NULL
CONSTRAINT projectAW2017_TerritoryID_PK PRIMARY KEY (TerritoryID),
Name NVARCHAR(50) NOT NULL,
CountryRegionCode NVARCHAR(3) NOT NULL,
[Group] NVARCHAR(50) NOT NULL,
SalesYTD MONEY NOT NULL
CONSTRAINT projectAW2017_SalesYTD_DE DEFAULT (0.00),
SalesLastYear MONEY NOT NULL
CONSTRAINT projectAW2017_SalesLastYear_DE DEFAULT (0.00),
CostYTD MONEY NOT NULL
CONSTRAINT projectAW2017_CostYTD_DE DEFAULT (0.00),
CostLastYear MONEY NOT NULL
CONSTRAINT projectAW2017_CostLastYear_DE DEFAULT (0.00),
rowguid UNIQUEIDENTIFIER NOT NULL
CONSTRAINT projectAW2017_rowguidSalesTerritory_DE DEFAULT (NEWID()),
ModifiedDate DATETIME NOT NULL
CONSTRAINT projectAW2017_ModifiedSalesTerritory_DE DEFAULT (GETDATE())
);
GO

INSERT INTO SalesTerritory (TerritoryID, Name, CountryRegionCode, [Group], SalesYTD, SalesLastYear, CostYTD, CostLastYear, rowguid, ModifiedDate)
SELECT TOP 20
TerritoryID, Name, CountryRegionCode, [Group], SalesYTD, SalesLastYear, CostYTD, CostLastYear, rowguid, ModifiedDate
FROM AdventureWorks2017.Sales.SalesTerritory
ORDER BY TerritoryID;
GO

CREATE TABLE SalesPerson
(
BusinessEntityID INT NOT NULL
CONSTRAINT projectAW2017_BusinessEntityID_PK PRIMARY KEY (BusinessEntityID),
TerritoryID INT
CONSTRAINT projectAW2017_TerritoryIdSalesPerson_FK FOREIGN KEY (TerritoryID) REFERENCES SalesTerritory(TerritoryID),
SalesQuota MONEY,
Bonus MONEY NOT NULL
CONSTRAINT projectAW2017_Bonus_DE DEFAULT (0.00),
CommissionPct SMALLMONEY NOT NULL
CONSTRAINT projectAW2017_CommissionPct_DE DEFAULT (0.00),
SalesYTD MONEY NOT NULL
CONSTRAINT projectAW2017_SalesYTDSalesPerson_DE DEFAULT (0.00),
SalesLastYear MONEY NOT NULL
CONSTRAINT projectAW2017_SalesLastYearSalesPerson_DE DEFAULT (0.00),
rowguid UNIQUEIDENTIFIER NOT NULL
CONSTRAINT projectAW2017_rowguidSalesPerson_DE DEFAULT (NEWID()),
ModifiedDate DATETIME NOT NULL
CONSTRAINT projectAW2017_ModifiedSalesPerson_DE DEFAULT (GETDATE())
);
GO

INSERT INTO SalesPerson 
(BusinessEntityID, TerritoryID, SalesQuota, Bonus, 
CommissionPct, SalesYTD, SalesLastYear, rowguid, ModifiedDate)
SELECT TOP 20
BusinessEntityID, TerritoryID, SalesQuota, Bonus, 
CommissionPct, SalesYTD, SalesLastYear, rowguid, ModifiedDate
FROM AdventureWorks2017.Sales.SalesPerson
ORDER BY BusinessEntityID;
GO

CREATE TABLE Customer
(
CustomerID INT NOT NULL 
CONSTRAINT projectAW2017_CustomerID_PK PRIMARY KEY (CustomerID),
PersonID INT,
StoreID INT,
TerritoryID INT
CONSTRAINT projectAW2017_TerritoryIdCustomer_FK FOREIGN KEY (TerritoryID) REFERENCES SalesTerritory(TerritoryID),
AccountNumber AS (ISNULL('AW' + FORMAT(CustomerID, '0000000000'), '')),
rowguid UNIQUEIDENTIFIER NOT NULL
CONSTRAINT projectAW2017_rowguidCustomer_DE DEFAULT (NEWID()),
ModifiedDate DATETIME NOT NULL
CONSTRAINT projectAW2017_ModifiedCustomer_DE DEFAULT (GETDATE())
);
GO

INSERT INTO Customer (CustomerID, PersonID, StoreID, TerritoryID, rowguid, ModifiedDate)
SELECT TOP 20
CustomerID, PersonID, StoreID, TerritoryID, rowguid, ModifiedDate
FROM AdventureWorks2017.Sales.Customer
ORDER BY CustomerID;



