#
# STA 2453 Project 2
# Team: Carey LeMesurier and Wen Li
#

# load the libraries ------------------------------------------------------
library(shiny)
library(dplyr)
library(readr)
library(ggplot2)
library(plotly)
library(bslib)
library(magrittr)


# load our data -----------------------------------------------------------
# national level statistics
scotland_df <- read_csv('data/scotland.csv')
england_df <- read_csv('data/england.csv')
wales_df <- read_csv("data/wales.csv")
north_df <- read_csv("data/north_ireland.csv")

# city level statistics
belfast_df <- read_csv("data/belfast.csv")
belfast_df$hospitalCases = north_df$hospitalCases
cardiff_df <- read_csv("data/cardiff.csv")
cardiff_df$hospitalCases = wales_df$hospitalCases
edinburgh_df <- read_csv("data/edinburgh.csv")
edinburgh_df$hospitalCases = scotland_df$hospitalCases
birmingham_df <- read_csv("data/birmingham.csv")
birmingham_df$hospitalCases = england_df$hospitalCases
bristol_df <- read_csv("data/bristol.csv")
bristol_df$hospitalCases = england_df$hospitalCases
cambridge_df <- read_csv("data/cambridge.csv")
cambridge_df$hospitalCases = england_df$hospitalCases
glasgow_df <- read_csv("data/glasgow.csv")
glasgow_df$hospitalCases = scotland_df$hospitalCases

belfast_vac_df <- read_csv("data/belfast_vac.csv")
cardiff_vac_df <- read_csv("data/cardiff_vac.csv")
edinburgh_vac_df <- read_csv("data/edinburgh_vac.csv")
birmingham_vac_df <- read_csv("data/birmingham_vac.csv")
bristol_vac_df <- read_csv("data/bristol_vac.csv")
cambridge_vac_df <- read_csv("data/cambridge_vac.csv")
glasgow_vac_df <- read_csv("data/glasgow_vac.csv")



# Define UI for application that draws a histogram
ui <- fluidPage(
    theme = bs_theme(bootswatch = "lux"),
    
    titlePanel("Compnay X's COVID-19 Updates Dashboard" ),
    
    tabsetPanel(
        tabPanel("Home", htmlOutput("homePage"), ),
        tabPanel("Case Counts"), 
        tabPanel("Vaccine Impact", htmlOutput("vaccinePage"))
    
))

vaccinePage <- fluidPage(
    titlePanel("Vaccine Information"),
    
    mainPanel(
        h3("England"),
        h3("North Ireland"),
        h3("Wales"),
        h3("Scotland")
    )
)

homePage <- fluidPage(
    mainPanel(
        h3("Objective"),
        p("The objective of this dashboard is to provide Company X Executives, 
        with a COVID-19 dashboard, that clearly shows the current state of the
        pandemic specfically across UK cities Compnay X does business in. \n"),
        h3("Intended Use"),
        p("The dashboard can be used to monitor the current status of the pandemic 
        with respect to case counts and vaccine impacts. The dashboard will provide
        alerts when daily cases in relevant regions, increase by a significant amount 
        over the last week. This can alert executives to closely monitor and potentially 
        make changes to local policies. The dashboard can also be used for supporting longer 
        term decisions around vaccine mandates acording to the Vaccine impact tab.")
    )
)


# Define server logic required to draw a histogram
server <- function(input, output) {
    output$homePage <- renderUI(homePage)
    
    output$vaccinePage <- renderUI(vaccinePage)
    
}

# Run the application 
shinyApp(ui = ui, server = server)
