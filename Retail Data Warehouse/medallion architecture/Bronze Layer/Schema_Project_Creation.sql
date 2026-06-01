USE master;
GO

-- Drop and recreate the 'Project' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Project')
BEGIN
    ALTER DATABASE Project SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Project;
END;

create database Project 
use Project


IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'bronze')
    EXEC('CREATE SCHEMA bronze');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver')
    EXEC('CREATE SCHEMA silver');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'gold')
    EXEC('CREATE SCHEMA gold');
GO