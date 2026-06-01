/*
===============================================================================
Silver Layer Stored Procedures
===============================================================================
*/

USE Project;
GO

-- ===========================================================================
-- 1. load_brands
-- ===========================================================================
CREATE OR ALTER PROCEDURE silver.load_brands AS
BEGIN TRY
    DECLARE @start DATETIME = GETDATE();
    TRUNCATE TABLE silver.brands;
    INSERT INTO silver.brands (brand_id, brand_name)
    SELECT DISTINCT brand_id, LTRIM(RTRIM(brand_name))
    FROM bronze.brands WHERE brand_id IS NOT NULL;
    INSERT INTO silver.load_log (procedure_name, table_name, load_start_time, load_end_time, duration_seconds, rows_inserted, status)
    VALUES ('silver.load_brands','brands',@start,GETDATE(),DATEDIFF(SECOND,@start,GETDATE()),@@ROWCOUNT,'Success');
END TRY
BEGIN CATCH
    INSERT INTO silver.load_log (procedure_name, table_name, load_start_time, load_end_time, duration_seconds, rows_inserted, status, error_message)
    VALUES ('silver.load_brands','brands',GETDATE(),GETDATE(),0,0,'Failed',ERROR_MESSAGE());
END CATCH;
GO

-- ===========================================================================
-- 2. load_departments
-- ===========================================================================
CREATE OR ALTER PROCEDURE silver.load_departments AS
BEGIN TRY
    DECLARE @start DATETIME = GETDATE();
    TRUNCATE TABLE silver.departments;
    INSERT INTO silver.departments (department_id, department_name)
    SELECT DISTINCT department_id, LTRIM(RTRIM(department_name))
    FROM bronze.departments WHERE department_id IS NOT NULL;
    INSERT INTO silver.load_log (procedure_name, table_name, load_start_time, load_end_time, duration_seconds, rows_inserted, status)
    VALUES ('silver.load_departments','departments',@start,GETDATE(),DATEDIFF(SECOND,@start,GETDATE()),@@ROWCOUNT,'Success');
END TRY
BEGIN CATCH
    INSERT INTO silver.load_log (procedure_name, table_name, load_start_time, load_end_time, duration_seconds, rows_inserted, status, error_message)
    VALUES ('silver.load_departments','departments',GETDATE(),GETDATE(),0,0,'Failed',ERROR_MESSAGE());
END CATCH;
GO

-- ===========================================================================
-- 3. load_customers
-- FIX: ALTER TABLE columns guarded with IF NOT EXISTS
-- ===========================================================================
CREATE OR ALTER PROCEDURE silver.load_customers AS
BEGIN TRY
    DECLARE @start DATETIME = GETDATE();
    TRUNCATE TABLE silver.customers;

    WITH Deduped AS (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY email ORDER BY customer_id) AS rn
        FROM bronze.customers
    )
    INSERT INTO silver.customers (customer_id, first_name, last_name, gender, city, loyalty_level, email)
    SELECT customer_id,
           LTRIM(RTRIM(first_name)),
           LTRIM(RTRIM(last_name)),
           CASE WHEN gender IN ('M','Male')   THEN 'Male'
                WHEN gender IN ('F','Female') THEN 'Female'
                ELSE 'Unknown' END,
           LTRIM(RTRIM(city)),
           ISNULL(loyalty_level,'Standard'),
           LOWER(LTRIM(RTRIM(email)))
    FROM Deduped WHERE rn = 1;

    -- ── Computed columns — only add if they don't already exist ──────────
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('silver.customers') AND name = 'full_name')
        ALTER TABLE silver.customers ADD full_name AS (first_name + ' ' + last_name);

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('silver.customers') AND name = 'email_domain')
        ALTER TABLE silver.customers ADD email_domain AS (RIGHT(email, LEN(email) - CHARINDEX('@', email)));

    INSERT INTO silver.load_log (procedure_name, table_name, load_start_time, load_end_time, duration_seconds, rows_inserted, status)
    VALUES ('silver.load_customers','customers',@start,GETDATE(),DATEDIFF(SECOND,@start,GETDATE()),@@ROWCOUNT,'Success');
