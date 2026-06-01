/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
*/

USE Project;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @start_time DATETIME,
        @end_time DATETIME,
        @rows INT,
        @table_name NVARCHAR(200),
        @proc_name NVARCHAR(200) = 'bronze.load_bronze';

    PRINT '======================================';
    PRINT 'Starting Bronze Layer Load';
    PRINT 'Procedure: bronze.load_bronze';
    PRINT 'Start Time: ' + CAST(GETDATE() AS NVARCHAR(50));
    PRINT '======================================';

    BEGIN TRY

        /* =======================================================
           Enable OPENROWSET if not already enabled
        ======================================================== */
        IF NOT EXISTS (
            SELECT 1
            FROM sys.configurations
            WHERE name = 'Ad Hoc Distributed Queries'
            AND value_in_use = 1
        )
        BEGIN
            PRINT '>> Enabling Ad Hoc Distributed Queries (OPENROWSET)...';

            EXEC sp_configure 'show advanced options', 1;
            RECONFIGURE;

            EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
            RECONFIGURE;

            PRINT '>> OPENROWSET Enabled Successfully';
        END
        ELSE
        BEGIN
            PRINT '>> OPENROWSET Already Enabled';
        END;

        PRINT '================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '================================================';

        /* =======================================================
           DATA TABLES
        ======================================================== */
        PRINT '------------------------------------------------';
        PRINT 'Loading DATA Tables';
        PRINT '------------------------------------------------';

        -- ------------------- bronze.brands -------------------
        SET @table_name = 'bronze.brands';
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: ' + @table_name;
        TRUNCATE TABLE bronze.brands;

        PRINT '>> Inserting Data Into: ' + @table_name;
        BULK INSERT bronze.brands
        FROM 'D:\Sem 6\Business Intelligence\Project\datasets\bi_full_dataset\BRANDS.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a',
            TABLOCK,
            CODEPAGE = '65001'
        );

        SET @rows = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Inserted Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        INSERT INTO bronze.load_log
        VALUES
        (@proc_name,@table_name,@start_time,@end_time,
        DATEDIFF(SECOND,@start_time,@end_time),@rows,'SUCCESS',NULL);

        -- ------------------- bronze.customers -------------------
        SET @table_name = 'bronze.customers';
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: ' + @table_name;
        TRUNCATE TABLE bronze.customers;

        PRINT '>> Inserting Data Into: ' + @table_name;
        BULK INSERT bronze.customers
        FROM 'D:\Sem 6\Business Intelligence\Project\datasets\bi_full_dataset\CUSTOMERS.csv' 
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a',
            TABLOCK,
            CODEPAGE = '65001'
        );

        SET @rows = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Inserted Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        INSERT INTO bronze.load_log
        VALUES
        (@proc_name,@table_name,@start_time,@end_time,
        DATEDIFF(SECOND,@start_time,@end_time),@rows,'SUCCESS',NULL);

        -- ------------------- bronze.data_quality_report -------------------
        SET @table_name = 'bronze.data_quality_report';
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: ' + @table_name;
        TRUNCATE TABLE bronze.data_quality_report;

        PRINT '>> Inserting Data Into: ' + @table_name;
        BULK INSERT bronze.data_quality_report
        FROM 'D:\Sem 6\Business Intelligence\Project\datasets\bi_full_dataset\DATA_QUALITY_REPORT.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a',
            TABLOCK,
            CODEPAGE = '65001'
        );

        SET @rows = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Inserted Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        INSERT INTO bronze.load_log
        VALUES
        (@proc_name,@table_name,@start_time,@end_time,
        DATEDIFF(SECOND,@start_time,@end_time),@rows,'SUCCESS',NULL);

        
        -- ------------------- bronze.deliveries -------------------
        SET @table_name = 'bronze.deliveries';
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: ' + @table_name;
        TRUNCATE TABLE bronze.deliveries;

        PRINT '>> Inserting Data Into: ' + @table_name;
        BULK INSERT bronze.deliveries
        FROM 'D:\Sem 6\Business Intelligence\Project\datasets\bi_full_dataset\DELIVERIES.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a',
            TABLOCK,
            CODEPAGE = '65001'
        );

        SET @rows = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Inserted Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        INSERT INTO bronze.load_log
        VALUES
        (@proc_name,@table_name,@start_time,@end_time,
        DATEDIFF(SECOND,@start_time,@end_time),@rows,'SUCCESS',NULL);

         -- ------------------- bronze.delivery_providers -------------------
        SET @table_name = 'bronze.delivery_providers';
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: ' + @table_name;
        TRUNCATE TABLE bronze.delivery_providers;

        PRINT '>> Inserting Data Into: ' + @table_name;
        BULK INSERT bronze.delivery_providers
        FROM 'D:\Sem 6\Business Intelligence\Project\datasets\bi_full_dataset\DELIVERY_PROVIDERS.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a',
            TABLOCK,
            CODEPAGE = '65001'
        );

        SET @rows = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Inserted Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        INSERT INTO bronze.load_log
        VALUES
        (@proc_name,@table_name,@start_time,@end_time,
        DATEDIFF(SECOND,@start_time,@end_time),@rows,'SUCCESS',NULL);

        -- ------------------- bronze.departments -------------------
        SET @table_name = 'bronze.departments';
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: ' + @table_name;
        TRUNCATE TABLE bronze.departments;

        PRINT '>> Inserting Data Into: ' + @table_name;
        BULK INSERT bronze.departments
        FROM 'D:\Sem 6\Business Intelligence\Project\datasets\bi_full_dataset\DEPARTMENTS.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a',
            TABLOCK,
            CODEPAGE = '65001'
        );

        SET @rows = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Inserted Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        INSERT INTO bronze.load_log
        VALUES
        (@proc_name,@table_name,@start_time,@end_time,
        DATEDIFF(SECOND,@start_time,@end_time),@rows,'SUCCESS',NULL);

    -- ------------------- bronze.employees -------------------
        SET @table_name = 'bronze.employees';
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: ' + @table_name;
        TRUNCATE TABLE bronze.employees;

        PRINT '>> Inserting Data Into: ' + @table_name;
        BULK INSERT bronze.employees
        FROM 'D:\Sem 6\Business Intelligence\Project\datasets\bi_full_dataset\EMPLOYEES.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a',
            TABLOCK,
            CODEPAGE = '65001'
        );

        SET @rows = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Inserted Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        INSERT INTO bronze.load_log
        VALUES
        (@proc_name,@table_name,@start_time,@end_time,
        DATEDIFF(SECOND,@start_time,@end_time),@rows,'SUCCESS',NULL);


 -- ------------------- bronze.inventory -------------------
        SET @table_name = 'bronze.inventory';
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: ' + @table_name;
        TRUNCATE TABLE bronze.inventory;

        PRINT '>> Inserting Data Into: ' + @table_name;
        BULK INSERT bronze.inventory
        FROM 'D:\Sem 6\Business Intelligence\Project\datasets\bi_full_dataset\INVENTORY.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a',
            TABLOCK,
            CODEPAGE = '65001'
        );

        SET @rows = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Inserted Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        INSERT INTO bronze.load_log
        VALUES
        (@proc_name,@table_name,@start_time,@end_time,
        DATEDIFF(SECOND,@start_time,@end_time),@rows,'SUCCESS',NULL);

 -- ------------------- bronze.online_orders_items -------------------
        SET @table_name = 'bronze.online_orders_items';
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: ' + @table_name;
        TRUNCATE TABLE bronze.online_orders_items;

        PRINT '>> Inserting Data Into: ' + @table_name;
        BULK INSERT bronze.online_orders_items
        FROM 'D:\Sem 6\Business Intelligence\Project\datasets\bi_full_dataset\ONLINE_ORDER_ITEMS.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a',
            TABLOCK,
            CODEPAGE = '65001'
        );

        SET @rows = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Inserted Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        INSERT INTO bronze.load_log
        VALUES
        (@proc_name,@table_name,@start_time,@end_time,
        DATEDIFF(SECOND,@start_time,@end_time),@rows,'SUCCESS',NULL);

    -- ------------------- bronze.online_orders -------------------
        SET @table_name = 'bronze.online_orders';
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: ' + @table_name;
        TRUNCATE TABLE bronze.online_orders;

        PRINT '>> Inserting Data Into: ' + @table_name;
        BULK INSERT bronze.online_orders
        FROM 'D:\Sem 6\Business Intelligence\Project\datasets\bi_full_dataset\ONLINE_ORDERS.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a',
            TABLOCK,
            CODEPAGE = '65001'
        );

        SET @rows = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Inserted Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        INSERT INTO bronze.load_log
        VALUES
        (@proc_name,@table_name,@start_time,@end_time,
        DATEDIFF(SECOND,@start_time,@end_time),@rows,'SUCCESS',NULL);

    -- ------------------- bronze.payments -------------------
        SET @table_name = 'bronze.payments';
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: ' + @table_name;
        TRUNCATE TABLE bronze.payments;

        PRINT '>> Inserting Data Into: ' + @table_name;
        BULK INSERT bronze.payments
        FROM 'D:\Sem 6\Business Intelligence\Project\datasets\bi_full_dataset\PAYMENTS.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a',
            TABLOCK,
            CODEPAGE = '65001'
        );

        SET @rows = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Inserted Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        INSERT INTO bronze.load_log
        VALUES
        (@proc_name,@table_name,@start_time,@end_time,
        DATEDIFF(SECOND,@start_time,@end_time),@rows,'SUCCESS',NULL);

     -- ------------------- bronze.POS_Transactions -------------------
        SET @table_name = 'bronze.POS_Transactions';
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: ' + @table_name;
        TRUNCATE TABLE bronze.POS_Transactions;

        PRINT '>> Inserting Data Into: ' + @table_name;
        BULK INSERT bronze.POS_Transactions
        FROM 'D:\Sem 6\Business Intelligence\Project\datasets\bi_full_dataset\POS_TRANSACTIONS.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a',
            TABLOCK,
            CODEPAGE = '65001'
        );

        SET @rows = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Inserted Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        INSERT INTO bronze.load_log
        VALUES
        (@proc_name,@table_name,@start_time,@end_time,
        DATEDIFF(SECOND,@start_time,@end_time),@rows,'SUCCESS',NULL);

     -- ------------------- bronze.Product_Suppliers -------------------
        SET @table_name = 'bronze.Product_Suppliers';
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: ' + @table_name;
        TRUNCATE TABLE bronze.Product_Suppliers;

        PRINT '>> Inserting Data Into: ' + @table_name;
        BULK INSERT bronze.Product_Suppliers
        FROM 'D:\Sem 6\Business Intelligence\Project\datasets\bi_full_dataset\PRODUCT_SUPPLIERS.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a',
            TABLOCK,
            CODEPAGE = '65001'
        );

        SET @rows = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Inserted Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        INSERT INTO bronze.load_log
        VALUES
        (@proc_name,@table_name,@start_time,@end_time,
        DATEDIFF(SECOND,@start_time,@end_time),@rows,'SUCCESS',NULL);

    -- ------------------- bronze.products -------------------
        SET @table_name = 'bronze.products';
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: ' + @table_name;
        TRUNCATE TABLE bronze.products;

        PRINT '>> Inserting Data Into: ' + @table_name;
        BULK INSERT bronze.products
        FROM 'D:\Sem 6\Business Intelligence\Project\datasets\bi_full_dataset\PRODUCTS.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a',
            TABLOCK,
            CODEPAGE = '65001'
        );

        SET @rows = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Inserted Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        INSERT INTO bronze.load_log
        VALUES
        (@proc_name,@table_name,@start_time,@end_time,
        DATEDIFF(SECOND,@start_time,@end_time),@rows,'SUCCESS',NULL);

 -- ------------------- bronze.promotions -------------------
        SET @table_name = 'bronze.promotions';
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: ' + @table_name;
        TRUNCATE TABLE bronze.promotions;

        PRINT '>> Inserting Data Into: ' + @table_name;
        BULK INSERT bronze.promotions
        FROM 'D:\Sem 6\Business Intelligence\Project\datasets\bi_full_dataset\PROMOTIONS.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a',
            TABLOCK,
            CODEPAGE = '65001'
        );

        SET @rows = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Inserted Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        INSERT INTO bronze.load_log
        VALUES
        (@proc_name,@table_name,@start_time,@end_time,
        DATEDIFF(SECOND,@start_time,@end_time),@rows,'SUCCESS',NULL);
       
     -- ------------------- bronze.registers -------------------
        SET @table_name = 'bronze.registers';
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: ' + @table_name;
        TRUNCATE TABLE bronze.registers;

        PRINT '>> Inserting Data Into: ' + @table_name;
        BULK INSERT bronze.registers
        FROM 'D:\Sem 6\Business Intelligence\Project\datasets\bi_full_dataset\REGISTERS.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a',
            TABLOCK,
            CODEPAGE = '65001'
        );

        SET @rows = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Inserted Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        INSERT INTO bronze.load_log
        VALUES
        (@proc_name,@table_name,@start_time,@end_time,
        DATEDIFF(SECOND,@start_time,@end_time),@rows,'SUCCESS',NULL);

      -- ------------------- bronze.stores -------------------
        SET @table_name = 'bronze.stores';
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: ' + @table_name;
        TRUNCATE TABLE bronze.stores;

        PRINT '>> Inserting Data Into: ' + @table_name;
        BULK INSERT bronze.stores
        FROM 'D:\Sem 6\Business Intelligence\Project\datasets\bi_full_dataset\STORES.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a',
            TABLOCK,
            CODEPAGE = '65001'
        );

        SET @rows = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Inserted Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        INSERT INTO bronze.load_log
        VALUES
        (@proc_name,@table_name,@start_time,@end_time,
        DATEDIFF(SECOND,@start_time,@end_time),@rows,'SUCCESS',NULL);

    
      -- ------------------- bronze.suppliers -------------------
        SET @table_name = 'bronze.suppliers'
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: ' + @table_name;
        TRUNCATE TABLE bronze.suppliers;

        PRINT '>> Inserting Data Into: ' + @table_name;
        BULK INSERT bronze.suppliers
        FROM 'D:\Sem 6\Business Intelligence\Project\datasets\bi_full_dataset\SUPPLIERS.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a',
            TABLOCK,
            CODEPAGE = '65001'
        );

        SET @rows = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Inserted Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        INSERT INTO bronze.load_log
        VALUES
        (@proc_name,@table_name,@start_time,@end_time,
        DATEDIFF(SECOND,@start_time,@end_time),@rows,'SUCCESS',NULL);

     -- ------------------- bronze.Transaction_Items -------------------
        SET @table_name = 'bronze.Transaction_Items'
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: ' + @table_name;
        TRUNCATE TABLE bronze.Transaction_Items;

        PRINT '>> Inserting Data Into: ' + @table_name;
        BULK INSERT bronze.Transaction_Items
        FROM 'D:\Sem 6\Business Intelligence\Project\datasets\bi_full_dataset\TRANSACTION_ITEMS.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a',
            TABLOCK,
            CODEPAGE = '65001'
        );

        SET @rows = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Inserted Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        INSERT INTO bronze.load_log
        VALUES
        (@proc_name,@table_name,@start_time,@end_time,
        DATEDIFF(SECOND,@start_time,@end_time),@rows,'SUCCESS',NULL);

    -- ------------------- bronze.warehouses -------------------
        SET @table_name = 'bronze.warehouses'
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: ' + @table_name;
        TRUNCATE TABLE bronze.warehouses;

        PRINT '>> Inserting Data Into: ' + @table_name;
        BULK INSERT bronze.warehouses
        FROM 'D:\Sem 6\Business Intelligence\Project\datasets\bi_full_dataset\WAREHOUSES.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a',
            TABLOCK,
            CODEPAGE = '65001'
        );

        SET @rows = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Inserted Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        INSERT INTO bronze.load_log
        VALUES
        (@proc_name,@table_name,@start_time,@end_time,
        DATEDIFF(SECOND,@start_time,@end_time),@rows,'SUCCESS',NULL);

        PRINT '==========================================';
        PRINT 'Loading Bronze Layer Completed Successfully';
        PRINT 'End Time: ' + CAST(GETDATE() AS NVARCHAR(50));
        PRINT '==========================================';

    END TRY

    BEGIN CATCH
        PRINT 'ERROR OCCURRED';
        PRINT ERROR_MESSAGE();

        INSERT INTO bronze.load_log
        VALUES
        (
            @proc_name,
            @table_name,
            @start_time,
            GETDATE(),
            NULL,
            NULL,
            'FAILED',
            ERROR_MESSAGE()
        );
    END CATCH
END

EXEC bronze.load_bronze;