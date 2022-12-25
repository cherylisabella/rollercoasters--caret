---
  title: "Rollercoasters - Caret"
author: "Cheryl Isabella"
output: html_document
---
  
# 1. Introduction
  
  ```{r include = FALSE, echo=FALSE}
library(readxl)
rollercoasters <- read_excel("C:/Users/Isabella/Documents/writings/rollercoasters/rollercoasters.xlsx")
```
```{r setup, results=FALSE}
library(caret)
library(dplyr)
library(corrplot)
```

# 2. Data Preparation

The rollercoasters dataset consists of 408 observations, differentiated by 16 variables. 
- Out of the 16 variables, 9 are categorical, 5 are numerical and 2 are integers. 

```{r}
head(rollercoasters)
```
## 2.1 Handling Missing Data

Manual investigation of the data set in Excel showed that there are missing values in variables Height, Speed, Length, Duration, G force, Year Opened. Most variables with missing values are numerical variables. Year opened is the only integer variable with missing values.

```{r}
#To view total number of missing values:
missing <- sum(is.na(rollercoasters)) 
missing
#To view the number of missing values in each variables
colSums(is.na(rollercoasters)) 
```

**Result:** 902 missing values were identifed in the entire data set. Specifically, there are 82 missing values in Height, 138 missing values in Speed, 90 missing values in Length, 216 missing values in Duration, 348 missing values in GForce, 28 missing values in Year Opened.
Since there are a significant number of missing values, data in variables Height, Speed, Length, Duration, the missing values will be imputed. Missing values to be imputed are assumed to be Missing At Random(MAR), and the MICE package is utilised. For Year Opened variable, missing values will be omitted since they account for approximately 6.86% of the total number of observations. 

```{r, results= FALSE}
library(mice)
rollercoasters_0 <- mice(data = rollercoasters, m=5, method="pmm", maxit=50, seed=500)

rollercoasters_0 <- complete(rollercoasters_0)
rollercoasters_1 <- rollercoasters_0 %>% na.omit()
missing_1 <- sum(is.na(rollercoasters_1)) #missing values check
```
A run of the missing values function confirms that all missing values have been imputed.

## 2.2 Removing duplicate rows and Gforce variable:
- Gforce variable will be omitted since missing values account for approximately 85.3%(3sf) of the total number of observations. 

For omission of variables, the select function from dplyr package is used. 
- Categorical variables Name, Park, City, State and Country will be removed as they have too many levels and are highly unlikely to have any effect on Speed. 
- Type will also be removed as its values are simply abbrevations for values in Construction. 
- Removing observations that are duplicates: Duplicate rows are identified as follows: Row 222 is a duplicate of row 220. Row 225 is a duplicate of row 224. Row 239 is a duplicate of row 240. Row 309 is a duplicate of row 310. Row 391 is a duplicate of row 390.  
```{r}
rollercoasters_1 <- select(rollercoasters_0, -GForce)
rollercoasters_2 <- select(rollercoasters_1, -c(1:6))
rollercoasters_final <- rollercoasters_2[-c(222, 225, 239, 309,391),]
```

## 2.3 Outlier treatment:
Graphs are utilised to identify outliers. Outliers are defined as values lying outside 1.5 times the interquartile range above the upper quartile and below the lower quartile, and are visualised as red stars in every plot. 

