-- Mel's Concept Kickoff
-- Challenge lab: Create a new database and add two stages
use role sysadmin;
create database MELS_SMOOTHIE_CHALLENGE_DB;
create schema MELS_SMOOTHIE_CHALLENGE_DB.TRAILS;
drop schema MELS_SMOOTHIE_CHALLENGE_DB.PUBLIC; 

create stage MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.TRAILS_GEOJSON
url = 's3://uni-lab-files-more/dlkw/trails/trails_geojson';
list @MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.TRAILS_GEOJSON;

create stage MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.TRAILS_PARQUET
url = 's3://uni-lab-files-more/dlkw/trails/trails_parquet';
list @MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.TRAILS_PARQUET;

-- Challenge lab: Create two File Formats for JSON Data and PARQUET Data:
CREATE FILE FORMAT MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.FF_JSON
TYPE = 'JSON' 
COMPRESSION = 'AUTO' 
ENABLE_OCTAL = FALSE
ALLOW_DUPLICATE = FALSE
STRIP_OUTER_ARRAY = TRUE
STRIP_NULL_VALUES = FALSE
IGNORE_UTF8_ERRORS = FALSE
TRIM_SPACE = TRUE; 

CREATE FILE FORMAT MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.FF_PARQUET 
TYPE = 'PARQUET' 
COMPRESSION = 'AUTO' 
TRIM_SPACE = TRUE; 

-- Query the Stage using the File Format:
select $1
from @trails_geojson
(file_format => ff_json);

select $1
from @trails_parquet
(file_format => ff_parquet);
