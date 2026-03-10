--
-- notebooks
--
USE ROLE SYSADMIN;
USE DATABASE HM_DB;
USE SCHEMA HM_SCHEMA;


-- churn_prediction.ipynb
CREATE OR REPLACE NOTEBOOK churn_prediction
    FROM '@hm_db.hm_schema.hm_stage'
    MAIN_FILE = 'CHURN_PREDICTION.ipynb'
    QUERY_WAREHOUSE = HM_WH
    RUNTIME_NAME = 'SYSTEM$GPU_RUNTIME'
    COMPUTE_POOL = 'GNN_ENGINE_GPU_S';

-- purchase_recommendations.ipynb
CREATE OR REPLACE NOTEBOOK purchase_recommendations
    FROM '@hm_db.hm_schema.hm_stage'
    MAIN_FILE = 'PURCHASE_RECOMMENDATIONS.ipynb'
    QUERY_WAREHOUSE = HM_WH
    RUNTIME_NAME = 'SYSTEM$GPU_RUNTIME'
    COMPUTE_POOL = 'GNN_ENGINE_GPU_S';
    ;
