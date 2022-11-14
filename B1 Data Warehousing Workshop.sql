-- Tables, Data Types, and Loading Data
-- Create a table:
use role sysadmin;
create or replace table GARDEN_PLANTS.VEGGIES.ROOT_DEPTH (
   ROOT_DEPTH_ID number(1), 
   ROOT_DEPTH_CODE text(1), 
   ROOT_DEPTH_NAME text(7), 
   UNIT_OF_MEASURE text(2),
   RANGE_MIN number(2),
   RANGE_MAX number(2)
   );
   
USE WAREHOUSE COMPUTE_WH;

-- Insert a row of data into the new table:
INSERT INTO ROOT_DEPTH (
	ROOT_DEPTH_ID ,
	ROOT_DEPTH_CODE ,
	ROOT_DEPTH_NAME ,
	UNIT_OF_MEASURE ,
	RANGE_MIN ,
	RANGE_MAX 
)

VALUES
(
    3,
    'D',
    'Deep',
    'cm',
    60,
    90
);

SELECT * FROM ROOT_DEPTH LIMIT 3;

create table vegetable_details
(
plant_name varchar(25)
, root_depth_code varchar(1)    
);

--PUT 'file:///dfab2087d1b1413d92d6d166b851c540' '@~/uploads/dataloader'
--copy into IDENTIFIER('"GARDEN_PLANTS"."VEGGIES"."VEGETABLE_DETAILS"') from '@~/uploads/dataloader/dfab2087d1b1413d92d6d166b851c540' file_format = (TYPE=csv, FIELD_OPTIONALLY_ENCLOSED_BY='"', ESCAPE_UNENCLOSED_FIELD=None, SKIP_HEADER=1) purge = true ON_ERROR=CONTINUE

list @~/uploads/dataloader;

SELECT * FROM vegetable_details;


-- File Formats, PUTs, and COPY INTOs
-- CSV Uploader Generated Code:
COPY INTO IDENTIFIER('GARDEN_PLANTS.VEGGIES.VEGETABLE_DETAILS')
from '@~/uploads/dataloader/bc53c15f8aa2a4e6f06bef20b9ad47e2'
file_format = (
    TYPE=csv,
    FIELD_OPTIONALLY_ENCLOSED_BY='"',
    ESCAPE_UNENCLOSED_FIELD=None,
    SKIP_HEADER=1,
    FIELD_DELIMITER = '|'
);

-- Create two file formates:
create file format garden_plants.veggies.PIPECOLSEP_ONEHEADROW 
    TYPE = 'CSV'--csv is used for any flat file (tsv, pipe-separated, etc)
    FIELD_DELIMITER = '|' --pipes as column separators
    SKIP_HEADER = 1 --one header row to skip
    ;

create file format garden_plants.veggies.COMMASEP_DBLQUOT_ONEHEADROW 
    TYPE = 'CSV'--csv for comma separated files
    SKIP_HEADER = 1 --one header row  
    FIELD_OPTIONALLY_ENCLOSED_BY = '"' --this means that some values will be wrapped in double-quotes bc they have commas in them
    ;
    
delete from vegetable_details where plant_name = 'Spinach' and root_depth_code = 'D';

select * from vegetable_details;

use role accountadmin;
use database demo_db; --change this to a different database if you prefer
use schema public; --change this to a different schema if you prefer


--  Checking for Schemas by Name:
SELECT * 
FROM GARDEN_PLANTS.INFORMATION_SCHEMA.SCHEMATA;

SELECT * 
FROM GARDEN_PLANTS.INFORMATION_SCHEMA.SCHEMATA
where schema_name in ('FLOWERS','FRUITS','VEGGIES'); 

SELECT count(*) as SCHEMAS_FOUND, '3' as SCHEMAS_EXPECTED 
FROM GARDEN_PLANTS.INFORMATION_SCHEMA.SCHEMATA
where schema_name in ('FLOWERS','FRUITS','VEGGIES'); 



