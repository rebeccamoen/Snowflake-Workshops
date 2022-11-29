-- Leaving the Data Where it Lands
-- Query Data in the ZMD stage:
select $1 --  see what appears in the first column ($1) of each file
from @uni_klaus_zmd; 

-- Query Data in Just One File at a Time:
select $1
from @uni_klaus_zmd/product_coordination_suggestions.txt; 

-- Create an Exploratory File Format:
create file format zmd_file_format_1
RECORD_DELIMITER = '^';

-- Use the Exploratory File Format in a Query:
select $1
from @uni_klaus_zmd/product_coordination_suggestions.txt
(file_format => zmd_file_format_1);

-- Testing Our Second Theory:
create file format zmd_file_format_2
FIELD_DELIMITER = '^';  

select $1, $2, $3, $4, $5, $6, $7, $8, $9, $10
from @uni_klaus_zmd/product_coordination_suggestions.txt
(file_format => zmd_file_format_2);

-- A Third Possibility using both a field delimiter and a row delimiter:
create or replace file format zmd_file_format_3
FIELD_DELIMITER = '='
RECORD_DELIMITER = '^'; 

select $1, $2
from @uni_klaus_zmd/product_coordination_suggestions.txt
(file_format => zmd_file_format_3);

-- Revise zmd_file_format_1:
create or replace file format zmd_file_format_1
RECORD_DELIMITER = ';';

select $1 as sizes_available
from @uni_klaus_zmd/sweatsuit_sizes.txt
(file_format => zmd_file_format_1 );

-- Revamp zmd_file_format_2:
create or replace file format zmd_file_format_2
FIELD_DELIMITER = '|'
RECORD_DELIMITER = ';'
TRIM_SPACE = TRUE;

select $1, $2, $3
from @uni_klaus_zmd/swt_product_line.txt
(file_format => zmd_file_format_2);

-- Dealing with Unexpected Characters:
select TRIM(REPLACE($1,chr(13)||chr(10))) as sizes_available -- either add TRIM here or in the file format
from @uni_klaus_zmd/sweatsuit_sizes.txt
(file_format => zmd_file_format_1)
where sizes_available <> ''; -- removes the last empty row

-- Convert Your Select to a View:
create view zenas_athleisure_db.products.sweatsuit_sizes as 
select TRIM(REPLACE($1,chr(13)||chr(10))) as sizes_available
from @uni_klaus_zmd/sweatsuit_sizes.txt
(file_format => zmd_file_format_1)
where sizes_available <> '';

select * from zenas_athleisure_db.products.sweatsuit_sizes;

-- Challenge lab: Make the Sweatband Product Line File look great
create view zenas_athleisure_db.products.SWEATBAND_PRODUCT_LINE as
select REPLACE($1,chr(13)||chr(10)) as PRODUCT_CODE, $2 as HEADBAND_DESCRIPTION, $3 as WRISTBAND_DESCRIPTION
from @uni_klaus_zmd/swt_product_line.txt
(file_format => zmd_file_format_2);

select * from zenas_athleisure_db.products.SWEATBAND_PRODUCT_LINE;

-- Challenge lab: Make the Product Coordination Data look great:
create view zenas_athleisure_db.products.SWEATBAND_COORDINATION as
select REPLACE($1,chr(13)||chr(10)) as PRODUCT_CODE, $2 as HAS_MATCHING_SWEATSUIT
from @uni_klaus_zmd/product_coordination_suggestions.txt
(file_format => zmd_file_format_3);

select * from zenas_athleisure_db.products.SWEATBAND_COORDINATION;
