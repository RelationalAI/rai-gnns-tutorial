<a name="-mlflow"></a>

## 📈 MLflow

If desired, you can visit [MLflow](https://mlflow.org/) to monitor the training process in real time, including loss trends and evaluation metrics. For a detailed guide on how to use MLflow with our Streamlit App, refer to the instructions under the **"MLFlow"** Section of the [Detailed Documentation](#file-01_detaileddocumentation-md).

Upon opening MLflow, you will see two main tabs: the **Experiments** tab and the **Models** tab. The **Experiments** tab displays a list of all your experiments on the left side. By selecting your current experiment `HM_Dataset/binary_classification/Churn`, you will see all models trained under that experiment listed on the main page. Clicking on a specific model (here `crawling-mole-592`) will direct you to its detailed page, where you can track its progress. 


<p align="center">
  <img src="https://drive.google.com/uc?export=view&id=1vUFfr4bODHSFCyiyeVXKCyzjwShFkgCl" alt="Image" />
</p>
<p align="center"><em>Figure 1: Example of an MLFLow experiments tracking section.</em></p>


If the model is still training, the `Overview` tab will indicate that its Status is `Running`. 


<p align="center">
  <img src="https://drive.google.com/uc?export=view&id=1Rjb6Q1GCnpozhkhbW0U4SCAVWtJ6gBrV" alt="Image" />
</p>
<p align="center"><em>Figure 2: Example of an MLFLow experiments overview.</em></p>


To analyze a model's  performance metrics in real time, navigate to the **Model Metrics** tab, where you can see key training statistics such as **training loss**, **validation loss**, **evaluation metrics**, and **learning rate** updates. These metrics are continuously updated as training progresses, allowing you to track improvements and detect any potential issues.


<p align="center">
  <img src="https://drive.google.com/uc?export=view&id=1y8oYXRzbXCJwWlbZdQKnG5hpW5RYCXgM" alt="Image" />
</p>
<p align="center"><em>Figure 3: Example of an MLFLow experiment metric tracking.</em></p>

As shown in the image, there are several key metrics displayed during the model training process that can help you evaluate the model's performance:
* `train_loss`: This plot shows how the model's error decreases over time on the training data, indicating its progress in learning. A decreasing train loss signifies that the model is improving its ability to predict the training data.
* `val_loss`: Tracks the model's error on unseen validation data. This helps in detecting overfitting—if the validation loss starts to increase while the train loss continues to decrease, it may indicate the model is memorizing the training data rather than generalizing well.
* `train_metric_average_precision`: This measures how well the model correctly classifies the training data, reflecting its learning efficiency.
* `val_metric_average_precision`: This evaluates how well the model performs on unseen validation data, giving insight into its generalization ability.
