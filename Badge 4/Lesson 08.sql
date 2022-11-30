-- Supercharging Development with Marketplace Data
ALTER DATABASE OpenStreetMap_Denver RENAME TO SONRA_DENVER_CO_USA_FREE;
 
-- Using Variables in Snowflake Worksheets:
-- Melanie's Location into a 2 Variables (mc for melanies cafe)
set mc_lat='-104.97300245114094';
set mc_lng='39.76471253574085';

-- Confluence Park into a Variable (loc for location)
set loc_lat='-105.00840763333615'; 
set loc_lng='39.754141917497826';

-- Test your variables to see if they work with the Makepoint function
select st_makepoint($mc_lat,$mc_lng) as melanies_cafe_point;
select st_makepoint($loc_lat,$loc_lng) as confluent_park_point;

-- Use the variables to calculate the distance from 
-- Melanie's Cafe to Confluent Park
select st_distance(
        st_makepoint($mc_lat,$mc_lng)
        ,st_makepoint($loc_lat,$loc_lng)
        ) as mc_to_cp;
        
-- Calculating the distance to Melanie's Cafe using constants for coordinates:
select st_distance(
        st_makepoint('-104.97300245114094', '39.76471253574085')
        ,st_makepoint($loc_lat,$loc_lng)
        ) as mc_to_cp;

-- Create a User-Defined Function (UDF) for measuring distance:
create schema MELS_SMOOTHIE_CHALLENGE_DB.LOCATIONS;

CREATE OR REPLACE FUNCTION distance_to_mc(loc_lat number(38,32), loc_lng number(38,32))
  RETURNS FLOAT
  AS
  $$
   st_distance(
        st_makepoint('-104.97300245114094','39.76471253574085')
        ,st_makepoint(loc_lat,loc_lng)
        )
  $$
  ;

-- Test the New Function:
set tc_lat='-105.00532059763648'; 
set tc_lng='39.74548137398218';

select distance_to_mc($tc_lat,$tc_lng);

-- Create a List of Competing Juice Bars in the Area:
select * 
from SONRA_DENVER_CO_USA_FREE.DENVER.V_OSM_DEN_AMENITY_SUSTENANCE
where 
    ((amenity in ('fast_food','cafe','restaurant','juice_bar'))
    and 
    (name ilike '%jamba%' or name ilike '%juice%'
     or name ilike '%superfruit%'))
 or 
    (cuisine like '%smoothie%' or cuisine like '%juice%');
    
-- Challenge lab: Convert the List into a View
create view MELS_SMOOTHIE_CHALLENGE_DB.LOCATIONS.COMPETITION as
select * 
from SONRA_DENVER_CO_USA_FREE.DENVER.V_OSM_DEN_AMENITY_SUSTENANCE
where 
    ((amenity in ('fast_food','cafe','restaurant','juice_bar'))
    and 
    (name ilike '%jamba%' or name ilike '%juice%'
     or name ilike '%superfruit%'))
 or 
    (cuisine like '%smoothie%' or cuisine like '%juice%');
    
-- Which Competitor is Closest to Melanie's?
SELECT
 name
 ,cuisine
 , ST_DISTANCE(
    st_makepoint('-104.97300245114094','39.76471253574085')
    , coordinates
  ) AS distance_from_melanies
 ,*
FROM  competition
ORDER by distance_from_melanies;

-- Changing the Function to Accept a GEOGRAPHY Argument:
CREATE OR REPLACE FUNCTION distance_to_mc(lat_and_lng GEOGRAPHY)
  RETURNS FLOAT
  AS
  $$
   st_distance(
        st_makepoint('-104.97300245114094','39.76471253574085')
        ,lat_and_lng
        )
  $$
  ;

-- Now We Can Use it In Our Sonra Select:
SELECT
 name
 ,cuisine
 ,distance_to_mc(coordinates) AS distance_from_melanies
 ,*
FROM  competition
ORDER by distance_from_melanies;

-- We now have two Functions with Different Options but the Same Outcome:
-- Tattered Cover Bookstore McGregor Square:
set tcb_lat='-104.9956203'; 
set tcb_lng='39.754874';

-- This will run the first version of the UDF:
select distance_to_mc($tcb_lat,$tcb_lng);

-- This will run the second version of the UDF, bc it converts the coords 
-- to a geography object before passing them into the function:
select distance_to_mc(st_makepoint($tcb_lat,$tcb_lng));

-- This will run the second version bc the Sonra Coordinates column
-- contains geography objects already:
select name
, distance_to_mc(coordinates) as distance_to_melanies 
, ST_ASWKT(coordinates)
from SONRA_DENVER_CO_USA_FREE.DENVER.V_OSM_DEN_SHOP
where shop='books' 
and name like '%Tattered Cover%'
and addr_street like '%Wazee%';

-- Challenge lab: Create a View of Bike Shops in the Denver Data
create or replace view mels_smoothie_challenge_db.locations.denver_bike_shops as
select id, coordinates, shop, name, addr_city, opening_hours, phone, website, distance_to_mc(coordinates) as distance_to_melanies
from SONRA_DENVER_CO_USA_FREE.DENVER.V_OSM_DEN_SHOP_OUTDOORS_AND_SPORT_VEHICLES
where shop = 'bicycle';

select * from mels_smoothie_challenge_db.locations.denver_bike_shops;

-- Which Promo Partner is Closest to Melanie's?
select name, ST_ASWKT(coordinates), distance_to_melanies 
from mels_smoothie_challenge_db.locations.denver_bike_shops order by distance_to_melanies;
