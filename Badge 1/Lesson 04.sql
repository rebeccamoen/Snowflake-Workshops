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
