-- Exploring GeoSpatial Functions
-- Challenge lab: TO_GEOGRAPHY
select 
'LINESTRING('|| listagg(coord_pair, ',') within group (order by point_id)||')' as my_linestring
, TO_GEOGRAPHY(my_linestring) as length_of_trail
from cherry_creek_trail
group by trail_name;

-- Challenge lab: Calculate the Lengths for the Other Trails
select feature_name, st_length(TO_GEOGRAPHY(geometry)) as trail_length from denver_area_trails;

-- Challenge lab: Change your DENVER_AREA_TRAILS view to include a Length Column
select get_ddl('view', 'DENVER_AREA_TRAILS'); -- gets a copy of a CREATE OR REPLACE VIEW code block of the existing view

create or replace view DENVER_AREA_TRAILS(
    feature_name,
    feature_coordinates,
    geometry,
    trail_length, -- new column
    feature_properties,
    specs,
    whole_object
) as
select
$1:features[0]:properties:Name::string as feature_name
,$1:features[0]:geometry:coordinates::string as feature_coordinates
,$1:features[0]:geometry::string as geometry
,st_length(TO_GEOGRAPHY(geometry)) as trail_length -- new column
,$1:features[0]:properties::string as feature_properties
,$1:crs:properties:name::string as specs
,$1 as whole_object
from @trails_geojson (file_format => ff_json);

select * from denver_area_trails;

-- Create a View on Cherry Creek Data to have similar columns to DENVER_AREA_TRAILS:
select * from cherry_creek_trail;

-- (Even though this data started out as Parquet, and we're joining it with geoJSON data)
-- (So let's make it look like geoJSON instead)
create view DENVER_AREA_TRAILS_2 as
select 
trail_name as feature_name
,'{"coordinates":['||listagg('['||lng||','||lat||']',',')||'],"type":"LineString"}' as geometry
,st_length(to_geography(geometry)) as trail_length
from cherry_creek_trail
group by trail_name;

select * from denver_area_trails_2;

-- Use A Union All to Bring the Rows Into a Single Result Set:
select feature_name, geometry, trail_length
from DENVER_AREA_TRAILS
union all
select feature_name, geometry, trail_length
from DENVER_AREA_TRAILS_2;

-- GeoSpatial LineStrings for All 5 Trails in the Same View:
select feature_name, to_geography(geometry) as my_linestring, trail_length
from DENVER_AREA_TRAILS
union all
select feature_name, to_geography(geometry) as my_linestring, trail_length
from DENVER_AREA_TRAILS_2;

-- Add more GeoSpatial Calculations to get more GeoSpecial Information! 
select feature_name
, to_geography(geometry) as my_linestring
, st_xmin(my_linestring) as min_eastwest
, st_xmax(my_linestring) as max_eastwest
, st_ymin(my_linestring) as min_northsouth
, st_ymax(my_linestring) as max_northsouth
, trail_length
from DENVER_AREA_TRAILS
union all
select feature_name
, to_geography(geometry) as my_linestring
, st_xmin(my_linestring) as min_eastwest
, st_xmax(my_linestring) as max_eastwest
, st_ymin(my_linestring) as min_northsouth
, st_ymax(my_linestring) as max_northsouth
, trail_length
from DENVER_AREA_TRAILS_2;

-- Make it a View:
create view trails_and_boundaries as
select feature_name
, to_geography(geometry) as my_linestring
, st_xmin(my_linestring) as min_eastwest
, st_xmax(my_linestring) as max_eastwest
, st_ymin(my_linestring) as min_northsouth
, st_ymax(my_linestring) as max_northsouth
, trail_length
from DENVER_AREA_TRAILS
union all
select feature_name
, to_geography(geometry) as my_linestring
, st_xmin(my_linestring) as min_eastwest
, st_xmax(my_linestring) as max_eastwest
, st_ymin(my_linestring) as min_northsouth
, st_ymax(my_linestring) as max_northsouth
, trail_length
from DENVER_AREA_TRAILS_2;

select * from trails_and_boundaries;

-- A Polygon Can be Used to Create a Bounding Box:
select min(min_eastwest) as western_edge
,min(min_northsouth) as southern_edge
,max(max_eastwest) as eastern_edge
,max(max_northsouth) as northern_edge
from trails_and_boundaries;

select 'POLYGON(('||
    min(min_eastwest) ||' '|| max(max_northsouth) ||','||
    max(max_eastwest) ||' '|| max(max_northsouth) ||','||
    max(max_eastwest) ||' '|| min(min_northsouth) ||','||
    min(min_eastwest) ||' '|| min(min_northsouth) ||'))' as my_polygon
from trails_and_boundaries;

-- (Visualise in https://clydedacruz.github.io/openstreetmap-wkt-playground)

