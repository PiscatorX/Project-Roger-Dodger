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

from sklearn.preprocessing import StandardScaler
from load_data import get_zeo

zeolite_final = get_zeo("/home/drewx/Documents/Project-Roger-Dodger/data/zeolites_review_TP.csv")





zeolite_final = sc.transform(zeolite_final)  

print(zeolite_final)

y = zeolite_final.loc[:,"Capacity"].values                                                                                                                                             
X = zeolite_final.drop(["Capacity"], axis = 1).values 

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2) 
print(X_train.shape, X_test.shape, y_train.shape, y_test.shape)

n_features =  X_train.shape[1]


