# Load required libraries
library(dplyr)
library(caret)
library(pROC)
library(survival)
library(AER)

# Set working directory and load data
setwd("D:/Masters/VCU/Classes/SCMA/R/A4")
df <- read.csv("../A1/Ref/NSSO68.csv")

# -------------------------------------
# Recode Religion and Social Group
# -------------------------------------
df <- df %>%
  mutate(
    Religion_Label = case_when(
      Religion == 1 ~ "Hinduism",
      Religion == 2 ~ "Islam",
      Religion == 3 ~ "Christianity",
      Religion == 4 ~ "Sikhism",
      Religion == 5 ~ "Jainism",
      Religion == 6 ~ "Buddhism",
      Religion == 7 ~ "Zoroastrianism",
      Religion == 9 ~ "Others"
    ),
    Social_Group_Label = case_when(
      Social_Group == 1 ~ "Scheduled Tribe",
      Social_Group == 2 ~ "Scheduled Caste",
      Social_Group == 3 ~ "Other Backward Class",
      Social_Group == 9 ~ "Others"
    )
  )

# -------------------------------------
# Create Target Variables
# -------------------------------------
df <- df %>%
  mutate(
    nonveg_flag = ifelse(
      fishprawn_v > 0 | goatmeat_v > 0 | beef_v > 0 | pork_v > 0 | chicken_v > 0 | othrbirds_v > 0,
      1, 0
    ),
    nonveg_value = fishprawn_v + goatmeat_v + beef_v + pork_v + chicken_v + othrbirds_v
  )

# -------------------------------------
# Prepare Data: Select & Clean
# -------------------------------------
df_model <- df %>%
  select(nonveg_flag, Age, Sex, Religion, Social_Group, MPCE_MRP) %>%
  filter(complete.cases(.)) %>%
  mutate(
    nonveg_flag = as.factor(nonveg_flag),
    Sex = as.factor(Sex),
    Religion = as.factor(Religion),
    Social_Group = as.factor(Social_Group)
  )

# -------------------------------------
# Downsample for Class Balance
# -------------------------------------
set.seed(123)
df_balanced <- df_model %>%
  group_by(nonveg_flag) %>%
  sample_n(size = min(table(df_model$nonveg_flag))) %>%
  ungroup()

# Train-test Split
set.seed(123)
split <- createDataPartition(df_balanced$nonveg_flag, p = 0.7, list = FALSE)
train <- df_balanced[split, ]
test <- df_balanced[-split, ]

# ----------------------------
# PART A – Logistic Regression
# ----------------------------
logit_model <- glm(nonveg_flag ~ ., data = train, family = "binomial")
summary(logit_model)

# Predict and Evaluate
prob_logit <- predict(logit_model, newdata = test, type = "response")
pred_logit <- ifelse(prob_logit > 0.5, 1, 0)
confusionMatrix(factor(pred_logit, levels = c(0, 1)), factor(test$nonveg_flag, levels = c(0, 1)))

roc_logit <- roc(as.numeric(as.character(test$nonveg_flag)), prob_logit)
plot(roc_logit, main = "ROC Curve - Logistic Regression")
auc(test$nonveg_flag, prob_logit)

# ----------------------------
# PART B – Probit Regression
# ----------------------------
probit_model <- glm(nonveg_flag ~ Age + Sex + Religion + Social_Group + MPCE_MRP,
                    data = train,
                    family = binomial(link = "probit"))
summary(probit_model)

prob_probit <- predict(probit_model, newdata = test, type = "response")
pred_probit <- ifelse(prob_probit > 0.5, 1, 0)
confusionMatrix(factor(pred_probit, levels = c(0, 1)), factor(test$nonveg_flag, levels = c(0, 1)))

roc_probit <- roc(as.numeric(as.character(test$nonveg_flag)), prob_probit)
plot(roc_probit, main = "ROC Curve - Probit Regression")
auc(test$nonveg_flag, prob_probit)

# ----------------------------
# PART C – Tobit Regression
# ----------------------------
df_tobit <- df %>%
  select(nonveg_value, Age, Sex, Religion, Social_Group, MPCE_MRP) %>%
  filter(complete.cases(.)) %>%
  mutate(
    Sex = as.factor(Sex),
    Religion = as.factor(Religion),
    Social_Group = as.factor(Social_Group)
  )

tobit_model <- tobit(nonveg_value ~ Age + Sex + Religion + Social_Group + MPCE_MRP,
                     data = df_tobit,
                     left = 0)
summary(tobit_model)

# Plot fitted values
hist(fitted(tobit_model), main = "Fitted Values (Tobit)", xlab = "fitted(tobit_model)", col = "skyblue", breaks = 50)

