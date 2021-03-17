#!/usr/bin/env python
# coding: utf-8

# In[35]:


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


# In[2]:


#zeolite datafile exported from excel
zeolite_fname = "/home/drewx/Documents/Project-Roger-Dodger/Python-ML/zeolites database one febl14.txt"
#filename for datafile
zeolite_outfile = "ZeoX_Final_encoded.tsv" 


# In[3]:


#open the raw tsv data file 
#the file has to be correctly formatted with columns headers  
zeolite_fileObj = open(zeolite_fname)


# In[4]:


#create an instance to start processing the datafile
getZeo = GetZeoliteTsv(zeolite_fileObj, zeolite_outfile)


# In[5]:


#Sanity check of datatypes
#important to recognise that datatypes are detected from the files
#this step also make the string variables as categorical variables
getZeo.set_dtypes()


# In[6]:


#this counts the missing records per column and saves them to provided filename
getZeo.missingness("ZeoX_Final_encoded.miss")


# In[7]:


#take not of number of columns
getZeo.zeolite_df.shape


# In[8]:


#Drops empty columns inplace
getZeo.zeolite_df.dropna(how='all', axis=1, inplace = True)


# In[9]:


#Very that columns have indeed been lost
getZeo.zeolite_df.shape


# In[10]:


#Imputation: step by step for easy debugging
getZeo.GroupMeanImputation('Adsorbent','SA')
#This last step takes care of singletons 
getZeo.MeanImputation('SA')


# In[11]:


getZeo.GroupMeanImputation('Adsorbent','Vmicro')
getZeo.MeanImputation('Vmicro')


# In[12]:


getZeo.GroupMeanImputation('Adsorbent','Vmeso')
getZeo.MeanImputation('Vmeso')


# In[13]:


getZeo.GroupMeanImputation('Adsorbent','pore_size')
getZeo.MeanImputation('pore_size')


# In[14]:


getZeo.GroupMeanImputation('Adsorbent','pore_size')
getZeo.MeanImputation('pore_size')


# In[15]:


getZeo.GroupMeanImputation('Adsorbent','Si_Al')
getZeo.MeanImputation('Si_Al')


# In[16]:


#Mean imputations only for these variables
#Names from column headers
for var in ["C_0","oil_adsorbent_ratio","Temp"]:
         getZeo.MeanImputation(var)


# In[17]:


getZeo.zeolite_df.columns


# In[18]:


#Fill missing values for metals with zeros
for metal in ['Na', 'Ag', 'Ce', 'Cu', 'Ni', 'Zn','Cs']:
         getZeo.zerofill(metal)


# In[19]:


#convert the categorical variables to intergers also known as one-hot-encoding
#https://towardsdatascience.com/the-dummys-guide-to-creating-dummy-variables-f21faddb1d40
getZeo.encode_categorical()


# In[20]:


#save the new data to a tsv file
getZeo.save_zeo("ZeoX_Final_encoded.tsv")


# In[21]:


#get our dataframe 
zeolite_final  = getZeo.zeolite_df


# In[22]:


#check our dataframe
zeolite_final.shape


# In[23]:


#We extract our data features 
#attributes 
y = zeolite_final.loc[:,"Capacity"].values
#labels
X = zeolite_final.drop(["Capacity"], axis = 1).values


# In[24]:


#Split our data into training and test dataset 
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=0)


# In[25]:


y_train.shape


# In[26]:


y_test.shape


# In[27]:


#Standardize features by removing the mean and scaling to unit variasnce
sc = StandardScaler()
#https://datascience.stackexchange.com/questions/12321/whats-the-difference-between-fit-and-fit-transform-in-scikit-learn-models#:~:text=%22fit%22%20computes%20the%20mean%20and,both%20at%20the%20same%20time.
#This should not make much of a difference but its good practice
#TO DO
#Compare accuracy with and without scaling
X_train = sc.fit_transform(X_train)
X_test = sc.transform(X_test)


# In[28]:


regressor = RandomForestRegressor(n_estimators=1000, random_state=0)
#TO DO
#increase n_estimators
#run in parallel


# In[29]:


regressor.fit(X_train, y_train)


# In[30]:


y_pred = regressor.predict(X_test)


# In[31]:


data_table = pd.DataFrame.from_dict({'y_pred': y_pred, 'y_test': y_test, 'errors': y_pred - y_test, 'abs_errors': abs(y_pred - y_test)})


# In[32]:


pd.options.display.max_rows = 4000
print(data_table)


# In[36]:


np.mean(data_table['errors']**2)


# In[ ]:


#data_table.drop(43, inplace = True)


# In[37]:


slope, intercept, r_value, p_value, std_err = stats.linregress(data_table['y_pred'], data_table['y_test'])


# In[38]:


print("Correlation coefficient (R): {:.4f} ".format(r_value))
print("p-value : {}".format(p_value))
print("Intercept: {:.4f}".format(intercept))
print("Slope: {:.4f}".format(slope))
print("std_error: {:.4f}".format(std_err))


# In[39]:


ax = sns.regplot(y="y_pred",
                 x="y_test", 
                 color="g", 
                 marker="+",
                 line_kws={'label':'$r^2$ = {:.2f}'.format(slope, intercept,r_value**2, p_value)},
                 data = data_table)

plt.ylabel('Predicted adsorptive capacity (mgS/g)')
plt.xlabel('Experimental adsorptive capacity (mgS/g)')
ax.legend(loc=9)
plt.savefig('traning_r2.pdf', format='pdf', dpi=1200)
plt.show()
os.getcwd()


# In[40]:


print('Mean Absolute Error:', metrics.mean_absolute_error(y_test, y_pred))
print('Mean Squared Error:', metrics.mean_squared_error(y_test, y_pred))
print('Root Mean Squared Error:', np.sqrt(metrics.mean_squared_error(y_test, y_pred)))


# In[42]:


mape = 100 * (data_table['errors']/data_table['y_pred'])
# Calculate and display accuracy
accuracy = 100 - np.mean(mape)
print('Accuracy:', round(accuracy, 2), '%.')


# In[ ]:


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

get_ipython().run_line_magic('pinfo', 'pyplot.bar')


# In[ ]:





# In[ ]:


X = zeolite_final.drop(["Capacity"], axis = 1)
X.iloc[:,19]


# In[ ]:


X = zeolite_final.drop(["Capacity"], axis = 1)
feat_importances = pd.Series(model.feature_importances_, index=X.columns)
feat_importances.nlargest(20).plot(kind='barh')


# In[ ]:


get_ipython().run_line_magic('pinfo', 'feat_importances.nlargest')


# In[ ]:


get_ipython().run_line_magic('pinfo', 'sns.regplot')


# In[ ]:




