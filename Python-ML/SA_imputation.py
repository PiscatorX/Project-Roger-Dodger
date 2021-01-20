#!/usr/bin/env python
# coding: utf-8

# In[17]:


from load_data import GetZeoliteTsv


# In[ ]:





# In[18]:


getZeo = GetZeoliteTsv("New_data_imputation.tsv", "Imputated_Data.tsv")


# In[19]:


zeolite = getZeo.parse_zeo()


# In[24]:


zeolite


# In[25]:


zeolite.loc[zeolite['SA'].isna(),'imputed'] = 'imputed'


# In[ ]:


zeolite


# In[ ]:


getZeo.GroupMeanImputation('Adsorbent','SA')


# In[ ]:


getZeo.encode_categorical("Adsorbent","solvent","adsorbate","Batch_Dynamic")


# In[ ]:


getZeo.save_zeo()
#GetZeoliteTsv(object)

