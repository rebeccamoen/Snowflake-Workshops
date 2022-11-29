-- GeoSpatial Views
-- Look at the Parquet Data and sparse the data into columns:
select
    $1:sequence_1 as sequence_1,
    $1:trail_name::varchar as trail_name,
    $1:latitude as latitude,
    $1:longitude as longitude,
    $1:sequence_2 as sequence_2,
    $1:elevation as elevation
from @trails_parquet
(file_format => ff_parquet)
order by sequence_1;

-- Use a Select Statement to Fix some Issues:
-- (Don't need more than 8 decimal points on coordinates to get accuracy to within a millimeter)
select
    $1:sequence_1 as point_id,
    $1:trail_name::varchar as trail_name, -- latitude and longitude are flipped so lat = lng and lng = lat
    $1:latitude::number(11,8) as lng, -- longitudes are between 0 (the prime meridian) and 180, only 3 digits are needed to the left of the decimal
    $1:longitude::number(11,8) as lat -- latitudes are between 0 (the equator) and 90 (the poles), only 2 digits are needed left of the decimal
from @trails_parquet
(file_format => ff_parquet)
order by point_id;

-- Create a View of the Query:
CREATE VIEW MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.CHERRY_CREEK_TRAIL as
select
    $1:sequence_1 as point_id,
    $1:trail_name::varchar as trail_name,
    $1:latitude::number(11,8) as lng,
    $1:longitude::number(11,8) as lat
from @trails_parquet
(file_format => ff_parquet)
order by point_id;

select * from MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.CHERRY_CREEK_TRAIL;

-- Using concatenate to prepare the data for plotting on a map:
-- (Use the double pipe || to concatenate Chain Lat and Lng Together into a Coordinate Sets string)
select top 100
    lng||' ' ||lat as coord_pair
    ,'POINT('||coord_pair||')' as trail_point
from cherry_creek_trail;

-- Add coord_pairs as a column into our view:
-- (To add a column, we have to replace the entire view)
create or replace view cherry_creek_trail as
select 
 $1:sequence_1 as point_id,
 $1:trail_name::varchar as trail_name,
 $1:latitude::number(11,8) as lng,
 $1:longitude::number(11,8) as lat,
 lng||' '||lat as coord_pair
from @trails_parquet
(file_format => ff_parquet)
order by point_id;

select * from MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.CHERRY_CREEK_TRAIL;

-- Collapse Sets of Coordinates into Linestrings:
-- (Use Snowflakes LISTAGG function and the new COORD_PAIR column to make LINESTRINGS to paste into KWT Playground)
select 
'LINESTRING('||
listagg(coord_pair, ',') 
within group (order by point_id)
||')' as my_linestring
from cherry_creek_trail
where point_id <= 10
group by trail_name;

-- Making the whole trial into a single linestring:
select 
'LINESTRING('||
listagg(coord_pair, ',') 
within group (order by point_id)
||')' as my_linestring
from cherry_creek_trail
group by trail_name;

-- Look at the geoJSON Data:
select $1
from @trails_geojson
(file_format => ff_json);

-- Normalize the Data Without Loading It:
select
$1:features[0]:properties:Name::string as feature_name
,$1:features[0]:geometry:coordinates::string as feature_coordinates
,$1:features[0]:geometry::string as geometry
,$1:features[0]:properties::string as feature_properties
,$1:crs:properties:name::string as specs
,$1 as whole_object
from @trails_geojson (file_format => ff_json);

-- (Visually Display the geoJSON Data by pasting the coordinates into geojson.io)

-- Create a View Called DENVER_AREA_TRAILS:
create view denver_area_trails as
select
$1:features[0]:properties:Name::string as feature_name
,$1:features[0]:geometry:coordinates::string as feature_coordinates
,$1:features[0]:geometry::string as geometry
,$1:features[0]:properties::string as feature_properties
,$1:crs:properties:name::string as specs
,$1 as whole_object
from @trails_geojson (file_format => ff_json);