-- Staging Data
-- Create a Snowflake Stage Object:
 create stage garden_plants.veggies.like_a_window_into_an_s3_bucket 
 url = 's3://uni-lab-files';
 
 list @like_a_window_into_an_s3_bucket/THIS_;
 
 -- Create a Table for Soil Types:
 create or replace table vegetable_details_soil_type
( plant_name varchar(25)
 ,soil_type number(1,0)
);

copy into vegetable_details_soil_type
from @like_a_window_into_an_s3_bucket
files = ( 'VEG_NAME_TO_SOIL_TYPE_PIPE.txt')
file_format = ( format_name=PIPECOLSEP_ONEHEADROW );

-- Create a Soil Type Look Up Table:
create or replace table LU_SOIL_TYPE(
SOIL_TYPE_ID number,	
SOIL_TYPE varchar(15),
SOIL_DESCRIPTION varchar(75)
);


-- Challenge lab: Create a File Format
CREATE FILE FORMAT L8_CHALLENGE_FF
TYPE = 'CSV'
FIELD_DELIMITER = '\t'
TRIM_SPACE = TRUE
SKIP_HEADER = 1
;

copy into LU_SOIL_TYPE
from @like_a_window_into_an_s3_bucket
files = ( 'LU_SOIL_TYPE.tsv')
file_format = ( format_name=L8_CHALLENGE_FF );


-- Challenge lab: Create a table
create or replace table VEGETABLE_DETAILS_PLANT_HEIGHT(
PLANT_NAME varchar(30),
UOM varchar(1),
LOW_END_OF_RANGE number,
HIGH_END_OF_RANGE number
);

copy into VEGETABLE_DETAILS_PLANT_HEIGHT
from @like_a_window_into_an_s3_bucket
files = ( 'veg_plant_height.csv')
file_format = ( format_name=COMMASEP_DBLQUOT_ONEHEADROW );


-- Data Storage Structures



-- Create a 2nd Counter, a Book Table, and a Mapping Table:
USE DATABASE LIBRARY_CARD_CATALOG;

-- Create a new sequence, this one will be a counter for the book table:
CREATE OR REPLACE SEQUENCE "LIBRARY_CARD_CATALOG"."PUBLIC"."SEQ_BOOK_UID" 
START 1 
INCREMENT 1 
COMMENT = 'Use this to fill in the BOOK_UID everytime you add a row';

-- Create the book table and use the NEXTVAL as the default value each time a row is added to the table:
CREATE OR REPLACE TABLE BOOK
( BOOK_UID NUMBER DEFAULT SEQ_BOOK_UID.nextval
 ,TITLE VARCHAR(50)
 ,YEAR_PUBLISHED NUMBER(4,0)
);

-- Insert records into the book table, dont have to list anything for the BOOK_UID field because the default setting will take care of it:
INSERT INTO BOOK(TITLE,YEAR_PUBLISHED)
VALUES
 ('Food',2001)
,('Food',2006)
,('Food',2008)
,('Food',2016)
,('Food',2015);

-- Create the relationships table this is sometimes called a "Many-to-Many table":
CREATE TABLE BOOK_TO_AUTHOR
(  BOOK_UID NUMBER
  ,AUTHOR_UID NUMBER
);

-- Insert rows of the known relationships:
INSERT INTO BOOK_TO_AUTHOR(BOOK_UID,AUTHOR_UID)
VALUES
 (1,1) -- This row links the 2001 book to Fiona Macdonald
,(1,2) -- This row links the 2001 book to Gian Paulo Faleschini
,(2,3) -- Links 2006 book to Laura K Egendorf
,(3,4) -- Links 2008 book to Jan Grover
,(4,5) -- Links 2016 book to Jennifer Clapp
,(5,6);-- Links 2015 book to Kathleen Petelinsek

-- Check your work by joining the 3 tables together, should get 1 row for every author:
select * 
from book_to_author ba 
join author a 
on ba.author_uid = a.author_uid 
join book b 
on b.book_uid=ba.book_uid; 


