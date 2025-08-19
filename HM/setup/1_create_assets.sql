--
-- NOTE: everything is DROPPED and re-created
--
--
-- NOTE: this file works but is work in progress. For now, please don't change the
-- initial parameters (db_name, schema_name, etc.)
--

USE ROLE ACCOUNTADMIN;

-- set up of constants, change the names in this section of what assets you'd like to create,
-- no need to touch the rest of the code

SET db_name = 'hm_db';
SET schema_name = 'hm_schema';
SET schema_full_name = $db_name||'.'||$schema_name; -- fully-qualified
SET schema_purchase_name = 'hm_purchase';
SET schema_purchase_full_name = $db_name||'.'||$schema_purchase_name; -- fully-qualified
SET schema_churn_name = 'hm_churn';
SET schema_churn_full_name = $db_name||'.'||$schema_churn_name; -- fully-qualified
SET stage_name = 'hm_stage'; -- fully-qualified
SET stage_full_name = $schema_full_name||'.'||$stage_name;
SET wh_name = 'hm_wh';
SET wh_size = 'X-SMALL';
SET role_name = 'SYSADMIN';   -- what role will have access to the db/warehouse/schema etc.

--
-- assets
--
-- cleanup
DROP DATABASE IF EXISTS identifier($db_name);
DROP WAREHOUSE IF EXISTS identifier($wh_name);

-- create role
CREATE ROLE IF NOT EXISTS identifier($role_name);

USE ROLE identifier($role_name);

-- create a database
CREATE DATABASE IF NOT EXISTS identifier($db_name);
USE DATABASE identifier($db_name);

-- create warehouse
CREATE OR REPLACE WAREHOUSE identifier($wh_name) WITH WAREHOUSE_SIZE = $wh_size;

-- create schemas
CREATE SCHEMA IF NOT EXISTS identifier($schema_full_name);
USE SCHEMA identifier($schema_full_name);

CREATE SCHEMA IF NOT EXISTS identifier($schema_churn_full_name);
USE SCHEMA identifier($schema_churn_full_name);

CREATE SCHEMA IF NOT EXISTS identifier($schema_purchase_full_name);
USE SCHEMA identifier($schema_purchase_full_name);

-- create a stage
CREATE STAGE IF NOT EXISTS identifier($stage_full_name) DIRECTORY = ( ENABLE = true );

-- privilege for notebook
GRANT CREATE NOTEBOOK ON SCHEMA identifier($schema_full_name) TO ROLE identifier($role_name);
