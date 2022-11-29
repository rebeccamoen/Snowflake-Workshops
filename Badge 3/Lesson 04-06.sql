-- Lesson 4
-- Creating an Outbound Share
-- Make sharing "down" to a Standard Account allowed:
use role accountadmin;
grant override share restrictions on account to role accountadmin;

-- Account Locator:
SELECT CURRENT_ACCOUNT();

-- Convert "Regular" Views to Secure Views:
ALTER VIEW INTL_DB.PUBLIC.NATIONS_SAMPLE_PLUS_ISO
SET SECURE; 

ALTER VIEW INTL_DB.PUBLIC.SIMPLE_CURRENCY
SET SECURE;


-- Lesson 5
-- Setting up a Managed Reader Account for a Business Partner
-- Account Locator for the Managed Reader Account:
SHOW MANAGED ACCOUNTS;


-- Lesson 6
-- From Reader Explorer to Full Snowflake Customer Account
-- View Your Resource Monitors using a Command:
USE ROLE ACCOUNTADMIN;
SHOW RESOURCE MONITORS;