-- Semi-Structured Data
-- Create an Ingestion Table for XML Data:
CREATE TABLE LIBRARY_CARD_CATALOG.PUBLIC.AUTHOR_INGEST_XML 
(
  "RAW_AUTHOR" VARIANT
);

-- Create File Format for XML Data:
CREATE FILE FORMAT LIBRARY_CARD_CATALOG.PUBLIC.XML_FILE_FORMAT 
TYPE = 'XML' 
STRIP_OUTER_ELEMENT = FALSE 
; 

-- Load the XML Data into the XML Table:
create stage LIBRARY_CARD_CATALOG.PUBLIC.like_a_window_into_an_s3_bucket 
url = 's3://uni-lab-files';

copy into LIBRARY_CARD_CATALOG.PUBLIC.AUTHOR_INGEST_XML
From @like_a_window_into_an_s3_bucket
files = ( 'author_with_header.xml')
file_format = ( format_name='LIBRARY_CARD_CATALOG.PUBLIC.XML_FILE_FORMAT' );

-- MODIFY File Format for XML Data by Changing Config:
CREATE OR REPLACE FILE FORMAT LIBRARY_CARD_CATALOG.PUBLIC.XML_FILE_FORMAT 
TYPE = 'XML' 
COMPRESSION = 'AUTO' 
PRESERVE_SPACE = FALSE 
STRIP_OUTER_ELEMENT = TRUE 
DISABLE_SNOWFLAKE_DATA = FALSE 
DISABLE_AUTO_CONVERT = FALSE 
IGNORE_UTF8_ERRORS = FALSE; 

-- Drop all the rows from the table:
TRUNCATE LIBRARY_CARD_CATALOG.PUBLIC.AUTHOR_INGEST_XML;

-- Returns entire record:
SELECT raw_author 
FROM author_ingest_xml;

-- Presents a kind of meta-data view of the data:
SELECT raw_author:"$" 
FROM author_ingest_xml; 

-- Shows the root or top-level object name of each row:
SELECT raw_author:"@" 
FROM author_ingest_xml; 

-- Returns AUTHOR_UID value from top-level object's attribute:
SELECT raw_author:"@AUTHOR_UID"
FROM author_ingest_xml;

-- Returns value of NESTED OBJECT called FIRST_NAME:
SELECT XMLGET(raw_author, 'FIRST_NAME'):"$"
FROM author_ingest_xml;

-- Returns the data in a way that makes it look like a normalized table:
SELECT 
raw_author:"@AUTHOR_UID" as AUTHOR_ID
,XMLGET(raw_author, 'FIRST_NAME'):"$" as FIRST_NAME
,XMLGET(raw_author, 'MIDDLE_NAME'):"$" as MIDDLE_NAME
,XMLGET(raw_author, 'LAST_NAME'):"$" as LAST_NAME
FROM AUTHOR_INGEST_XML;

-- Add ::STRING to cast the values into strings and get rid of the quotes:
SELECT 
raw_author:"@AUTHOR_UID" as AUTHOR_ID
,XMLGET(raw_author, 'FIRST_NAME'):"$"::STRING as FIRST_NAME
,XMLGET(raw_author, 'MIDDLE_NAME'):"$"::STRING as MIDDLE_NAME
,XMLGET(raw_author, 'LAST_NAME'):"$"::STRING as LAST_NAME
FROM AUTHOR_INGEST_XML; 

-- Nested Semi-Structured Data
-- Create an Ingestion Table for JSON Data:
CREATE TABLE "LIBRARY_CARD_CATALOG"."PUBLIC"."AUTHOR_INGEST_JSON" 
(
  "RAW_AUTHOR" VARIANT
);

-- Create File Format for JSON Data:
CREATE FILE FORMAT LIBRARY_CARD_CATALOG.PUBLIC.JSON_FILE_FORMAT 
TYPE = 'JSON' 
COMPRESSION = 'AUTO' 
ENABLE_OCTAL = FALSE
ALLOW_DUPLICATE = FALSE
STRIP_OUTER_ARRAY = TRUE
STRIP_NULL_VALUES = FALSE
IGNORE_UTF8_ERRORS = FALSE; 

