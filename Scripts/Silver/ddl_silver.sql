/* 
=========================================================
DDL Scripts: Create Silver Tables
=========================================================
Script Parpose:
    This scripts tables in the 'silver' schema, dropping existing tables if they already exist.
    Run this script to re-define the DDL structure of 'bronze' Tables
=========================================================
*/

IF OBJECT_ID ('silver.crm_cust_info' , 'U')IS NOT NULL
		DROP TABLE silver.crm_cust_info ;
Go
  
Create table silver.crm_cust_info(
		cst_id INT,
		cst_key NVARCHAR(50),
		cst_firstname NVARCHAR(50),
		cst_lastname NVARCHAR(50),
		cst_material_status NVARCHAR(50),
		csst_gndr NVARCHAR(50),
		cst_create_date DATE,
		dwh_create_date DATETIME2 Default GETDATE   ()
);



IF OBJECT_ID ('silver.crm_prd_info' , 'U')IS NOT NULL
		DROP TABLE silver.crm_prd_info ;
Create Table silver.crm_prd_info(
		prd_id INT,
		cat_id  NVARCHAR(50),
		prd_key NVARCHAR(50),
		prd_nm NVARCHAR(50),
		prd_cost INT,
		prd_line NVARCHAR(50),
		prd_start_dt DATE,
		prd_end_dt DATE,
		dwh_create_date DATETIME2 Default GETDATE   ()
);


IF OBJECT_ID ('silver.crm_sales_details' , 'U')IS NOT NULL
		DROP TABLE silver.crm_sales_details ;
Create Table silver.crm_sales_details(
		sls_ord_nim NVARCHAR(50),
		sls_prd_key NVARCHAR(50),
		sls_cust_id INT,
		sls_order_dt INT,
		sls_ship_dt INT,
		sls_due_dt INT,
		sls_sales INT,
		sls_quantity INT,
		sls_price INT,
		dwh_create_date DATETIME2 Default GETDATE   ()
);



IF OBJECT_ID ('silver.erp_cust_az12' , 'U')IS NOT NULL
		DROP TABLE silver.erp_cust_az12 ;
Create Table silver.erp_cust_az12(
		CID NVARCHAR(50),
		BDATE Date,
		GEN NVARCHAR(50),
		dwh_create_date DATETIME2 Default GETDATE   ()
);



IF OBJECT_ID ('silver.erp_loc_a101' , 'U')IS NOT NULL
		DROP TABLE silver.erp_loc_a101 ;
Create Table silver.erp_loc_a101(
		CID NVARCHAR(50),
		CNTRY NVARCHAR(50),
		dwh_create_date DATETIME2 Default GETDATE   ()
);


IF OBJECT_ID ('silver.erp_px_cat_g1v2' , 'U')IS NOT NULL
		DROP TABLE silver.erp_px_cat_g1v2 ;
Create Table silver.erp_px_cat_g1v2(
		ID NVARCHAR(50),
		CAT NVARCHAR(50),
		SUBCAT NVARCHAR(50),
		MAINTENANCE  NVARCHAR(50),
		dwh_create_date DATETIME2 Default GETDATE   ()
);

-- Inserting the data into the tables

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN

	DECLARE @start_time DATETIME , @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
		BEGIN TRY
			SET @batch_start_time  = GETDATE();
			PRINT '==============================================';
			PRINT ' Loading silver layer ';
			PRINT '==============================================';

			PRINT '------------------------------------------------------------------------------';
			PRINT ' Loading CRM Tables ';
			PRINT '------------------------------------------------------------------------------';

			SET @start_time = GETDATE();
			PRINT ' >> Truncating table :  silver.crm_cust_info '
			TRUNCATE TABLE  silver.crm_cust_info;
			PRINT ' >> Inserting data into :  silver.crm_cust_info '
			BULK INSERT silver.crm_cust_info
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
			PRINT ' >> Truncating table :  silver.crm_prd_info '
			TRUNCATE TABLE  silver.crm_prd_info;

			PRINT ' >> Inserting data into :  silver.crm_prd_info '
			BULK INSERT silver.crm_prd_info
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
			PRINT ' >> Truncating table :  silver.crm_sales_details '
				TRUNCATE TABLE  silver.crm_sales_details;

			PRINT ' >> Inserting data into :  silver.crm_sales_details '
				BULK INSERT silver.crm_sales_details
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
			PRINT ' >> Truncating table :  silver.erp_cust_az12 '
				TRUNCATE TABLE  silver.erp_cust_az12;

			PRINT ' >> Inserting data into :  silver.erp_cust_az12 '
				BULK INSERT silver.erp_cust_az12
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
			PRINT ' >> Truncating table :  silver.erp_loc_a101 '
				TRUNCATE TABLE  silver.erp_loc_a101;

			PRINT ' >> Inserting data into :  silver.erp_loc_a101 '
				BULK INSERT silver.erp_loc_a101
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
			PRINT ' >> Truncating table :  silver.erp_px_cat_g1v2 '
				TRUNCATE TABLE  silver.erp_px_cat_g1v2;

			PRINT ' >> Inserting data into :  silver.erp_px_cat_g1v2 '
				BULK INSERT silver.erp_px_cat_g1v2
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
			PRINT ' Loading silver layer is completed ';
			PRINT ' >> TOTAL lOAD DURATION: ' + CAST(DATEDIFF(second, @batch_start_time , @batch_end_time ) as NVARCHAR) + ' second ';
			PRINT '==================================='

		END TRY
			BEGIN CATCH
				PRINT '==================================='
				PRINT ' ERROR OCCURED DURING LOADING silver LAYER'
				PRINT 'Error message' + ERROR_MESSAGE();
				PRINT 'Error message' + CAST(ERROR_NUMBER() AS NVARCHAR);
				PRINT 'Error message' + CAST(ERROR_STATE() AS NVARCHAR);
				PRINT '==================================='
			END CATCH
END

