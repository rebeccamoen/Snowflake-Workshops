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
