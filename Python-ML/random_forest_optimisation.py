#!/usr/bin/env python
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from sklearn.preprocessing import StandardScaler
from sklearn.tree import DecisionTreeRegressor
from load_data import GetZeoliteTsv
from matplotlib import pyplot
from sklearn import metrics
import pandas as pd
import numpy as np
import secrets
import sys
import os




def Scale_subsample(zeolite_final):


    #We extract our data features 
    y = zeolite_final.loc[:,"Capacity"].values
    #labels
    X = zeolite_final.drop(["Capacity"], axis = 1).values

    #Split our data into training and test dataset 
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=0)

    #Standardize features by removing the mean and scaling to unit variasnce
    sc = StandardScaler()
    #https://datascience.stackexchange.com/questions/12321/whats-the-difference-between-fit-and-fit-transform-in-scikit-learn-models
    #TO DO
    #Compare accuracy with and without scaling
    X_train = sc.fit_transform(X_train)
    X_test = sc.transform(X_test)

    return X_train, X_test, y_train, y_test



def RunBruteForce(X_train,
                  X_test,
                  y_train,
                  y_test,
                  min_trees =  1,
                  max_trees =  1000,
                  trees_step = 1,
                  n_jobs  = 16):


    random_string = secrets.token_hex(nbytes=4)
    outfile = ''.join(['RF_optimisation_',random_string, '.dat'])
    outfile_obj = open(outfile, 'w')
     
    n_entries, n_features  = X_train.shape

    
    #https://www.dataquest.io/blog/understanding-regression-error-metrics/
    header = "n_feat\tn_trees\tmae\tmse\trmse\tmape\tr2"
    print(header, file = outfile_obj)
    print(header)
    for n_feat  in range(1, n_features + 1):
       print(file = outfile_obj)
       print()
       for n_trees in range(min_trees,  max_trees+trees_step,  trees_step):
           #print(n_feat, n_trees)
           regressor = RandomForestRegressor(n_estimators=n_trees, max_features = n_feat, n_jobs = n_jobs )
           regressor.fit(X_train, y_train)
           y_pred = regressor.predict(X_test)
           mae = metrics.mean_absolute_error(y_test, y_pred)
           mse = metrics.mean_squared_error(y_test, y_pred)
           rmse = metrics.mean_squared_error(y_test, y_pred, squared = False)
           mape = metrics.mean_absolute_percentage_error(y_test, y_pred)
           r2 =  metrics.r2_score(y_test, y_pred)
           data = "{}\t{}\t{:.3f}\t{:.3f}\t{:.3f}\t{:.3f}\t{:.3f}".format(n_feat,n_trees, mae, mse, rmse, mape, r2)
           print(data, file = outfile_obj)
           outfile_obj.flush()
           print(data)

    outfile_obj.close()


    
if __name__ == "__main__":
     
    zeolite_final = pd.read_csv("ZeoX_Final_encoded.tsv", delimiter = "\t")
    X_train, X_test, y_train, y_test = Scale_subsample(zeolite_final) 
    RunBruteForce(X_train, X_test, y_train, y_test)
