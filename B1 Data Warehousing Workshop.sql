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


