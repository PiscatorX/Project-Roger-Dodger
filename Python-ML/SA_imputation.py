#!/usr/bin/env python
# coding: utf-8

# In[12]:


from load_data import GetZeoliteTsv
from matplotlib import pyplot
import seaborn as sns


# In[ ]:





# In[3]:


getZeo = GetZeoliteTsv("New_data_imputation.tsv", "Imputated_Data.tsv")


# In[4]:


zeolite = getZeo.parse_zeo()


# In[6]:


zeolite.head()


# In[9]:


zeolite.loc[zeolite['SA'].isna(),'imputed'] = 'imputed'


# In[10]:


zeolite.head()


# In[15]:


sns.scatterplot(data=zeolite, x="SA", y="Capacity")


# In[16]:


get_ipython().run_line_magic('pinfo', 'sns.scatterplot')


# In[ ]:


zeolite.head()


# In[ ]:


getZeo.GroupMeanImputation('Adsorbent','SA')


# In[ ]:


getZeo.encode_categorical("Adsorbent","solvent","adsorbate","Batch_Dynamic")


# In[ ]:


getZeo.save_zeo()
#GetZeoliteTsv(object)

