<a name="-mlflow"></a>

## 📈 MLflow

If desired, you can visit [MLflow](https://mlflow.org/) to monitor the training process in real time, including loss trends and evaluation metrics. For a detailed guide on how to use MLflow with the RelationalAI GNN App, refer to the [instructions](/MLflow.md) here.

To access the MLflow page from a Snowflake notebook you can run:

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

Upon opening MLflow, you will see two main tabs: the **Experiments** tab and the **Models** tab. The **Experiments** tab displays a list of all your experiments on the left side. By selecting your current experiment `HM_Dataset/binary_classification/Churn`, you will see all models trained under that experiment listed on the main page, as shown in Figure 1 below. 


<p align="center">
  <img src="assets/mlfow_1.png" alt="Image" />
</p>
<p align="center"><em>Figure 1: Example of an MLFLow experiments tracking section.</em></p>

Clicking on a specific model (here `crawling-mole-592`) will direct you to its detailed page, where you can track its progress.
If the model is still training, the `Overview` tab will indicate that its Status is `Running`, like shown in the figure below. 


<p align="center">
  <img src="assets/mlflow_2.png" alt="Image" />
</p>
<p align="center"><em>Figure 2: Example of an MLFLow experiments overview.</em></p>


To analyze a model's  performance metrics in real time, navigate to the **Model Metrics** tab, where you can see key training statistics such as **training loss**, **validation loss**, **evaluation metrics**, and **learning rate** updates. These metrics are continuously updated as training progresses, allowing you to track improvements and detect any potential issues.


<p align="center">
  <img src="assets/mlflow_3.png" alt="Image" />
</p>
<p align="center"><em>Figure 3: Example of an MLFLow experiment metric tracking.</em></p>

As shown in the image, there are several key metrics displayed during the model training process that can help you evaluate the model's performance:
* `train_loss`: This plot shows how the model's error decreases over time on the training data, indicating its progress in learning. A decreasing train loss signifies that the model is improving its ability to predict the training data.
* `val_loss`: Tracks the model's error on unseen validation data. This helps in detecting overfitting—if the validation loss starts to increase while the train loss continues to decrease, it may indicate the model is memorizing the training data rather than generalizing well.
* `train_metric_average_precision`: This measures how well the model correctly classifies the training data, reflecting its learning efficiency.
* `val_metric_average_precision`: This evaluates how well the model performs on unseen validation data, giving insight into its generalization ability.
