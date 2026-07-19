/*
===================================================================
Stored Procedure: load Bronze Layer (Source -> Bronze)
===================================================================
Script Purpose:
    This script procedure loads data into the 'bronze' schema from external CSV files.
    It performs the follwing actions:
    - Truncate the bronze tables before loading data.
    - Uses the  "BULK INSERT" command to load data from csv files to bronze tables.

Parameters:
    None.
  This Stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Bronze.load_Bronze;
===================================================================
*/

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

