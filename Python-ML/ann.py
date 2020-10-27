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

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.preprocessing import LabelEncoder
from tensorflow.keras.layers import Dense
from tensorflow.keras import Sequential
from load_data import get_zeo 
from pandas import read_csv
from numpy import sqrt


zeolite_final = get_zeo("/home/drewx/Documents/Project-Roger-Dodger/data/zeolites_review_TP.csv")

#https://stackabuse.com/random-forest-algorithm-with-python-and-scikit-learn/                                                                                                                                                                                                                                                                                                 
#attributes                                                                                                                                                                            
y = zeolite_final.loc[:,"Capacity"].values                                                                                                                                             
#labels                                                                                                                                                                                
X = zeolite_final.drop(["Capacity"], axis = 1).values                                                                                                                                  

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2) 
print(X_train.shape, X_test.shape, y_train.shape, y_test.shape)

#Standardize features by removing the mean and scaling to unit variasnce                                                                                                               
sc = StandardScaler()                                                                                                                                                                  
#https://datascience.stackexchange.com/questions/12321/whats-the-difference-between-fit-and-fit-transform-in-scikit-learn-models#:~:text=%22fit%22%20computes%20the%20mean%20and,both%20at%20the%20same%20time.                                                                                                                                                          
#This should not make much of a difference but its good practice                                                                                                                       
#TO DO                                                                                                                                                                                 
#Compare accuracy with and without scaling                                                                                                                                             
X_train = sc.fit_transform(X_train)                                                                                                                                                    
X_test = sc.transform(X_test)       

n_features =  X_train.shape[1]

#Model definition
#https://www.tensorflow.org/guide/keras/sequential_model
model = Sequential()

model.add(Dense(10, activation='relu', kernel_initializer = 'he_normal', input_shape =  (n_features,)))
model.add(Dense(8, activation ='relu', kernel_initializer = 'he_normal' ))
model.add(Dense(1))

#model compilation
model.compile(optimizer = 'adam', loss = 'mse')

model.fit(X_train,  y_train, epochs = 150, batch_size =  32,  verbose = 1)

error =  model.evaluate(X_test, y_test, verbose = 0)

print('MSE: %.3f, RMSE: %.3f' % (error, sqrt(error)))