END TRY
BEGIN CATCH
    INSERT INTO silver.load_log (procedure_name, table_name, load_start_time, load_end_time, duration_seconds, rows_inserted, status, error_message)
    VALUES ('silver.load_customers','customers',GETDATE(),GETDATE(),0,0,'Failed',ERROR_MESSAGE());
END CATCH;
GO

-- ===========================================================================
-- 4. load_stores
-- FIX: ALTER TABLE columns guarded with IF NOT EXISTS
-- ===========================================================================
CREATE OR ALTER PROCEDURE silver.load_stores AS
BEGIN TRY
    DECLARE @start DATETIME = GETDATE();
    TRUNCATE TABLE silver.stores;

    WITH Deduped AS (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY store_name, city, state ORDER BY store_id) AS rn
        FROM bronze.stores
    )
    INSERT INTO silver.stores (store_id, store_name, city, state, region, opening_date)
    SELECT store_id,
           CASE WHEN store_name LIKE 'Los Store%' THEN REPLACE(store_name,'Los Store','Los Angeles Store')
                WHEN store_name LIKE 'San Store%' THEN REPLACE(store_name,'San Store','San Diego Store')
                ELSE LTRIM(RTRIM(store_name)) END,
           LTRIM(RTRIM(city)),
           ISNULL(LTRIM(RTRIM(state)),'NA'),
           ISNULL(LTRIM(RTRIM(region)),'Unknown'),
           CONVERT(DATE, opening_date)
    FROM Deduped WHERE rn = 1;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('silver.stores') AND name = 'store_full_name')
        ALTER TABLE silver.stores ADD store_full_name AS (city + ' - ' + store_name);

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('silver.stores') AND name = 'store_age_years')
        ALTER TABLE silver.stores ADD store_age_years AS (DATEDIFF(YEAR, opening_date, GETDATE()));

    INSERT INTO silver.load_log (procedure_name, table_name, load_start_time, load_end_time, duration_seconds, rows_inserted, status)
    VALUES ('silver.load_stores','stores',@start,GETDATE(),DATEDIFF(SECOND,@start,GETDATE()),@@ROWCOUNT,'Success');
END TRY
BEGIN CATCH
    INSERT INTO silver.load_log (procedure_name, table_name, load_start_time, load_end_time, duration_seconds, rows_inserted, status, error_message)
    VALUES ('silver.load_stores','stores',GETDATE(),GETDATE(),0,0,'Failed',ERROR_MESSAGE());
END CATCH;
GO

-- ===========================================================================
-- 5. load_employees
-- FIX: ALTER TABLE columns guarded with IF NOT EXISTS
-- ===========================================================================
CREATE OR ALTER PROCEDURE silver.load_employees AS
BEGIN TRY
    DECLARE @start DATETIME = GETDATE();
    TRUNCATE TABLE silver.employees;

    WITH Deduped AS (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY Name, Store_ID, Position ORDER BY Employee_ID) AS rn
        FROM bronze.employees
    )
    INSERT INTO silver.employees (employee_id, name, gender, position, store_id, hire_date)
    SELECT employee_id,
           LTRIM(RTRIM(Name)),
           CASE WHEN Gender IN ('M','Male')   THEN 'Male'
                WHEN Gender IN ('F','Female') THEN 'Female'
                ELSE 'Unknown' END,
           ISNULL(LTRIM(RTRIM(Position)),'Unassigned'),
           Store_ID,
           CONVERT(DATE, Hire_Date)
    FROM Deduped WHERE rn = 1;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('silver.employees') AND name = 'tenure_years')
        ALTER TABLE silver.employees ADD tenure_years AS (DATEDIFF(YEAR, hire_date, GETDATE()));

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('silver.employees') AND name = 'first_name')
        ALTER TABLE silver.employees ADD first_name AS (LEFT(name, CHARINDEX(' ', name + ' ') - 1));

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('silver.employees') AND name = 'last_name')
        ALTER TABLE silver.employees ADD last_name AS (SUBSTRING(name, CHARINDEX(' ', name + ' ') + 1, LEN(name)));

    INSERT INTO silver.load_log (procedure_name, table_name, load_start_time, load_end_time, duration_seconds, rows_inserted, status)
    VALUES ('silver.load_employees','employees',@start,GETDATE(),DATEDIFF(SECOND,@start,GETDATE()),@@ROWCOUNT,'Success');
