/*
=========================================================
Stored Procedure: load silver Layer (Bronze -> Silver)
=========================================================
Script Purpose:
    This Stored performs the ETL (Extract, Transform, Load) Process to populate the 'silver' schema tables from the 'bronze' schema.
actions performed:
  - Truncates silver tables.
  - Inserts transformed and cleansed data from bronze into silver tables.

Parameters:
    None.
    This Stored Procedure does not accept any parameters or return any values.

Usage Example:
    EXEC silver.load_silver;
=========================================================
*/

Create Or Alter Procedure silver.load_silver AS
Begin

-- First Table [silver.crm_cust_info]
Print '>> Truncate Table: silver.crm_cust_info'
Truncate Table silver.crm_cust_info
Print '>> Inserting Data into: silver.crm_cust_info'

INSERT INTO silver.crm_cust_info(
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_material_status,
			csst_gndr,
			cst_create_date
)
SELECT 
			cst_id,
			cst_key,
			TRIM(cst_firstname) as cst_firstname,
			TRIM(cst_lastname)as cst_lastname,
CASE	WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single'
			WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married'
			ELSE 'n/a' -- Normalize material statues values to readable format.
END cst_material_status,
CASE	 WHEN UPPER(TRIM(csst_gndr)) = 'F' THEN 'Female'
			 WHEN UPPER(TRIM(csst_gndr)) = 'M' THEN 'Male'
			 ELSE 'n/a' -- Normalize gender values to readable format.
END csst_gndr,
			cst_create_date
FROM
			(SELECT 
			*,
			ROW_NUMBER() OVER ( PARTITION BY cst_id ORDER BY cst_create_date DESC ) AS flag_last
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL ) t
WHERE flag_last = 1; -- Select the most recent record per customer


-- Second Table [silver.crm_prd_info]
Print '>> Truncate Table: silver.crm_prd_info'
Truncate Table silver.crm_prd_info
Print '>> Inserting Data into: silver.crm_prd_info'

INSERT INTO silver.crm_prd_info(
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
)
SELECT 
	prd_id,
	Replace(SUBSTRING(prd_key, 1, 5), '-', '_') As cat_id , -- Extract category ID
	SUBSTRING(prd_key, 7, len(prd_key)) As prd_key, -- Extract product key
	prd_nm,
	ISNULL(prd_cost,0) AS prd_cost,
	CASE  UPPER(TRIM(prd_line)) 
				WHEN 'M' THEN 'Mountain'
				WHEN 'R' THEN 'Road'
				WHEN 'S' THEN 'Other Sales'
				WHEN 'T' THEN 'Touring'
				ELSE 'n/a'
	END AS prd_line, -- Map product line codes to descriptive values
	prd_start_dt,
    DATEADD(DAY, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) AS prd_end_dt -- Calculate end data as one day before the next start date
From bronze.crm_prd_info 


-- Third Table [silver.crm_prd_info]
Print '>> Truncate Table: silver.crm_sales_details'
Truncate Table silver.crm_sales_details
Print '>> Inserting Data into: silver.crm_sales_details'

INSERT INTO silver.crm_sales_details(
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price )
SELECT 
		sls_ord_nim,
		sls_prd_key,
		sls_cust_id,
		CASE 
				WHEN sls_order_dt = 0 OR LEN( sls_order_dt ) != 8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE ) 
		END AS sls_order_dt,
		CASE 
				WHEN sls_ship_dt = 0 OR LEN( sls_ship_dt ) != 8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE ) 
		END AS sls_ship_dt,
		CASE 
				WHEN sls_due_dt = 0 OR LEN( sls_due_dt ) != 8 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE ) 
		END AS sls_due_dt,
		CASE
				WHEN sls_sales IS NULL OR sls_sales  <= 0 OR sls_sales != sls_quantity * ABS (sls_price)
						THEN sls_quantity * ABS (sls_price)
				ELSE sls_sales
		END AS sls_sales, --Recalculate Sales if original value is missing or incorrect
		sls_quantity,
		CASE 
				WHEN sls_price IS NULL OR sls_price <= 0 
						THEN sls_sales / NULLIF(sls_quantity, 0)
		ELSE sls_price
		END AS sls_price -- Derive price if original value is invalid
FROM  bronze.crm_sales_details



-- Fourth Table [silver.erp_cust_az12]
Print '>> Truncate Table: silver.erp_cust_az12'
Truncate Table silver.erp_cust_az12
Print '>> Inserting Data into: silver.erp_cust_az12'

 INSERT INTO silver.erp_cust_az12(
 cid,
 bdate,
 gen
 )
SELECT 
		CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID, 4, LEN(CID))    --Remove 'NAS' prefix if present
			ELSE CID
		END AS CID,
		CASE WHEN BDATE > GETDATE() THEN NULL
			ELSE BDATE
		END AS BDATE,   -- Set Futures birthdates to NULL
		CASE WHEN  Upper(TRIM(GEN)) IN ('F','FEMALE') THEN 'FEMALE'
					WHEN  Upper(TRIM(GEN)) IN ('M','MALE') THEN 'MALE'
			ELSE 'N/A'		
		END AS GEN   -- Normalize gender values and Handle unknown cases
FROM bronze.erp_cust_az12


-- Fifth Table [silver.erp_loc_a101]
Print '>> Truncate Table: silver.erp_loc_a101'
Truncate Table silver.erp_loc_a101
Print '>> Inserting Data into: silver.erp_loc_a101'

INSERT INTO silver.erp_loc_a101 (cid, cntry)
Select 
REPLACE(cid, '-', '') AS cid,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
			WHEN TRIM(cntry) IN ('USA','US') THEN 'United States'
			WHEN TRIM(cntry) = ' ' OR cntry IS NULL THEN 'n/a'
			ELSE TRIM(cntry)
END AS cntry    -- Normmalize and Handle missing or blanck country codes
From bronze.erp_loc_a101


-- Sixth Table [silver.erp_px_cat_g1v2]
Print '>> Truncate Table: silver.erp_px_cat_g1v2'
Truncate Table silver.erp_px_cat_g1v2
Print '>> Inserting Data into: silver.erp_px_cat_g1v2'

INSERT INTO silver.erp_px_cat_g1v2(
id,
cat,
subcat,
maintenance)
Select 
ID,
CAT,
SUBCAT,
MAINTENANCE
from bronze.erp_px_cat_g1v2
 
 END
