# COVID-19Dashboard
The purpose of this dashboard is to provide a hypothetical Company's Executives, with key information and updates on the COVID-19 pandemic, specfically across the cities the Company does business in (we choose 7 cities across the UK as an example). The information on this dashboard can help executives closely monitor changes to make informed and efficient policy changes. The dashboard can also be used for supporting longer term decisions around vaccine mandates acording to the Vaccine Impact tab. 

## The data
The data is scraped using the python code in the "web-scraping" folder, from the UK government's API ("api.coronavirus.data.gov.uk/"), and saved in csv files in the "data" folder. The pull_data.py code can be rerun to load in newer data. The data is ingested into the dashboard through the app.R file's read_csv calls. 

## The dashboard
The dashboard is built using Shiny in R. The app.R code contains all of the required code to run the app, as long as it has access to the data folder.
The app is also hosted at the following URL:  https://careylemesurier.shinyapps.io/covid-19dashboard/

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