END TRY
BEGIN CATCH
    INSERT INTO silver.load_log (procedure_name, table_name, load_start_time, load_end_time, duration_seconds, rows_inserted, status, error_message)
    VALUES ('silver.load_employees','employees',GETDATE(),GETDATE(),0,0,'Failed',ERROR_MESSAGE());
END CATCH;
GO

-- ===========================================================================
-- 6. load_products
-- FIX: ALTER TABLE columns guarded with IF NOT EXISTS
-- ===========================================================================
CREATE OR ALTER PROCEDURE silver.load_products AS
BEGIN TRY
    DECLARE @start DATETIME = GETDATE();
    TRUNCATE TABLE silver.products;

    WITH Deduped AS (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY sku ORDER BY product_id) AS rn
        FROM bronze.products
    )
    INSERT INTO silver.products (product_id, sku, product_name, brand_id, department_id, package_size)
    SELECT product_id,
           LTRIM(RTRIM(sku)),
           LTRIM(RTRIM(product_name)),
           brand_id,
           department_id,
           LTRIM(RTRIM(package_size))
    FROM Deduped WHERE rn = 1;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('silver.products') AND name = 'package_size_value')
        ALTER TABLE silver.products ADD package_size_value AS
            TRY_CAST(LEFT(package_size, PATINDEX('%[^0-9]%', package_size + 'X') - 1) AS INT);

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('silver.products') AND name = 'package_size_unit')
        ALTER TABLE silver.products ADD package_size_unit AS
            LTRIM(RTRIM(SUBSTRING(package_size, PATINDEX('%[^0-9]%', package_size + 'X'), LEN(package_size))));

    INSERT INTO silver.load_log (procedure_name, table_name, load_start_time, load_end_time, duration_seconds, rows_inserted, status)
    VALUES ('silver.load_products','products',@start,GETDATE(),DATEDIFF(SECOND,@start,GETDATE()),@@ROWCOUNT,'Success');
END TRY
BEGIN CATCH
    INSERT INTO silver.load_log (procedure_name, table_name, load_start_time, load_end_time, duration_seconds, rows_inserted, status, error_message)
    VALUES ('silver.load_products','products',GETDATE(),GETDATE(),0,0,'Failed',ERROR_MESSAGE());
END CATCH;
GO

-- ===========================================================================
-- 7. load_delivery_providers
-- ===========================================================================
CREATE OR ALTER PROCEDURE silver.load_delivery_providers AS
BEGIN TRY
    DECLARE @start DATETIME = GETDATE();
    TRUNCATE TABLE silver.delivery_providers;
    INSERT INTO silver.delivery_providers (provider_id, provider_name, phone)
    SELECT provider_id,
           LTRIM(RTRIM(provider_name)),
           REPLACE(REPLACE(REPLACE(phone,' ',''),'-',''),'.','')
    FROM bronze.delivery_providers;
    INSERT INTO silver.load_log (procedure_name, table_name, load_start_time, load_end_time, duration_seconds, rows_inserted, status)
    VALUES ('silver.load_delivery_providers','delivery_providers',@start,GETDATE(),DATEDIFF(SECOND,@start,GETDATE()),@@ROWCOUNT,'Success');
END TRY
BEGIN CATCH
    INSERT INTO silver.load_log (procedure_name, table_name, load_start_time, load_end_time, duration_seconds, rows_inserted, status, error_message)
    VALUES ('silver.load_delivery_providers','delivery_providers',GETDATE(),GETDATE(),0,0,'Failed',ERROR_MESSAGE());
END CATCH;
GO

-- ===========================================================================
-- 8. load_deliveries
-- ===========================================================================
CREATE OR ALTER PROCEDURE silver.load_deliveries AS
BEGIN TRY
    DECLARE @start DATETIME = GETDATE();
    TRUNCATE TABLE silver.deliveries;
    INSERT INTO silver.deliveries (delivery_id, order_id, provider_id, ship_date, delivery_date, delivery_status)
    SELECT delivery_id, order_id, provider_id, ship_date, delivery_date,
           ISNULL(LTRIM(RTRIM(delivery_status)),'Unknown')
    FROM bronze.deliveries;
    INSERT INTO silver.load_log (procedure_name, table_name, load_start_time, load_end_time, duration_seconds, rows_inserted, status)
    VALUES ('silver.load_deliveries','deliveries',@start,GETDATE(),DATEDIFF(SECOND,@start,GETDATE()),@@ROWCOUNT,'Success');