For the 6 quantitative variables:
  ```{r, echo=FALSE}
library(patchwork)
#For the 6 quantitative variables: 
par(mfrow=c(3,2))    # set the plotting area into a 3*2 array
p1 <- ggplot(rollercoasters_final, aes(y=Height)) + 
  geom_boxplot(outlier.colour = "red", outlier.shape = 8, outlier.size = 2)+ggtitle("Box Plot of Height")
p2 <- ggplot(rollercoasters_final, aes(y=Speed)) + 
  geom_boxplot(outlier.colour = "red", outlier.shape = 8, outlier.size = 2)+ggtitle("Box Plot of Speed")
p3 <- ggplot(rollercoasters_final, aes(y=Length)) + 
  geom_boxplot(outlier.colour = "red", outlier.shape = 8, outlier.size = 2)+ggtitle("Box Plot of Length")
p4 <- ggplot(rollercoasters_final, aes(y=Duration)) + 
  geom_boxplot(outlier.colour = "red", outlier.shape = 8, outlier.size = 2) +ggtitle("Box Plot of Duration")
p5 <- ggplot(rollercoasters_final, aes(y=Numinversions)) + 
  geom_boxplot(outlier.colour = "red", outlier.shape = 8, outlier.size = 2)+ggtitle("Box Plot of Numinversions")
p6 <- ggplot(rollercoasters_final, aes(y=Opened)) + 
  geom_boxplot(outlier.colour = "red", outlier.shape = 8, outlier.size = 2)+ggtitle("Box Plot of Year Opened")
p1 + p2 + p3
p4 + p5 + p6
```
Here is a closer look at the values of the respective outliers: 
  ```{r}
#For quantitative variables with outliers, the values of the respective outliers are printer out below.
boxplot.stats(rollercoasters_final$Height)$out
boxplot.stats(rollercoasters_final$Speed)$out
boxplot.stats(rollercoasters_final$Length)$out
boxplot.stats(rollercoasters_final$Duration)$out
boxplot.stats(rollercoasters_final$Numinversions)$out
boxplot.stats(rollercoasters_final$Opened)$out

#Identifying outliers with respect to height 
head(rollercoasters_final %>%  arrange(desc(rollercoasters_final$Height)))

#Identifying outliers with respect to length
head(rollercoasters_final %>% 
       arrange(desc(rollercoasters_final$Length)))

#Identifying outliers with respect to duration
head(rollercoasters_final %>% 
       arrange(desc(rollercoasters_final$Duration)))

#Identifying outliers with respect to Number of Inversions
head(rollercoasters_final %>% 
       arrange(desc(rollercoasters_final$Numinversions)))

#Identifying outliers with respect to Year opened
head(rollercoasters_final %>% 
       arrange(rollercoasters_final$Opened))
```

**Results:**
  
  - Height: 7 outliers were found - Top Thrill Dragster, Superman The Escape, Millennium Force, Titan, Silver Star, Goliath, Diamondback (in descending order w.r.t height). Since all their maximum heights above ground correspond to the reported heights found online(eg. Coasterpedia, Six flags’ website, wikipedia), none of these outliers will be removed.

- Speed: The fastest rollercoasters in the world have a maximum speed of 149mph. Hence there is reason to believe that the 3 outliers are entry errors and will be removed. An inspection of the slowest rollercoasters yielded 3 outliers. Of these 3, Jr. Gemini(from the US) is known to be the slowest rollercoaster in existence and hence will not be removed. Dragon(from France and the US) will not be removed as their speeds corresponds to the published speeds(found online) and are considered to be rollercoasters for children.

- Length: 11 outliers were found - Beast, Son of Beast, Millennium Force, Voyage, California Screamin’, Vertigorama, Superman El Último Escape, Mean Streak, Silver Star, Titan, Diamondback (in descending order). Again, since all their total track lengths correspond to data found online, none of these outliers will be removed.

- Duration: 9 outliers were identified - Journey to Atlantis, Euro Mir, Beast, Silver Star, Poseidon, Temple of the Night Hawk, Avalancha, Big Thunder Mountain, Galaxi (in descending order). None of them will be removed since their durations match the data found online.

- Numinversions: Since all the number of inversions match the data found online, none of the outliers will be removed.

- Year opened: The year opened for all 21 outliers match data found online. Thus, none of them will be removed.

