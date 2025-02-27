-- Nested Semi-Structured Data

-- Create an Ingestion Table for the NESTED JSON Data
CREATE OR REPLACE TABLE LIBRARY_CARD_CATALOG.PUBLIC.NESTED_INGEST_JSON 
(
  "RAW_NESTED_BOOK" VARIANT
);

-- Create File Format for JSON Data
CREATE FILE FORMAT LIBRARY_CARD_CATALOG.PUBLIC.JSON_FILE_FORMAT 
TYPE = 'JSON' 
COMPRESSION = 'AUTO' 
ENABLE_OCTAL = FALSE
ALLOW_DUPLICATE = FALSE
STRIP_OUTER_ARRAY = TRUE
STRIP_NULL_VALUES = FALSE
IGNORE_UTF8_ERRORS = FALSE; 

-- Load data into the table
copy into LIBRARY_CARD_CATALOG.PUBLIC.NESTED_INGEST_JSON 
From @like_a_window_into_an_s3_bucket
files = ( 'json_book_author_nested.txt')
file_format = ( format_name='LIBRARY_CARD_CATALOG.PUBLIC.JSON_FILE_FORMAT' );

-- a few simple queries
SELECT RAW_NESTED_BOOK
FROM NESTED_INGEST_JSON;

SELECT RAW_NESTED_BOOK:year_published
FROM NESTED_INGEST_JSON;

SELECT RAW_NESTED_BOOK:authors
FROM NESTED_INGEST_JSON;

-- try changing the number in the bracketsd to return authors from a different row
SELECT RAW_NESTED_BOOK:authors[0].first_name
FROM NESTED_INGEST_JSON;

-- Use these example flatten commands to explore flattening the nested book and author data
SELECT value:first_name
FROM NESTED_INGEST_JSON
,LATERAL FLATTEN(input => RAW_NESTED_BOOK:authors);

SELECT value:first_name
FROM NESTED_INGEST_JSON
,table(flatten(RAW_NESTED_BOOK:authors));

-- Add a CAST command to the fields returned
SELECT value:first_name::VARCHAR, value:last_name::VARCHAR
FROM NESTED_INGEST_JSON
,LATERAL FLATTEN(input => RAW_NESTED_BOOK:authors);

-- Assign new column  names to the columns using "AS"
SELECT value:first_name::VARCHAR AS FIRST_NM
, value:last_name::VARCHAR AS LAST_NM
FROM NESTED_INGEST_JSON
,LATERAL FLATTEN(input => RAW_NESTED_BOOK:authors);

-- Create a new database to hold the Twitter file
CREATE DATABASE SOCIAL_MEDIA_FLOODGATES 
COMMENT = 'There\'s so much data from social media - flood warning';

USE DATABASE SOCIAL_MEDIA_FLOODGATES;

-- Create a table in the new database
CREATE TABLE SOCIAL_MEDIA_FLOODGATES.PUBLIC.TWEET_INGEST 
("RAW_STATUS" VARIANT) 
COMMENT = 'Bring in tweets, one row per tweet or status entity';

-- Create a JSON file format in the new database
CREATE FILE FORMAT SOCIAL_MEDIA_FLOODGATES.PUBLIC.JSON_FILE_FORMAT 
TYPE = 'JSON' 
COMPRESSION = 'AUTO' 
ENABLE_OCTAL = FALSE 
ALLOW_DUPLICATE = FALSE 
STRIP_OUTER_ARRAY = TRUE 
STRIP_NULL_VALUES = FALSE 
IGNORE_UTF8_ERRORS = FALSE;

-- Create a stage
create stage SOCIAL_MEDIA_FLOODGATES.PUBLIC.like_a_window_into_an_s3_bucket 
 url = 's3://uni-lab-files';
 
-- Load data into the table
copy into SOCIAL_MEDIA_FLOODGATES.PUBLIC.TWEET_INGEST 
From @like_a_window_into_an_s3_bucket
files = ( 'nutrition_tweets.json')
file_format = ( format_name='SOCIAL_MEDIA_FLOODGATES.PUBLIC.JSON_FILE_FORMAT' );

-- select statements as seen in the video
SELECT RAW_STATUS
FROM TWEET_INGEST;

SELECT RAW_STATUS:entities
FROM TWEET_INGEST;

SELECT RAW_STATUS:entities:hashtags
FROM TWEET_INGEST;

-- Explore looking at specific hashtags by adding bracketed numbers
-- This query returns just the first hashtag in each tweet
SELECT RAW_STATUS:entities:hashtags[0].text
FROM TWEET_INGEST;

-- This version adds a WHERE clause to get rid of any tweet that doesnt include any hashtags
SELECT RAW_STATUS:entities:hashtags[0].text
FROM TWEET_INGEST
WHERE RAW_STATUS:entities:hashtags[0].text is not null;

-- Perform a simple CAST on the created_at key
-- Add an ORDER BY clause to sort by the tweets creation date
SELECT RAW_STATUS:created_at::DATE
FROM TWEET_INGEST
ORDER BY RAW_STATUS:created_at::DATE;

-- Flatten statements that return the whole hashtag entity
SELECT value
FROM TWEET_INGEST
,LATERAL FLATTEN
(input => RAW_STATUS:entities:hashtags);

SELECT value
FROM TWEET_INGEST
,TABLE(FLATTEN(RAW_STATUS:entities:hashtags));

-- Flatten statement that restricts the value to just the TEXT of the hashtag
SELECT value:text
FROM TWEET_INGEST
,LATERAL FLATTEN
(input => RAW_STATUS:entities:hashtags);

-- Flatten and return just the hashtag text, CAST the text as VARCHAR
SELECT value:text::VARCHAR
FROM TWEET_INGEST
,LATERAL FLATTEN
(input => RAW_STATUS:entities:hashtags);

-- Flatten and return just the hashtag text, CAST the text as VARCHAR
-- Use the AS command to name the column
SELECT value:text::VARCHAR AS THE_HASHTAG
FROM TWEET_INGEST
,LATERAL FLATTEN
(input => RAW_STATUS:entities:hashtags);

-- Add the Tweet ID and User ID to the returned table
SELECT RAW_STATUS:user:id AS USER_ID
,RAW_STATUS:id AS TWEET_ID
,value:text::VARCHAR AS HASHTAG_TEXT
FROM TWEET_INGEST
,LATERAL FLATTEN
(input => RAW_STATUS:entities:hashtags);
 
-- Create a View of the Tweet Data Looking "Normalized"
create or replace view SOCIAL_MEDIA_FLOODGATES.PUBLIC.HASHTAGS_NORMALIZED as
(SELECT RAW_STATUS:user:id AS USER_ID
,RAW_STATUS:id AS TWEET_ID
,value:text::VARCHAR AS HASHTAG_TEXT
FROM TWEET_INGEST
,LATERAL FLATTEN
(input => RAW_STATUS:entities:hashtags)
);

SELECT * FROM SOCIAL_MEDIA_FLOODGATES.PUBLIC.HASHTAGS_NORMALIZED;
