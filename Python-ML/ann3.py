# -*- coding: utf-8 -*-
# ---
# jupyter:
#   jupytext:
#     text_representation:
#       extension: .py
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.6.0
#   kernelspec:
#     display_name: Python 3
#     language: python
#     name: python3
# ---

from tensorflow.keras.layers.experimental import preprocessing
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from tensorflow.keras.layers import Dense
from tensorflow.keras import Sequential
from sklearn.metrics import r2_score
import matplotlib.pyplot as plt
from load_data import get_zeo
from tensorflow import keras
from pandas import read_csv
from scipy import stats
import tensorflow as tf
import seaborn as sns
import pandas as pd
import numpy as np

zeolite_final = get_zeo("/home/drewx/Documents/Project-Roger-Dodger/data/zeolites_review_TP.csv")
sns.pairplot(zeolite_final[['SA', 'Vmicro', 'Vmeso', 'pore size', 'adsorbent', 'Capacity']], diag_kind='kde')

y = zeolite_final.loc[:,"Capacity"].values                                                                                                                                             
X = zeolite_final.drop(["Capacity"], axis = 1).values 

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2) 
print(X_train.shape, X_test.shape, y_train.shape, y_test.shape)

sc = StandardScaler()                                                                                                                                                                   
X_train = sc.fit_transform(X_train)   
X_train_df = pd.DataFrame(X_train)
X_test = sc.transform(X_test)  
X_train.shape

n_features =  X_train.shape[1]

#Model definition
#https://www.tensorflow.org/guide/keras/sequential_model
model = Sequential()

#Adding layers
#Number of nuerons will have to be fine tuned
#Currently set on number of features
model.add(Dense(28, activation='relu', kernel_initializer = 'he_normal', input_shape =  (n_features,)))
model.add(Dense(10, activation ='relu', kernel_initializer = 'he_normal' ))
model.add(Dense(1))
#Visualisation
#http://alexlenail.me/NN-SVG/index.html

#compilation
#https://www.tensorflow.org/api_docs/python/tf/keras/optimizers/Adam
#Paper used RMSE, I will have to compare or provide both
#What is the difference between a Capacity of 1 vs 2
#Could use MAE for testing and fine tuning and provide RMSE
#https://medium.com/human-in-a-machine-world/mae-and-rmse-which-metric-is-better-e60ac3bde13d
model.compile(optimizer = 'adam', loss = 'mae')
model.summary()

#This where the magic happens
#Epoch will have to be fine tuned
#Have to look into other model params e.g. batch size
#No accuracy metric for regression only for classification
history = model.fit(X_train,  y_train, epochs =2000,  verbose = 0)
#TO DO
#Have dig into the details regarding the how weights and biases are updated
#would be nice to visualise the nuerons firing 

# +
def plot_loss(history):    
    plt.plot(history.history['loss'], label='loss')
    plt.ylim([0, 10])
    plt.xlabel('Epoch')
    plt.ylabel('Error [Capacity]')
    plt.legend()
    plt.grid(True)

plot_loss(history)
# -

#https://www.tensorflow.org/api_docs/python/tf/keras/Sequential#evaluate
error =  model.evaluate(X_test, y_test, verbose = 1, return_dict = True)

error

y_pred = model.predict(X_test)

#Labelling the data for visualisations
X_test_df = pd.DataFrame(X_test, columns = zeolite_final.columns[:-1])


#scatter plot of test_test data
def scatter_plot( X_test_df, xvar = 'SA',):  
    plt.scatter(X_test_df[xvar], y_test, c = 'green')
    plt.xlabel(xvar)
    plt.ylabel('Capacity')  
scatter_plot(X_test_df, xvar = 'SA')


# +
#scatter with predicted values 
def scatter_plot(X_test_df, y_pred, y_test, xvar = 'SA'):  
    plt.scatter(X_test_df[xvar], y_test, c = 'green')
    plt.scatter(X_test_df[xvar], y_pred, c = 'red')
    plt.xlabel(xvar)
    plt.ylabel('Capacity')
    
scatter_plot(X_test_df, y_pred, y_test, xvar = 'SA')
#Significant differences when using 'mae' v 'mse' as loss functions
#Will give this a detailed analysis when we have enough data

# +
def regrplot(y_pred, y_test):
    #Correlation coefficient
    #Pearson’s correlation
    slope, intercept, r_value, p_value, std_err = stats.linregress(y_test, y_pred)
    #coefficient of determination 
    #proportion of the variance
    r2 = r2_score(y_test, y_pred)
    ax = sns.regplot(x = y_pred, 
                y = y_test,
               line_kws={'label':"$r$ = {:.2f}\n$r^2$={}".format(r_value,r2)})
    ax.set(xlabel='Y_Pred',
        ylabel='X_pred')
    ax.legend()
    plt.show()

    
regrplot(y_pred.flatten(), y_test.flatten())
# -






