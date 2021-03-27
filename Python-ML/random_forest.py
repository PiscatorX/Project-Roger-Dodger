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

from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from sklearn.preprocessing import StandardScaler
from sklearn.tree import DecisionTreeRegressor
from load_data import GetZeoliteTsv
import matplotlib.pyplot as plt
from sklearn import metrics
from scipy import stats
import seaborn as sns
import pandas as pd
import numpy as np
import os
np.random.seed(1)


#zeolite datafile exported from excel
zeolite_fname = "/home/drewx/Documents/Project-Roger-Dodger/Python-ML/zeolites database one febl14.txt"
#filename for datafile
zeolite_outfile = "ZeoX_Final_encoded.tsv" 


#open the raw tsv data file 
#the file has to be correctly formatted with columns headers  
zeolite_fileObj = open(zeolite_fname)


#create an instance to start processing the datafile
getZeo = GetZeoliteTsv(zeolite_fileObj, zeolite_outfile)


#Sanity check of datatypes
#important to recognise that datatypes are detected from the files
#this step alsos makes the string variables as categorical variables
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
getZeo.save_zeo("ZeoX_Final_encoded.tsv")


#get our dataframe 
zeolite_final  = getZeo.zeolite_df


#check our dataframe
zeolite_final.shape


#We extract our data features 
#attributes 
y = zeolite_final.loc[:,"Capacity"].values
#labels
X = zeolite_final.drop(["Capacity"], axis = 1).values


#Split our data into training and test dataset 
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=0)


y_train.shape


y_test.shape


#Standardize features by removing the mean and scaling to unit variasnce
sc = StandardScaler()
#https://datascience.stackexchange.com/questions/12321/whats-the-difference-between-fit-and-fit-transform-in-scikit-learn-models#:~:text=%22fit%22%20computes%20the%20mean%20and,both%20at%20the%20same%20time.
#This should not make much of a difference but its good practice
#TO DO
#Compare accuracy with and without scaling
X_train = sc.fit_transform(X_train)
X_test = sc.transform(X_test)


n_trees = 1000
n_feat = 0
#max_features=n_features,
regressor = RandomForestRegressor(n_estimators=n_trees, random_state=0)
#TO DO
#increase n_estimators
#run in parallel


regressor.fit(X_train, y_train)


y_pred = regressor.predict(X_test)


data = pd.DataFrame.from_dict({'y_pred': y_pred, 'y_test': y_test, 'errors': y_pred - y_test, 'abs_errors': abs(y_pred - y_test)})


pd.options.display.max_rows = 4000
data


data.to_csv("random_forest.dataset")

mae = metrics.mean_absolute_error(y_test, y_pred)
mse = metrics.mean_squared_error(y_test, y_pred)
rmse = metrics.mean_squared_error(y_test, y_pred, squared = False)
mape = metrics.mean_absolute_percentage_error(y_test, y_pred)
r2 =  metrics.r2_score(y_test, y_pred)


data_table = pd.DataFrame.from_dict({"n_feat": [n_feat],
                                    "n_trees":[n_trees],
                                     "mae": [mae], 
                                     "mse": [mse], 
                                     "rmse":[rmse],
                                     "r2":[r2],
                                     "mape":[mape]})

data_table

slope, intercept, r_value, p_value, std_err = stats.linregress(y_pred, y_test)


print("Correlation coefficient (R): {:.4f} ".format(r_value))
print("p-value : {}".format(p_value))
print("Intercept: {:.4f}".format(intercept))
print("Slope: {:.4f}".format(slope))
print("std_error: {:.4f}".format(std_err))


# +
ax = sns.regplot(y="y_pred",
                 x="y_test", 
                 color="g", 
                 marker="+",
                 line_kws={'label':'$r^2$ = {:.2f}'.format(r_value**2)},
                 data = data)

plt.ylabel('Predicted adsorptive capacity (mgS/g)')
plt.xlabel('Experimental adsorptive capacity (mgS/g)')
ax.legend(loc=9)
plt.savefig('traning_r2.pdf', format='pdf', dpi=1200)
plt.show()
os.getcwd()
# -


# #https://stackoverflow.com/questions/51953709/fast-pairwise-simple-linear-regression-between-variables-in-a-data-frame


