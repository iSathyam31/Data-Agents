-- 01_setup.sql
-- IMPORTANT: Run this script as the ACCOUNTADMIN role

-- 1. Create a network policy to allow all IPs (for development purposes)
CREATE OR REPLACE NETWORK POLICY dash_dev_policy
  ALLOWED_IP_LIST=('0.0.0.0/0')
  COMMENT='Allow all IPs for Dash Agent development';

-- Note: To apply this account-wide, you would run:
-- ALTER ACCOUNT SET NETWORK_POLICY = dash_dev_policy;
-- However, it is safer to attach it directly to the user (done in step 3).

-- 2. Create the Roles needed for the Dash Agent
CREATE OR REPLACE ROLE dash_analyst_role COMMENT = 'Read-only role for the Dash Analyst agent';
CREATE OR REPLACE ROLE dash_engineer_role COMMENT = 'Write role for the Dash Engineer agent';

-- 3. Create the User for the Dash Agent
CREATE OR REPLACE USER dash_user
  PASSWORD = 'DashPassword123!'
  DEFAULT_ROLE = dash_engineer_role
  DEFAULT_WAREHOUSE = compute_wh
  MUST_CHANGE_PASSWORD = FALSE
  NETWORK_POLICY = dash_dev_policy
  COMMENT = 'User for Dash Data Agent';

-- 4. Grant roles to the user
GRANT ROLE dash_analyst_role TO USER dash_user;
GRANT ROLE dash_engineer_role TO USER dash_user;

-- 5. Grant roles to sysadmin so the sysadmin can manage them in the future
GRANT ROLE dash_analyst_role TO ROLE sysadmin;
GRANT ROLE dash_engineer_role TO ROLE sysadmin;

-- 6. Grant access to SNOWFLAKE_SAMPLE_DATA (TPC-DS dataset)
GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE_SAMPLE_DATA TO ROLE dash_analyst_role;
GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE_SAMPLE_DATA TO ROLE dash_engineer_role;

-- 7. Grant USAGE on the warehouse to both roles
--    Without this, USE WAREHOUSE / queries always fail with "missing active warehouse"
GRANT USAGE ON WAREHOUSE compute_wh TO ROLE dash_analyst_role;
GRANT USAGE ON WAREHOUSE compute_wh TO ROLE dash_engineer_role;

-- 7b. Tune the warehouse for TPC-DS SF100TCL (100TB)
--     X-Large = 16 servers, suitable for heavy multi-table aggregations.
--     AUTO_SUSPEND at 60s to avoid burning credits while idle.
--     Downsize to LARGE or MEDIUM if cost is a concern.
ALTER WAREHOUSE compute_wh SET
  WAREHOUSE_SIZE = 'X-LARGE'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  STATEMENT_TIMEOUT_IN_SECONDS = 300;  -- warehouse-level hard cap

-- 8. Create the writable DASH_AGENT database and dash schema
--    SNOWFLAKE_SAMPLE_DATA is a shared read-only DB; Engineer objects must live here.
CREATE DATABASE IF NOT EXISTS DASH_AGENT
  COMMENT = 'Dash Agent output: Engineer-created views and summary tables';

CREATE SCHEMA IF NOT EXISTS DASH_AGENT.dash
  COMMENT = 'Agent-managed views and computed tables built by the Engineer';

-- 9. Grant Engineer full control over DASH_AGENT.dash
GRANT USAGE ON DATABASE DASH_AGENT TO ROLE dash_engineer_role;
GRANT ALL ON SCHEMA DASH_AGENT.dash TO ROLE dash_engineer_role;
GRANT CREATE TABLE ON SCHEMA DASH_AGENT.dash TO ROLE dash_engineer_role;
GRANT CREATE VIEW ON SCHEMA DASH_AGENT.dash TO ROLE dash_engineer_role;

-- 10. Grant Analyst read access to DASH_AGENT.dash (to query Engineer views)
GRANT USAGE ON DATABASE DASH_AGENT TO ROLE dash_analyst_role;
GRANT USAGE ON SCHEMA DASH_AGENT.dash TO ROLE dash_analyst_role;
GRANT SELECT ON ALL TABLES IN SCHEMA DASH_AGENT.dash TO ROLE dash_analyst_role;
GRANT SELECT ON ALL VIEWS IN SCHEMA DASH_AGENT.dash TO ROLE dash_analyst_role;
GRANT SELECT ON FUTURE TABLES IN SCHEMA DASH_AGENT.dash TO ROLE dash_analyst_role;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA DASH_AGENT.dash TO ROLE dash_analyst_role;