END TRY
BEGIN CATCH
    INSERT INTO silver.load_log (procedure_name, table_name, load_start_time, load_end_time, duration_seconds, rows_inserted, status, error_message)
    VALUES ('silver.load_deliveries','deliveries',GETDATE(),GETDATE(),0,0,'Failed',ERROR_MESSAGE());
END CATCH;
GO

-- ===========================================================================
-- 9. load_inventory
-- ===========================================================================
CREATE OR ALTER PROCEDURE silver.load_inventory AS
BEGIN TRY
    DECLARE @start DATETIME = GETDATE();
    TRUNCATE TABLE silver.Inventory;
    INSERT INTO silver.Inventory (inventory_id, store_id, product_id, stock_level, last_updated)
    SELECT inventory_id, store_id, product_id,
           CASE WHEN stock_level < 0 THEN 0 ELSE stock_level END,
           ISNULL(last_updated, GETDATE())
    FROM bronze.Inventory;
    INSERT INTO silver.load_log (procedure_name, table_name, load_start_time, load_end_time, duration_seconds, rows_inserted, status)
    VALUES ('silver.load_inventory','Inventory',@start,GETDATE(),DATEDIFF(SECOND,@start,GETDATE()),@@ROWCOUNT,'Success');
END TRY
BEGIN CATCH
    INSERT INTO silver.load_log (procedure_name, table_name, load_start_time, load_end_time, duration_seconds, rows_inserted, status, error_message)
    VALUES ('silver.load_inventory','Inventory',GETDATE(),GETDATE(),0,0,'Failed',ERROR_MESSAGE());
END CATCH;
GO

-- ===========================================================================
-- 10. load_pos_transactions
-- ===========================================================================
CREATE OR ALTER PROCEDURE silver.load_pos_transactions AS
BEGIN TRY
    DECLARE @start DATETIME = GETDATE();
    TRUNCATE TABLE silver.POS_Transactions;
    INSERT INTO silver.POS_Transactions (transaction_id, store_id, register_id, employee_id, customer_id, transaction_time)
    SELECT DISTINCT
           TRIM(transaction_id),   -- TRIM critical: whitespace breaks the JOIN to Transaction_Items
           store_id,
           register_id,
           employee_id,
           customer_id,
           transaction_time
    FROM bronze.POS_Transactions
    WHERE transaction_id IS NOT NULL AND transaction_time IS NOT NULL;
    INSERT INTO silver.load_log (procedure_name, table_name, load_start_time, load_end_time, duration_seconds, rows_inserted, status)
    VALUES ('silver.load_pos_transactions','POS_Transactions',@start,GETDATE(),DATEDIFF(SECOND,@start,GETDATE()),@@ROWCOUNT,'Success');
END TRY
BEGIN CATCH
    INSERT INTO silver.load_log (procedure_name, table_name, load_start_time, load_end_time, duration_seconds, rows_inserted, status, error_message)
    VALUES ('silver.load_pos_transactions','POS_Transactions',GETDATE(),GETDATE(),0,0,'Failed',ERROR_MESSAGE());
END CATCH;
GO

-- ===========================================================================
-- 11. load_transaction_items  ← NEW (was missing — critical for FACT_STORE_SALES POS)
-- ===========================================================================
CREATE OR ALTER PROCEDURE silver.load_transaction_items AS
BEGIN TRY
    DECLARE @start DATETIME = GETDATE();
    TRUNCATE TABLE silver.Transaction_Items;
    INSERT INTO silver.Transaction_Items (line_id, transaction_id, product_id, promotion_id, quantity, unit_price)
    SELECT line_id,
           TRIM(transaction_id),   -- TRIM must match the TRIM applied in load_pos_transactions
           product_id,
           promotion_id,
           ABS(quantity),          -- ensure positive
           unit_price
    FROM bronze.Transaction_Items
    WHERE line_id      IS NOT NULL
      AND product_id   IS NOT NULL
      AND quantity     <> 0
      AND unit_price   > 0;
    INSERT INTO silver.load_log (procedure_name, table_name, load_start_time, load_end_time, duration_seconds, rows_inserted, status)
    VALUES ('silver.load_transaction_items','Transaction_Items',@start,GETDATE(),DATEDIFF(SECOND,@start,GETDATE()),@@ROWCOUNT,'Success');