# 3. Exploratory Data Analysis 
## 3.1 Exploring quantitative variables
A correlation plot is plotted to visualise the strength of (positive/negative) correlations between quantitative variables. A pairwise correlation matrix is also printed for those interested in the numerical specifics of correlations.
The package "corrplot" is used. 
```{r echo=FALSE}
#subgroup numerics
Height <- rollercoasters_final$Height
Speed <- rollercoasters_final$Speed
Length <- rollercoasters_final$Length
Duration <- rollercoasters_final$Duration
Numinversions <- rollercoasters_final$Numinversions
Opened <- rollercoasters_final$Opened
quantnames <- cbind(Height, Speed, Length, Duration, Numinversions, Opened)
#propertynumeric
cor <- cor(quantnames)
corrplot(cor, method = 'shade', order = 'AOE', diag = FALSE,  tl.col = "#273e52")
print(cor)
```
**Results:** Since the target variable is Speed, relationships between variables will be based on Speed.

- Height exhibits a strong positive linear relationship with Speed (correlation coefficient = 0.91423320). Since its correlation coeeficient is the highest, it indicates that Height would be the most significant predictor for Speed.

- Length shows a strong positive linear relationship with Speed (correlation coefficient = 0.72175528).

- Duration has a moderate positive linear relationship with Speed (correlation coefficient = 0.43499920).

- Numinversions has a weak positive linear relationship with Speed (correlation coefficient = 0.35334778).

- Opened shows virtually no relationship with Speed (correlation coefficient = -0.01563838).

Most of the results make sense as one can expect factors like maximum height above ground level in feet and duration of the ride to inform the (top) Speed of a rollercoaster. Similarly, one would expected the year a rollercoaster is opened to have little effect on its top Speed. An interesting finding is that numinversions has a weak positive linear relationship with Speed. This is as a rollercoaster finishes an inversion, it would usually speed up (due to gravity and inertia).

## 3.2 Exploring categorical variables
Since Speed is the target variable, it will be recoded into a categorical variable using the cut function. Speed ranges from 9.72mph to 194.4mph. Thus, the break argument will be applied so the speed will be binned into 5 classes - Very slow, Slow, Moderate, Fast and Very fast. Each class is binned according to increments of 37mph. A summary is printed - 153 observations fall into “Very slow”, 162 are binned into “Slow”, 78 into “Moderate”, 8 into “Fast”, and 2 into “Very fast”. 

```{r}
speed_cut <- cut(Speed, breaks = c(9.5,46.5,83.5, 120.5, 157.5, 194.5), include.lowest = TRUE, right = TRUE)
levels(speed_cut) <- c("Very slow", "Slow", "Moderate", "Fast", "Very fast")
summary(speed_cut)
```

Overlayed barplots are visualised to uncover relationships between speed and categorical variables. 
```{r echo=FALSE}
p7 <- ggplot(rollercoasters_final, aes(x=Construction, fill = speed_cut )) + 
  geom_bar(position = "fill") + 
  labs(y = "Proportion")
p8 <- ggplot(rollercoasters_final, aes(x=Inversions, fill = speed_cut )) + 
  geom_bar(position = "fill") + 
  labs(y = "Proportion")
p9 <- ggplot(rollercoasters_final, aes(x=Region, fill = speed_cut )) + 
  geom_bar(position = "fill") + 
  labs(y = "Proportion")
p7+ p8 + p9
```
Since Speed is the target variable, the findings will be evaluted with respect to Speed.
- Construction: Rollercoasters with steel tracks have both a larger proportion of Very fast and very slow rollercoasters. Rollercoasters with wood tracks, on the other hand, account for a larger proportion of moderate-speed rollercoasters. Also, at least half of the rollercoasters with wooden tracks are classed as “Moderate”(speed). Overall, the most significant finding is that rollercoaster with steel tracks are able to accommodate very fast and very slow rollercoasters. Steel tracks are also indicated to result in faster rollercoasters.

- Inversions: the most significant finding is that rollercoasters without inversions result in a larger proportion of Very fast rollercoasters. As reasoned earlier, rollercoasters without inversions also result in a greater proportion of Very slow rollercoasters. Overall, these findings complement the result of the correlation plot from section 3.1.

- Region: A significant finding is that North America has the highest proportion of Very fast and Fast rollercoaster, and the lowest proportion of Very slow rollercoasters. Europe has the largest proportion of Very Slow rollercoasters. Further, more than 50% of rollercoasters from Europe fell into the “Very slow” class. This could suggest a correlation between Region and Speed. 

## 3.3 Creation of flag variables for categorical variables
```{r}
encode_ordinal <- function(x, order = unique(x)) {
  x <- as.numeric(factor(x, levels = order, exclude = NULL))
  x
}
flag_construction <- encode_ordinal(rollercoasters_final$Construction)
flag_inversions <- encode_ordinal(rollercoasters_final$Inversions)
flag_region <- encode_ordinal(rollercoasters_final$Region)
```

# 4. Predictive Regression models on Speed using Caret Package
A new data set comprising of the original quantitative variables and flag variables will be constructed. The preprocess function(from the Caret Package) will be used to preprocess the rollercoasters_q_flag data set. The data set will be partitioned into a training (75%) set and test (25%) set.
```{r}
set.seed(123)
Height <- rollercoasters_final$Height
Speed <- rollercoasters_final$Speed
Length <- rollercoasters_final$Length
Duration <- rollercoasters_final$Duration
Numinversions <- rollercoasters_final$Numinversions
Opened <- rollercoasters_final$Opened
rollercoasters_q_flag <- cbind(Height, Speed, Length, Duration, Numinversions, Opened, flag_construction,flag_inversions, flag_region,speed_cut)

dfrollercoasters_q_flag <- as.data.frame(rollercoasters_q_flag)
#Split data set using Caret
trainIndexcaret <- createDataPartition(dfrollercoasters_q_flag$Speed, p = .75, 
                                       list = FALSE, 
                                       times = 1)
Train_rollercoastersqflag <- rollercoasters_q_flag[trainIndexcaret,]
Test_rollercoastersqflag  <- rollercoasters_q_flag[-trainIndexcaret,]
dfTrain_qflag <- as.data.frame(Train_rollercoastersqflag)
dfTest_qflag <- as.data.frame(Test_rollercoastersqflag)
```

## 4.1 Linear regression model on speed:
```{r}
#Remove speed_cut
lmdftrain_qflag <- dfTrain_qflag[,-10]
lmdftest_qflag <- dfTest_qflag[,-10]

#5 fold cross validation 
control <- trainControl(method = "cv", number=2, savePredictions="all ")
#Linear regression model
lm.fit <- train(Speed~., data = lmdftrain_qflag, trControl = trainControl(method = "cv", number = 5),  method = "lm", preProcess = c("center", "scale"), na.action = na.omit )
pred_lm.fit <- predict(lm.fit, newdata = lmdftest_qflag)
lm.fit
```
**Result**: This linear regression model has a RMSE just above 10 and a high Rsquared. The 4 most significant predictors are (in decreasing rank) Height, Length, flag_inversions and flag_construction. The sequence and number of predictors of this model are identical to the findings from the linear regression model generated without using CARET. 

## 4.2 KNN Regression model on speed:
```{r}
library(kknn)
# Configure 5-fold cross validation:
control <- trainControl(method = "cv", number = 5, savePredictions = "all")
#Remove speed_cut:
kknnrollercoastersqflag <- dfrollercoasters_q_flag[,-10]
# Create a hyper-parameter grid for kknn:
kknn.grid <- expand.grid(kmax = 5, distance = 2, kernel = "inv")
# Train a KNN regression model using 5-fold cross validation:
kknncaret <- train(Speed~., data = kknnrollercoastersqflag, method = "kknn",
                   trControl = control, tuneGrid = kknn.grid, preProcess = c("center", "scale"))
kknncaret
```
**Result:** The KNN regression model has a RMSE of around 12 and a moderately high Rsquared. Since this KNN regression model yields a higher RSME and lower Rsquared value compared to the linear regression model, the linear regression model is a better fit between the two.

