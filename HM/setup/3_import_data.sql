-- ============================================
-- Script to load the H&M Personalized Fashion Recommendations dataset into Snowflake tables
-- ============================================

BEGIN
    -- 1. Declare variables
    LET db_name STRING := 'HM_DB_EDGE_IF';
    LET schema_name STRING := 'HM_SCHEMA';
    LET schema_full_name STRING := db_name || '.' || schema_name;
    LET role_name STRING := 'SYSADMIN';
    LET wh_name STRING := 'HM_WH';
    LET stage_name STRING := 'HM_STAGE';
    LET stage_full_name STRING := schema_full_name || '.' || stage_name;

    LET customers_table_stage_loc STRING := '@' || stage_full_name || '/customers.csv';
    LET articles_table_stage_loc STRING := '@' || stage_full_name || '/articles.csv';
    LET transactions_table_stage_loc STRING := '@' || stage_full_name || '/transactions_train.csv';

    -- 2. Use role, database, schema, warehouse dynamically
    EXECUTE IMMEDIATE 'USE ROLE ' || role_name;
    EXECUTE IMMEDIATE 'USE DATABASE ' || db_name;
    EXECUTE IMMEDIATE 'USE SCHEMA ' || schema_full_name;
    EXECUTE IMMEDIATE 'USE WAREHOUSE ' || wh_name;

    -- 3. Create a file format for CSV
    EXECUTE IMMEDIATE $$
        CREATE OR REPLACE FILE FORMAT my_csv_format
        TYPE = 'CSV'
        FIELD_DELIMITER = ','
        SKIP_HEADER = 1
        NULL_IF = ('NULL', 'null')
        FIELD_OPTIONALLY_ENCLOSED_BY = '0x22'
        EMPTY_FIELD_AS_NULL = TRUE
    $$;

    -- 4. Create tables
    EXECUTE IMMEDIATE $$
        CREATE OR REPLACE TABLE CUSTOMERS (
            "customer_id" VARCHAR,
            "FN" FLOAT,
            "Active" FLOAT,
            "club_member_status" VARCHAR,
            "fashion_news_frequency" VARCHAR,
            "age" FLOAT,
            "postal_code" VARCHAR
        )
    $$;

    EXECUTE IMMEDIATE $$
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
        )
    $$;

    EXECUTE IMMEDIATE $$
        CREATE OR REPLACE TABLE TRANSACTIONS (
            "t_dat" VARCHAR,
            "customer_id" VARCHAR,
            "article_id" VARCHAR,
            "price" FLOAT,
            "sales_channel_id" NUMBER(38,0)
        )
    $$;

    -- 5. Load data into tables using dynamic stage paths
    EXECUTE IMMEDIATE
        'COPY INTO CUSTOMERS FROM ''' || customers_table_stage_loc || ''' FILE_FORMAT = my_csv_format';

    EXECUTE IMMEDIATE
        'COPY INTO ARTICLES FROM ''' || articles_table_stage_loc || ''' FILE_FORMAT = my_csv_format';

    EXECUTE IMMEDIATE
        'COPY INTO TRANSACTIONS FROM ''' || transactions_table_stage_loc || ''' FILE_FORMAT = my_csv_format';

    -- 6. Clean up stage files
    EXECUTE IMMEDIATE 'REMOVE ''' || customers_table_stage_loc || '''';
    EXECUTE IMMEDIATE 'REMOVE ''' || articles_table_stage_loc || '''';
    EXECUTE IMMEDIATE 'REMOVE ''' || transactions_table_stage_loc || '''';

END;