END TRY
BEGIN CATCH
    INSERT INTO silver.load_log (procedure_name, table_name, load_start_time, load_end_time, duration_seconds, rows_inserted, status, error_message)
    VALUES ('silver.load_transaction_items','Transaction_Items',GETDATE(),GETDATE(),0,0,'Failed',ERROR_MESSAGE());
END CATCH;
GO

-- ===========================================================================
-- 12. load_online_orders  ← NEW (was missing — needed for FACT_STORE_SALES online)
-- ===========================================================================
CREATE OR ALTER PROCEDURE silver.load_online_orders AS
BEGIN TRY
    DECLARE @start DATETIME = GETDATE();
    TRUNCATE TABLE silver.online_orders;
    INSERT INTO silver.online_orders (order_id, customer_id, warehouse_id, order_time, order_status, order_total)
    SELECT order_id,
           customer_id,
           warehouse_id,
           order_time,
           ISNULL(LTRIM(RTRIM(order_status)), 'Unknown'),
           order_total
    FROM bronze.online_orders
    WHERE order_id IS NOT NULL AND order_time IS NOT NULL;
    INSERT INTO silver.load_log (procedure_name, table_name, load_start_time, load_end_time, duration_seconds, rows_inserted, status)
    VALUES ('silver.load_online_orders','online_orders',@start,GETDATE(),DATEDIFF(SECOND,@start,GETDATE()),@@ROWCOUNT,'Success');
END TRY
BEGIN CATCH
    INSERT INTO silver.load_log (procedure_name, table_name, load_start_time, load_end_time, duration_seconds, rows_inserted, status, error_message)
    VALUES ('silver.load_online_orders','online_orders',GETDATE(),GETDATE(),0,0,'Failed',ERROR_MESSAGE());
END CATCH;
GO

-- ===========================================================================
-- 13. load_online_order_items
-- ===========================================================================
CREATE OR ALTER PROCEDURE silver.load_online_order_items AS
BEGIN TRY
    DECLARE @start DATETIME = GETDATE();
    TRUNCATE TABLE silver.online_orders_items;
    INSERT INTO silver.online_orders_items (order_item_id, order_id, product_id, promotion_id, quantity, unit_price)
    SELECT order_item_id, order_id, product_id, promotion_id,
           ABS(quantity),
           unit_price
    FROM bronze.online_orders_items
    WHERE order_item_id IS NOT NULL AND quantity <> 0 AND unit_price > 0;
    INSERT INTO silver.load_log (procedure_name, table_name, load_start_time, load_end_time, duration_seconds, rows_inserted, status)
    VALUES ('silver.load_online_order_items','online_orders_items',@start,GETDATE(),DATEDIFF(SECOND,@start,GETDATE()),@@ROWCOUNT,'Success');
END TRY
BEGIN CATCH
    INSERT INTO silver.load_log (procedure_name, table_name, load_start_time, load_end_time, duration_seconds, rows_inserted, status, error_message)
    VALUES ('silver.load_online_order_items','online_orders_items',GETDATE(),GETDATE(),0,0,'Failed',ERROR_MESSAGE());
END CATCH;
GO

-- ===========================================================================
-- 14. load_promotions  ← NEW (was missing — needed for DIM_PROMOTION)
-- ===========================================================================
CREATE OR ALTER PROCEDURE silver.load_promotions AS
BEGIN TRY
    DECLARE @start DATETIME = GETDATE();
    TRUNCATE TABLE silver.promotions;
    INSERT INTO silver.promotions (promotion_id, promo_type, discount_percent, start_date, end_date)
    SELECT promotion_id,
           ISNULL(LTRIM(RTRIM(promo_type)), 'Unknown'),
           ISNULL(discount_percent, 0.00),
           start_date,
           end_date
    FROM bronze.promotions
    WHERE promotion_id IS NOT NULL;
    INSERT INTO silver.load_log (procedure_name, table_name, load_start_time, load_end_time, duration_seconds, rows_inserted, status)
    VALUES ('silver.load_promotions','promotions',@start,GETDATE(),DATEDIFF(SECOND,@start,GETDATE()),@@ROWCOUNT,'Success');
