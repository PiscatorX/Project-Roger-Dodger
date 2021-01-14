#!/usr/bin/env python
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from tensorflow.keras.layers import Dense
from tensorflow.keras import Sequential
from tensorflow.keras import backend 
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







# n_entries, n_features = X_train.shape
# #https://developers.google.com/machine-learning/glossary#neuron
# min_neurons = 10
# max_neurons = n_features
# #https://developers.google.com/machine-learning/glossary#epoch
# #epoch is a measure of the number of times all of the training vectors are used once to update the weights.
# #For batches all of the training samples pass through the learning algorithm simultaneously in one epoch before weights are updated
# # epochs: Integer. Number of epochs to train the model.
# #     An epoch is an iteration over the entire `x` and `y`
# #     data provided.
# #     Note that in conjunction with `initial_epoch`,
# #     `epochs` is to be understood as "final epoch".
# #     The model is not trained for a number of iterations
# #     given by `epochs`, but merely until the epoch
# #     of index `epochs` is reached.
# min_epochs = 125
# max_epochs = 125
# epoch_step = 25
# # batch_size: Integer or `None`.
# #     Number of samples per gradient update.
# #     If unspecified, `batch_size` will default to 32.
# #https://stats.stackexchange.com/questions/153531/what-is-batch-size-in-neural-network
# n_jobs = 4


# print("neurons\tn_epochs\tmae")
# for neurons in range(min_neurons, n_entries + 1):
#        for n_epochs in range(min_epochs,  max_epochs+epoch_step,  epoch_step):
#             model = Sequential()
#             model.add(Dense(neurons,
#                              activation='relu',
#                              kernel_initializer = 'he_normal',
#                              input_shape =  (n_features,)))
#             model.add(Dense(1))
#             model.compile(optimizer = 'adam', loss = 'mse')
#             ##https://stats.stackexchange.com/questions/153531/what-is-batch-size-in-neural-network
#             model.fit(X_train,  y_train, epochs = n_epochs, workers = n_jobs, verbose = 0)
#             # #model.fit(X_train,  y_train, epochs = 150, batch_size =  32,  verbose = 1)
#             mae =  model.evaluate(X_test, y_test, verbose = 0)
#             print("{}\t{}\t{}".format(neurons,n_epochs,mae))
#             backend.clear_session()




         
