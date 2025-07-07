# Installation Instructions


In the following you will find installation instructions for the code of the different H&M use cases.

## tl;dr

The process below explains step by step how to create the necessary database, warehouse, stage, notebooks etc. The tl;dr version of this process is the following, assuming you already have a Snowflake account and you are logged in:

1. In a SQL Worksheet, run [create_assets.sql](/HM/setup/1_create_assets.sql)
2. Locally on your computer, run the Python script [get_data.py](/HM/setup/2_get_data.py)
3. Go to the stage created and upload all the files under [/for_stage](/HM/for_stage/)
4. In a SQL Worksheet, run [import_data.sql](/HM/setup/3_import_data.sql)
5. In a SQL Worksheet, run [create_tasks.sql](/HM/setup/3_create_tasks.sql)
6. In a SQL Worksheet, run [create_notebooks.sql](/HM/setup/4_create_notebooks.sql)
7. Under Notebooks in the Snowflake UI you can view the Python notebooks created by this tutorial. Note that you will need to install some [Python](#loading-python-packages) and [RelationalAI](#loading-the-relationalaizip-and-rai_gnns_experimentalzip-python-packages) Python packages and also [provide access to S3](#external-access) for the notebooks to work.

## Account & User (optional)

You will need an account on Snowflake. If you need to create (and have permissions to do so) a new account, you can run the [create_account_and_user.sql](/HM/setup/0_create_account_and_user.sql) script specifying the specific admin name, password, etc.

> [!NOTE]
> You do not need to create a new account if you already have one.

Here is an example of creating an account called `HM_DEV`:

```sql
CREATE ACCOUNT HM_DEV
    ADMIN_NAME = <EXISTING_USER_HERE>
    ADMIN_PASSWORD = '<PASSWORD_HERE>'
    EMAIL = '<EMAIL_HERE>'
    MUST_CHANGE_PASSWORD = FALSE
    EDITION = ENTERPRISE
    ;
```

You will also need a user on the account. This user can be an existing user or you can create a new one (you can check out the [create_account_and_user.sql](/HM/setup/0_create_account_and_user.sql) script). Please ensure that you have logged into the account you will be using (e.g. with the `ADMIN_NAME` user specified above).

Here is an example of creating a new user `HM_ADMIN`.

```sql
USE ROLE ACCOUNTADMIN;

CREATE USER HM_ADMIN
    PASSWORD='<PASSWORD_HERE>'
    DEFAULT_ROLE = SYSADMIN
    DEFAULT_SECONDARY_ROLES = ('ALL')
    MUST_CHANGE_PASSWORD = FALSE
    LOGIN_NAME = HM_ADMIN
    DISPLAY_NAME = HM_ADMIN
    FIRST_NAME = HM_ADMIN
    LAST_NAME = HM_ADMIN
    ;

-- grant roles
GRANT ROLE ACCOUNTADMIN, SYSADMIN TO USER HM_ADMIN;

-- set default role to sysadmin
ALTER USER HM_ADMIN SET DEFAULT_ROLE=SYSADMIN;
```

## Getting Access to the RelationalAI Native App

For the use cases you will need to have access to the RelationalAI Native App.
For both apps, you can contact Nikolaos Vasiloglou `nik.vasiloglou@relational.ai` and Pigi Kouki `pigi.kouki@relational.ai` if you need assistance.

You will need your account to have the [RAI Native App for Snowflake](https://docs.relational.ai/manage/install) installed. The link provides detailed instructions on how to install the App. Note that you will need to be a user with either `ORGADMIN` or `ACCOUNTADMIN` privileges and it requires notification from Relational AI as to when your access is enabled for your account. Please ensure to specify that you need access to the experimental version of the RelationalAI Native App which has the `GNN` features available.

## Building the `rai_gnns_experimental.zip` package

For traininig models and making predictions you will be working through a Snowflake Notebook and you will need to access certain RelationalAI services through the GNN Python SDK. To this end, you will need the `rai_gnns_experimental.zip` file.

> [!WARNING]
> If you do not have access to the RelationalAI internal code repository you should ask a RelationalAI representative (Nikolaos Vasiloglou `nik.vasiloglou@relational.ai` and Pigi Kouki `pigi.kouki@relational.ai`) to give you the latest version of the `rai_gnns_experimental.zip` file. For your convenience a version has been provided in the [/for_stage](/for_stage/) folder but it is advisable to ask a RelationalAI representative for the latest version.

If you have access to RelationalAI's internal code repository you can build the `rai_gnns_experimental.zip` package from scratch by following the steps below in a shell.

```sh
git clone https://github.com/RelationalAI/gnn-learning-engine.git

cd gnn-learning-engine

zip -r rai_gnns_experimental rai_gnns_experimental
```

Once the process completes (or you directly got the file from [/for_stage](/for_stage/) or a RelationalAI representative) you will now have a file called `rai_gnns_experimental.zip`. Keep this file as we will upload it later on to a Snowflake stage.

## Set up Database Objects

In the following steps you will be creating Snowflake Database Objects such as a warehouse, schema, stage, etc.

### Specify Object Names

You can decide on the names that you'd like to use and set them up in variables in the beginning, so that the rest of the code below can create the objects.

> [!NOTE]
> You will need to run the following in a Snowflake SQL worksheet. You can find all the code in one place in the [create_assets.sql](/HM/setup/1_create_assets.sql) file.

Here is an example of the configuration of names for database, warehouse, stage, etc

```sql
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
```



### Cleanup and Create Role
The following cleans up by removing the database and warehouse for a fresh installation.

```sql
--
-- NOTE: in the following everything is DROPPED and re-created
--

-- cleanup
DROP DATABASE IF EXISTS identifier($db_name);
DROP WAREHOUSE IF EXISTS identifier($wh_name);

-- create role if needed
CREATE ROLE IF NOT EXISTS identifier($role_name);
```



### Create a Database

Next, you will create a database:

```sql
-- create a database
CREATE DATABASE IF NOT EXISTS identifier($db_name);
GRANT OWNERSHIP ON DATABASE identifier($db_name) TO ROLE identifier($role_name) COPY CURRENT GRANTS;
USE DATABASE identifier($db_name);
```



### Create a Warehouse

Next, you will create a warehouse:

```sql
-- create warehouse
CREATE OR REPLACE WAREHOUSE identifier($wh_name) WITH WAREHOUSE_SIZE = $wh_size;
GRANT USAGE ON WAREHOUSE identifier($wh_name) TO ROLE identifier($role_name);
```



### Create Schemas

You will need three schemas, the hm schema with the H&M tables, the churn chema with the churn task tables and the purchase schema with the purchase task tables. You can create these schemas as follows:

```sql
-- create schemas
CREATE SCHEMA IF NOT EXISTS identifier($schema_full_name);
GRANT USAGE ON SCHEMA identifier($schema_full_name) TO ROLE identifier($role_name);
USE SCHEMA identifier($schema_full_name);

CREATE SCHEMA IF NOT EXISTS identifier($schema_churn_full_name);
GRANT USAGE ON SCHEMA identifier($schema_churn_full_name) TO ROLE identifier($role_name);
USE SCHEMA identifier($schema_churn_full_name);

CREATE SCHEMA IF NOT EXISTS identifier($schema_purchase_full_name);
GRANT USAGE ON SCHEMA identifier($schema_purchase_full_name) TO ROLE identifier($role_name);
USE SCHEMA identifier($schema_purchase_full_name);
```



### Create a Stage

You will need the stage to upload the Python Notebooks as well as the raw csv data that will then imported into Snowflake Tables. You can create a stage as follows:

```sql
-- create a stage
CREATE STAGE IF NOT EXISTS identifier($stage_full_name) DIRECTORY = ( ENABLE = true );
GRANT READ ON STAGE identifier($stage_full_name) TO ROLE identifier($role_name);
```



### Enable User to Create Notebooks

Depending on the role used for accessing the database, you may need to grant the user certain privileges to allow creation of notebooks. You can grant the privilege as follows:

```sql
-- privilege for notebook
GRANT CREATE NOTEBOOK ON SCHEMA identifier($schema_full_name) TO ROLE identifier($role_name);
```

## Get data and upload to Snowflake stage

The use cases of this tutorial are based on the [**H&M Personalized Fashion Recommendations**](https://www.kaggle.com/competitions/h-and-m-personalized-fashion-recommendations/data?select=customers.csv). You will need to download the data from Kaggle and then upload it to the Snowflake stage you previously created. For that you have to follow these steps:

1. Go to the **Rules** page of the **H&M Personalized Fashion Recommendations** competition and accept the rules.
2. Go to the **settings** of your Kaggle profile, find the **API** section and click on the **Create New Token** button. This is going to download a **kaggle.json** containing your username and a key.
3. Download the [**get_data.py**](/HM/setup/2_get_data.py)
4. On your local machine create a conda environment:

```sh
conda create --name snowflake_kaggle_connector python=3.10

conda activate snowflake_kaggle_connector

pip install snowflake-connector-python kaggle python-dotenv pandas
```
4. In the same directory you put the **get_data.py**, create a **.env** file defining the following variables. 

```sh
KAGGLE_USERNAME = <username from kaggle.json>
KAGGLE_KEY = <key from kaggle.json>
SNOWFLAKE_USER=<snowflake username>
SNOWFLAKE_PASSWORD=<snowflake password>
SNOWFLAKE_ACCOUNT=<snowflake account>
SNOWFLAKE_WAREHOUSE=HM_WH
SNOWFLAKE_DATABASE=HM_DB
SNOWFLAKE_SCHEMA=HM_SCHEMA
SNOWFLAKE_ROLE=ACCOUNTADMIN
SNOWFLAKE_STAGE=HM_STAGE
```
5. Run the **get_data.py**
```sh
python 2_get_data.py
```

