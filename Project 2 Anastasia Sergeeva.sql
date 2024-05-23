--Project 2 : Anastasia Sergeeva

--EX 1
SELECT p.ProductID, p.Name, p.Color, p.ListPrice,p.Size
FROM Production.Product AS p
LEFT JOIN Sales.SalesOrderDetail AS od ON p.ProductID = od.ProductID
WHERE od.SalesOrderID IS NULL
ORDER BY p.ProductID;

--EX 2 
SELECT C.CustomerID, ISNULL(P.LastName, 'Unknown') AS LastName, ISNULL(P.FirstName, 'Unknown') AS FirstName
FROM Sales.Customer AS C
LEFT JOIN Person.Person AS P 
ON P.BusinessEntityID = C.CustomerID
LEFT JOIN Sales.SalesOrderHeader AS OH 
ON C.CustomerID = OH.CustomerID
WHERE OH.OrderDate IS NULL
ORDER BY C.CustomerID;

--EX 3
WITH CTE_OrderCounts 
AS 
(
SELECT OH.CustomerID, COUNT(*) AS CountOfOrders
FROM Sales.SalesOrderHeader AS OH
GROUP BY OH.CustomerID
)
------------
SELECT TOP 10
OC.CustomerID, P.FirstName, P.LastName, OC.CountOfOrders
FROM CTE_OrderCounts AS OC
JOIN Sales.Customer AS C 
ON OC.CustomerID = C.CustomerID
JOIN Person.Person AS P 
ON C.PersonID = P.BusinessEntityID
ORDER BY OC.CountOfOrders DESC;

--EX 4
WITH CTE_CountJobTitle 
AS
(
SELECT e.JobTitle, COUNT(e.JobTitle) AS CountOfTitle
FROM HumanResources.Employee AS e
GROUP BY e.JobTitle
)
---------------------
SELECT p.FirstName, p.LastName, e.JobTitle, e.HireDate, CT.CountOfTitle
FROM CTE_CountJobTitle AS CT
JOIN HumanResources.Employee AS e 
ON CT.JobTitle = e.JobTitle
JOIN Person.Person AS p 
ON p.BusinessEntityID = e.BusinessEntityID
ORDER BY e.JobTitle;

--EX 5
WITH CTE_TBL
AS 
(
SELECT  s.SalesOrderID, c.CustomerID,  p.LastName,  p.FirstName,  s.OrderDate AS LastOrder,
DENSE_RANK() OVER (PARTITION BY c.CustomerID ORDER BY s.OrderDate DESC) AS RN,
LAG(s.OrderDate) OVER (PARTITION BY s.CustomerID ORDER BY s.OrderDate ASC) AS PreviousOrder
FROM Sales.SalesOrderHeader as s
JOIN Sales.Customer as c 
ON s.CustomerID = c.CustomerID
JOIN Person.Person as p 
ON c.PersonID = p.BusinessEntityID
) 
---------------------------------------------------------
SELECT SalesOrderID, CustomerID,  LastName, FirstName,  LastOrder, PreviousOrder
FROM CTE_TBL
WHERE RN = 1
ORDER BY LastName, FirstName, CustomerID


--EX 6
WITH CTE_OrderTotals 
AS 
(
SELECT YEAR(oh.OrderDate) AS Year, oh.SalesOrderID, c.CustomerID,
SUM(od.UnitPrice * (1 - od.UnitPriceDiscount) * od.OrderQty) AS Total
FROM Sales.SalesOrderDetail od
JOIN Sales.SalesOrderHeader oh 
ON od.SalesOrderID = oh.SalesOrderID
JOIN Sales.Customer c
ON oh.CustomerID = c.CustomerID
GROUP BY YEAR(oh.OrderDate), oh.SalesOrderID, c.CustomerID
),
---------------------
CTE_RankedOrders 
AS 
(
SELECT ot.Year, ot.SalesOrderID, ot.CustomerID, ot.Total,
RANK() OVER(PARTITION BY ot.Year ORDER BY ot.Total DESC) AS Rank
FROM CTE_OrderTotals AS ot
),
----------------------
CTE_CustomerDetails 
AS 
(
SELECT ro.Year, ro.SalesOrderID, ro.Total, p.FirstName, p.LastName
FROM CTE_RankedOrders AS ro
JOIN Sales.Customer c 
ON ro.CustomerID = c.CustomerID
JOIN Person.Person p 
ON c.PersonID = p.BusinessEntityID
WHERE ro.Rank = 1
)
------------------------
SELECT cd.Year, cd.SalesOrderID, cd.FirstName, cd.LastName, cd.Total
FROM CTE_CustomerDetails  AS cd
ORDER BY cd.Year;

