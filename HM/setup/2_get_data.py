import os
import shutil
import pandas as pd
import snowflake.connector
from zipfile import ZipFile
from dotenv import load_dotenv
from kaggle.api.kaggle_api_extended import KaggleApi

# Load environment variables from .env file
load_dotenv()

# Connecting to Kaggle
api = KaggleApi()
api.authenticate()

# Connecting to Snowflake
conn = snowflake.connector.connect(
    user=os.getenv("SNOWFLAKE_USER"),
    password=os.getenv("SNOWFLAKE_PASSWORD"),
    account=os.getenv("SNOWFLAKE_ACCOUNT"),
    warehouse=os.getenv("SNOWFLAKE_WAREHOUSE"),
    database=os.getenv("SNOWFLAKE_DATABASE"),
    schema=os.getenv("SNOWFLAKE_SCHEMA"),
    role=os.getenv("SNOWFLAKE_ROLE")
)

# Define paths and dataset information
zip_path = './hm-tables-zip'
data_path = './hm-tables'
dataset_name = 'h-and-m-personalized-fashion-recommendations'
file_names = ['articles.csv', 'customers.csv', 'transactions_train.csv']

# Create directories for storing the downloaded zip files and extracted data
os.makedirs(zip_path, exist_ok=False)
os.makedirs(data_path, exist_ok=False)

# Downloading and extracting the files from Kaggle competition H&M Personalized Fashion Recommendations
for file_name in file_names:
    api.competition_download_file(dataset_name, file_name, path=zip_path)
    with ZipFile(os.path.join(zip_path, file_name)) as zf:
        zf.extractall(data_path)

# Read the CSV files into pandas DataFrames
articles_df = pd.read_csv(os.path.join(data_path, 'articles.csv'))
print(articles_df.head())

# Clean up the zip directory after extraction
shutil.rmtree(zip_path)

# Upload the CSV files to Snowflake stage
for file_name in file_names:
    # File and stage path
    local_csv_path = os.path.join(data_path, file_name)
    stage_path = f"@{os.getenv('SNOWFLAKE_DATABASE')}.{os.getenv('SNOWFLAKE_SCHEMA')}.{os.getenv('SNOWFLAKE_STAGE')}"

    # Upload the file
    put_command = f"""
    PUT file://{os.path.abspath(local_csv_path)} {stage_path}
    AUTO_COMPRESS=TRUE
    """

    cursor = conn.cursor()
    cursor.execute(put_command)
    print("✅ Upload successful!")
    for row in cursor.fetchall():
        print(row)

cursor.close()
conn.close()