-- Load data into the table:
copy into LIBRARY_CARD_CATALOG.PUBLIC.AUTHOR_INGEST_JSON
From @like_a_window_into_an_s3_bucket
files = ( 'author_with_header.json')
file_format = ( format_name='LIBRARY_CARD_CATALOG.PUBLIC.JSON_FILE_FORMAT' );

-- Returns AUTHOR_UID value from top-level object's attribute:
select raw_author:AUTHOR_UID
from author_ingest_json;

-- Returns the data in a way that makes it look like a normalized table:
SELECT 
 raw_author:AUTHOR_UID
,raw_author:FIRST_NAME::STRING as FIRST_NAME
,raw_author:MIDDLE_NAME::STRING as MIDDLE_NAME
,raw_author:LAST_NAME::STRING as LAST_NAME
FROM AUTHOR_INGEST_JSON;

-- Create an Ingestion Table for the NESTED JSON Data:
CREATE OR REPLACE TABLE LIBRARY_CARD_CATALOG.PUBLIC.NESTED_INGEST_JSON 
(
  "RAW_NESTED_BOOK" VARIANT
);

-- Create File Format for JSON Data:
CREATE FILE FORMAT LIBRARY_CARD_CATALOG.PUBLIC.JSON_FILE_FORMAT 
TYPE = 'JSON' 
COMPRESSION = 'AUTO' 
ENABLE_OCTAL = FALSE
ALLOW_DUPLICATE = FALSE
STRIP_OUTER_ARRAY = TRUE
STRIP_NULL_VALUES = FALSE
IGNORE_UTF8_ERRORS = FALSE; 

-- Load data into the table:
copy into LIBRARY_CARD_CATALOG.PUBLIC.NESTED_INGEST_JSON 
From @like_a_window_into_an_s3_bucket
files = ( 'json_book_author_nested.txt')
file_format = ( format_name='LIBRARY_CARD_CATALOG.PUBLIC.JSON_FILE_FORMAT' );

-- A few simple queries:
SELECT RAW_NESTED_BOOK
FROM NESTED_INGEST_JSON;

SELECT RAW_NESTED_BOOK:year_published
FROM NESTED_INGEST_JSON;

SELECT RAW_NESTED_BOOK:authors
FROM NESTED_INGEST_JSON;

-- Try changing the number in the bracketsd to return authors from a different row:
SELECT RAW_NESTED_BOOK:authors[0].first_name
FROM NESTED_INGEST_JSON;

-- Use these example flatten commands to explore flattening the nested book and author data:
SELECT value:first_name
FROM NESTED_INGEST_JSON
,LATERAL FLATTEN(input => RAW_NESTED_BOOK:authors);

SELECT value:first_name
FROM NESTED_INGEST_JSON
,table(flatten(RAW_NESTED_BOOK:authors));

-- Add a CAST command to the fields returned:
SELECT value:first_name::VARCHAR, value:last_name::VARCHAR
FROM NESTED_INGEST_JSON
,LATERAL FLATTEN(input => RAW_NESTED_BOOK:authors);

-- Assign new column  names to the columns using "AS":
SELECT value:first_name::VARCHAR AS FIRST_NM
, value:last_name::VARCHAR AS LAST_NM
FROM NESTED_INGEST_JSON
,LATERAL FLATTEN(input => RAW_NESTED_BOOK:authors);

-- Create a new database to hold the Twitter file:
CREATE DATABASE SOCIAL_MEDIA_FLOODGATES 
COMMENT = 'There\'s so much data from social media - flood warning';

USE DATABASE SOCIAL_MEDIA_FLOODGATES;

-- Create a table in the new database:
CREATE TABLE SOCIAL_MEDIA_FLOODGATES.PUBLIC.TWEET_INGEST 
("RAW_STATUS" VARIANT) 
COMMENT = 'Bring in tweets, one row per tweet or status entity';

