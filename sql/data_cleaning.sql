-- ============================================
-- NHS A&E Data Cleaning & Transformation
-- ============================================
-- Purpose: Clean, standardize, and prepare NHS A&E data for Power BI visualization
-- Source: NHS England A&E Attendances - December 2025
-- Output: nhs_ae_cleaned table
-- 
-- Author: Davina Adu
-- Date: February 2026
--
-- Transformations:
-- - Handle clinical suppression marks (-)
-- - Type casting (NVARCHAR → INT/DECIMAL)
-- - Remove % symbols from performance metrics
-- - Semantic column renaming for clarity
-- ============================================

-- SQL Code
SELECT 
org_code,
region,
org_name,
TRY_CAST (NULLIF (total_att_t1, '-') AS INT) AS total_att_type_1,
TRY_CAST (NULLIF (total_att_t2, '-') AS INT) AS total_att_type_2, 
TRY_CAST (NULLIF (total_att_t3, '-') AS INT) AS total_att_type_3,
TRY_CAST (NULLIF (total_att_all, '-') AS INT) AS total_att,
TRY_CAST (NULLIF (under4_t1, '-') AS INT) AS seen_under_4hr_type_1,
TRY_CAST (NULLIF (under4_t2, '-') AS INT) AS seen_under_4hr_type_2,
TRY_CAST (NULLIF (under4_t3, '-') AS INT) AS seen_under_4hr_type_3,
TRY_CAST (NULLIF (under4_all, '-') AS INT) AS seen_under_4hr_total,
TRY_CAST (NULLIF (over4_t1, '-') AS INT) AS waits_over_4hr_type_1,
TRY_CAST (NULLIF (over4_t2, '-') AS INT) AS waits_over_4hr_type_2,
TRY_CAST (NULLIF (over4_t3, '-') AS INT) AS waits_over_4hr_type_3,
TRY_CAST (NULLIF (over4_all, '-') AS INT) AS waits_over_4hr_total,
TRY_CAST (REPLACE (NULLIF (pct_all, '-'), '%', '') AS DECIMAL (10,2)) AS performance_pct_total,
TRY_CAST (REPLACE (NULLIF (pct_t1, '-'), '%', '') AS DECIMAL (10,2)) AS performance_pct_type_1,
TRY_CAST (REPLACE (NULLIF (pct_t2, '-'), '%', '') AS DECIMAL (10,2)) AS performance_pct_type_2,
TRY_CAST (REPLACE (NULLIF (pct_t3, '-'), '%', '') AS DECIMAL (10,2)) AS performance_pct_type_3,
TRY_CAST (NULLIF (adm_t1, '-') AS INT) AS emergency_adm_type_1,
TRY_CAST (NULLIF (adm_t2, '-') AS INT) AS emergency_adm_type_2,
TRY_CAST (NULLIF (adm_t3_4, '-') AS INT) AS emergency_adm_type_3_4,
TRY_CAST (NULLIF (adm_total_ae, '-') AS INT) AS emergency_adm_total_ae,
TRY_CAST (NULLIF (adm_non_ae, '-') AS INT) AS other_emergency_adm,
TRY_CAST (NULLIF (adm_total, '-') AS INT) AS emergency_adm_total,
TRY_CAST (NULLIF (dta_over4, '-') AS INT) AS over_4hr_waits,
TRY_CAST (NULLIF (dta_over12, '-') AS INT) AS over_12hr_waits
INTO nhs_ae_cleaned  
FROM nhs_ae_dec25;
