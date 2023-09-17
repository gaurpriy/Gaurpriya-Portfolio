#!/usr/bin/env python
# coding: utf-8

# In[11]:


#BMI CALCULATOR

def bmi():
    weight = float(input('Enter your weight in kg:'))
    height = float(input('Enter your Height in meters:'))
    h= weight/(height)**2
    print('Your BMI is:',h)
    if h<18.5:
        print("You are Underweight")
    elif h>18.5:
        print('You are Healthy')
    elif h<25:
        print('You are Healthy')
    else:
        print('You are Overweight')
    
    


# In[12]:


bmi()


# In[ ]:




