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

## Getting Access to the Native Apps

For the use cases you will need to have access to two different RelationalAI Native Apps.
For both apps, you can contact Nikolaos Vasiloglou `nik.vasiloglou@relational.ai` and Pigi Kouki `pigi.kouki@relational.ai` if you need assistance.

### RelationalAI Native App

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

