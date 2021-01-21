#!/usr/bin/env python
# coding: utf-8

# In[1]:


from load_data import GetZeoliteTsv
from matplotlib import pyplot
import seaborn as sns


# In[2]:


getZeo = GetZeoliteTsv("New_data_imputation.tsv", "Imputed_out.tsv")


# In[3]:


#This assigns data types and ensures that we have the correct data tupes categories vs floats etc
#for more details view the load_data.py file
zeolite = getZeo.parse_zeo()


# In[4]:


#check the file
zeolite.head()


# In[5]:


#This creates a new column of name 'imputed'
#Assign 'Yes' to rows where SA is empty
#These are there rows that will be imputed
zeolite.loc[zeolite['SA'].isna(),'imputed'] = 'Yes'


# In[6]:


#Assign 'No' to the rows that have values
zeolite.loc[zeolite['SA'].notna(),'imputed'] = 'No'


# In[7]:


#make the datatype of the column category
zeolite['imputed'] = zeolite['imputed'].astype('category')


# In[8]:


#Check the file
zeolite.head()


# In[9]:


#Fill in missing date by grouping Adsorbents
#Means are calculated from each group and then nan are replaced
#Some value remain unimputed
getZeo.GroupMeanImputation('Adsorbent','SA')


# In[10]:


getZeo.zeolite_df.head()


# In[11]:


#visualise imputed data
sns.scatterplot(data = zeolite, x="SA", y="Capacity", hue='imputed', legend=True)


# In[12]:


#plot SA vs Capacity  grouped by type of Adsorbent
#Plot data and regression model fits
sns.lmplot(data = zeolite, x="SA", y="Capacity", hue="imputed", row="Adsorbent")


# In[13]:


#save imputed output file
getZeo.save_zeo()

