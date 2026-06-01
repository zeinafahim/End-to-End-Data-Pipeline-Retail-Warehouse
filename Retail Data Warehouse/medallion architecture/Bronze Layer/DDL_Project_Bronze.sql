/*
===============================================================================
DDL Script: Create Bronze Tables
*/

USE Project;
GO


IF OBJECT_ID('bronze.brands', 'U') IS NOT NULL
    DROP TABLE bronze.brands;

IF OBJECT_ID('bronze.departments', 'U') IS NOT NULL
    DROP TABLE bronze.departments;

IF OBJECT_ID('bronze.delivery_providers', 'U') IS NOT NULL
    DROP TABLE bronze.delivery_providers;


IF OBJECT_ID('bronze.customers', 'U') IS NOT NULL
    DROP TABLE bronze.customers;

IF OBJECT_ID('bronze.employees', 'U') IS NOT NULL
    DROP TABLE bronze.employees;

IF OBJECT_ID('bronze.deliveries', 'U') IS NOT NULL
    DROP TABLE bronze.deliveries;

IF OBJECT_ID('bronze.online_orders', 'U') IS NOT NULL
    DROP TABLE bronze.online_orders;

IF OBJECT_ID('bronze.payments', 'U') IS NOT NULL 
    DROP TABLE bronze.payments;

IF OBJECT_ID('bronze.products', 'U') IS NOT NULL 
    DROP TABLE bronze.products;

IF OBJECT_ID('bronze.promotions', 'U') IS NOT NULL 
    DROP TABLE bronze.promotions;

IF OBJECT_ID('bronze.registers', 'U') IS NOT NULL 
    DROP TABLE bronze.registers;

IF OBJECT_ID('bronze.stores', 'U') IS NOT NULL 
    DROP TABLE bronze.stores;

IF OBJECT_ID('bronze.suppliers', 'U') IS NOT NULL 
    DROP TABLE bronze.suppliers;

IF OBJECT_ID('bronze.warehouses', 'U') IS NOT NULL 
    DROP TABLE bronze.warehouses;

IF OBJECT_ID('bronze.Data_Quality_Report', 'U') IS NOT NULL 
    DROP TABLE bronze.Data_Quality_Report;

IF OBJECT_ID('bronze.Inventory', 'U') IS NOT NULL 
    DROP TABLE bronze.Inventory;

IF OBJECT_ID('bronze.online_orders_items', 'U') IS NOT NULL 
    DROP TABLE bronze.online_orders_items;

IF OBJECT_ID('bronze.POS_Transactions', 'U') IS NOT NULL 
    DROP TABLE bronze.POS_Transactions;

IF OBJECT_ID('bronze.Transaction_Items', 'U') IS NOT NULL 
    DROP TABLE bronze.Transaction_Items;

IF OBJECT_ID('bronze.Product_Suppliers', 'U') IS NOT NULL 
    DROP TABLE bronze.Product_Suppliers;

-- ===================== LOG TABLE =====================

IF OBJECT_ID('bronze.load_log', 'U') IS NOT NULL
    DROP TABLE bronze.load_log;
GO
-- ===================== CREATE  DATA TABLES =====================

CREATE TABLE bronze.brands (
    brand_id    INT,
    brand_name  NVARCHAR(100)
);

CREATE TABLE bronze.departments (
    department_id   INT,
    department_name NVARCHAR(100)
);

CREATE TABLE bronze.delivery_providers (
    provider_id   INT,
    provider_name NVARCHAR(100),
    phone         NVARCHAR(20)
);


CREATE TABLE bronze.customers (
    customer_id     INT,
    first_name      NVARCHAR(50),
    last_name       NVARCHAR(50),
    gender          NVARCHAR(20),
    city            NVARCHAR(100),
    loyalty_level   NVARCHAR(50),
    email           NVARCHAR(100)
);

