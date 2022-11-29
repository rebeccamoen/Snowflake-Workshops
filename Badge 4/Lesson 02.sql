-- Reviewing Data Structuring & Stage Types
-- Create a Database for Zena's Athleisure Idea:
use role sysadmin;
create database ZENAS_ATHLEISURE_DB;
create schema ZENAS_ATHLEISURE_DB.PRODUCTS;
drop schema ZENAS_ATHLEISURE_DB.PUBLIC;

-- Create a Stage to Access the Sweat Suit Images:
create stage ZENAS_ATHLEISURE_DB.PRODUCTS.UNI_KLAUS_CLOTHING
url = 's3://uni-klaus/clothing';

list @ZENAS_ATHLEISURE_DB.PRODUCTS.UNI_KLAUS_CLOTHING;

-- Create another Stage for another of Klaus' folders:
create stage ZENAS_ATHLEISURE_DB.PRODUCTS.UNI_KLAUS_ZMD
url = 's3://uni-klaus/zenas_metadata';

list @ZENAS_ATHLEISURE_DB.PRODUCTS.UNI_KLAUS_ZMD;

-- Create a third Stage:
create stage ZENAS_ATHLEISURE_DB.PRODUCTS.UNI_KLAUS_SNEAKERS
url = 's3://uni-klaus/sneakers';

list @ZENAS_ATHLEISURE_DB.PRODUCTS.UNI_KLAUS_SNEAKERS;
