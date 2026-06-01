/*
===============================================================================
DDL Script: Create silver Tables
*/

USE Project;
GO


IF OBJECT_ID('silver.brands', 'U') IS NOT NULL
    DROP TABLE silver.brands;

IF OBJECT_ID('silver.departments', 'U') IS NOT NULL
    DROP TABLE silver.departments;

IF OBJECT_ID('silver.delivery_providers', 'U') IS NOT NULL
    DROP TABLE silver.delivery_providers;


IF OBJECT_ID('silver.customers', 'U') IS NOT NULL
    DROP TABLE silver.customers;

IF OBJECT_ID('silver.employees', 'U') IS NOT NULL
    DROP TABLE silver.employees;

IF OBJECT_ID('silver.deliveries', 'U') IS NOT NULL
    DROP TABLE silver.deliveries;

IF OBJECT_ID('silver.online_orders', 'U') IS NOT NULL
    DROP TABLE silver.online_orders;

IF OBJECT_ID('silver.payments', 'U') IS NOT NULL 
    DROP TABLE silver.payments;

IF OBJECT_ID('silver.products', 'U') IS NOT NULL 
    DROP TABLE silver.products;

IF OBJECT_ID('silver.promotions', 'U') IS NOT NULL 
    DROP TABLE silver.promotions;

IF OBJECT_ID('silver.registers', 'U') IS NOT NULL 
    DROP TABLE silver.registers;

IF OBJECT_ID('silver.stores', 'U') IS NOT NULL 
    DROP TABLE silver.stores;

IF OBJECT_ID('silver.suppliers', 'U') IS NOT NULL 
    DROP TABLE silver.suppliers;

IF OBJECT_ID('silver.warehouses', 'U') IS NOT NULL 
    DROP TABLE silver.warehouses;

IF OBJECT_ID('silver.Data_Quality_Report', 'U') IS NOT NULL 
    DROP TABLE silver.Data_Quality_Report;

IF OBJECT_ID('silver.Inventory', 'U') IS NOT NULL 
    DROP TABLE silver.Inventory;

IF OBJECT_ID('silver.online_orders_items', 'U') IS NOT NULL 
    DROP TABLE silver.online_orders_items;

IF OBJECT_ID('silver.POS_Transactions', 'U') IS NOT NULL 
    DROP TABLE silver.POS_Transactions;

IF OBJECT_ID('silver.Transaction_Items', 'U') IS NOT NULL 
    DROP TABLE silver.Transaction_Items;

IF OBJECT_ID('silver.Product_Suppliers', 'U') IS NOT NULL 
    DROP TABLE silver.Product_Suppliers;

-- ===================== LOG TABLE =====================

IF OBJECT_ID('silver.load_log', 'U') IS NOT NULL
    DROP TABLE silver.load_log;
GO
-- ===================== CREATE  DATA TABLES =====================

CREATE TABLE silver.brands (
    brand_id    INT,
    brand_name  NVARCHAR(100)
);

CREATE TABLE silver.departments (
    department_id   INT,
    department_name NVARCHAR(100)
);

CREATE TABLE silver.delivery_providers (
    provider_id   INT,
    provider_name NVARCHAR(100),
    phone         NVARCHAR(20)
);


CREATE TABLE silver.customers (
    customer_id     INT,
    first_name      NVARCHAR(50),
    last_name       NVARCHAR(50),
    gender          NVARCHAR(20),
    city            NVARCHAR(100),
    loyalty_level   NVARCHAR(50),
    email           NVARCHAR(100)
);

CREATE TABLE silver.employees (
    employee_id     INT,
    name            NVARCHAR(100),
    gender          NVARCHAR(20),
    position        NVARCHAR(100),
    store_id        INT,
    hire_date       DATE
);

CREATE TABLE silver.deliveries (
    delivery_id     INT,
    order_id        INT,
    provider_id     INT,
    ship_date       DATETIME,
    delivery_date   DATETIME,
    delivery_status NVARCHAR(50)
);

CREATE TABLE silver.online_orders (
    order_id        INT,
    customer_id     INT,
    warehouse_id    INT,
    order_time      DATETIME,
    order_status    NVARCHAR(50),
    order_total     DECIMAL(18,2)
);


CREATE TABLE silver.payments (
    payment_id      INT,
    
    order_id        INT,
    payment_method  NVARCHAR(50),
    payment_amount  DECIMAL(18,2),
    payment_time    DATETIME
);

CREATE TABLE silver.products (
    product_id      INT,
    
    sku             NVARCHAR(50),
    product_name    NVARCHAR(200),
    brand_id        INT,
    department_id   INT,
    package_size    NVARCHAR(50)
);


CREATE TABLE silver.promotions (
    promotion_id    INT,
  
    promo_type      NVARCHAR(50),
    discount_percent DECIMAL(5,2),
    start_date      DATE,
    end_date        DATE
);

CREATE TABLE silver.registers (
    register_id     INT,
   
    store_id        INT,
    register_number INT
);


CREATE TABLE silver.stores (
    store_id        INT,
    
    store_name      NVARCHAR(200),
    city            NVARCHAR(100),
    state           NVARCHAR(50),
    region          NVARCHAR(50),
    opening_date    DATE
);


CREATE TABLE silver.suppliers (
    supplier_id     INT,
    
    supplier_name   NVARCHAR(200),
    country         NVARCHAR(100),
    phone           NVARCHAR(20)
);


CREATE TABLE silver.warehouses (
    warehouse_id    INT,
   
    warehouse_name  NVARCHAR(200),
    city            NVARCHAR(100),
    state           NVARCHAR(50)
);
GO

CREATE TABLE silver.Data_Quality_Report ( 
    table_name    NVARCHAR(100),
   
    row_count     INT
    );
    GO

CREATE TABLE silver.Inventory (
    inventory_id    INT,
   
    store_id        INT,
    product_id      INT,
    stock_level     INT,
    last_updated    DATETIME
    );
    GO

CREATE TABLE silver.online_orders_items (
    order_item_id  INT,
   
    order_id       INT,
    product_id     INT,
    promotion_id   INT,
    quantity       INT,
    unit_price     DECIMAL(5,2)
    );
    GO

CREATE TABLE silver.POS_Transactions (
    transaction_id   NVARCHAR(200),
    store_id         INT,
    register_id      INT,
    employee_id      INT,
    customer_id      INT,
    transaction_time DATETIME
    );
    GO

CREATE TABLE silver.Transaction_Items (
    line_id        INT,
    transaction_id NVARCHAR(200),
    product_id     INT,
    promotion_id   INT,
    quantity       INT,
    unit_price     DECIMAL(5,2)
    );
    GO

CREATE TABLE silver.Product_Suppliers (
    product_id           INT,
    supplier_id          INT,
    supply_price         DECIMAL(5,2)
    );
    GO




-- ===================== CREATE LOG TABLE =====================

IF OBJECT_ID('silver.load_log', 'U') IS NOT NULL
    DROP TABLE silver.load_log;

CREATE TABLE silver.load_log (
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
