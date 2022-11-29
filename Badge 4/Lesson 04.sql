-- Working with External Unstructured Data
-- Run a List Command On the Clothing Stage:
list @ZENAS_ATHLEISURE_DB.PRODUCTS.UNI_KLAUS_CLOTHING;

-- Query the Unstructured External Data with 2 Built-In Meta-Data Columns:
select metadata$filename, metadata$file_row_number
from @uni_klaus_clothing/90s_tracksuit.png;

-- Write a Query that returns something more like a List Command:
select metadata$filename, count(metadata$file_row_number)
from @uni_klaus_clothing/90s_tracksuit.png
GROUP BY metadata$filename;

-- Enabling, Refreshing and Querying Directory Tables:
-- (Directory Tables)
select * from directory(@uni_klaus_clothing);

-- (Oh Yeah! We have to turn them on, first)
alter stage uni_klaus_clothing 
set directory = (enable = true);

-- (Now?)
select * from directory(@uni_klaus_clothing);

-- (Oh Yeah! Then we have to refresh the directory table!)
alter stage uni_klaus_clothing refresh;

-- (Now?)
select * from directory(@uni_klaus_clothing);

-- Testing UPPER and REPLACE functions on directory table:
-- (Define a column using the AS syntax and then use that column name in the very next line of the same SELECT)
select UPPER(RELATIVE_PATH) as uppercase_filename
, REPLACE(uppercase_filename,'/') as no_slash_filename
, REPLACE(no_slash_filename,'_',' ') as no_underscores_filename
, REPLACE(no_underscores_filename,'.PNG') as just_words_filename
from directory(@uni_klaus_clothing); 

-- Challenge lab: Nest 4 Functions into 1 Statement
select REPLACE(REPLACE(REPLACE(UPPER(RELATIVE_PATH),'/'), '_', ' '),'.PNG') as product_name
from directory(@uni_klaus_clothing); 

-- Functions Work on Directory Tables, What About Joins?
-- Create an Internal Table in the Zena Database for some sweat suit info:
create or replace TABLE ZENAS_ATHLEISURE_DB.PRODUCTS.SWEATSUITS (
	COLOR_OR_STYLE VARCHAR(25),
	DIRECT_URL VARCHAR(200),
	PRICE NUMBER(5,2)
);

-- Fill the new table with some data:
insert into  ZENAS_ATHLEISURE_DB.PRODUCTS.SWEATSUITS 
          (COLOR_OR_STYLE, DIRECT_URL, PRICE)
values
('90s', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/90s_tracksuit.png',500)
,('Burgundy', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/burgundy_sweatsuit.png',65)
,('Charcoal Grey', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/charcoal_grey_sweatsuit.png',65)
,('Forest Green', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/forest_green_sweatsuit.png',65)
,('Navy Blue', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/navy_blue_sweatsuit.png',65)
,('Orange', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/orange_sweatsuit.png',65)
,('Pink', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/pink_sweatsuit.png',65)
,('Purple', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/purple_sweatsuit.png',65)
,('Red', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/red_sweatsuit.png',65)
,('Royal Blue',	'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/royal_blue_sweatsuit.png',65)
,('Yellow', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/yellow_sweatsuit.png',65);

--  Using Functions in the ON clause of the JOIN:
SELECT color_or_style, direct_url, price, size as image_size, last_modified as image_last_modified 
FROM ZENAS_ATHLEISURE_DB.PRODUCTS.SWEATSUITS s
JOIN directory(@uni_klaus_clothing) d
ON d.relative_path = SUBSTR(s.direct_url,54,50);

-- Add a CROSS JOIN:
-- 3 way join - internal table, directory table, and view based on external data:
select color_or_style
, direct_url
, price
, size as image_size
, last_modified as image_last_modified
, sizes_available
from sweatsuits 
join directory(@uni_klaus_clothing) 
on relative_path = SUBSTR(direct_url,54,50)
cross join sweatsuit_sizes;

-- Convert Your Select Statement to a View:
CREATE VIEW ZENAS_ATHLEISURE_DB.PRODUCTS.CATALOG as
select color_or_style
, direct_url
, price
, size as image_size
, last_modified as image_last_modified
, sizes_available
from ZENAS_ATHLEISURE_DB.PRODUCTS.SWEATSUITS 
join directory(@uni_klaus_clothing) 
on relative_path = SUBSTR(direct_url,54,50)
cross join sweatsuit_sizes;

select * from ZENAS_ATHLEISURE_DB.PRODUCTS.CATALOG;

-- Add the Upsell Table and Populate It:
-- Add a table to map the sweat suits to the sweat band sets:
create table ZENAS_ATHLEISURE_DB.PRODUCTS.UPSELL_MAPPING
(
SWEATSUIT_COLOR_OR_STYLE varchar(25)
,UPSELL_PRODUCT_CODE varchar(10)
);

-- Populate the upsell table:
insert into ZENAS_ATHLEISURE_DB.PRODUCTS.UPSELL_MAPPING
(
SWEATSUIT_COLOR_OR_STYLE
,UPSELL_PRODUCT_CODE 
)
VALUES
('Charcoal Grey','SWT_GRY')
,('Forest Green','SWT_FGN')
,('Orange','SWT_ORG')
,('Pink', 'SWT_PNK')
,('Red','SWT_RED')
,('Yellow', 'SWT_YLW');

SELECT * FROM ZENAS_ATHLEISURE_DB.PRODUCTS.UPSELL_MAPPING;

-- Zena's View for the Athleisure Web Catalog Prototype:
-- Zena needs a single view she can query for her website prototype
create view catalog_for_website as 
select color_or_style
,price
,direct_url
,size_list
,coalesce('BONUS: ' ||  headband_description || ' & ' || wristband_description, 'Consider White, Black or Grey Sweat Accessories')  as upsell_product_desc
from
(   select color_or_style, price, direct_url, image_last_modified,image_size
    ,listagg(sizes_available, ' | ') within group (order by sizes_available) as size_list
    from catalog
    group by color_or_style, price, direct_url, image_last_modified, image_size
) c
left join upsell_mapping u
on u.sweatsuit_color_or_style = c.color_or_style
left join sweatband_coordination sc
on sc.product_code = u.upsell_product_code
left join sweatband_product_line spl
on spl.product_code = sc.product_code
where price < 200 -- high priced items like vintage sweatsuits aren't a good fit for this website
and image_size < 1000000 -- large images need to be processed to a smaller size
;

SELECT * FROM catalog_for_website;
