-- cust_info_Table
-- Check For Nulls or Duplicates in primary key
-- Expectation: No results

SELECT 
cst_id,
COUNT(*)
From bronze.crm_cust_info
Group by  cst_id
HAVING COUNT(*) > 1 or cst_id is null


-- Check for unwanted Spaces
-- EXpectation: No Results
  -- Remove un nesessary spaces
-- Remove Duplicates
-- Normalize the values
-- Inserting after cleaning 

SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE  cst_firstname != TRIM(cst_firstname)
go
SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE  cst_lastname != TRIM(cst_lastname)
go
SELECT csst_gndr
FROM bronze.crm_cust_info
WHERE  csst_gndr != TRIM(csst_gndr)
go



-- prd_info Table
-- Check For Nulls or Duplicates in primary key
-- Expectation: No results
 
SELECT 
prd_id,
COUNT(*)
FROM bronze.crm_prd_info
Group by prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL ; 

-- Check for unwanted spaces
-- Expectation: No results
SELECT prd_nm 
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for Negative and Null Values
-- Expectation: No results
SELECT prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data Standarization and Consistency
-- Expectation: No results
SELECT DISTINCT prd_line 
FROM silver.crm_prd_info;

-- Check for invalid Date Orders
-- Expectation: No results
SELECT * 
FROM silver.crm_prd_info
WHERE  prd_start_dt > prd_end_dt;



-- sales_details Table
select * from silver.crm_sales_details


-- Check the relation 
select * from silver.crm_sales_details
WHERE sls_cust_id Not in (Select cst_id From silver.crm_cust_info);

-- Check for Invalid Dates
SELECT 
NullIf ( sls_order_dt , 0 ) AS sls_order_dt
FROM silver.crm_sales_details
Where sls_order_dt <= 0 OR LEN( sls_order_dt ) != 8

select * from silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt  > sls_due_dt

-- Check for data Consisty between : Quantity, Price, Sales
-- >> Sales = Quantity * Price
-- >> Values must be Not Null, Not Negative, Not Zero

SELECT DISTINCT 
sls_sales AS old_sls_sales ,
sls_quantity  ,
sls_price AS old_sls_price,
CASE WHEN sls_sales IS NULL OR sls_sales  <= 0 OR sls_sales != sls_quantity * ABS (sls_price)
			THEN sls_quantity * ABS (sls_price)
ELSE sls_sales
END AS sls_sales,
CASE WHEN sls_price IS NULL OR sls_price <= 0 
			THEN sls_sales / NULLIF(sls_quantity, 0)
ELSE sls_price
END AS sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price 
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0


-- erp_cast_az12
SELECT  * FROM bronze.erp_cust_az12

-- Check for consistency & Standarization
SELECT DISTINCT gen
 FROM silver.erp_cust_az12

 -- Check for invalid Dates
 SELECT  bdate FROM silver.erp_cust_az12
 WHERE  bdate > GETDATE()


-- erp_loc_a101

SELECT *FROM bronze.erp_loc_a101


-- Check data Standardization & Consistency
Select Distinct cntry 
From silver.erp_loc_a101

-- Check for Un necessary spaces
Select cid
From silver.erp_loc_a101

-- Recreate the table 
IF OBJECT_ID ('silver.erp_loc_a101' , 'U')IS NOT NULL
		DROP TABLE silver.erp_loc_a101 ;
Create Table silver.erp_loc_a101(
		cid NVARCHAR(50),
		cntry VARCHAR(50),
		dwh_create_date DATETIME2 Default GETDATE   ()
);

-- erp_px_cat_g1v2

Select * from bronze.erp_px_cat_g1v2

Select * from silver.crm_prd_info

-- Check for un wanted spaces
Select *
From bronze.erp_px_cat_g1v2
WHERE  CAT != TRIM(CAT) OR SUBCAT != TRIM(SUBCAT) OR MAINTENANCE != TRIM(MAINTENANCE)

--Recreate the Table
IF OBJECT_ID ('silver.erp_px_cat_g1v2' , 'U')IS NOT NULL
		DROP TABLE bronze.erp_px_cat_g1v2 ;
Create Table bronze.erp_px_cat_g1v2(
		id NVARCHAR(50),
		cat NVARCHAR(50),
		subcat NVARCHAR(50),
		maintenance  NVARCHAR(50),
		dwh_create_date DATETIME2 Default GETDATE   ()
);


