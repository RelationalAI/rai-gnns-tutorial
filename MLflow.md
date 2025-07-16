<a name="mlflow"></a>
### 📈 MLflow
[MLflow](https://mlflow.org/)  is a widely used platform in the data science community, making it a familiar and powerful choice for tracking and managing machine learning experiments. Its comprehensive features allow users to monitor training progress, evaluate model performance, and manage model versions efficiently.

MLflow simplifies multiple stages of the modeling process, allowing you to:

- track real-time training metrics
- analyze results post-training and register models for future use
- viewing and managing registered models
 
Below, we provide an overview of these three key areas. For a comprehensive guide to MLflow’s capabilities, you can refer to the official [MLflow documentation](https://mlflow.org/docs/latest/index.html).

<a name="track-real-time-training-metrics"></a>
#### 🎯 Track real-time training metrics
During training, you can monitor the training process in real time via the **MLflow** page.

To access the MLflow page you can run:

```python
connector._get_gnn_engine_details(engine_name)
```

This will return a table with the engine details:

<picture>
  <img src="/HM/assets/mlflow_4.png" alt="stage" style="width:950px;">
</picture>

Scroll to the right and locate the **ingress URL** for the **mlflowendpoint** in the **Settings** cell. Use the URL to navigate to the MLflow page, then log in using your Snowflake credentials.

<picture>
  <img src="/HM/assets/mlflow_5.png" alt="stage" style="width:950px;">
</picture>

Upon opening MLflow, you will see two main tabs: the **Experiments** tab and the **Models** tab. The **Experiments** tab displays a list of all your experiments on the left side. By selecting your current experiment, identified by its `DatasetName/TaskType/TaskName`, you will see all models trained under that experiment listed on the main page. Clicking on a specific model will direct you to its detailed page, where you can track its progress. 

If the model is still training, the **Overview** tab will indicate that its **Status** is **Running**. To analyze its performance metrics in real time, navigate to the **Model Metrics** tab, where you can see key training statistics such as **training loss**, **validation loss**, **evaluation metrics**, and **learning rate updates**. These metrics are continuously updated as training progresses, allowing you to track improvements and detect any potential issues.

<a name="analyze-results-post-training-and-register-models-for-future-use"></a>
#### 🎯 Analyze Results Post-training and Register Models for Future Use
Once training is complete, you can inspect the details and the final evaluation metrics of your trained model. To do so, once again, go to the **Experiments** tab and select the appropriate experiment using the `DatasetName/TaskType/TaskName` format. From there, choose the trained model you wish to examine. Clicking on the model will take you to its dedicated page, where you can review its final results.

In the **Overview** tab, the **Status** will now be marked as **Finished**, indicating that training has concluded. Here, you will find a summary of the model’s **parameters** and **final evaluation metrics**. If you navigate to the **Model Metrics** tab, you will see a detailed view of how the model’s metrics evolved during training, including loss curves and performance trends. Monitoring these trends can help you assess whether the model is learning effectively or if adjustments are needed. 

Typically, the training loss should decrease as the model trains for more epochs, while the validation loss may initially decrease and then stabilize or slightly increase if overfitting occurs. Similarly, the validation metric (e.g., accuracy or F1 score) should generally improve during training but may plateau or decline if the model starts overfitting.Training should ideally finish when the model reaches a balance between minimizing training loss and maintaining strong validation performance. 

Additionally, in the **Artifacts** tab, you will find stored files related to your model, such as the **dataset configuration**, the **GNN system configuration**, and the trained model’s **weights**.

After training multiple models, once you have identified a satisfactory one, you can proceed with registering it for future use. After registering it, you can perform inference on new, unseen data with this model refering to it by its **name** and **version**. So, to register a model, first navigate to its page by selecting the appropriate experiment and then the model within the **Experiments** tab. Once on the model’s page, click the **"Register Model"** button, located in the top-right corner. 

You will then be presented with two options. The first option allows you to create a new model by clicking on **"+ Create New Model"**, where you can specify a custom name for it. The second option lets you **register the model as a new version of an existing registered model**, in which case the newly trained model will be added as a version update to the selected model. After selecting the appropriate option, click **"Register"** to finalize the process. 

<a name="viewing-and-managing-registered-models"></a>
#### ▪️ Viewing and Managing Registered Models
Once a model has been registered, you can access it by navigating to the **Models** tab in MLflow. This tab provides an overview of all registered models. Clicking on a model will display a list of its **registered versions**, and you can assign **tags** to differentiate between various versions based on their characteristics or performance.

Selecting a specific version will take you to its details page, where you can review key metadata, including the **Source Run**, which refers to the original training run that produced the model. Additional information about the version is also available.