CREATE TABLE bronze.employees (
    employee_id     INT,
    name            NVARCHAR(100),
    gender          NVARCHAR(20),
    position        NVARCHAR(100),
    store_id        INT,
    hire_date       DATE
);

CREATE TABLE bronze.deliveries (
    delivery_id     INT,
    order_id        INT,
    provider_id     INT,
    ship_date       DATETIME,
    delivery_date   DATETIME,
    delivery_status NVARCHAR(50)
);

CREATE TABLE bronze.online_orders (
    order_id        INT,
    customer_id     INT,
    warehouse_id    INT,
    order_time      DATETIME,
    order_status    NVARCHAR(50),
    order_total     DECIMAL(18,2)
);


CREATE TABLE bronze.payments (
    payment_id      INT,
    
    order_id        INT,
    payment_method  NVARCHAR(50),
    payment_amount  DECIMAL(18,2),
    payment_time    DATETIME
);

CREATE TABLE bronze.products (
    product_id      INT,
    
    sku             NVARCHAR(50),
    product_name    NVARCHAR(200),
    brand_id        INT,
    department_id   INT,
    package_size    NVARCHAR(50)
);


CREATE TABLE bronze.promotions (
    promotion_id    INT,
  
    promo_type      NVARCHAR(50),
    discount_percent DECIMAL(5,2),
    start_date      DATE,
    end_date        DATE
);

CREATE TABLE bronze.registers (
    register_id     INT,
   
    store_id        INT,
    register_number INT
);


CREATE TABLE bronze.stores (
    store_id        INT,
    
    store_name      NVARCHAR(200),
    city            NVARCHAR(100),
    state           NVARCHAR(50),
    region          NVARCHAR(50),
    opening_date    DATE
);


CREATE TABLE bronze.suppliers (
    supplier_id     INT,
    
    supplier_name   NVARCHAR(200),
    country         NVARCHAR(100),
    phone           NVARCHAR(20)
);


CREATE TABLE bronze.warehouses (
    warehouse_id    INT,
   
    warehouse_name  NVARCHAR(200),
    city            NVARCHAR(100),
    state           NVARCHAR(50)
);
GO

CREATE TABLE bronze.Data_Quality_Report ( 
    table_name    NVARCHAR(100),
   
    row_count     INT
    );
    GO

CREATE TABLE bronze.Inventory (
    inventory_id    INT,
   
    store_id        INT,
    product_id      INT,
    stock_level     INT,
    last_updated    DATETIME
    );
    GO

CREATE TABLE bronze.online_orders_items (
    order_item_id  INT,
   
    order_id       INT,
    product_id     INT,
    promotion_id   INT,
    quantity       INT,
    unit_price     DECIMAL(5,2)
    );
    GO

CREATE TABLE bronze.POS_Transactions (
    transaction_id   NVARCHAR(200),
    
    store_id         INT,
    register_id      INT,
    employee_id      INT,
    customer_id      INT,
    transaction_time DATETIME
    );
    GO

CREATE TABLE bronze.Transaction_Items (
    line_id        INT,
    transaction_id NVARCHAR(200),
    product_id     INT,
    promotion_id   INT,
    quantity       INT,
    unit_price     DECIMAL(5,2)
    );
    GO

CREATE TABLE bronze.Product_Suppliers (
    product_id           INT,
    supplier_id          INT,
    supply_price         DECIMAL(5,2)
    );
    GO




-- ===================== CREATE LOG TABLE =====================

IF OBJECT_ID('bronze.load_log', 'U') IS NOT NULL
    DROP TABLE bronze.load_log;

CREATE TABLE bronze.load_log (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    procedure_name NVARCHAR(200),
    table_name NVARCHAR(200),
    load_start_time DATETIME,
    load_end_time DATETIME,
    duration_seconds INT,
    rows_inserted INT,
    status NVARCHAR(20),
    error_message NVARCHAR(MAX)
);
GO

