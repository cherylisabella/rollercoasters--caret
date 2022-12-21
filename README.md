# Multiple Regression using caret

About 2 years ago, I was tasked with compiling a multiple regression analysis for a Statistics course at university. We were free to choose whatever software we wanted, so I chose to use my newly acquired R skills for the paper.

![Photo courtesy of Wolfram K from Pexels](https://github.com/cherylisabella/rollercoasters-caret/blob/main/image%20files/pexels-wolfram-k-804115.jpg?raw=true)

## Background

The rollercoasters project prefaces with a story of when John Wardley, the award-winning concept designer of theme parks and roller coasters, including Nitro and Oblivion, was about to test the roller coaster Nemesis for the first time, he asked Walter Bolliger, the president of the coaster’s manufacturer, B&M, “What if the coaster stalls? How will we get the trains back to the station?” Bolliger replied, “Our coasters never stall. They always work perfectly the first time.” And, it did work perfectly. Roller coaster connoisseurs know that Bolliger & Mabillard Consulting Engineers, Inc. (B&M) is responsible for some of the most innovative roller coasters in the business. The company was founded in the late 1980s when Walter Bolliger and Claude Mabillard left Intamin AG, where they had designed the company’s first stand-up coaster. B&M has built its reputation on innovation. They developed the first “inverted” roller coaster in which the train runs under the track with the seats attached to the wheel carriage and pioneered “diving machines,” which feature a vertical drop, introduced first with Oblivion. B&M coasters are famous among enthusiasts for particularly smooth rides and their reliability, easy maintainability, and excellent safety record. Unlike some other manufacturers, B&M does not use powered launches, preferring, as do many coaster connoisseurs, gravity-powered coasters. B&M is an international leader in the roller coaster design field, having designed 24 of the top 50 steel roller coasters on the 2009 Golden Ticket Awards list and 3 of the top 10 in the 2013 Awards.

Theme parks are big businesses. In the United States alone, there are nearly 500 theme and amusement parks that generate over $10 billion a year in revenue. The U.S. industry is fairly mature, but parks in the rest of the world are still growing. Europe now generates more than $1 billion a year from their theme parks, and Asia’s industry is growing fast. Although theme parks have started to diversify to include water parks and zoos, rides are still the main attraction at most parks, and at the centre of the rides is the roller coaster. Engineers and designers compete to make them bigger and faster. For a two-minute ride on the fastest and best roller coasters, fans will wait for hours. Can we learn what makes a roller coaster fast? What are the most important design considerations in getting the fastest coaster?

## Data

The original dataset contains 16 variables, and short descriptions for some of the variables are given:

Track indicates what kind of track the roller coaster has. The possible values are “Wood” and “Steel.”
Duration is the duration of the ride in seconds.
Speed is top speed in miles per hour.
Height is the maximum height above ground level in feet.
Drop is the greatest drop in feet.
Length is the total length of the track in feet.
Inversions reports whether riders are turned upside down during the ride. It has the values 1 (yes) and 0 (no). Some coasters have multiple inversions.

## Goal

The goal of this analysis is to analyse how the speed of a coaster relates to the other properties of coasters. Additionally, I endeavour to develop prediction models whilst providing interpretations to link the modelling process.

## Tools

R will be used as the primary software, along with packages such as caret, dplyr and corrplot.

## Exploratory Data Analysis (EDA)

Before diving into the exploratory data analysis, I prepared the data by handling missing values, removing duplicate rows and conducting outlier treatment.

This EDA is split into two parts: EDA for quantitative variables and EDA for qualitative variables.

1. EDA for quantitative variables: the corrplot package is used to create a correlation plot that visualises the strength of (positive/negative) correlations between quantitative variables.

![](https://github.com/cherylisabella/rollercoasters-caret/blob/main/image%20files/corrplot.png?raw=true)

A pairwise correlation matrix is also printed below for those interested in the numerical specifics of correlations.

![](https://github.com/cherylisabella/rollercoasters-caret/blob/main/image%20files/cor.png?raw=true)

Results: Since the target variable is Speed, intepretations of relationships between variables will be based on Speed.

- Height exhibits a strong positive linear relationship with Speed (correlation coefficient = 0.91423320). Since its correlation coefficient is the highest, it indicates that Height would be the most significant predictor for Speed.
- Length shows a strong positive linear relationship with Speed (correlation coefficient = 0.72175528).
- Duration has a moderate positive linear relationship with Speed (correlation coefficient = 0.43499920).
- Numinversions has a weak positive linear relationship with Speed (correlation coefficient = 0.35334778).
- Opened shows virtually no relationship with Speed (correlation coefficient = -0.01563838).
Most of the results make sense as one can expect factors like maximum height above ground level in feet and duration of the ride to inform the (top) Speed of a rollercoaster. Similarly, one would expect the year a rollercoaster is opened to have little effect on its top Speed. An interesting finding is that numinversions has a weak positive linear relationship with Speed. This is as a rollercoaster finishes an inversion, it would usually speed up (due to gravity and inertia).

2. EDA for qualitative variables:

Since Speed is the target variable, it will be recoded into a categorical variable using the cut function. Speed ranges from 9.72mph to 194.4mph. Thus, the break argument will be applied so the speed will be binned into 5 classes — Very slow, Slow, Moderate, Fast and Very fast. Each class is binned according to increments of 37mph. A summary is printed — 153 observations fall into “Very slow”, 162 are binned into “Slow”, 78 into “Moderate”, 8 into “Fast”, and 2 into “Very fast”.

![](https://github.com/cherylisabella/rollercoasters-caret/blob/main/image%20files/qual.png?raw=true)

Results (evaluated w.r.t Speed):

- Construction: Rollercoasters with steel tracks have both a larger proportion of Very fast and very slow rollercoasters. Rollercoasters with wood tracks, on the other hand, account for a larger proportion of moderate-speed rollercoasters. Also, at least half of the rollercoasters with wooden tracks are classed as “Moderate”(speed). Overall, the most significant finding is that rollercoaster with steel tracks are able to accommodate very fast and very slow rollercoasters. Steel tracks are also indicated to result in faster rollercoasters.
- Inversions: the most significant finding is that rollercoasters without inversions result in a larger proportion of Very fast rollercoasters. As reasoned earlier, rollercoasters without inversions also result in a greater proportion of Very slow rollercoasters. Overall, these findings complement the result of the correlation plot from section 3.1.
- Region: A significant finding is that North America has the highest proportion of Very fast and Fast rollercoaster, and the lowest proportion of Very slow rollercoasters. Europe has the largest proportion of Very Slow rollercoasters. Further, more than 50% of rollercoasters from Europe fell into the “Very slow” class. This could suggest a correlation between Region and Speed.

# Predictive Regression models on Speed using caret Package

I created a function to encode flag variables for categorical variables before constructing a new data set comprising of the original quantitative variables and flag variables will be constructed.

![Flag variable function](https://github.com/cherylisabella/rollercoasters-caret/blob/main/image%20files/Screenshot%202022-12-21%20at%2018-16-36%20Rollercoasters%20-%20Caret.png?raw=true)

1. Linear Regression Model (with 5 fold cross validation):

![](https://github.com/cherylisabella/rollercoasters-caret/blob/main/image%20files/Screenshot%202022-12-21%20at%2018-20-30%20Rollercoasters%20-%20Caret.png?raw=true)

Result: This linear regression model has a RMSE just above 10 and a high Rsquared. The 4 most significant predictors are (in decreasing rank) Height, Length, flag_inversions and flag_construction. The sequence and number of predictors of this model are identical to the findings from the linear regression model generated without using caret.

2. KNN Regression model (with 5 fold cross validationi and the kknn package):

![](https://github.com/cherylisabella/rollercoasters-caret/blob/main/image%20files/Screenshot%202022-12-21%20at%2018-23-22%20Rollercoasters%20-%20Caret.png?raw=true)

Result: The KNN regression model has a RMSE of around 12 and a moderately high Rsquared. Since this KNN regression model yields a higher RSME and lower Rsquared value compared to the linear regression model, the linear regression model is a better fit between the two.

3. CART Regression Tree Model (with 5 fold cross validation):

![](https://github.com/cherylisabella/rollercoasters-caret/blob/main/image%20files/Screenshot%202022-12-21%20at%2018-25-04%20Rollercoasters%20-%20Caret.png?raw=true)

Result: This CART regression model has a RMSE lower than that of the KNN regression model but higher than the linear regression model. The Rsquared value here is higher than that of the KNN regression model but lower than that of the linear regression model. This means that the linear regression model would be the best fit amongst the 3 models.

## Performance comparison for regression models built using Caret

![](https://github.com/cherylisabella/rollercoasters-caret/blob/main/image%20files/reg.png?raw=true)

Overall, the linear regression model is suggested to be the best(most accurate) model for predicting Speed. This is because it has the lowest RSME and highest Rsquared values amongst the 3 regression models. Interestingly, the first dotplot shows that variability based on RSME and confidence level of 0.95 that is about the same. The second Rsquared dotplot shows that the linear regression model has the least variability, which could suggest that is it less sensitive to data/changes. The Rsquared values based on a 95% confidence level are all below 1 which is a good sign.

## Predictive Classification models for Speed using Caret Package
The dataset is once again split using the caret package and flag variables are included in both the training and testing sets.

1. KNN Classification Model (with 5 fold cross validation):

![](https://github.com/cherylisabella/rollercoasters-caret/blob/main/image%20files/Screenshot%202022-12-21%20at%2018-43-33%20Untitled%20presentation%20-%20Google%20Slides.png?raw=true)

Result: Accuracy and Kapp values were used to select the final value of k=3 for the optimal model. This is corroborated by the trend seen in the plot of accuracy against no. of nearest neighbours, supporting the notion that accuracy is highest when k=3.

2. Weighted KNN Classification Model (with 5 fold cross validation)

For this model, a hyperparameter grid is created for kknn, with kmax = 5.

![](https://github.com/cherylisabella/rollercoasters-caret/blob/main/image%20files/Screenshot%202022-12-21%20at%2018-34-38%20Rollercoasters%20-%20Caret.png?raw=true)

Result: The weighted KNN classification model has lower accuracy and kappa values than the KNN classification model(when k=3). This indicates that the KNN classification model is the better fit so far.

3. Cart Classification Model (with 5 fold cross validation):

![](https://github.com/cherylisabella/rollercoasters-caret/blob/main/image%20files/Screenshot%202022-12-21%20at%2018-45-25%20Rollercoasters%20-%20Caret.png?raw=true)

Result: The CART classification model has highest accuracy and kappa values so far. This indicates that the CART classification model is currently the most accurate model for predicting speed.

4. C5.0 Classification Model (with 5 fold cross validation):

The package C50 is used to train a C5.0 classification tree.

![](https://github.com/cherylisabella/rollercoasters-caret/blob/main/image%20files/Screenshot%202022-12-21%20at%2018-46-49%20Rollercoasters%20-%20Caret.png?raw=true)

Result: The C5.0 model has the 2nd highest accuracy and kappa values compared to the rest of the classification models built using Caret. Height, Length and Region are the most significant predictors for Speed in this model.

## Performance comparison for classification models built using caret

![](https://github.com/cherylisabella/rollercoasters-caret/blob/main/image%20files/two.png?raw=true)

The dotplot above shows that variance CART is the smallest. It also shows that the accuracy of CART is the highest.

## Checking model assumptions
Since CART is suggested to be the most accurate in predicting for speed, model assumptions for this specific model will be checked. The only assumption made by decision trees is that the data is independently and identically distributed(iid). Since each rollercoaster is unique, the speed of one rollercoaster is not expected to be dependent on the speed of another rollercoaster and each variable can be assumed to have the same probability distribution as the others, the iid assumption can be assumed to be met.

## Comparison of best models from each modelling technique:
When using caret, the linear model would be the best regression model for predicting speed while the CART model would be the best classification model. The 4 most significant predictors for the linear regression model are (in decreasing rank) height, length, flag_inversions and flag_construction. The 4 most significant predictors for the CART classification model are (in decreasing rank) height, length, duration and numinversions.

## Conclusion:
The most important finding through constructing and evaluating different models is that height and length are always the most significant predictors for speed, regardless of model used. This finding would be especially useful for rollercoaster manufacturers who wish to know which variables to focus on in order to produce the fastest rollercoaster(s) for coaster fans. The duration, presence of inversions, number of inversions, and material used to construct the tracks are also significant design considerations that should be noted.

Hopefully, this rollercoasters project has provided insight and/or another perspective on using caret to multiple regression analysis. As I reflect on this project, I am reminded that though it is invariably possible to use base R and other packages for multiple regression analysis, it is always a good practice to expand our toolboxes for analytical practice.

