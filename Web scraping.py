#!/usr/bin/env python
# coding: utf-8

# In[15]:


# Largest Indian companies on revenue basis  


# In[6]:


from bs4 import BeautifulSoup as bs
import requests
import numpy as np


# In[7]:


url = 'https://en.wikipedia.org/wiki/List_of_largest_companies_in_India'


# In[8]:


pg = requests.get(url)


# In[9]:


soup = bs(pg.text , 'html')
print(soup.prettify())


# In[10]:


#<table class="wikitable sortable jquery-tablesorter" style="text-align:right;">

soup.find('table')


# In[11]:


soup.find_all('table')


# In[12]:


table = soup.find_all('table')[0]


# In[13]:


print(table)


# In[14]:


world_table_title = table.find_all('th')


# In[15]:


world_title = [title.text.strip()  for title in world_table_title]

print(world_title)


# In[16]:


import pandas as pd


# In[17]:


df = pd.DataFrame(columns = ['Rank','Rank Growth','Forbes Rank 2000','Forbes Growth','Name','Headquarters','Revenue(billion US$)','Profit(billion US$)','Assets(Billion US$)','Value(Billion US$)','Industry'])


# In[18]:


df


# In[19]:


c_data = table.find_all('tr')


# In[23]:


for row in c_data[1:]:
    r_data = row.find_all('td')
    single_data = [data.text.strip()  for data in r_data]
    
    length = len(df)
    df.loc[length] = single_data


# In[24]:


df


# In[30]:


# we do index = False , because otherwise we will have two indexes 

df.to_csv(r'C:\Users\HP\Desktop\Web Scraping\Gaurpriya_Web_Scraping.csv', index = False)


# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:




