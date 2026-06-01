/*
===============================================================================
Gold Layer Stored Procedures — FIXED
Fix applied: FACT_STORE_SALES now tracks @@ROWCOUNT for BOTH inserts
             (POS block + online orders block) and sums them correctly.
===============================================================================
*/

USE Project;
GO

CREATE OR ALTER PROCEDURE gold.usp_load_gold_DIM_DATE AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @proc NVARCHAR(200) = 'gold.usp_load_gold_DIM_DATE', @table NVARCHAR(200) = 'gold.DIM_DATE',
            @start DATETIME = GETDATE(), @rows INT = 0, @status NVARCHAR(20) = 'SUCCESS', @err NVARCHAR(MAX) = NULL;
    BEGIN TRY
        DELETE FROM gold.DIM_DATE;
        INSERT INTO gold.DIM_DATE (Date_Key, Full_Date, Day, Month, Year)
        SELECT DISTINCT CONVERT(INT, FORMAT(d.full_date,'yyyyMMdd')), d.full_date, DAY(d.full_date), MONTH(d.full_date), YEAR(d.full_date)
        FROM (
            SELECT CAST(transaction_time AS DATE) FROM silver.POS_Transactions WHERE transaction_time IS NOT NULL
            UNION SELECT CAST(order_time AS DATE)  FROM silver.online_orders      WHERE order_time    IS NOT NULL
            UNION SELECT CAST(last_updated AS DATE) FROM silver.Inventory         WHERE last_updated  IS NOT NULL
        ) d(full_date);
        SET @rows = @@ROWCOUNT;
    END TRY
    BEGIN CATCH SET @status = 'FAILED'; SET @err = ERROR_MESSAGE(); END CATCH;
    INSERT INTO gold.load_log (procedure_name,table_name,load_start_time,load_end_time,duration_seconds,rows_inserted,status,error_message)
    VALUES (@proc,@table,@start,GETDATE(),DATEDIFF(SECOND,@start,GETDATE()),@rows,@status,@err);
    IF @status = 'FAILED' RAISERROR(@err,16,1);
END;
GO

CREATE OR ALTER PROCEDURE gold.usp_load_gold_DIM_STORE AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @proc NVARCHAR(200) = 'gold.usp_load_gold_DIM_STORE', @table NVARCHAR(200) = 'gold.DIM_STORE',
            @start DATETIME = GETDATE(), @rows INT = 0, @status NVARCHAR(20) = 'SUCCESS', @err NVARCHAR(MAX) = NULL;
    BEGIN TRY
        DELETE FROM gold.DIM_STORE;
        INSERT INTO gold.DIM_STORE (Store_ID, Store_Name, City, State, Region, Opening_Date)
        SELECT store_id, TRIM(store_name), TRIM(city), TRIM(state), TRIM(region), opening_date
        FROM silver.stores WHERE store_id IS NOT NULL;
        SET @rows = @@ROWCOUNT;
    END TRY
    BEGIN CATCH SET @status = 'FAILED'; SET @err = ERROR_MESSAGE(); END CATCH;
    INSERT INTO gold.load_log (procedure_name,table_name,load_start_time,load_end_time,duration_seconds,rows_inserted,status,error_message)
    VALUES (@proc,@table,@start,GETDATE(),DATEDIFF(SECOND,@start,GETDATE()),@rows,@status,@err);
    IF @status = 'FAILED' RAISERROR(@err,16,1);
END;
GO

CREATE OR ALTER PROCEDURE gold.usp_load_gold_DIM_PRODUCT AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @proc NVARCHAR(200) = 'gold.usp_load_gold_DIM_PRODUCT', @table NVARCHAR(200) = 'gold.DIM_PRODUCT',
            @start DATETIME = GETDATE(), @rows INT = 0, @status NVARCHAR(20) = 'SUCCESS', @err NVARCHAR(MAX) = NULL;
    BEGIN TRY
        DELETE FROM gold.DIM_PRODUCT;
        INSERT INTO gold.DIM_PRODUCT (Product_ID, SKU, Product_Name, Package_Size, Brand_Name, Department_Name)
        SELECT p.product_id, TRIM(p.sku), TRIM(p.product_name), TRIM(p.package_size),
               ISNULL(TRIM(b.brand_name),'Unknown'), ISNULL(TRIM(d.department_name),'Unknown')
        FROM silver.products p
        LEFT JOIN silver.brands      b ON p.brand_id      = b.brand_id
        LEFT JOIN silver.departments d ON p.department_id = d.department_id
        WHERE p.product_id IS NOT NULL;
        SET @rows = @@ROWCOUNT;
    END TRY
    BEGIN CATCH SET @status = 'FAILED'; SET @err = ERROR_MESSAGE(); END CATCH;
    INSERT INTO gold.load_log (procedure_name,table_name,load_start_time,load_end_time,duration_seconds,rows_inserted,status,error_message)
    VALUES (@proc,@table,@start,GETDATE(),DATEDIFF(SECOND,@start,GETDATE()),@rows,@status,@err);
    IF @status = 'FAILED' RAISERROR(@err,16,1);
END;
GO

CREATE OR ALTER PROCEDURE gold.usp_load_gold_DIM_CUSTOMER AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @proc NVARCHAR(200) = 'gold.usp_load_gold_DIM_CUSTOMER', @table NVARCHAR(200) = 'gold.DIM_CUSTOMER',
            @start DATETIME = GETDATE(), @rows INT = 0, @status NVARCHAR(20) = 'SUCCESS', @err NVARCHAR(MAX) = NULL;
    BEGIN TRY
        DELETE FROM gold.DIM_CUSTOMER;
        INSERT INTO gold.DIM_CUSTOMER (Customer_ID, First_Name, Last_Name, City, Loyalty_Level, Email)
        SELECT customer_id, TRIM(first_name), TRIM(last_name), TRIM(city),
               ISNULL(TRIM(loyalty_level),'Standard'), LOWER(TRIM(email))
        FROM silver.customers WHERE customer_id IS NOT NULL;
        SET @rows = @@ROWCOUNT;
    END TRY
    BEGIN CATCH SET @status = 'FAILED'; SET @err = ERROR_MESSAGE(); END CATCH;
    INSERT INTO gold.load_log (procedure_name,table_name,load_start_time,load_end_time,duration_seconds,rows_inserted,status,error_message)
    VALUES (@proc,@table,@start,GETDATE(),DATEDIFF(SECOND,@start,GETDATE()),@rows,@status,@err);
    IF @status = 'FAILED' RAISERROR(@err,16,1);
END;
GO

CREATE OR ALTER PROCEDURE gold.usp_load_gold_DIM_EMPLOYEE AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @proc NVARCHAR(200) = 'gold.usp_load_gold_DIM_EMPLOYEE', @table NVARCHAR(200) = 'gold.DIM_EMPLOYEE',
            @start DATETIME = GETDATE(), @rows INT = 0, @status NVARCHAR(20) = 'SUCCESS', @err NVARCHAR(MAX) = NULL;
    BEGIN TRY
        DELETE FROM gold.DIM_EMPLOYEE;
        INSERT INTO gold.DIM_EMPLOYEE (Employee_ID, Name, Position, Hire_Date)
        SELECT employee_id, TRIM(name), ISNULL(TRIM(position),'Unknown'), hire_date
        FROM silver.employees WHERE employee_id IS NOT NULL;
        SET @rows = @@ROWCOUNT;
    END TRY
    BEGIN CATCH SET @status = 'FAILED'; SET @err = ERROR_MESSAGE(); END CATCH;
    INSERT INTO gold.load_log (procedure_name,table_name,load_start_time,load_end_time,duration_seconds,rows_inserted,status,error_message)
    VALUES (@proc,@table,@start,GETDATE(),DATEDIFF(SECOND,@start,GETDATE()),@rows,@status,@err);
    IF @status = 'FAILED' RAISERROR(@err,16,1);
END;
GO

