-- Lions & Tigers & Bears, Oh My!!!
select * from mels_smoothie_challenge_db.trails.cherry_creek_trail;

alter view mels_smoothie_challenge_db.trails.cherry_creek_trail
rename to mels_smoothie_challenge_db.trails.v_cherry_creek_trail;

-- Create a Super-Simple, Stripped Down External Table:
create or replace external table T_CHERRY_CREEK_TRAIL(
	my_filename varchar(50) as (metadata$filename::varchar(50))
) 
location= @trails_parquet
auto_refresh = true
file_format = (type = parquet);

-- Modify Our V_CHERRY_CREEK_TRAIL Code to Create the New Table:
select get_ddl('view','mels_smoothie_challenge_db.trails.v_cherry_creek_trail'); -- get copy of our view code

create or replace view V_CHERRY_CREEK_TRAIL(
	POINT_ID,
	TRAIL_NAME,
	LNG,
	LAT,
	COORD_PAIR
) as
select 
 $1:sequence_1 as point_id,
 $1:trail_name::varchar as trail_name,
 $1:latitude::number(11,8) as lng,
 $1:longitude::number(11,8) as lat,
 lng||' '||lat as coord_pair
from @trails_parquet
(file_format => ff_parquet)
order by point_id;

-- Rearrange some of the syntax and put into T_CHERRY_CREEK_TRAIL:
create or replace external table T_CHERRY_CREEK_TRAIL(
	POINT_ID number as ($1:sequence_1::number),
    TRAIL_NAME varchar(50) as ($1:trail_name::varchar),
    LNG number(11,8) as ($1:latitude::number(11,8)),
    LAT number(11,8) as ($1:longitude::number(11,8)),
    COORD_PAIR varchar(50) as (lng::varchar||' '||lat::varchar)
) 
location= @trails_parquet
auto_refresh = true
file_format = (type = parquet);

select * from T_CHERRY_CREEK_TRAIL;

-- Create a Materialized View on Top of the External Table:
create secure materialized view SMV_CHERRY_CREEK_TRAIL as 
select * from T_CHERRY_CREEK_TRAIL;

select * from SMV_CHERRY_CREEK_TRAIL;


-- Iceberg tables are coming to Snowflake, what is coming soon:
-- Create the external volume where we want the Iceberg table to store its data and metadata:
create or replace external volume summit_demo_TEST
STORAGE_LOCATIONS =
(
    (
        NAME = 'my-s3-us-east-1'
        STORAGE_PROVIDER = 'S3'
        STORAGE_BASE_URL = 's3://datalake-storage-team/demo/exvol/iceberg_summit_demo'
        STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::631484165566:role/datalake-storage-integration-role'    
    )
);

-- Crate an Iceberg table from the external table data, using external volume:
create or replace iceberg table depositors
    with EXTERNAL_VOLUME='summit_demo_TEST'
    as select first_name, last_name, birth_date, address, phone, depositor_id, state from financial_one_depositors_ext;
    
