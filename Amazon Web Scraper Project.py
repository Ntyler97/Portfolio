#!/usr/bin/env python
# coding: utf-8

# In[1]:


# Import libraries 

from bs4 import BeautifulSoup
import requests
import time
import datetime
import pandas as pd
import smtplib


# In[2]:


# Connect to website and pull variables

URL = 'https://www.amazon.com/Funny-Data-Systems-Business-Analyst/dp/B07FNW9FGJ'

headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36", "Accept-Encoding":"gzip, deflate", "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", "DNT":"1","Connection":"close", "Upgrade-Insecure-Requests":"1"}

page = requests.get(URL, headers=headers)

soup1 = BeautifulSoup(page.content, 'html.parser')

soup2 = BeautifulSoup(soup1.prettify(), 'html.parser')

title = soup2.find(id='productTitle').get_text().strip()
price = soup2.find(id='corePriceDisplay_desktop_feature_div').get_text().strip()
rating = soup2.find(id='acrPopover').get_text().strip()

print(title)
print(price)
print(rating)


# In[3]:


# Clean pricing data

decimal = price.index('.')
clean_price = price[1:decimal + 3]

print(title)
print(clean_price)
print(rating)


# In[4]:


# Create timestamp data

today= datetime.date.today()

print(today)


# In[5]:


# Create CSV and write headers and data into the file

import csv

header = ['Product Name', 'Price', 'Rating', 'Date']
data = [title, clean_price, rating, today]

with open('AmazonWebScraperDataset.csv', 'w', newline='', encoding='UTF8') as f:
    writer = csv.writer(f)
    writer.writerow(header)
    writer.writerow(data)


# In[6]:


# View CSV

df = pd.read_csv(r'C:\Users\ntyle\AmazonWebScraperDataset.csv')

df


# In[7]:


# Append data to CSV

with open('AmazonWebScraperDataset.csv', 'a+', newline='', encoding='UTF8') as f:
    writer = csv.writer(f)
    writer.writerow(data)


# In[8]:


# Create function that notifies user if there is a price drop

def send_mail():
    server = smtplib.SMTP_SSL('smtp.gmail.com',465)
    server.ehlo()
    #server.starttls()
    server.ehlo()
    server.login('ntyler322@gmail.com','xxxxxxxxxxxxxx')
    
    subject = "Python Code has detected a price drop!"
    body = "Your code has detected a price drop! Link here: https://www.amazon.com/Funny-Data-Systems-Business-Analyst/dp/B07FNW9FGJ"
   
    msg = f"Subject: {subject}\n\n{body}"
    
    server.sendmail(
        'ntyler322@gmail.com',
        msg   
    )


# In[14]:


# Create custom function using above code

def check_price():
    URL = 'https://www.amazon.com/Funny-Data-Systems-Business-Analyst/dp/B07FNW9FGJ'
    headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36", "Accept-Encoding":"gzip, deflate", "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", "DNT":"1","Connection":"close", "Upgrade-Insecure-Requests":"1"}
    page = requests.get(URL, headers=headers)

    soup1 = BeautifulSoup(page.content, 'html.parser')
    soup2 = BeautifulSoup(soup1.prettify(), 'html.parser')

    title = soup2.find(id='productTitle').get_text().strip()
    price = soup2.find(id='corePriceDisplay_desktop_feature_div').get_text().strip()
    rating = soup2.find(id='acrPopover').get_text().strip()
    
    decimal = price.index('.')
    clean_price = price[1:decimal + 3]
    
    today= datetime.date.today()

    header = ['Product Name', 'Price', 'Rating', 'Date']
    data = [title, clean_price, rating, today]
    
    with open('AmazonWebScraperDataset.csv', 'a+', newline='', encoding='UTF8') as f:
        writer = csv.writer(f)
        writer.writerow(data)
        
    if (float(clean_price) < 16.99):
        send_mail()


# In[ ]:


# Run check_price every 24hrs and input data into your CSV

while(True):
    check_price()
    time.sleep(86400)