## 4.3 CART Regression Tree Model on speed:
```{r}
#Remove speed_cut:
cartrollercoastersqflag <- dfrollercoasters_q_flag[,-10]
# Train a CART regression tree using 5-fold cross validation:
cart.fit <- train(Speed~., data = cartrollercoastersqflag, method = "rpart1SE",
                  trControl = control, preProcess = c("center", "scale"))
cart.fit
```
**Result:** This CART regression model has a RMSE lower than that of the KNN regression model but higher than the linear regression model. The Rsquared value here is higher than that of the KNN regression model but lower than that of the linear regression model. This means that the linear regression model would be the best fit amongst the 3 models.

## 4.4 Performance comparison for regression models built using Caret
```{r}
# Resample performance of the models:
out <- resamples(list(LM = lm.fit, KKNN = kknncaret, CART = cart.fit))
# Plot performance
par(mfrow=c(1,2))    # set the plotting area into a 1*2 array
dotplot(out, metric = "RMSE")
dotplot(out, metric = "Rsquared")
```

Overall, the linear regression model is suggested to be the best(most accurate) model for predicting Speed. This is because it has the lowest RSME and highest Rsquared values amongst the 3 regression models. Interestingly, the first dotplot shows that variability based on RSME and confidence level of 0.95 that is about the same. The second Rsquared dotplot shows that the linear regression model has the least variability, which could suggest that is it less sensitive to data/changes. The Rsquared values based on a 95% confidence level are all below 1 which is a good sign. 


# 5. Predictive Classification models for Speed using Caret Package
Predictive classifications models will now be construction to predict for Speed. The data set created in section 4 (“dfrollercoasters_q_flag”) will be used in this section.
```{r}
set.seed(321)  
#Split data set using Caret
trainIndexcc <- createDataPartition(dfrollercoasters_q_flag$Speed, p = .75, 
                                    list = FALSE, 
                                    times = 1)
Train_qflagc <- rollercoasters_q_flag[trainIndexcc,]
Test_qflagc  <- rollercoasters_q_flag[-trainIndexcc,]
dfTrain_qflagc <- as.data.frame(Train_qflagc)
dfTest_qflagc <- as.data.frame(Test_qflagc)
```


## 5.1 KNN Classification Model on speed_cut:
```{r}
#Remove speed from data set:
knncaret <- dfrollercoasters_q_flag[,-2]
#Convert reponse variable to factor:
knncaret$speed_cut = as.factor(knncaret$speed_cut)
# Create a hyperparameter grid for knn:
knn.grid <- expand.grid(k = c(1, 3, 5))
# Configure 5-fold cross validation:
control <- trainControl(method = "cv", number = 5, savePredictions = "all")
# Train a KNN classification model using 5-fold cross validation:
knn.fit <- train(speed_cut ~., data = knncaret, method = "knn",
                 trControl = control, tuneGrid = knn.grid, preProcess = c("center", "scale"))
knn.fit
plot(knn.fit)
```
k=3 is used for the final KNN classification model as it has the highest accuracy and kappa values. The trend seen in the plot of accuracy against no. of nearest neighbours supports the notion that accuracy is highest when k=3. 

## 5.2 Weighted KNN Classification Model on speed_cut: 
```{r}
#Remove Speed from data set:
kknncaret <- dfrollercoasters_q_flag[,-2]
#Convert reponse variable to factor:
kknncaret$speed_cut = as.factor(kknncaret$speed_cut)

# Create a hyperparameter grid for kknn, with kmax (maximum number of k values), (Euclidean) distance=2, and the kernel or similarity function (equal to "inv" for weighted voting):
kknn.grid <- expand.grid(kmax = 5, distance = 2, kernel = "inv")
# Train a weighted KNN classification model using 5-fold cross validation:
kknn.fit <- train(speed_cut ~., data = kknncaret, method = "kknn",
                  trControl = control, tuneGrid = kknn.grid, preProcess = c("center", "scale"))
kknn.fit
```
**Result:** The weighted KNN classification model has lower accuracy and kappa values than the KNN classification model(when k=3). This indicates that the KNN classification model is the better fit so far.

