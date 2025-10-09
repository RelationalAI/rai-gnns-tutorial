-- Define database, schemas and tables
SET db_name = 'hm_db';
SET schema_name = 'hm_schema';
SET schema_full_name = $db_name||'.'||$schema_name; -- fully-qualified
SET schema_purchase_name = 'hm_purchase';
SET schema_purchase_full_name = $db_name||'.'||$schema_purchase_name; -- fully-qualified
SET schema_churn_name = 'hm_churn';
SET schema_churn_full_name = $db_name||'.'||$schema_churn_name; -- fully-qualified

SET customers_table_name = 'customers';
SET customers_table_full_name = $schema_full_name||'.'||$customers_table_name;
SET articles_table_name = 'articles';
SET articles_table_full_name = $schema_full_name||'.'||$articles_table_name;
SET transactions_table_name = 'transactions';
SET transactions_table_full_name = $schema_full_name||'.'||$transactions_table_name;

SET churn_train_table_name = $schema_churn_full_name||'.'||'train';
SET churn_validation_table_name = $schema_churn_full_name||'.'||'validation';
SET churn_test_table_name = $schema_churn_full_name||'.'||'test';

SET purchase_train_table_name = $schema_purchase_full_name||'.'||'train';
SET purchase_validation_table_name = $schema_purchase_full_name||'.'||'validation';
SET purchase_test_table_name = $schema_purchase_full_name||'.'||'test';

USE ROLE SYSADMIN;
USE DATABASE IDENTIFIER($db_name);

-- CHURN TASK
-- Create or replace the TRAIN table with the first 52 weeks
CREATE OR REPLACE TABLE IDENTIFIER($churn_train_table_name) AS
-- Generates 52 timestamps, each one week apart, starting from '2019-09-02'
WITH timestamps AS (
    SELECT DATEADD(WEEK, ROW_NUMBER() OVER (ORDER BY TRUE) - 1, '2019-09-02') AS timestamp
    FROM TABLE(GENERATOR(ROWCOUNT => 52))
)
-- Check if a customer churned by checking
-- if there were transactions made by that customer during the next week
SELECT * FROM (
SELECT
    TO_VARCHAR(ts.timestamp, 'YYYY-MM-DD') AS "timestamp",
    c."customer_id",
    CAST(
        NOT EXISTS (
            SELECT 1
            FROM IDENTIFIER($transactions_table_full_name) t
            WHERE
                t."customer_id" = c."customer_id"
                AND CAST(t."t_dat" AS DATE) > ts.timestamp
                AND CAST(t."t_dat" AS DATE) <= DATEADD(DAY, 7, ts.timestamp)
        ) AS INTEGER
    ) AS "churn"
FROM
    timestamps ts,
    IDENTIFIER($customers_table_full_name) c
-- Ensure that the customer was active before by checking if
-- there were transactions made by that customer during the previous week
WHERE
    EXISTS (
        SELECT 1
        FROM IDENTIFIER($transactions_table_full_name) t
        WHERE
            t."customer_id" = c."customer_id"
            AND CAST(t."t_dat" AS DATE) > DATEADD(DAY, -7, ts.timestamp)
            AND CAST(t."t_dat" AS DATE) <= ts.timestamp
    )
) AS shuffled_table
ORDER BY RANDOM();

-- Create the VALIDATION table with the 53rd week
CREATE OR REPLACE TABLE IDENTIFIER($churn_validation_table_name) AS
WITH timestamps AS (
    SELECT '2020-08-31' AS timestamp
)
SELECT * FROM (
SELECT
    ts.timestamp as "timestamp",
    c."customer_id",
    CAST(
        NOT EXISTS (
            SELECT 1
            FROM IDENTIFIER($transactions_table_full_name) t
            WHERE
                t."customer_id" = c."customer_id"
                AND CAST(t."t_dat" AS DATE) > ts.timestamp
                AND CAST(t."t_dat" AS DATE) <= DATEADD(DAY, 7, ts.timestamp)
        ) AS INTEGER
    ) AS "churn"
FROM
    timestamps ts,
    IDENTIFIER($customers_table_full_name) c
WHERE
    EXISTS (
        SELECT 1
        FROM IDENTIFIER($transactions_table_full_name) t
        WHERE
            t."customer_id" = c."customer_id"
            AND CAST(t."t_dat" AS DATE) > DATEADD(DAY, -7, ts.timestamp)
            AND CAST(t."t_dat" AS DATE) <= ts.timestamp
    )
) AS shuffled_table
ORDER BY RANDOM();

