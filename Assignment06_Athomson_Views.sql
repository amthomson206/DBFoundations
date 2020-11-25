--*************************************************************************--
-- Title: Assignment06
-- Author: Amthomson
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,Amthomson,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_Amthomson')
	 Begin 
	  Alter Database [Assignment06DB_Amthomson] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_Amthomson;
	 End
	Create Database Assignment06DB_Amthomson;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_Amthomson;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5 pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
Create View vCategories
	With Schemabinding
	AS Select CategoryID, CategoryName from dbo.Categories; 
	go
--Select * from vCategories

Create View vProducts
	With Schemabinding
	AS Select ProductID, ProductName, CategoryID, UnitPrice from dbo.Products;
	go
--Select * from vProducts

Create View vEmployees
	With Schemabinding
	AS Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID from dbo.Employees;
	go
--Select * from vEmployees

Create View vInventories
	With Schemabinding
	AS Select InventoryID, InventoryDate, EmployeeID, ProductID, [Count] from dbo.Inventories;
	go
--Select * from vInventories

-- Question 2 (5 pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Grant Select on vCategories To Public;
go

Grant Select on vProducts to Public;
go

Grant Select on vEmployees to Public;
go

Grant Select on vInventories to Public; 
go

-- Question 3 (10 pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00

Create View vCatProdPrice
AS
	Select Top 10000 CategoryName, ProductName, UnitPrice
from Categories
INNER JOIN Products
On Categories.CategoryID = Products.CategoryID
Order by 1, 2;
go
--Select * From vCatProdPrice

-- Question 4 (10 pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83
Create View vProductNameInventoryDateInventoryCount
AS
Select Top 1000 ProductName, InventoryDate, [Count] 
From Products
Inner Join Inventories
On Products.ProductID = Inventories.ProductID
Order by 1, 2, 3; 
go

--Select * from vProductNameInventoryDateInventoryCount

-- Question 5 (10 pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth

Create View vInventoryDateEmployeeName
AS
Select Top 1000 InventoryDate, EmployeeFirstName, EmployeeLastName
From Inventories
Inner Join Employees
On Inventories.EmployeeID = Employees.EmployeeID
Group by InventoryDate, EmployeeFirstName, EmployeeLastName
Order by 1;
go

--Select * from vInventoryDateEmployeeName

-- Question 6 (10 pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54

Create View vCategoryProductDateCount
AS
Select Top 10000 CategoryName, ProductName, InventoryDate, [Count] 
from Categories
Inner Join Products
On Products.CategoryID = Categories.CategoryID
Inner Join Inventories
On Inventories.ProductID = Products.ProductID
Order by 1, 2, 3, 4;
go

--Select * From vCategoryProductDateCount

-- Question 7 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan

Create View vProductDateCountbyEmployee
AS
SELECT Top 1000 CategoryName, ProductName, InventoryDate, [Count], EmployeeFirstName, EmployeeLastName
FROM Inventories
INNER JOIN Employees On Employees.EmployeeID = Inventories.EmployeeID
INNER JOIN (
	SELECT CategoryName, ProductName, ProductID FROM Categories 
	INNER JOIN Products ON Categories.CategoryID = Products.CategoryID
) AS products ON Inventories.ProductID = products.ProductID

--Select * from vProductDateCountbyEmployee

-- Question 8 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King

Create View vChaiChangeProdDateCountbyEmployee
AS
SELECT Top 1000 CategoryName, ProductName, InventoryDate, [Count], EmployeeFirstName, EmployeeLastName
FROM Inventories
INNER JOIN Employees On Employees.EmployeeID = Inventories.EmployeeID
INNER JOIN (
	SELECT CategoryName, ProductName, ProductID FROM Categories 
	INNER JOIN Products ON Categories.CategoryID = Products.CategoryID
	WHERE Products.ProductName IN ('Chai', 'Chang')
) AS products ON Inventories.ProductID = products.ProductID

--Select * from vChaiChangeProdDateCountbyEmployee

-- Question 9 (10 pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan

Create View vEmployeesbyManager
AS
Select Top 1000 M.EmployeeFirstName + ' ' + M.EmployeeLastName as Manager,
E.EmployeeFirstName + ' ' + E.EmployeeLastName as Employee
From Employees AS E
Inner Join Employees As M
	On E.ManagerID = M.EmployeeID
Order by 1,2

--Select * From vEmployeesbyManager

-- Question 10 (10 pts): How can you create one view to show all the data from all four 
-- BASIC Views?

-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

Create View vEmployeeManagerIDMapping2
AS
Select Top 1000 E.EmployeeID,
E.EmployeeFirstName + ' ' + E.EmployeeLastName as Employee,
M.EmployeeFirstName + ' ' + M.EmployeeLastName as Manager
From Employees AS E
Inner Join Employees As M
	On E.ManagerID = M.EmployeeID
Order by 1,2

--Select * From vEmployeeManagerIDMapping2

Create View vInventoryByProductByCategoryByEmployee
AS
Select TOP 100  C.CategoryID, CategoryName, Products.ProductID, ProductName, UnitPrice, InventoryID, InventoryDate, [Count], vEmployeeManagerIDMapping2.*
From (SELECT * FROM Categories) AS C
Inner Join Products
On Products.CategoryID = C.CategoryID
Inner Join Inventories
On Inventories.ProductID = Products.ProductID
Inner Join vEmployeeManagerIDMapping2
On vEmployeeManagerIDMapping2.EmployeeID = Inventories.EmployeeID
Order by 1,2,3,4,5,6,7;
go

--Select * From vInventoryByProductByCategoryByEmployee

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vCatProdPrice]
Select * From [dbo].[vProductNameInventoryDateInventoryCount]
Select * From [dbo].[vInventoryDateEmployeeName]
Select * From [dbo].[vCategoryProductDateCount]
Select * From [dbo].[vProductDateCountbyEmployee]
Select * From [dbo].[vChaiChangeProdDateCountbyEmployee]
Select * From [dbo].[vEmployeesbyManager]
Select * From [dbo].[vInventoryByProductByCategoryByEmployee]
/***************************************************************************************/