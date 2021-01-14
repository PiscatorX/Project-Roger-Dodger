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
from matplotlib import pyplot
from sklearn import metrics
import pandas as pd
import numpy as np
np.random.seed(0)

#importing into pandas dataframe
zeolite_df = pd.read_csv("/home/drewx/Documents/Project-Roger-Dodger/data/zeolites_review_TP.csv", delimiter = "\t")

zeolite_df["Adsorbent"]

for var in ["SA","Vmicro","Vmeso","pore size","Si_Al","Ag","Ce","Cu","C_start","C_end", "adsorbent"]:
        zeolite_df[var] =  zeolite_df[var].fillna(0)
        zeolite_df[var] =  zeolite_df[var].astype('float64')

for var in ["Adsorbent","adsorbate","solvent","Batch_Dynamic"]:
    zeolite_df[var] =  zeolite_df[var].astype('category')

zeolite_df['References'] = zeolite_df['References'].astype('string')

#https://towardsdatascience.com/the-dummys-guide-to-creating-dummy-variables-f21faddb1d40
zeolite_df.shape
#zeolite_df

#convert the categorical variables to intergers also known as one-hot-encoding
#https://towardsdatascience.com/the-dummys-guide-to-creating-dummy-variables-f21faddb1d40
#This can be automated to identify only those categorical variables, encode them and save them to a list for concat
encoded_Adsorbent = pd.get_dummies(zeolite_df['Adsorbent'])
encoded_solvent = pd.get_dummies(zeolite_df['solvent'])
#No need to encode this, all values appear to be same?
#encoded_adsorbate = pd.get_dummies(zeolite_df['adsorbate'])
encoded_Batch_Dynamic = pd.get_dummies(zeolite_df['Batch_Dynamic'])

encoded_Adsorbent

#remove the categoricol variable columns and any unwanted columns in this case "References"
#this can also be automated as part of the step abov
zeolite_dropped = zeolite_df.drop(["Adsorbent","solvent","adsorbate","Batch_Dynamic", "References"],axis= 1)
#zeolite_dropped.dtypes

#encoded_Adsorbent
encoded_solvent 
#encoded_Batch_Dynamic  

zeolite_final = pd.concat([zeolite_dropped, encoded_solvent, encoded_Adsorbent, encoded_Batch_Dynamic],axis=1 )

zeolite_dropped

#We have our data ready for machine learning
#zeolite_final.dtypes
#saving dataframe to file for optimisation
#zeolite_final.to_csv("zeolite_finalx.tsv", sep='\t', index = False)
from load_data import get_zeo
zeolite_final = get_zeo("/home/drewx/Documents/Project-Roger-Dodger/data/zeolites_review_TP.csv", "zeo.dat")

# +
#https://stackabuse.com/random-forest-algorithm-with-python-and-scikit-learn/
#zeolite_final.columns
# -

#attributes 
y = zeolite_final.loc[:,"Capacity"].values
#labels
X = zeolite_final.drop(["Capacity"], axis = 1).values

X

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=0)



#Standardize features by removing the mean and scaling to unit variasnce
sc = StandardScaler()
#https://datascience.stackexchange.com/questions/12321/whats-the-difference-between-fit-and-fit-transform-in-scikit-learn-models#:~:text=%22fit%22%20computes%20the%20mean%20and,both%20at%20the%20same%20time.
#This should not make much of a difference but its good practice
#TO DO
#Compare accuracy with and without scaling
X_train = sc.fit_transform(X_train)
X_test = sc.transform(X_test)
print(X_test)

regressor = RandomForestRegressor(n_estimators=1000, random_state=0)
#TO DO
#increase n_estimators
#run in parallel

regressor.fit(X_train, y_train)

y_pred = regressor.predict(X_test)

pd.DataFrame(y_pred).to_csv('y_pred.csv',  index = False)
pd.DataFrame(y_test).to_csv('y_test.csv', index = False)

# ?RandomForestRegressor


print('Mean Absolute Error:', metrics.mean_absolute_error(y_test, y_pred))
print('Mean Squared Error:', metrics.mean_squared_error(y_test, y_pred))
print('Root Mean Squared Error:', np.sqrt(metrics.mean_squared_error(y_test, y_pred)))

errors = abs(y_pred - y_test)

mape = 100 * (errors / y_test)
# Calculate and display accuracy
accuracy = 100 - np.mean(mape)
print('Accuracy:', round(accuracy, 2), '%.')

# +
model = DecisionTreeRegressor()
# fit the model
model.fit(X_train, y_train)
# get importance
importance = model.feature_importances_


# summarize feature importance
for i,v in enumerate(importance):
	print('[%s]\tFeature: %0d, Score: %.5f' % (X.columns[i], i,v))
#plot feature importance
#pyplot.bar([x for x in range(len(importance))], importance)
#pyplot.bar([x for x in X.columns], importance)

pyplot.show()
#print([x for x in range(len(importance))])

# ?pyplot.bar
# -

X = zeolite_final.drop(["Capacity"], axis = 1)
X.iloc[:,19]

X = zeolite_final.drop(["Capacity"], axis = 1)
feat_importances = pd.Series(model.feature_importances_, index=X.columns)
feat_importances.nlargest(20).plot(kind='barh')

# ?feat_importances.nlargest


