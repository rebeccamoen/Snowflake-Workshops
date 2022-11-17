-- Set your worksheet drop lists to the location of your GRADER function
-- Where did you put the function?
show functions in account;

-- Did you put it here?
select * 
from snowflake.account_usage.functions
where function_name = 'GRADER'
and function_catalog = 'DEMO_DB'
and function_owner = 'ACCOUNTADMIN';

-- Set your worksheet drop lists to the location of your GRADER function using commands
use role accountadmin;
use database demo_db;
use schema public;

-- Test if DORA is working
select GRADER(step,(actual = expected), actual, expected, description) as graded_results from (
SELECT 'DORA_IS_WORKING' as step
 ,(select 223 ) as actual
 ,223 as expected
 ,'Dora is working!' as description
); 

-- DORA 1
select grader(step, (actual = expected), actual, expected, description) as graded_results from( 
 SELECT 'SMEW01' as step
 ,(select count(*) 
   from snowflake.account_usage.databases
   where database_name = 'INTL_DB' 
   and deleted is null) as actual
 , 1 as expected
 ,'Created INTL_DB' as description
 );
 
 -- DORA 2
select grader(step, (actual = expected), actual, expected, description) as graded_results from(
SELECT 'SMEW02' as step
 ,(select count(*) 
   from INTL_DB.INFORMATION_SCHEMA.TABLES 
   where table_schema = 'PUBLIC' 
   and table_name = 'INT_STDS_ORG_3661') as actual
 , 1 as expected
 ,'ISO table created' as description
);

-- DORA 3
select grader(step, (actual = expected), actual, expected, description) as graded_results from( 
SELECT 'SMEW03' as step 
 ,(select row_count 
   from INTL_DB.INFORMATION_SCHEMA.TABLES  
   where table_name = 'INT_STDS_ORG_3661') as actual 
 , 249 as expected 
 ,'ISO Table Loaded' as description 
); 

-- DORA 4
select grader(step, (actual = expected), actual, expected, description) as graded_results from(
SELECT 'SMEW04' as step
 ,(select count(*) 
   from INTL_DB.PUBLIC.NATIONS_SAMPLE_PLUS_ISO) as actual
 , 249 as expected
 ,'Nations Sample Plus Iso' as description
);

-- DORA 5
select grader(step, (actual = expected), actual, expected, description) as graded_results from(
SELECT 'SMEW05' as step
 ,(select row_count 
  from INTL_DB.INFORMATION_SCHEMA.TABLES 
  where table_schema = 'PUBLIC' 
  and table_name = 'COUNTRY_CODE_TO_CURRENCY_CODE') as actual
 , 265 as expected
 ,'CCTCC Table Loaded' as description
);

-- DORA 6
select grader(step, (actual = expected), actual, expected, description) as graded_results from(
SELECT 'SMEW06' as step
 ,(select row_count 
  from INTL_DB.INFORMATION_SCHEMA.TABLES 
  where table_schema = 'PUBLIC' 
  and table_name = 'CURRENCIES') as actual
 , 151 as expected
 ,'Currencies table loaded' as description
);

-- DORA 7
select grader(step, (actual = expected), actual, expected, description) as graded_results from(
 SELECT 'SMEW07' as step 
,(select count(*) 
  from INTL_DB.PUBLIC.SIMPLE_CURRENCY ) as actual
, 265 as expected
,'Simple Currency Looks Good' as description
);
