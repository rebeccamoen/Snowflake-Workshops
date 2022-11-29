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

-- DORA 8-11
select grader(step, (actual = expected), actual, expected, description) as graded_results from
(
SELECT 
 'SMEW08' as step
 ,(select count(*)/NULLIF(count(*),0) from snowflake.reader_account_usage.query_history
where USER_NAME = 'MANAGED_READER_ADMIN' and query_text ilike ('%366%')) as actual
 , 1 as expected
 ,'03-00-01-08' as description
UNION ALL
SELECT 
  'SMEW09' as step
 ,(select count(*)/NULLIF(count(*),0) from snowflake.reader_account_usage.query_history
where USER_NAME = 'MANAGED_READER_ADMIN' and query_text ilike ('%NCIES%')) as actual
 , 1 as expected
 ,'03-00-01-09' as description
UNION ALL
SELECT 
  'SMEW10' as step
 ,(select count(*)/NULLIF(count(*),0) from snowflake.reader_account_usage.query_history
where USER_NAME = 'MANAGED_READER_ADMIN' and query_text ilike ('%IMPLE%')) as actual
 , 1 as expected
 ,'03-00-01-10' as description
UNION ALL 
SELECT 
    'SMEW11' as step 
,(select count(*)/NULLIF(count(*),0) from snowflake.reader_account_usage.query_history
where USER_NAME = 'MANAGED_READER_ADMIN' and query_text ilike ('%DE_TO%')) as actual
, 1 as expected
,'03-00-01-11' as description
); 

-- DORA 12
select grader(step, (actual = expected), actual, expected, description) as graded_results from (
 SELECT 'SMEW12' as step
 ,(select count(*) 
   from SNOWFLAKE.ACCOUNT_USAGE.DATABASES 
   where database_name in ('INTL_DB','DEMO_DB','ACME', 'ACME_DETROIT','ADU_VINHANCED') 
   and deleted is null) as actual
 , 5 as expected
 ,'Databases from all over!' as description
); 
