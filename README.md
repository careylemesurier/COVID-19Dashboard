# COVID-19Dashboard
The purpose of this dashboard is to provide a hypothetical Company's Executives, with key information and updates on the COVID-19 pandemic, specfically across the cities the Company does business in (we choose 7 cities across the UK as an example). The information on this dashboard can help executives closely monitor changes to make informed and efficient policy changes. The dashboard can also be used for supporting longer term decisions around vaccine mandates acording to the Vaccine Impact tab. 

## The data
The data is scraped using the python script "pull_data.py" in the "web-scraping" folder, from the UK government's API ("api.coronavirus.data.gov.uk/"), and saved in csv files in the "data" folder. The "pull_data.py" can be rerun to load in newer data. To achieve that in details, run (1) "cd web-scrapping" then (2) "python pull_data.py" in terminal.

We read, clean and manipulate the data in clean_data.R and use source(clean_data.R) to apply them into our app. We use numbers, time series plots, map statistics and proportion plots to show the data.

## The dashboard
The dashboard is built using Shiny in R. The app.R code contains all of the required code to run the app, as long as it has access to the data folder by reference source(clean_data.R).
There would be three pages, Home page, Case Counts, and Vaccine information. All of them are easy to follow how to check data. 
For home page, users can view basic description and general weekly updates on case counts. For Case counts pages, it provides details for each city where users also can range the date to check the time series plot for particular counts. And the vaccine information page includes (1) Current proportions for 1st does, 2nd does, 3rd does in each city and (2) time series plot for the three proportions in each city.
The app is also hosted at the following URL:  https://careylemesurier.shinyapps.io/covid-19dashboard/

## How the data is ingested into the dashboard
In general, we used dataframe to store the fetched and cleaned csv file and then apply them into shiny back-end environment. In details, once the users interact with the UI, the server would check which part information users want to view, then have a call to show relevant statistics in appropriate format(time series plots, numbers, or other formats). For case counts statistics, we use numbers, map plots, time series plots to show. For vaccine rate statistics, we use circle + numbers to show the current proportion plots and also time series plots to show the trend.


## Package Requirements
The following packages need to be installed to run the app:  
library(shiny)  
library(dplyr)  
library(readr)  
library(ggplot2)  
library(plotly)  
library(bslib)  
library(magrittr)  
require(maps)  
require(viridis)  
library(hash)  
library(cowplot)  