## 5.3 Cart Classification Model on speed_cut:
```{r}
#Remove Speed from data set:
cartcaret <- dfrollercoasters_q_flag[,-2]
#Convert reponse variable to factor:
cartcaret$speed_cut = as.factor(cartcaret$speed_cut)
# Configure 5-fold cross validation:
control <- trainControl(method = "cv", number = 5, savePredictions = "all")
# Train a CART classification tree using 5-fold cross validation:
cart.fit <- train(speed_cut~., data = cartcaret, method = "rpart1SE",
                  trControl = control, preProcess = c("center", "scale"))
cart.fit
```
**Result**: The CART classification model has highest accuracy and kappa values so far. This indicates that the CART classification model is currently the most accurate model for predicting speed. 

## 5.4 C5.0 Classification Model on speed_cut:
```{r}
library(C50)
#Remove Speed from data set:
c5caret <- dfrollercoasters_q_flag[,-2]
#Convert reponse variable to factor:
c5caret$speed_cut = as.factor(c5caret$speed_cut)
# Configure 5-fold cross validation:
control <- trainControl(method = "cv", number = 5, savePredictions = "all")
# Train a C5.0 classification tree using 5-fold cross validation:
c5.0.fit <- train(speed_cut~., data = c5caret, method = "C5.0Tree",
                  trControl = control, preProcess = c("center", "scale"))
c5.0.fit
```
**Result:** The C5.0 model has the 2nd highest accuracy and kappa values compared to the rest of the classification models built using Caret. Height, Length and Region are the most significant predictors for Speed in this model. 

## 5.5 Performance comparison for classification models built using Caret
```{r}
# Resample performance of the models:
out <- resamples(list(KNN = knn.fit, KKNN = kknn.fit, CART = cart.fit, C5.0 = c5.0.fit))
# Plot performance:
dotplot(out, metric = "Accuracy")
```
The dotplot shows that variance CART is the smallest. It also shows that the accuracy of CART is the highest. 

## 5.6 Checking model assumptions
Since CART is suggested to be the most accurate in predicting for speed, model assumptions for this specific model will be checked. The only assumption made by decision trees is that the data is independently and identically distributed(iid). Since each rollercoaster is unique, the speed of one rollercoaster is not expected to be dependent on the speed of another rollercoaster and each variable can be assumed to have the same probability distribution as the others, the iid assumption can be assumed to be met. 

# 6. Comparison of best models from each modelling technique:
When constructing models without using CARET, the model that predicts most accurately is the linear regression model. The 4 most significant predictors for Speed using this model are height_n, followed by length_n, flag_inversions and flag_construction. Hence, if one wishes to predict for speed without using CARET, the use of linear regression model and predictors height, length and inversions would be highly recommended. When using CARET, the linear model would be the best regression model for predicting speed while the CART model would be the best classification model. The 4 most significant predictors for the linear regression model are (in decreasing rank) height, length, flag_inversions and flag_construction. The 4 most significant predictors for the CART classification model are (in decreasing rank) height, length, duration and numinversions. 

# 7. Conclusion:
The most important finding through constructing and evaluating different models is that height and length are always the most significant predictors for speed, regardless of model used. This finding would be especially useful for rollercoaster manufacturers who wish to know which variables to focus on in order to produce the fastest rollercoaster(s) for coaster fans. The duration, presence of inversions, number of inversions, and material used to construct the tracks are also significant design considerations that should be noted. 



