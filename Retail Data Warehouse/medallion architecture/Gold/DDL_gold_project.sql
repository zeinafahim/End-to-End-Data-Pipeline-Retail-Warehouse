/*
===============================================================================
DDL Script: Create Gold Layer Tables — FIXED
Fix applied: Store_Key in FACT_STORE_SALES changed from NOT NULL to NULL
             Online orders have no physical store — inserting NULL was crashing
             the procedure with a constraint violation.
===============================================================================
*/

USE Project;
GO

IF OBJECT_ID('gold.FACT_STORE_SALES',  'U') IS NOT NULL DROP TABLE gold.FACT_STORE_SALES;
IF OBJECT_ID('gold.FACT_INVENTORY',    'U') IS NOT NULL DROP TABLE gold.FACT_INVENTORY;
IF OBJECT_ID('gold.DIM_DATE',          'U') IS NOT NULL DROP TABLE gold.DIM_DATE;
IF OBJECT_ID('gold.DIM_STORE',         'U') IS NOT NULL DROP TABLE gold.DIM_STORE;
IF OBJECT_ID('gold.DIM_PRODUCT',       'U') IS NOT NULL DROP TABLE gold.DIM_PRODUCT;
IF OBJECT_ID('gold.DIM_CUSTOMER',      'U') IS NOT NULL DROP TABLE gold.DIM_CUSTOMER;
IF OBJECT_ID('gold.DIM_EMPLOYEE',      'U') IS NOT NULL DROP TABLE gold.DIM_EMPLOYEE;
IF OBJECT_ID('gold.DIM_PROMOTION',     'U') IS NOT NULL DROP TABLE gold.DIM_PROMOTION;
IF OBJECT_ID('gold.load_log',          'U') IS NOT NULL DROP TABLE gold.load_log;
GO

CREATE TABLE gold.DIM_DATE (
    Date_Key  INT  NOT NULL PRIMARY KEY,
    Full_Date DATE NOT NULL,
    Day       INT  NOT NULL,
    Month     INT  NOT NULL,
    Year      INT  NOT NULL
);
GO

CREATE TABLE gold.DIM_STORE (
    Store_Key    INT          NOT NULL PRIMARY KEY IDENTITY(1,1),
    Store_ID     INT          NOT NULL,
    Store_Name   NVARCHAR(200) NOT NULL,
    City         NVARCHAR(100),
    State        NVARCHAR(50),
    Region       NVARCHAR(50),
    Opening_Date DATE
);
GO

CREATE TABLE gold.DIM_PRODUCT (
    Product_Key     INT           NOT NULL PRIMARY KEY IDENTITY(1,1),
    Product_ID      INT           NOT NULL,
    SKU             NVARCHAR(50),
    Product_Name    NVARCHAR(200) NOT NULL,
    Package_Size    NVARCHAR(50),
    Brand_Name      NVARCHAR(100),
    Department_Name NVARCHAR(100)
);
GO

CREATE TABLE gold.DIM_CUSTOMER (
    Customer_Key  INT           NOT NULL PRIMARY KEY IDENTITY(1,1),
    Customer_ID   INT           NOT NULL,
    First_Name    NVARCHAR(50),
    Last_Name     NVARCHAR(50),
    City          NVARCHAR(100),
    Loyalty_Level NVARCHAR(50),
    Email         NVARCHAR(100)
);
GO

CREATE TABLE gold.DIM_EMPLOYEE (
    Employee_Key INT           NOT NULL PRIMARY KEY IDENTITY(1,1),
    Employee_ID  INT           NOT NULL,
    Name         NVARCHAR(100) NOT NULL,
    Position     NVARCHAR(100),
    Hire_Date    DATE
);
GO

CREATE TABLE gold.DIM_PROMOTION (
    Promotion_Key    INT          NOT NULL PRIMARY KEY IDENTITY(1,1),
    Promotion_ID     INT          NOT NULL,
    Promo_Type       NVARCHAR(50),
    Discount_Percent DECIMAL(5,2),
    Start_Date       DATE,
    End_Date         DATE
);
GO

CREATE TABLE gold.FACT_STORE_SALES (
    Sales_ID      INT           NOT NULL PRIMARY KEY IDENTITY(1,1),
    Date_Key      INT           NOT NULL REFERENCES gold.DIM_DATE(Date_Key),
    Store_Key     INT           NULL     REFERENCES gold.DIM_STORE(Store_Key),     -- ← NULL allowed: online orders have no store
    Product_Key   INT           NOT NULL REFERENCES gold.DIM_PRODUCT(Product_Key),
    Customer_Key  INT           NULL     REFERENCES gold.DIM_CUSTOMER(Customer_Key),
    Employee_Key  INT           NULL     REFERENCES gold.DIM_EMPLOYEE(Employee_Key),
    Promotion_Key INT           NULL     REFERENCES gold.DIM_PROMOTION(Promotion_Key),
    Quantity      INT           NOT NULL,
    Unit_Price    DECIMAL(10,2) NOT NULL,
    Sales_Amount  DECIMAL(18,2) NOT NULL
);
GO

CREATE TABLE gold.FACT_INVENTORY (
    Inventory_Fact_ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    Date_Key          INT NOT NULL REFERENCES gold.DIM_DATE(Date_Key),
    Store_Key         INT NOT NULL REFERENCES gold.DIM_STORE(Store_Key),
    Product_Key       INT NOT NULL REFERENCES gold.DIM_PRODUCT(Product_Key),
    Stock_Level       INT NOT NULL
);
GO

CREATE TABLE gold.load_log (
    log_id           INT          IDENTITY(1,1) PRIMARY KEY,
    procedure_name   NVARCHAR(200),
    table_name       NVARCHAR(200),
    load_start_time  DATETIME,
    load_end_time    DATETIME,
    duration_seconds INT,
    rows_inserted    INT,
    status           NVARCHAR(20),
    error_message    NVARCHAR(MAX)
);
GO
