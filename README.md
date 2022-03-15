# COVID-19Dashboard
The purpose of this dashboard is to provide a hypothetical Company's Executives, with key information and updates on the COVID-19 pandemic, specfically across the cities the Company does business in (we choose 7 cities across the UK as an example). The information on this dashboard can help executives closely monitor changes to make informed and efficient policy changes. The dashboard can also be used for supporting longer term decisions around vaccine mandates acording to the Vaccine Impact tab. 

## The data
The data is scraped using the python script "pull_data.py" in the "web-scraping" folder, from the UK government's API ("api.coronavirus.data.gov.uk/"), and saved in csv files in the "data" folder. The "pull_data.py" can be rerun to load in newer data. To achieve that in detail, run (1) "cd web-scrapping" then (2) "python pull_data.py" in terminal.

We read, clean and manipulate the data in clean_data.R and use source(clean_data.R) to apply them into our app. We use numbers, time series plots, map statistics and proportion plots to show the data.

## The dashboard
The dashboard is built using Shiny in R. The app.R code contains all of the required code to run the app, as long as it has access to the data folder by reference source(clean_data.R).
There are three pages, Home page, Case Counts, and Vaccination Rates. 
For the home page, users can view a description of the dashboard and a high level weekly update on case counts. For Case Counts pages, details for each city are provided with various user inputs. The Vaccination Rates page includes (1) current proportions of the population with varying dosages of the vaccine, and (2) a time series plot of the changing vaccination rates.
The app is also hosted at the following URL:  https://careylemesurier.shinyapps.io/covid-19dashboard/

## How the data is ingested into the dashboard
At a high-level, a dataframe is used to store the fetched and cleaned data from the csv files, which is then processed in the shiny back-end environment. In detail, once the users interact with the UI, the server would check which part information users want to view, then have a call to show relevant statistics in appropriate format(time series plots, numbers, or other formats). For case counts statistics, we use numbers, map plots, and time series plots. For vaccine rate statistics, we use circle + numbers to show the current proportion plots and also time series plots to show the trends over time.


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
