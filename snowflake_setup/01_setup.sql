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