-- Create the TEST table with the 54th week
CREATE OR REPLACE TABLE IDENTIFIER($churn_test_table_name) AS
WITH timestamps AS (
    SELECT '2020-09-07' AS timestamp
)
SELECT * FROM (
SELECT
    ts.timestamp as "timestamp",
    c."customer_id",
    CAST(
        NOT EXISTS (
            SELECT 1
            FROM IDENTIFIER($transactions_table_full_name) t
            WHERE
                t."customer_id" = c."customer_id"
                AND CAST(t."t_dat" AS DATE) > ts.timestamp
                AND CAST(t."t_dat" AS DATE) <= DATEADD(DAY, 7, ts.timestamp)
        ) AS INTEGER
    ) AS "churn"
FROM
    timestamps ts,
    IDENTIFIER($customers_table_full_name) c
WHERE
    EXISTS (
        SELECT 1
        FROM IDENTIFIER($transactions_table_full_name) t
        WHERE
            t."customer_id" = c."customer_id"
            AND CAST(t."t_dat" AS DATE) > DATEADD(DAY, -7, ts.timestamp)
            AND CAST(t."t_dat" AS DATE) <= ts.timestamp
    )
) AS shuffled_table
ORDER BY RANDOM();

-- PURCHASE TASK
-- Create or replace the TRAIN task table for training
CREATE OR REPLACE TABLE IDENTIFIER($purchase_train_table_name) AS
-- Generate 52 weekly timestamps starting from 2019-09-02
WITH timestamps AS (
    SELECT DATEADD(WEEK, ROW_NUMBER() OVER (ORDER BY TRUE) - 1, '2019-09-02') AS timestamp
    FROM TABLE(GENERATOR(ROWCOUNT => 52))
),
-- Join transactions that happen within [timestamp, timestamp + 7 days]
joined AS (
    SELECT
        ts.timestamp,
        t."customer_id",
        t."article_id"
    FROM timestamps ts
    JOIN IDENTIFIER($transactions_table_full_name) t
        ON CAST(t."t_dat" AS DATE) > ts.timestamp
        AND CAST(t."t_dat" AS DATE) <= DATEADD(DAY, 7, ts.timestamp)
)
-- Aggregate article_ids as array per customer per timestamp
SELECT *
FROM joined
ORDER BY RANDOM();

-- Create the VALIDATION table with the 53rd week
CREATE OR REPLACE TABLE IDENTIFIER($purchase_validation_table_name) AS
WITH timestamps AS (
    SELECT '2020-08-31' AS timestamp
),
-- Join transactions that happen within [timestamp, timestamp + 7 days]
joined AS (
    SELECT
        ts.timestamp,
        t."customer_id",
        t."article_id"
    FROM timestamps ts
    JOIN IDENTIFIER($transactions_table_full_name) t
        ON CAST(t."t_dat" AS DATE) > ts.timestamp
        AND CAST(t."t_dat" AS DATE) <= DATEADD(DAY, 7, ts.timestamp)
)
-- Aggregate article_ids as array per customer per timestamp
SELECT *
FROM joined
ORDER BY RANDOM();

-- Create the TEST table with the 54th week
CREATE OR REPLACE TABLE IDENTIFIER($purchase_test_table_name) AS
WITH timestamps AS (
    SELECT '2020-09-07' AS timestamp
),
-- Join transactions that happen within [timestamp, timestamp + 7 days]
joined AS (
    SELECT
        ts.timestamp,
        t."customer_id",
        t."article_id"
    FROM timestamps ts
    JOIN IDENTIFIER($transactions_table_full_name) t
        ON CAST(t."t_dat" AS DATE) > ts.timestamp
        AND CAST(t."t_dat" AS DATE) <= DATEADD(DAY, 7, ts.timestamp)
)
SELECT *
FROM joined
ORDER BY RANDOM();