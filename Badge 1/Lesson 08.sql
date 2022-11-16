-- Staging Data

-- Create a Snowflake Stage Object
 create stage garden_plants.veggies.like_a_window_into_an_s3_bucket 
 url = 's3://uni-lab-files';
 
 list @like_a_window_into_an_s3_bucket/THIS_;
 
 -- Create a Table for Soil Types
 create or replace table vegetable_details_soil_type
( plant_name varchar(25)
 ,soil_type number(1,0)
);

copy into vegetable_details_soil_type
from @like_a_window_into_an_s3_bucket
files = ( 'VEG_NAME_TO_SOIL_TYPE_PIPE.txt')
file_format = ( format_name=PIPECOLSEP_ONEHEADROW );

-- Create a Soil Type Look Up Table
create or replace table LU_SOIL_TYPE(
SOIL_TYPE_ID number,	
SOIL_TYPE varchar(15),
SOIL_DESCRIPTION varchar(75)
);

-- Challenge lab: create a file format
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
