/*
====================================================================
Create Database and Schemas
====================================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists.
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas
    within the database: 'bronze', 'silver', and 'gold'.

WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists.
    All data in the database will be permanently deleted. Proceed with caution
    and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;

--Using Master Database
Use master;
GO

-- Creating The Database
Create Database Datawarehouse;

-- Using the Database
Use Datawarehouse;
GO

--Creating The Schemas(Bronze, Silver, Gold)
Create Schema Bronze;
GO
Create Schema Silver;
GO
Create Schema Gold;
GO


-- Creating the tables and extract from the source

IF OBJECT_ID ('bronze.crm_cust_info' , 'U')IS NOT NULL
		DROP TABLE bronze.crm_cust_info ;
Create table bronze.crm_cust_info(
		cst_id INT,
		cst_key NVARCHAR(50),
		cst_firstname NVARCHAR(50),
		cst_lastname NVARCHAR(50),
		cst_material_status NVARCHAR(50),
		csst_gndr NVARCHAR(50),
		cst_create_date DATE
);



IF OBJECT_ID ('bronze.crm_prd_info' , 'U')IS NOT NULL
		DROP TABLE bronze.crm_prd_info ;
Create Table bronze.crm_prd_info(
		prd_id INT,
		prd_key NVARCHAR(50),
		prd_nm NVARCHAR(50),
		prd_cost INT,
		prd_line NVARCHAR(50),
		prd_start_dt DATE,
		prd_end_dt DATE
);


IF OBJECT_ID ('bronze.crm_sales_details' , 'U')IS NOT NULL
		DROP TABLE bronze.crm_sales_details ;
Create Table bronze.crm_sales_details(
		sls_ord_nim NVARCHAR(50),
		sls_prd_key NVARCHAR(50),
		sls_cust_id INT,
		sls_order_dt INT,
		sls_ship_dt INT,
		sls_due_dt INT,
		sls_sales INT,
		sls_quantity INT,
		sls_price INT
);



IF OBJECT_ID ('bronze.erp_cust_az12' , 'U')IS NOT NULL
		DROP TABLE bronze.erp_cust_az12 ;
Create Table bronze.erp_cust_az12(
		CID NVARCHAR(50),
		BDATE Date,
		GEN NVARCHAR(50)
);



IF OBJECT_ID ('bronze.erp_loc_a101' , 'U')IS NOT NULL
		DROP TABLE bronze.erp_loc_a101 ;
Create Table bronze.erp_loc_a101(
		CID NVARCHAR(50),
		CNTRY NVARCHAR(50)
);


IF OBJECT_ID ('bronze.erp_px_cat_g1v2' , 'U')IS NOT NULL
		DROP TABLE bronze.erp_px_cat_g1v2 ;
Create Table bronze.erp_px_cat_g1v2(
		ID NVARCHAR(50),
		CAT NVARCHAR(50),
		SUBCAT NVARCHAR(50),
		MAINTENANCE  NVARCHAR(50)
);

-- Inserting the data into the tables

CREATE OR ALTER PROCEDURE Bronze.load_Bronze AS
BEGIN

	DECLARE @start_time DATETIME , @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
		BEGIN TRY
			SET @batch_start_time  = GETDATE();
			PRINT '==============================================';
			PRINT ' Loading Bronze layer ';
			PRINT '==============================================';

			PRINT '------------------------------------------------------------------------------';
			PRINT ' Loading CRM Tables ';
			PRINT '------------------------------------------------------------------------------';

			SET @start_time = GETDATE();
			PRINT ' >> Truncating table :  bronze.crm_cust_info '
			TRUNCATE TABLE  bronze.crm_cust_info;
			PRINT ' >> Inserting data into :  bronze.crm_cust_info '
			BULK INSERT bronze.crm_cust_info
			FROM 'D:\ME\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
			WITH (
						FIRSTROW = 2 ,
						FIELDTERMINATOR = ',' ,
						TABLOCK
				);
			SET @end_time = GETDATE();
			PRINT ' >> lOAD DURATION: ' + CAST(DATEDIFF(second, @start_time , @end_time ) as NVARCHAR) + ' second '
			PRINT' >>-------------------------- '

			SET @start_time = GETDATE();
			PRINT ' >> Truncating table :  bronze.crm_prd_info '
			TRUNCATE TABLE  bronze.crm_prd_info;

			PRINT ' >> Inserting data into :  bronze.crm_prd_info '
			BULK INSERT bronze.crm_prd_info
			FROM 'D:\ME\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
			WITH (
						FIRSTROW = 2 ,
						FIELDTERMINATOR = ',' ,
						TABLOCK
				);
		SET @end_time = GETDATE();
			PRINT ' >> lOAD DURATION: ' + CAST(DATEDIFF(second, @start_time , @end_time ) as NVARCHAR) + ' second '
			PRINT' >>-------------------------- '
----------------------------------------------------------------------------------------------------------
		SET @start_time = GETDATE();
			PRINT ' >> Truncating table :  bronze.crm_sales_details '
				TRUNCATE TABLE  bronze.crm_sales_details;

			PRINT ' >> Inserting data into :  bronze.crm_sales_details '
				BULK INSERT bronze.crm_sales_details
				FROM 'D:\ME\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
				WITH (
						FIRSTROW = 2 ,
						FIELDTERMINATOR = ',' ,
						TABLOCK
				);
		SET @end_time = GETDATE();
			PRINT ' >> lOAD DURATION: ' + CAST(DATEDIFF(second, @start_time , @end_time ) as NVARCHAR) + ' second '
			PRINT' >>-------------------------- '
----------------------------------------------------------------------------------------------------------
			PRINT '------------------------------------------------------------------------------';
			PRINT ' Loading CRM Tables ';
			PRINT '------------------------------------------------------------------------------';
----------------------------------------------------------------------------------------------------------
		SET @start_time = GETDATE();
			PRINT ' >> Truncating table :  bronze.erp_cust_az12 '
				TRUNCATE TABLE  bronze.erp_cust_az12;

			PRINT ' >> Inserting data into :  bronze.erp_cust_az12 '
				BULK INSERT bronze.erp_cust_az12
				FROM 'D:\ME\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
				WITH (
						FIRSTROW = 2 ,
						FIELDTERMINATOR = ',' ,
						TABLOCK
				);
		SET @end_time = GETDATE();
			PRINT ' >> lOAD DURATION: ' + CAST(DATEDIFF(second, @start_time , @end_time ) as NVARCHAR) + ' second '
			PRINT' >>-------------------------- '
----------------------------------------------------------------------------------------------------------
		SET @start_time = GETDATE();
			PRINT ' >> Truncating table :  bronze.erp_loc_a101 '
				TRUNCATE TABLE  bronze.erp_loc_a101;

			PRINT ' >> Inserting data into :  bronze.erp_loc_a101 '
				BULK INSERT bronze.erp_loc_a101
				FROM 'D:\ME\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
				WITH (
						FIRSTROW = 2 ,
						FIELDTERMINATOR = ',' ,
						TABLOCK
				);
		SET @end_time = GETDATE();
			PRINT ' >> lOAD DURATION: ' + CAST(DATEDIFF(second, @start_time , @end_time ) as NVARCHAR) + ' second '
			PRINT' >>-------------------------- '
----------------------------------------------------------------------------------------------------------
		SET @start_time = GETDATE();
			PRINT ' >> Truncating table :  bronze.erp_px_cat_g1v2 '
				TRUNCATE TABLE  bronze.erp_px_cat_g1v2;

			PRINT ' >> Inserting data into :  bronze.erp_px_cat_g1v2 '
				BULK INSERT bronze.erp_px_cat_g1v2
				FROM 'D:\ME\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
				WITH (
						FIRSTROW = 2 ,
						FIELDTERMINATOR = ',' ,
						TABLOCK
				);
		SET @end_time = GETDATE();
			PRINT ' >> lOAD DURATION: ' + CAST(DATEDIFF(second, @start_time , @end_time ) as NVARCHAR) + ' second '
			PRINT' >>-------------------------- '

			SET @batch_end_time  = GETDATE();
			PRINT '==================================='
			PRINT ' Loading bronze layer is completed ';
			PRINT ' >> TOTAL lOAD DURATION: ' + CAST(DATEDIFF(second, @batch_start_time , @batch_end_time ) as NVARCHAR) + ' second ';
			PRINT '==================================='

		END TRY
			BEGIN CATCH
				PRINT '==================================='
				PRINT ' ERROR OCCURED DURING LOADING BRONZE LAYER'
				PRINT 'Error message' + ERROR_MESSAGE();
				PRINT 'Error message' + CAST(ERROR_NUMBER() AS NVARCHAR);
				PRINT 'Error message' + CAST(ERROR_STATE() AS NVARCHAR);
				PRINT '==================================='
			END CATCH
END

