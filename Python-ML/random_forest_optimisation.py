#!/usr/bin/env python
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from sklearn.preprocessing import StandardScaler
from sklearn.tree import DecisionTreeRegressor
from matplotlib import pyplot
from sklearn import metrics
import pandas as pd
import numpy as np


#load saved and cleaned tsv file
zeolite_final = pd.read_csv("zeolite_finalx.tsv", delimiter = "\t")  

#attributes 
y = zeolite_final.loc[:,"Capacity"].values
#labels
X = zeolite_final.drop(["Capacity"], axis = 1).values

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=0)

#Standardize features by removing the mean and scaling to unit variasnce
sc = StandardScaler()
#https://datascience.stackexchange.com/questions/12321/whats-the-difference-between-fit-and-fit-transform-in-scikit-learn-models#:~:text=%22fit%22%20computes%20the%20mean%20and,both%20at%20the%20same%20time.
#This should not make much of a difference but its good practice
#TO DO
#Compare accuracy with and without scaling
X_train = sc.fit_transform(X_train)
X_test = sc.transform(X_test)

n_features, n_entries  = X_train.shape
min_trees =  100
max_trees =  2000
trees_step = 25
n_jobs  = 4
print("n_feat\tn_trees\tmae\tmse\trmse\taccuracy")

for n_feat  in range(1, n_features + 1):
     print()
     for n_trees in range(min_trees,  max_trees+trees_step,  trees_step):
         regressor = RandomForestRegressor(n_estimators=n_trees, random_state=0, max_features = n_feat, n_jobs = n_jobs )
         regressor.fit(X_train, y_train)
         y_pred = regressor.predict(X_test)
         mae = metrics.mean_absolute_error(y_test, y_pred)
         mse = metrics.mean_squared_error(y_test, y_pred)
         rmse = np.sqrt(metrics.mean_squared_error(y_test, y_pred))
         errors = abs(y_pred - y_test)
         mape = 100 * (errors / y_test)
         accuracy = 100 - np.mean(mape)
         print("{}\t{}\t{:.3f}\t{:.3f}\t{:.3f}\t{:.3f}".format(n_feat,n_trees, mae, mse, rmse, accuracy))