-- Create a JSON file format in the new database:
CREATE FILE FORMAT SOCIAL_MEDIA_FLOODGATES.PUBLIC.JSON_FILE_FORMAT 
TYPE = 'JSON' 
COMPRESSION = 'AUTO' 
ENABLE_OCTAL = FALSE 
ALLOW_DUPLICATE = FALSE 
STRIP_OUTER_ARRAY = TRUE 
STRIP_NULL_VALUES = FALSE 
IGNORE_UTF8_ERRORS = FALSE;

-- Create a stage:
create stage SOCIAL_MEDIA_FLOODGATES.PUBLIC.like_a_window_into_an_s3_bucket 
 url = 's3://uni-lab-files';
 
-- Load data into the table:
copy into SOCIAL_MEDIA_FLOODGATES.PUBLIC.TWEET_INGEST 
From @like_a_window_into_an_s3_bucket
files = ( 'nutrition_tweets.json')
file_format = ( format_name='SOCIAL_MEDIA_FLOODGATES.PUBLIC.JSON_FILE_FORMAT' );

-- Select statements as seen in the video:
SELECT RAW_STATUS
FROM TWEET_INGEST;

SELECT RAW_STATUS:entities
FROM TWEET_INGEST;

SELECT RAW_STATUS:entities:hashtags
FROM TWEET_INGEST;

-- Explore looking at specific hashtags by adding bracketed numbers:
-- This query returns just the first hashtag in each tweet
SELECT RAW_STATUS:entities:hashtags[0].text
FROM TWEET_INGEST;

-- This version adds a WHERE clause to get rid of any tweet that doesnt include any hashtags:
SELECT RAW_STATUS:entities:hashtags[0].text
FROM TWEET_INGEST
WHERE RAW_STATUS:entities:hashtags[0].text is not null;

-- Perform a simple CAST on the created_at key
-- Add an ORDER BY clause to sort by the tweets creation date:
SELECT RAW_STATUS:created_at::DATE
FROM TWEET_INGEST
ORDER BY RAW_STATUS:created_at::DATE;

-- Flatten statements that return the whole hashtag entity:
SELECT value
FROM TWEET_INGEST
,LATERAL FLATTEN
(input => RAW_STATUS:entities:hashtags);

SELECT value
FROM TWEET_INGEST
,TABLE(FLATTEN(RAW_STATUS:entities:hashtags));

-- Flatten statement that restricts the value to just the TEXT of the hashtag:
SELECT value:text
FROM TWEET_INGEST
,LATERAL FLATTEN
(input => RAW_STATUS:entities:hashtags);

-- Flatten and return just the hashtag text, CAST the text as VARCHAR:
SELECT value:text::VARCHAR
FROM TWEET_INGEST
,LATERAL FLATTEN
(input => RAW_STATUS:entities:hashtags);

-- Flatten and return just the hashtag text, CAST the text as VARCHAR
-- Use the AS command to name the column:
SELECT value:text::VARCHAR AS THE_HASHTAG
FROM TWEET_INGEST
,LATERAL FLATTEN
(input => RAW_STATUS:entities:hashtags);

-- Add the Tweet ID and User ID to the returned table:
SELECT RAW_STATUS:user:id AS USER_ID
,RAW_STATUS:id AS TWEET_ID
,value:text::VARCHAR AS HASHTAG_TEXT
FROM TWEET_INGEST
,LATERAL FLATTEN
(input => RAW_STATUS:entities:hashtags);
 
-- Create a View of the Tweet Data Looking "Normalized":
create or replace view SOCIAL_MEDIA_FLOODGATES.PUBLIC.HASHTAGS_NORMALIZED as
(SELECT RAW_STATUS:user:id AS USER_ID
,RAW_STATUS:id AS TWEET_ID
,value:text::VARCHAR AS HASHTAG_TEXT
FROM TWEET_INGEST
,LATERAL FLATTEN
(input => RAW_STATUS:entities:hashtags)
);

SELECT * FROM SOCIAL_MEDIA_FLOODGATES.PUBLIC.HASHTAGS_NORMALIZED;
