-- making sure "AWS" appears in the answer:
select current_region(); -- AWS_CA_CENTRAL_1

-- get your Account Locator:
select current_account(); -- MC23304


-- Fruityvice + Rivery River:
select * from PC_RIVERY_DB.PUBLIC.FDC_FOOD_INGEST;

-- Backup table:
CREATE TABLE FDC_FOOD_INGEST_303 CLONE FDC_FOOD_INGEST;
TRUNCATE TABLE FDC_FOOD_INGEST;

-- Create a Table with a list for Looping Logic:
CREATE TABLE FRUIT_LOAD_LIST(FRUIT_NAME varchar(255));
insert into pc_rivery_db.public.fruit_load_list values 
('banana')
,('cherry')
,('strawberry')
,('pineapple')
,('apple')
,('mango')
,('coconut')
,('plum')
,('avocado')
,('starfruit');


-- Stages, SnowSQL, and PUT Commands
-- The stages that currently exist in our account:
show stages in account;

-- Create an Internal Stage:
create stage "DEMO_DB"."PUBLIC".my_internal_named_stage;

-- LIST command to view a list of files in your Named Internal Stage:
list @my_internal_named_stage;

select $1 from @my_internal_named_stage/my_file.txt.gz;


-- Query the information_schema to view your user's login history:
select * from table(information_schema.login_history_by_user('username', result_limit=>10))
order by event_timestamp desc;

-- Add rows to Fruit List in Snowflake:
insert into fruit_load_list values ('test');
select * from fruit_load_list;

-- Delete any "test" and "from streamlit" rows:
delete from fruit_load_list
where fruit_name like 'test'
or fruit_name like 'from streamlit';
