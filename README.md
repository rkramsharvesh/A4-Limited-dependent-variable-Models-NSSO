***Part A – Logistic Regression & Decision Tree***

In this section, a logistic regression model is used to predict whether a household consumes non-vegetarian food, based on socio-demographic factors like age, gender, religion, social group, and expenditure levels. 
The model’s performance is evaluated using a confusion matrix, classification report, and ROC-AUC score to assess both accuracy and discriminative power. 
A decision tree model is also implemented to provide a non-parametric comparison, allowing us to contrast interpretability, performance, and robustness between the two approaches.

***Part B – Probit Regression***

This part applies a probit regression model to the same classification problem of identifying non-vegetarian households. 
While similar to logistic regression in form, the probit model uses a cumulative normal distribution for its link function. 
The results are interpreted with attention to probability thresholds and marginal effects, and the model is evaluated similarly using ROC analysis. 
The section also highlights the conditions under which a probit model may be theoretically preferred, such as in behavioral or latent decision processes.

***Part C – Tobit Regression***

Here, a Tobit model is employed to analyze the value of non-vegetarian consumption, which is a left-censored variable since many households report zero consumption. 
Unlike logistic and probit models that handle binary outcomes, the Tobit model accommodates the continuous nature of spending while accounting for censoring at zero. 
This section interprets both the probability of consumption and the expected consumption value, and discusses real-world applications where censored regression is useful such as in demand analysis and expenditure modeling.
