-- Script to load the H&M Personalized Fashion Recommendations dataset into Snowflake tables

USE ROLE ACCOUNTADMIN;
USE DATABASE HM_DB;
USE SCHEMA HM_SCHEMA;
USE WAREHOUSE HM_WH;

-- Create a file format for CSV
CREATE OR REPLACE FILE FORMAT my_csv_format
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    NULL_IF = ('NULL', 'null')
    FIELD_OPTIONALLY_ENCLOSED_BY = '0x22'
    EMPTY_FIELD_AS_NULL = TRUE;

-- Create the customers table
CREATE OR REPLACE TABLE CUSTOMERS (
	"customer_id" VARCHAR,
	"FN" FLOAT,
	"Active" FLOAT,
	"club_member_status" VARCHAR,
	"fashion_news_frequency" VARCHAR,
	"age" FLOAT,
	"postal_code" VARCHAR
);

-- Copy data into the customers table
COPY INTO CUSTOMERS
FROM '@"HM_DB"."HM_SCHEMA"."HM_STAGE"/customers.csv'
FILE_FORMAT = my_csv_format;

-- Create the articles table
CREATE OR REPLACE TABLE ARTICLES (
    "article_id" VARCHAR,
    "product_code" NUMBER(38,0),
    "prod_name" VARCHAR,
    "product_type_no" NUMBER(38,0),
    "product_type_name" VARCHAR,
    "product_group_name" VARCHAR,
    "graphical_appearance_no" NUMBER(38,0),
    "graphical_appearance_name" VARCHAR,
    "colour_group_code" NUMBER(38,0),
    "colour_group_name" VARCHAR,
    "perceived_colour_value_id" NUMBER(38,0),
    "perceived_colour_value_name" VARCHAR,
    "perceived_colour_master_id" NUMBER(38,0),
    "perceived_colour_master_name" VARCHAR,
    "department_no" NUMBER(38,0),
    "department_name" VARCHAR,
    "index_code" VARCHAR,
    "index_name" VARCHAR,
    "index_group_no" NUMBER(38,0),
    "index_group_name" VARCHAR,
    "section_no" NUMBER(38,0),
    "section_name" VARCHAR,
    "garment_group_no" NUMBER(38,0),
    "garment_group_name" VARCHAR,
    "detail_desc" VARCHAR
);

-- Copy data into the articles table
COPY INTO ARTICLES
FROM '@"HM_DB"."HM_SCHEMA"."HM_STAGE"/articles.csv'
FILE_FORMAT = my_csv_format;

-- Create the transactions table
CREATE OR REPLACE TABLE TRANSACTIONS (
    "t_dat" VARCHAR,
    "customer_id" VARCHAR,
    "article_id" VARCHAR,
    "price" FLOAT,
    "sales_channel_id" NUMBER(38,0)
);

-- Copy data into the transactions table
COPY INTO TRANSACTIONS
FROM '@"HM_DB"."HM_SCHEMA"."HM_STAGE"/transactions_train.csv'
FILE_FORMAT = my_csv_format;

-- Clean up
REMOVE '@"HM_DB"."HM_SCHEMA"."HM_STAGE"/customers.csv.gz';
REMOVE '@"HM_DB"."HM_SCHEMA"."HM_STAGE"/articles.csv.gz';
REMOVE '@"HM_DB"."HM_SCHEMA"."HM_STAGE"/transactions_train.csv.gz';
