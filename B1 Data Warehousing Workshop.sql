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
-- Create a new database and set the context to use the new database:
CREATE DATABASE LIBRARY_CARD_CATALOG COMMENT = 'DWW Lesson 9';
USE DATABASE LIBRARY_CARD_CATALOG;

-- Create and Author table:
CREATE OR REPLACE TABLE AUTHOR (
   AUTHOR_UID NUMBER 
  ,FIRST_NAME VARCHAR(50)
  ,MIDDLE_NAME VARCHAR(50)
  ,LAST_NAME VARCHAR(50)
);

-- Insert the first two authors into the Author table:
INSERT INTO AUTHOR(AUTHOR_UID,FIRST_NAME,MIDDLE_NAME, LAST_NAME) 
Values
(1, 'Fiona', '','Macdonald')
,(2, 'Gian','Paulo','Faleschini');

-- Look at your table with it's new rows:
SELECT * 
FROM AUTHOR;

-- Create a Sequence:
create sequence SEQ_AUTHOR_UID
    start = 1
    increment = 1
    comment = 'Use this to fill in AUTHOR_UID';
    
-- See how the nextval function works:
SELECT SEQ_AUTHOR_UID.nextval, SEQ_AUTHOR_UID.nextval;


