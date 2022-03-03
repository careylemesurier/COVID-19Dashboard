#!/usr/bin/env python
# coding: utf-8

# In[5]:


import requests
import pandas as pd
from bs4 import BeautifulSoup
url_north_ireland = "https://api.coronavirus.data.gov.uk/v2/data?areaType=nation&areaCode=N92000002&metric=cumCasesByPublishDate&metric=hospitalCases&metric=newCasesByPublishDate&metric=newDeaths28DaysByPublishDate&metric=cumCasesByPublishDate&format=csv"
url_england = "https://api.coronavirus.data.gov.uk/v2/data?areaType=nation&areaCode=E92000001&metric=cumCasesByPublishDate&metric=hospitalCases&metric=newCasesByPublishDate&metric=newDeaths28DaysByPublishDate&metric=cumDeaths28DaysByPublishDate&format=csv"
url_scot = "https://api.coronavirus.data.gov.uk/v2/data?areaType=nation&areaCode=S92000003&metric=cumCasesByPublishDate&metric=hospitalCases&metric=newCasesByPublishDate&metric=newDeaths28DaysByPublishDate&metric=cumDeaths28DaysByPublishDate&format=csv"
url_wales="https://api.coronavirus.data.gov.uk/v2/data?areaType=nation&areaCode=W92000004&metric=cumCasesByPublishDate&metric=hospitalCases&metric=newCasesByPublishDate&metric=newDeaths28DaysByPublishDate&metric=cumDeaths28DaysByPublishDate&format=csv"

url_london = "https://api.coronavirus.data.gov.uk/v2/data?areaType=utla&areaCode=E09000001&metric=cumCasesByPublishDate&metric=hospitalCases&metric=cumDeaths28DaysByDeathDate&metric=newCasesByPublishDate&metric=newDeaths28DaysByPublishDate&format=csv"
url_camb = "https://api.coronavirus.data.gov.uk/v2/data?areaType=utla&areaCode=E10000003&metric=cumCasesByPublishDate&metric=hospitalCases&metric=cumDeaths28DaysByDeathDate&metric=newCasesByPublishDate&metric=newDeaths28DaysByPublishDate&format=csv"
url_bristol = "https://api.coronavirus.data.gov.uk/v2/data?areaType=utla&areaCode=E06000023&metric=cumCasesByPublishDate&metric=hospitalCases&metric=cumDeaths28DaysByDeathDate&metric=newCasesByPublishDate&metric=newDeaths28DaysByPublishDate&format=csv"
url_edb = "https://api.coronavirus.data.gov.uk/v2/data?areaType=utla&areaCode=S12000036&metric=cumCasesByPublishDate&metric=hospitalCases&metric=cumDeaths28DaysByDeathDate&metric=newCasesByPublishDate&metric=newDeaths28DaysByPublishDate&format=csv"
url_belfast= "https://api.coronavirus.data.gov.uk/v2/data?areaType=utla&areaCode=N09000003&metric=cumCasesByPublishDate&metric=hospitalCases&metric=cumDeaths28DaysByDeathDate&metric=newCasesByPublishDate&metric=newDeaths28DaysByPublishDate&format=csv"
url_brim = "https://api.coronavirus.data.gov.uk/v2/data?areaType=utla&areaCode=E08000025&metric=cumCasesByPublishDate&metric=hospitalCases&metric=cumDeaths28DaysByDeathDate&metric=newCasesByPublishDate&metric=newDeaths28DaysByPublishDate&format=csv"
url_glas = "https://api.coronavirus.data.gov.uk/v2/data?areaType=utla&areaCode=S12000049&metric=cumCasesByPublishDate&metric=hospitalCases&metric=cumDeaths28DaysByDeathDate&metric=newCasesByPublishDate&metric=newDeaths28DaysByPublishDate&format=csv"
url_cardiff = "https://api.coronavirus.data.gov.uk/v2/data?areaType=utla&areaCode=W06000015&metric=cumCasesByPublishDate&metric=hospitalCases&metric=newCasesByPublishDate&metric=newDeaths28DaysByPublishDate&metric=cumDeaths28DaysByPublishDate&format=csv"

web_urls = [url_north_ireland, url_england, url_scot, url_wales, url_london, url_camb, url_bristol, url_edb, 
            url_belfast, url_brim, url_glas, url_cardiff]
file_names = ["north_ireland.csv", "england.csv", "scotland.csv", "wales.csv", "london.csv",
              "cambridge.csv", "bristol.csv", "edinburgh.csv", "belfast.csv", "birmingham.csv", "glasgow.csv", "cardiff.csv"]
path = "../data/"

for i in range(len(web_urls)):
    web_url = web_urls[i]
    response = requests.get(web_url)
    file_name = path + file_names[i]
    open(file_name, 'wb').write(response.content)

