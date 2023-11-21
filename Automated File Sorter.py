#!/usr/bin/env python
# coding: utf-8

# In[5]:


#AUTOMATED FILE SORTER


# os = operating system


# In[23]:


import os,shutil


# In[24]:


path =r'C:/Users/HP/Desktop/GAURPRIYA COLLEGE MATERIAL/'


# In[30]:


fn = os.listdir(path)


# In[28]:


folder_names = ['excel files','pdf file','word file']

for loop in range(0,3):
    if not os.path.exists(path + folder_names[loop]):
        print(path + folder_names[loop])
        os.makedirs(path + folder_names[loop]) 


# In[35]:


for file in fn:
    if '.xlsx' in file and not os.path.exists(path+'excel files/'+file):
        shutil.move(path + file, path +'excel files/'+file)
    elif '.docx' in file and not os.path.exists(path+'word file/'+file):
        shutil.move(path + file, path +'word file/'+file)   
    elif '.pdf' in file and not os.path.exists(path+'pdf file/'+file):
        shutil.move(path + file, path +'pdf file/'+file)


# In[ ]:




