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


#random string for filename
random_string = secrets.token_hex(nbytes=4)

outfile = ''.join(['RF_optimisation_',random_string, '.dat'])

outfile_obj = open(outfile, 'w')

#zeolite datafile exported from excel
zeolite_fname = "/home/drewx/Documents/Project-Roger-Dodger/Python-ML/zeolites database one febl14.txt"
#filename for datafile
zeolite_outfile = "ZeoX_Final_encoded.tsv" 

#open the raw tsv data file 
#the file has to be correctly formatted with columns headers  
zeolite_fileObj = open(zeolite_fname)

#create an instance to start processing the datafile
getZeo = GetZeoliteTsv(zeolite_fileObj)

#Sanity check of datatypes
#important to recognise that datatypes are detected from the files
#this step also make the string variables as categorical variables
getZeo.set_dtypes()

#this counts the missing records per column and saves them to provided filename
getZeo.missingness("ZeoX_Final_encoded.miss")

#take not of number of columns
getZeo.zeolite_df.shape

#Drops empty columns inplace
getZeo.zeolite_df.dropna(how='all', axis=1, inplace = True)

#Very that columns have indeed been lost
getZeo.zeolite_df.shape

#Imputation: step by step for easy debugging
getZeo.GroupMeanImputation('Adsorbent','SA')
#This last step takes care of singletons 
getZeo.MeanImputation('SA')

getZeo.GroupMeanImputation('Adsorbent','Vmicro')
getZeo.MeanImputation('Vmicro')

getZeo.GroupMeanImputation('Adsorbent','Vmeso')
getZeo.MeanImputation('Vmeso')

getZeo.GroupMeanImputation('Adsorbent','pore_size')
getZeo.MeanImputation('pore_size')

getZeo.GroupMeanImputation('Adsorbent','pore_size')
getZeo.MeanImputation('pore_size')

getZeo.GroupMeanImputation('Adsorbent','Si_Al')
getZeo.MeanImputation('Si_Al')

#Mean imputations only for these variables
#Names from column headers
for var in ["C_0","oil_adsorbent_ratio","Temp"]:
         getZeo.MeanImputation(var)

getZeo.zeolite_df.columns

#Fill missing values for metals with zeros
for metal in ['Na', 'Ag', 'Ce', 'Cu', 'Ni', 'Zn','Cs']:
         getZeo.zerofill(metal)

#convert the categorical variables to intergers also known as one-hot-encoding
#https://towardsdatascience.com/the-dummys-guide-to-creating-dummy-variables-f21faddb1d40
getZeo.encode_categorical()

#save the new data to a tsv file
#getZeo.save_zeo("ZeoX_Final_encoded.tsv")

#get our dataframe 
zeolite_final  = getZeo.zeolite_df

#We extract our data features 
#attributes 
y = zeolite_final.loc[:,"Capacity"].values
#labels
X = zeolite_final.drop(["Capacity"], axis = 1).values

#Split our data into training and test dataset 
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=0)

#Standardize features by removing the mean and scaling to unit variasnce
sc = StandardScaler()
#https://datascience.stackexchange.com/questions/12321/whats-the-difference-between-fit-and-fit-transform-in-scikit-learn-models#:~:text=%22fit%22%20computes%20the%20mean%20and,both%20at%20the%20same%20time.
#This should not make much of a difference but its good practice
#TO DO
#Compare accuracy with and without scaling
X_train = sc.fit_transform(X_train)
X_test = sc.transform(X_test)

n_entries, n_features  = X_train.shape
print(n_entries, n_features)
sys.exit(1)
min_trees =  1
max_trees =  1000
trees_step = 1
n_jobs  = 10

#https://www.dataquest.io/blog/understanding-regression-error-metrics/
header = "n_feat\tn_trees\tmae\tmse\trmse\tr2\tmape"

print(header, file = outfile_obj)
print(header)
for n_feat  in range(1, n_features + 1):
     print(file = outfile_obj)
     print()
     for n_trees in range(min_trees,  max_trees+trees_step,  trees_step):
         print(n_feat, n_trees)
         # regressor = RandomForestRegressor(n_estimators=n_trees, max_features = n_feat, n_jobs = n_jobs )
         # regressor.fit(X_train, y_train)
         # y_pred = regressor.predict(X_test)
         # mae = metrics.mean_absolute_error(y_test, y_pred)
         # mse = metrics.mean_squared_error(y_test, y_pred)
         # rmse = metrics.mean_squared_error(y_test, y_pred, squared = False)
         # #errors = abs(y_pred - y_test)
         # mape = metrics.mean_absolute_percentage_error(y_test, y_pred)
         # r2 =  metrics.r2_score(y_test, y_pred)
         # #data_table  = pd.DataFrame.from_dict({'y_pred':  y_pred,'y_test': y_test, 'errors': errors, 'mape': mape} )
         # #pd.options.display.max_rows = 4000
         # #print(data_table)
         # data = "{}\t{}\t{:.3f}\t{:.3f}\t{:.3f}\t{:.3f}\t{:.3f}".format(n_feat,n_trees, mae, mse, rmse, r2, mape)
         # print(data, file = outfile_obj)
         # outfile_obj.flush()
         # print(data)

outfile_obj.close()
