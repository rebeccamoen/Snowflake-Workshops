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
