# Installation Instructions


In the following you will find installation instructions for the code of the different HM use cases.

## tl;dr

The process below explains step by step how to create the necessary database, warehouse, stage, notebooks etc. The tl;dr version of this process is the following, assuming you already have a Snowflake account and you are logged in:

1. In a SQL Worksheet, run [create_assets.sql](/setup/1_create_assets.sql)
2. Locally on your computer, run the Python script [2_get_data.py](/setup/2_get_data.py)
3. Go to the stage created and upload all the files under [/for_stage](/for_stage/)
4. In a SQL Worksheet, run [import_data.sql](/setup/3_import_data.sql)
5. In a SQL Worksheet, run [create_notebooks.sql](/setup/4_create_notebooks.sql)
6. Under Notebooks in the Snowflake UI you can view the Python notebooks created by this tutorial. Note that you will need to install some [Python](#loading-python-packages) and [RelationalAI](#loading-the-relationalaizip-and-rai_gnns_experimentalzip-python-packages) Python packages and also [provide access to S3](#external-access) for the notebooks to work.