-----------can do it shorter----------
WITH CTE_MaxOrder
AS
(SELECT YEAR(s.OrderDate) as "Year",
s.SalesOrderID, p.LastName, p.FirstName, s.CustomerID,
REPLACE(STR(ROUND(SUM(od.UnitPrice * od.OrderQty * (1-od.UnitPriceDiscount)), 1, 1), 10, 1), '.0', '') as Total,
DENSE_RANK () over (partition by year(s.OrderDate) order by
SUM(od.UnitPrice * od.OrderQty * (1-od.UnitPriceDiscount)) DESC) AS RowNum
FROM Person.Person as p JOIN Sales.Customer as c
ON p.BusinessEntityID = c.PersonID JOIN Sales.SalesOrderHeader as s
ON s.CustomerID = c.CustomerID JOIN Sales.SalesOrderDetail as od
ON s.SalesOrderID = od.SalesOrderID
GROUP BY YEAR(s.OrderDate), s.SalesOrderID, p.LastName, p.FirstName, s.CustomerID)
-------------------
SELECT  Year, SalesOrderID, LastName, FirstName, Total
FROM CTE_MaxOrder
WHERE RowNum = 1






--EX 7
WITH CTE_years 
AS 
(
SELECT YEAR(OrderDate) AS Year_, MONTH(OrderDate) AS Month, 
COUNT(SalesOrderID) AS ord_count
FROM sales.SalesOrderHeader
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
)
------------------------------
SELECT Month, 
ISNULL([2011], 0) AS [2011], 
ISNULL([2012], 0) AS [2012], 
ISNULL([2013], 0) AS [2013], 
ISNULL([2014], 0) AS [2014]
FROM CTE_years
-----------------------------
PIVOT 
(SUM(ord_count)
FOR Year_ IN ([2011], [2012], [2013], [2014])) AS pvt
ORDER BY Month;

--EX 8
WITH CTE_TBL1
AS
(
SELECT YEAR(oh.OrderDate) AS Year, MONTH(oh.OrderDate) AS Month, 
ROUND(SUM((od.OrderQty*od.UnitPrice)*(1-od.UnitPriceDiscount)),2) AS Sum_price
FROM Sales.SalesOrderHeader as oh
JOIN Sales.SalesOrderDetail as od
ON oh.SalesOrderID = od.SalesOrderID
GROUP BY YEAR(oh.OrderDate), MONTH(oh.OrderDate)
),
---------------------------
CTE_TBL2
AS
(
SELECT *,
SUM(Sum_price) OVER (PARTITION BY Year ORDER BY MONTH ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS CumSum,
ROW_NUMBER() OVER (PARTITION BY Year ORDER BY MONTH) AS RN
FROM CTE_TBL1
),
---------------------------
CTE_TBL3
AS
(
SELECT Year, Cast(Month as varchar) AS Month, Sum_price, CumSum, RN
FROM CTE_TBL2

UNION
SELECT Year(oh.OrderDate) as Year, 'grand_total', NULL, SUM(od.UnitPrice) as Sum_price, 13
FROM Sales.SalesOrderHeader as oh
JOIN Sales.SalesOrderDetail as od
ON oh.SalesOrderID = od.SalesOrderID
GROUP BY YEAR(oh.OrderDate)

UNION
SELECT 3000, 'grand_total', NULL, SUM(od.UnitPrice) as Sum_price, 100
FROM Sales.SalesOrderHeader as oh
JOIN Sales.SalesOrderDetail as od
ON oh.SalesOrderID = od.SalesOrderID
)
-------------------------
SELECT Year, Month, Sum_price, CumSum
FROM CTE_TBL3
ORDER BY Year, RN


--EX 9
SELECT 
d.Name AS DepartmentName, 
e.BusinessEntityID AS EmployeesID,
p.FirstName + ' ' + p.LastName AS EmployeesFullName,
e.HireDate,
DATEDIFF(mm, e.HireDate, GETDATE()) AS Seniority,
LAG(p.FirstName + ' ' + p.LastName) OVER (PARTITION BY d.DepartmentID ORDER BY e.HireDate) AS PreviousEmpName,
LAG(e.HireDate) OVER (PARTITION BY d.DepartmentID ORDER BY e.HireDate) AS PreviousEmpHDate,
DATEDIFF(dd, LAG(e.HireDate) OVER (PARTITION BY d.DepartmentID ORDER BY e.HireDate),  e.HireDate) AS DiffDays
FROM HumanResources.Department AS d
JOIN HumanResources.EmployeeDepartmentHistory AS dh 
ON d.DepartmentID = dh.DepartmentID
JOIN HumanResources.Employee AS e 
ON dh.BusinessEntityID = e.BusinessEntityID
JOIN Person.Person AS p
ON e.BusinessEntityID = p.BusinessEntityID
ORDER BY DepartmentName, HireDate DESC;

--EX 10
SELECT t.HireDate, t.DepartmentID, 
STRING_AGG(CONCAT_WS(' ', t.BusinessEntityID, t.LastName, t.FirstName), ', ') AS TeamEmployees
FROM
(
SELECT
e.HireDate, d.DepartmentID, d.BusinessEntityID, p.LastName, p.FirstName,
ROW_NUMBER() OVER(PARTITION BY d.BusinessEntityID ORDER BY ISNULL(d.EndDate, '9999-12-31') DESC, d.StartDate DESC) AS rn
FROM HumanResources.Employee AS e
LEFT JOIN Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID
LEFT JOIN HumanResources.EmployeeDepartmentHistory AS d 
ON d.BusinessEntityID = e.BusinessEntityID
) AS t
WHERE t.rn =1 
GROUP BY t.HireDate, t.DepartmentID
ORDER BY t.HireDate DESC;















