-- ============================================================================
-- Dash-LangGraph — Snowflake Setup Script
-- Run this on a FRESH Snowflake trial account as ACCOUNTADMIN.
-- It creates everything the app needs: warehouse, database/schema, roles, users.
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │ 1. WAREHOUSE — LARGE to save credits (auto-suspend after 60 sec)      │
-- └──────────────────────────────────────────────────────────────────────────┘
CREATE OR REPLACE WAREHOUSE COMPUTE_WH
    WAREHOUSE_SIZE   = 'LARGE'
    AUTO_SUSPEND     = 60
    AUTO_RESUME      = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT          = 'Dash-LangGraph primary warehouse';

-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │ 2. VERIFY SAMPLE DATA — trial accounts come with SNOWFLAKE_SAMPLE_DATA │
-- └──────────────────────────────────────────────────────────────────────────┘
-- This should already exist on a trial account. Verify:
SHOW SCHEMAS IN DATABASE SNOWFLAKE_SAMPLE_DATA;
-- You should see TPCDS_SF100TCL in the list.

-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │ 3. DASH DATABASE & SCHEMA — for Engineer-created views/tables          │
-- └──────────────────────────────────────────────────────────────────────────┘
CREATE DATABASE IF NOT EXISTS DASH_DB
    COMMENT = 'Dash-LangGraph application database';

CREATE SCHEMA IF NOT EXISTS DASH_DB.DASH
    WITH MANAGED ACCESS
    COMMENT = 'Schema for Engineer-created views and summary tables';

-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │ 4. ROLES                                                                │
-- └──────────────────────────────────────────────────────────────────────────┘

-- 4a. DASH_ANALYST — read-only access to SNOWFLAKE_SAMPLE_DATA
CREATE OR REPLACE ROLE DASH_ANALYST
    COMMENT = 'Read-only role for the Dash Analyst agent';

-- 4b. DASH_ENGINEER — read SNOWFLAKE_SAMPLE_DATA + read/write DASH_DB.DASH
CREATE OR REPLACE ROLE DASH_ENGINEER
    COMMENT = 'Role for the Dash Engineer agent (can create views in DASH schema)';

-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │ 5. GRANTS — DASH_ANALYST (read-only)                                    │
-- └──────────────────────────────────────────────────────────────────────────┘

-- Warehouse
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE DASH_ANALYST;

-- Sample data: imported database requires IMPORTED PRIVILEGES
GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE_SAMPLE_DATA TO ROLE DASH_ANALYST;

-- DASH_DB: read-only (so analyst can query engineer-created views)
GRANT USAGE ON DATABASE DASH_DB TO ROLE DASH_ANALYST;
GRANT USAGE ON SCHEMA DASH_DB.DASH TO ROLE DASH_ANALYST;
GRANT SELECT ON ALL VIEWS IN SCHEMA DASH_DB.DASH TO ROLE DASH_ANALYST;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA DASH_DB.DASH TO ROLE DASH_ANALYST;

-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │ 6. GRANTS — DASH_ENGINEER (read sample data + write DASH schema)        │
-- └──────────────────────────────────────────────────────────────────────────┘

-- Warehouse
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE DASH_ENGINEER;

-- Sample data: imported database requires IMPORTED PRIVILEGES
GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE_SAMPLE_DATA TO ROLE DASH_ENGINEER;

-- DASH_DB: full control on DASH schema
GRANT USAGE ON DATABASE DASH_DB TO ROLE DASH_ENGINEER;
GRANT ALL ON SCHEMA DASH_DB.DASH TO ROLE DASH_ENGINEER;
GRANT ALL ON FUTURE TABLES IN SCHEMA DASH_DB.DASH TO ROLE DASH_ENGINEER;
GRANT ALL ON FUTURE VIEWS IN SCHEMA DASH_DB.DASH TO ROLE DASH_ENGINEER;

-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │ 7. SERVICE USER — single user for the Dash app                          │
-- └──────────────────────────────────────────────────────────────────────────┘
-- Change the password below before running!
CREATE OR REPLACE USER DASH_USER
    PASSWORD           = 'DashAgent123!'
    DEFAULT_WAREHOUSE  = COMPUTE_WH
    DEFAULT_ROLE       = DASH_ANALYST
    DEFAULT_NAMESPACE  = SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL
    MUST_CHANGE_PASSWORD = FALSE
    COMMENT            = 'Service user for Dash-LangGraph app';

-- Grant both roles to the service user
GRANT ROLE DASH_ANALYST  TO USER DASH_USER;
GRANT ROLE DASH_ENGINEER TO USER DASH_USER;

-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │ 8. GRANT ROLES UP TO SYSADMIN (best practice hierarchy)                 │
-- └──────────────────────────────────────────────────────────────────────────┘
GRANT ROLE DASH_ANALYST  TO ROLE SYSADMIN;
GRANT ROLE DASH_ENGINEER TO ROLE SYSADMIN;

-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │ 9. RESOURCE MONITOR — DISABLED (let credits exhaust naturally)          │
-- └──────────────────────────────────────────────────────────────────────────┘
-- Remove any existing monitor from the warehouse
ALTER WAREHOUSE COMPUTE_WH SET RESOURCE_MONITOR = NULL;
DROP RESOURCE MONITOR IF EXISTS DASH_CREDIT_MONITOR;

-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │ 10. VERIFY SETUP                                                        │
-- └──────────────────────────────────────────────────────────────────────────┘
-- Quick smoke test — run these to confirm everything works:

USE ROLE DASH_ANALYST;
USE WAREHOUSE COMPUTE_WH;

-- Should return rows:
SELECT COUNT(*) AS row_count 
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.STORE_SALES 
LIMIT 1;

-- Should return table list:
SELECT TABLE_NAME, ROW_COUNT, BYTES
FROM SNOWFLAKE_SAMPLE_DATA.INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'TPCDS_SF100TCL'
ORDER BY BYTES DESC;

USE ROLE DASH_ENGINEER;

-- Should succeed:
CREATE OR REPLACE VIEW DASH_DB.DASH.TEST_VIEW AS
    SELECT 1 AS TEST_COLUMN;

-- Clean up test view:
DROP VIEW IF EXISTS DASH_DB.DASH.TEST_VIEW;

-- ============================================================================
-- DONE! Update your .env file with:
--   SNOWFLAKE_USER=DASH_USER
--   SNOWFLAKE_PASSWORD=<the password you set above>
--   SNOWFLAKE_DATABASE=SNOWFLAKE_SAMPLE_DATA
--   SNOWFLAKE_SCHEMA=TPCDS_SF100TCL
--   SNOWFLAKE_WAREHOUSE=COMPUTE_WH
--   SNOWFLAKE_ROLE=DASH_ANALYST    (default; app switches to DASH_ENGINEER when needed)
-- ============================================================================
