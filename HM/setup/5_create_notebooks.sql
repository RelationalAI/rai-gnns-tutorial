--
-- notebooks
--
USE ROLE ACCOUNTADMIN;
USE DATABASE HM_DB;
USE SCHEMA HM_SCHEMA;


-- churn_prediction.ipynb
CREATE OR REPLACE NOTEBOOK churn_prediction
    FROM '@hm_db.hm_schema.hm_stage'
    MAIN_FILE = 'churn_prediction.ipynb'
    QUERY_WAREHOUSE = HM_WH
    WAREHOUSE = HM_WH
    ;

-- purchase_recommendations.ipynb
CREATE OR REPLACE NOTEBOOK purchase_recommendations
    FROM '@hm_db.hm_schema.hm_stage'
    MAIN_FILE = 'purchase_recommendations.ipynb'
    QUERY_WAREHOUSE = HM_WH
    WAREHOUSE = HM_WH
    ;