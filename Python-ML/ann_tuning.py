#!/usr/bin/env python

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from tensorflow.keras.layers import Dense
from tensorflow.keras import Sequential
from load_data import get_zeo
from pandas import read_csv
from numpy import sqrt
import pandas as pd
import numpy as np




zeolite_final = pd.read_csv("zeolite_finalx.tsv", delimiter = "\t")  
y = zeolite_final.loc[:,"Capacity"].values
X = zeolite_final.drop(["Capacity"], axis = 1).values
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=0)
sc = StandardScaler()
X_train = sc.fit_transform(X_train)
X_test = sc.transform(X_test)



n_entries, n_features = X_train.shape
min_neurons = 10
max_neurons = n_features
min_epochs = 100
max_epochs = 200
epoch_step = 25
n_jobs = 4



# print("neurons")
#batch_size, input_size
print("neurons\tn_epochs")
for neurons  in range(min_neurons, n_features + 1):
       for n_epochs in range(min_epochs,  max_epochs+epoch_step,  epoch_step):
            model = Sequential()
            model.add(Dense(10,
                             activation='relu',
                             kernel_initializer = 'he_normal',
                             input_shape =  (n_features,)))
            model.add(Dense(1))
            model.compile(optimizer = 'adam', loss = 'mse', metrics=["mae", "acc"])
            model.fit(X_train,  y_train, epochs = n_epochs, workers = n_jobs, verbose = 0)
            # #model.fit(X_train,  y_train, epochs = 150, batch_size =  32,  verbose = 1)
            # error =  model.evaluate(X_test, y_test, verbose = 0)
            print("{}\t{}".format(neurons,n_epochs))



         