END TRY
BEGIN CATCH
    INSERT INTO silver.load_log (procedure_name, table_name, load_start_time, load_end_time, duration_seconds, rows_inserted, status, error_message)
    VALUES ('silver.load_promotions','promotions',GETDATE(),GETDATE(),0,0,'Failed',ERROR_MESSAGE());
END CATCH;
GO

-- ===========================================================================
-- 15. load_warehouses  ← NEW (completeness)
-- ===========================================================================
CREATE OR ALTER PROCEDURE silver.load_warehouses AS
BEGIN TRY
    DECLARE @start DATETIME = GETDATE();
    TRUNCATE TABLE silver.warehouses;
    INSERT INTO silver.warehouses (warehouse_id, warehouse_name, city, state)
    SELECT warehouse_id,
           LTRIM(RTRIM(warehouse_name)),
           LTRIM(RTRIM(city)),
           LTRIM(RTRIM(state))
    FROM bronze.warehouses
    WHERE warehouse_id IS NOT NULL;
    INSERT INTO silver.load_log (procedure_name, table_name, load_start_time, load_end_time, duration_seconds, rows_inserted, status)
    VALUES ('silver.load_warehouses','warehouses',@start,GETDATE(),DATEDIFF(SECOND,@start,GETDATE()),@@ROWCOUNT,'Success');
END TRY
BEGIN CATCH
    INSERT INTO silver.load_log (procedure_name, table_name, load_start_time, load_end_time, duration_seconds, rows_inserted, status, error_message)
    VALUES ('silver.load_warehouses','warehouses',GETDATE(),GETDATE(),0,0,'Failed',ERROR_MESSAGE());
END CATCH;
GO

-- ===========================================================================
-- MASTER PROCEDURE — runs entire silver load in correct dependency order
-- ===========================================================================
CREATE OR ALTER PROCEDURE silver.load_all AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @start DATETIME = GETDATE();
    PRINT '=== Silver layer load started: ' + CONVERT(NVARCHAR,@start,120) + ' ===';

    -- Reference tables first (no dependencies)
    PRINT '[1/15] load_brands';          EXEC silver.load_brands;
    PRINT '[2/15] load_departments';     EXEC silver.load_departments;
    PRINT '[3/15] load_delivery_providers'; EXEC silver.load_delivery_providers;
    PRINT '[4/15] load_warehouses';      EXEC silver.load_warehouses;
    PRINT '[5/15] load_promotions';      EXEC silver.load_promotions;

    -- Entity tables
    PRINT '[6/15] load_stores';          EXEC silver.load_stores;
    PRINT '[7/15] load_customers';       EXEC silver.load_customers;
    PRINT '[8/15] load_employees';       EXEC silver.load_employees;
    PRINT '[9/15] load_products';        EXEC silver.load_products;

    -- Transaction tables (depend on entities above)
    PRINT '[10/15] load_pos_transactions';   EXEC silver.load_pos_transactions;
    PRINT '[11/15] load_transaction_items';  EXEC silver.load_transaction_items;
    PRINT '[12/15] load_online_orders';      EXEC silver.load_online_orders;
    PRINT '[13/15] load_online_order_items'; EXEC silver.load_online_order_items;

    -- Supporting tables
    PRINT '[14/15] load_deliveries';     EXEC silver.load_deliveries;
    PRINT '[15/15] load_inventory';      EXEC silver.load_inventory;

    PRINT '=== Silver layer complete. Duration: '
          + CAST(DATEDIFF(SECOND,@start,GETDATE()) AS NVARCHAR) + 's ===';

    -- Summary
    SELECT table_name, status, rows_inserted, duration_seconds, error_message
    FROM silver.load_log
    WHERE load_start_time >= @start
    ORDER BY log_id;
END;
GO

/*
===============================================================================
USAGE
  EXEC silver.load_all;                    -- run everything
  EXEC silver.load_transaction_items;      -- re-run one table
  SELECT * FROM silver.load_log ORDER BY log_id DESC;
===============================================================================
*/
EXEC silver.load_all;