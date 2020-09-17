# ---
# jupyter:
#   jupytext:
#     formats: ipynb,py
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

import pandas as pd
from sklearn.ensemble import RandomForestClassifier
import numpy as np
np.random.seed(0)

#importing into pandas dataframe
zeolite_df = pd.read_csv("/home/drewx/Documents/Project-Roger-Dodger/data/zeolites_review_TP.csv", delimiter = "\t")

for var in ["SA","Vmicro","Vmeso","pore size","Si_Al","Ag","Ce","Cu","C_start","C_end", "adsorbent"]:
        zeolite_df[var] =  zeolite_df[var].fillna(0)
        zeolite_df[var] =  zeolite_df[var].astype('float64')

for var in ["Adsorbent","adsorbate","solvent","Batch_Dynamic"]:
    zeolite_df[var] =  zeolite_df[var].astype('category')

zeolite_df['References'] = zeolite_df['References'].astype('string')

#https://towardsdatascience.com/the-dummys-guide-to-creating-dummy-variables-f21faddb1d40
zeolite_df.dtypes
#zeolite_df

#convett the categorical variables to intergers also known as one-hot-encoding
#https://towardsdatascience.com/the-dummys-guide-to-creating-dummy-variables-f21faddb1d40
#This can be automated to identify only those categorical variables, encode them and save them to a list for concat
encoded_Adsorbent = pd.get_dummies(zeolite_df['Adsorbent'])
encoded_solvent = pd.get_dummies(zeolite_df['solvent'])
#No need to encode this, all values appear to be same?
#encoded_adsorbate = pd.get_dummies(zeolite_df['adsorbate'])
encoded_Batch_Dynamic = pd.get_dummies(zeolite_df['Batch_Dynamic'])

#remove the categoricol variable columns and any unwanted columns in this case "References"
#this can also be automated as part of the step abov
zeolite_dropped = zeolite_df.drop(["Adsorbent","solvent","adsorbate","Batch_Dynamic", "References"],axis= 1)
#zeolite_dropped

# +
#encoded_Adsorbent
#encoded_solvent 
#encoded_Batch_Dynamic  
# -

zeolite_final = pd.concat([zeolite_dropped, encoded_Adsorbent,encoded_Batch_Dynamic], axis=1)

#We have our data ready for machine learning
zeolite_final.shape