CREATE OR ALTER PROCEDURE gold.usp_load_gold_DIM_PROMOTION AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @proc NVARCHAR(200) = 'gold.usp_load_gold_DIM_PROMOTION', @table NVARCHAR(200) = 'gold.DIM_PROMOTION',
            @start DATETIME = GETDATE(), @rows INT = 0, @status NVARCHAR(20) = 'SUCCESS', @err NVARCHAR(MAX) = NULL;
    BEGIN TRY
        DELETE FROM gold.DIM_PROMOTION;
        INSERT INTO gold.DIM_PROMOTION (Promotion_ID, Promo_Type, Discount_Percent, Start_Date, End_Date)
        SELECT promotion_id, ISNULL(TRIM(promo_type),'Unknown'), ISNULL(discount_percent,0.00), start_date, end_date
        FROM silver.promotions WHERE promotion_id IS NOT NULL;
        SET @rows = @@ROWCOUNT;
    END TRY
    BEGIN CATCH SET @status = 'FAILED'; SET @err = ERROR_MESSAGE(); END CATCH;
    INSERT INTO gold.load_log (procedure_name,table_name,load_start_time,load_end_time,duration_seconds,rows_inserted,status,error_message)
    VALUES (@proc,@table,@start,GETDATE(),DATEDIFF(SECOND,@start,GETDATE()),@rows,@status,@err);
    IF @status = 'FAILED' RAISERROR(@err,16,1);
END;
GO

-- ===========================================================================
-- FACT_STORE_SALES
-- FIX: separate @@ROWCOUNT variables for POS and online blocks, summed at end
-- ===========================================================================
CREATE OR ALTER PROCEDURE gold.usp_load_gold_FACT_STORE_SALES AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @proc NVARCHAR(200) = 'gold.usp_load_gold_FACT_STORE_SALES', @table NVARCHAR(200) = 'gold.FACT_STORE_SALES',
            @start DATETIME = GETDATE(), @rows_pos INT = 0, @rows_online INT = 0,
            @status NVARCHAR(20) = 'SUCCESS', @err NVARCHAR(MAX) = NULL;
    BEGIN TRY
        DELETE FROM gold.FACT_STORE_SALES;

        -- ── POS (in-store) sales ────────────────────────────────────────────
        INSERT INTO gold.FACT_STORE_SALES
            (Date_Key, Store_Key, Product_Key, Customer_Key, Employee_Key, Promotion_Key, Quantity, Unit_Price, Sales_Amount)
        SELECT
            CONVERT(INT, FORMAT(CAST(t.transaction_time AS DATE),'yyyyMMdd')),
            ds.Store_Key,
            dp.Product_Key,
            dc.Customer_Key,
            de.Employee_Key,
            dpr.Promotion_Key,
            ti.quantity,
            ti.unit_price,
            ROUND(ti.quantity * ti.unit_price * (1.0 - ISNULL(dpr.Discount_Percent,0) / 100.0), 2)
        FROM silver.POS_Transactions         t
        JOIN silver.Transaction_Items        ti  ON t.transaction_id = ti.transaction_id
        JOIN gold.DIM_STORE                  ds  ON t.store_id       = ds.Store_ID
        JOIN gold.DIM_PRODUCT                dp  ON ti.product_id    = dp.Product_ID
        LEFT JOIN gold.DIM_CUSTOMER          dc  ON t.customer_id    = dc.Customer_ID
        LEFT JOIN gold.DIM_EMPLOYEE          de  ON t.employee_id    = de.Employee_ID
        LEFT JOIN gold.DIM_PROMOTION         dpr ON ti.promotion_id  = dpr.Promotion_ID
        WHERE t.transaction_time IS NOT NULL AND ti.quantity > 0 AND ti.unit_price > 0;

        SET @rows_pos = @@ROWCOUNT;   -- ← capture POS rows immediately

        -- ── Online orders ───────────────────────────────────────────────────
        INSERT INTO gold.FACT_STORE_SALES
            (Date_Key, Store_Key, Product_Key, Customer_Key, Employee_Key, Promotion_Key, Quantity, Unit_Price, Sales_Amount)
        SELECT
            CONVERT(INT, FORMAT(CAST(o.order_time AS DATE),'yyyyMMdd')),
            NULL,                     -- no physical store for online orders
            dp.Product_Key,
            dc.Customer_Key,
            NULL,                     -- no employee for online channel
            dpr.Promotion_Key,
            oi.quantity,
            oi.unit_price,
            ROUND(oi.quantity * oi.unit_price * (1.0 - ISNULL(dpr.Discount_Percent,0) / 100.0), 2)
        FROM silver.online_orders            o
        JOIN silver.online_orders_items      oi  ON o.order_id     = oi.order_id
        JOIN gold.DIM_PRODUCT                dp  ON oi.product_id  = dp.Product_ID
        LEFT JOIN gold.DIM_CUSTOMER          dc  ON o.customer_id  = dc.Customer_ID
        LEFT JOIN gold.DIM_PROMOTION         dpr ON oi.promotion_id= dpr.Promotion_ID
        WHERE o.order_time IS NOT NULL AND o.order_status <> 'Cancelled'
          AND oi.quantity > 0 AND oi.unit_price > 0;

        SET @rows_online = @@ROWCOUNT; -- ← capture online rows immediately

    END TRY
    BEGIN CATCH SET @status = 'FAILED'; SET @err = ERROR_MESSAGE(); END CATCH;

    INSERT INTO gold.load_log (procedure_name,table_name,load_start_time,load_end_time,duration_seconds,rows_inserted,status,error_message)
    VALUES (@proc,@table,@start,GETDATE(),DATEDIFF(SECOND,@start,GETDATE()),
            @rows_pos + @rows_online,   -- ← correct total
            @status,@err);
    IF @status = 'FAILED' RAISERROR(@err,16,1);
