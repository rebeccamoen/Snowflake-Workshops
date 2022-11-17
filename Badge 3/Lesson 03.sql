-- Joining Local Data with Shared Data
-- Create another local database and warehouse:
USE ROLE SYSADMIN;
CREATE OR REPLACE DATABASE INTL_DB;
USE SCHEMA INTL_DB.PUBLIC;

-- Create a Warehouse for Loading INTL_DB:
CREATE WAREHOUSE INTL_WH 
WITH WAREHOUSE_SIZE = 'XSMALL' 
WAREHOUSE_TYPE = 'STANDARD' 
AUTO_SUSPEND = 600 
AUTO_RESUME = TRUE;

USE WAREHOUSE INTL_WH;
 
 -- Create Table INT_STDS_ORG_3661:
 CREATE OR REPLACE TABLE INTL_DB.PUBLIC.INT_STDS_ORG_3661 
(ISO_COUNTRY_NAME varchar(100), 
 COUNTRY_NAME_OFFICIAL varchar(200), 
 SOVEREIGNTY varchar(40), 
 ALPHA_CODE_2DIGIT varchar(2), 
 ALPHA_CODE_3DIGIT varchar(3), 
 NUMERIC_COUNTRY_CODE integer,
 ISO_SUBDIVISION varchar(15), 
 INTERNET_DOMAIN_CODE varchar(10)
);

-- Create a File Format to Load the Table:
CREATE OR REPLACE FILE FORMAT INTL_DB.PUBLIC.PIPE_DBLQUOTE_HEADER_CR 
  TYPE = 'CSV' 
  COMPRESSION = 'AUTO' 
  FIELD_DELIMITER = '|' 
  RECORD_DELIMITER = '\r' 
  SKIP_HEADER = 1 
  FIELD_OPTIONALLY_ENCLOSED_BY = '\042' 
  TRIM_SPACE = FALSE 
  ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE 
  ESCAPE = 'NONE' 
  ESCAPE_UNENCLOSED_FIELD = '\134'
  DATE_FORMAT = 'AUTO' 
  TIMESTAMP_FORMAT = 'AUTO' 
  NULL_IF = ('\\N');
  
-- Load the ISO Table Using Your File Format:
create stage demo_db.public.like_a_window_into_an_s3_bucket
url = 's3://uni-lab-files';

LIST @demo_db.public.like_a_window_into_an_s3_bucket; -- To find the exact name of the file

copy into INTL_DB.PUBLIC.INT_STDS_ORG_3661 
from @demo_db.public.like_a_window_into_an_s3_bucket
files = ( 'smew/ISO_Countries_UTF8_pipe.csv')
file_format = ( format_name='INTL_DB.PUBLIC.PIPE_DBLQUOTE_HEADER_CR' );

-- Check That You Created and Loaded the Table Properly:
SELECT count(*) as FOUND, '249' as EXPECTED 
FROM INTL_DB.PUBLIC.INT_STDS_ORG_3661; 

-- How to Test Whether You Set Up Your Table in the Right Place with the Right Name:
-- (Does a table with that name exist...in a certain schema...within a certain database)
select count(*) as OBJECTS_FOUND
from INTL_DB.INFORMATION_SCHEMA.TABLES -- from <database name>.INFORMATION_SCHEMA.TABLES 
where table_schema='PUBLIC' -- where table_schema=<schema name>
and table_name= 'INT_STDS_ORG_3661'; -- and table_name= <table name>;

-- How to Test That You Loaded the Expected Number of Rows:
-- (For the table we presume exists...in a certain schema...within a certain database...how many rows does the table hold?)
select row_count
from INTL_DB.INFORMATION_SCHEMA.TABLES -- from <database name>.INFORMATION_SCHEMA.TABLES
where table_schema='PUBLIC' -- where table_schema=<schema name> 
and table_name= 'INT_STDS_ORG_3661'; -- and table_name= <table name>;

-- Join Local Data with Shared Data:
SELECT  
    iso_country_name
    , country_name_official,alpha_code_2digit
    ,r_name as region
FROM INTL_DB.PUBLIC.INT_STDS_ORG_3661 i
LEFT JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION n
ON UPPER(i.iso_country_name)=n.n_name
LEFT JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION r
ON n_regionkey = r_regionkey;


-- Convert the Select Statement into a View:
-- (You can convert any SELECT into a VIEW by adding a CREATE VIEW command in front of the SELECT statement)
CREATE VIEW NATIONS_SAMPLE_PLUS_ISO (iso_country_name, country_name_official,alpha_code_2digit, region) AS
SELECT  
    iso_country_name
    , country_name_official,alpha_code_2digit
    ,r_name as region
FROM INTL_DB.PUBLIC.INT_STDS_ORG_3661 i
LEFT JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION n
ON UPPER(i.iso_country_name)=n.n_name
LEFT JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION r
ON n_regionkey = r_regionkey;
-- (If you find yourself using the logic of a select statement over and over again, wrap the statement in a view and run simple queries on the view)

-- Run a SELECT on the View You Created:
SELECT *
FROM INTL_DB.PUBLIC.NATIONS_SAMPLE_PLUS_ISO;

-- Load More Data for INTL_DB:
CREATE OR REPLACE FILE FORMAT INTL_DB.PUBLIC.CURRENCY
  TYPE = 'CSV'
  COMPRESSION = 'AUTO' 
  FIELD_DELIMITER = ',' 
  RECORD_DELIMITER = '\n' 
  SKIP_HEADER = 1 
  FIELD_OPTIONALLY_ENCLOSED_BY = 'NONE' 
  TRIM_SPACE = FALSE 
  ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE 
  ESCAPE = 'NONE' 
  ESCAPE_UNENCLOSED_FIELD = '\134' 
  DATE_FORMAT = 'AUTO' 
  TIMESTAMP_FORMAT = 'AUTO' 
  NULL_IF = ('\\N');
  
 CREATE OR REPLACE TABLE INTL_DB.PUBLIC.CURRENCIES 
(
  CURRENCY_ID INTEGER, 
  CURRENCY_CHAR_CODE varchar(3), 
  CURRENCY_SYMBOL varchar(4), 
  CURRENCY_DIGITAL_CODE varchar(3), 
  CURRENCY_DIGITAL_NAME varchar(30)
)
  COMMENT = 'Information about currencies including character codes, symbols, digital codes, etc.';

copy into INTL_DB.PUBLIC.CURRENCIES 
from @demo_db.public.like_a_window_into_an_s3_bucket
files = ( 'smew/currencies.csv')
file_format = ( format_name='INTL_DB.PUBLIC.CURRENCY' );

 CREATE OR REPLACE TABLE INTL_DB.PUBLIC.COUNTRY_CODE_TO_CURRENCY_CODE
(
    COUNTRY_CHAR_CODE Varchar(3), 
    COUNTRY_NUMERIC_CODE INTEGER, 
    COUNTRY_NAME Varchar(100), 
    CURRENCY_NAME Varchar(100), 
    CURRENCY_CHAR_CODE Varchar(3), 
    CURRENCY_NUMERIC_CODE INTEGER
) 
  COMMENT = 'Many to many code lookup table';

copy into INTL_DB.PUBLIC.COUNTRY_CODE_TO_CURRENCY_CODE
from @demo_db.public.like_a_window_into_an_s3_bucket
files = ( 'smew/country_code_to_currency_code.csv')
file_format = ( format_name='INTL_DB.PUBLIC.CURRENCY' );


-- Challenge lab: Create a View that will return the Currency and Country code
CREATE OR REPLACE VIEW INTL_DB.PUBLIC.SIMPLE_CURRENCY (CTY_CODE, CUR_CODE) AS
SELECT  
    CURRENCY_CHAR_CODE,
    COUNTRY_CHAR_CODE
FROM INTL_DB.PUBLIC.COUNTRY_CODE_TO_CURRENCY_CODE;

SELECT *
FROM INTL_DB.PUBLIC.SIMPLE_CURRENCY;