END;
GO

CREATE OR ALTER PROCEDURE gold.usp_load_gold_FACT_INVENTORY AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @proc NVARCHAR(200) = 'gold.usp_load_gold_FACT_INVENTORY', @table NVARCHAR(200) = 'gold.FACT_INVENTORY',
            @start DATETIME = GETDATE(), @rows INT = 0, @status NVARCHAR(20) = 'SUCCESS', @err NVARCHAR(MAX) = NULL;
    BEGIN TRY
        DELETE FROM gold.FACT_INVENTORY;
        INSERT INTO gold.FACT_INVENTORY (Date_Key, Store_Key, Product_Key, Stock_Level)
        SELECT CONVERT(INT, FORMAT(CAST(i.last_updated AS DATE),'yyyyMMdd')),
               ds.Store_Key, dp.Product_Key, i.stock_level
        FROM silver.Inventory   i
        JOIN gold.DIM_STORE     ds ON i.store_id   = ds.Store_ID
        JOIN gold.DIM_PRODUCT   dp ON i.product_id = dp.Product_ID
        WHERE i.last_updated IS NOT NULL AND i.stock_level >= 0;
        SET @rows = @@ROWCOUNT;
    END TRY
    BEGIN CATCH SET @status = 'FAILED'; SET @err = ERROR_MESSAGE(); END CATCH;
    INSERT INTO gold.load_log (procedure_name,table_name,load_start_time,load_end_time,duration_seconds,rows_inserted,status,error_message)
    VALUES (@proc,@table,@start,GETDATE(),DATEDIFF(SECOND,@start,GETDATE()),@rows,@status,@err);
    IF @status = 'FAILED' RAISERROR(@err,16,1);
END;
GO

-- ===========================================================================
-- MASTER PROCEDURE
-- ===========================================================================
CREATE OR ALTER PROCEDURE gold.usp_load_gold_all AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @start DATETIME = GETDATE();
    PRINT '=== Gold layer load started: ' + CONVERT(NVARCHAR,@start,120) + ' ===';

    PRINT '[1/8] DIM_DATE';       EXEC gold.usp_load_gold_DIM_DATE;
    PRINT '[2/8] DIM_STORE';      EXEC gold.usp_load_gold_DIM_STORE;
    PRINT '[3/8] DIM_PRODUCT';    EXEC gold.usp_load_gold_DIM_PRODUCT;
    PRINT '[4/8] DIM_CUSTOMER';   EXEC gold.usp_load_gold_DIM_CUSTOMER;
    PRINT '[5/8] DIM_EMPLOYEE';   EXEC gold.usp_load_gold_DIM_EMPLOYEE;
    PRINT '[6/8] DIM_PROMOTION';  EXEC gold.usp_load_gold_DIM_PROMOTION;
    PRINT '[7/8] FACT_STORE_SALES'; EXEC gold.usp_load_gold_FACT_STORE_SALES;
    PRINT '[8/8] FACT_INVENTORY'; EXEC gold.usp_load_gold_FACT_INVENTORY;

    PRINT '=== Gold layer complete. Duration: '
          + CAST(DATEDIFF(SECOND,@start,GETDATE()) AS NVARCHAR) + 's ===';

    SELECT table_name, status, rows_inserted, duration_seconds, error_message
    FROM gold.load_log
    WHERE load_start_time >= @start
    ORDER BY log_id;
END;
GO

/*
EXEC gold.usp_load_gold_all;
SELECT * FROM gold.load_log ORDER BY log_id DESC;
*/
EXEC gold.usp_load_gold_all;



