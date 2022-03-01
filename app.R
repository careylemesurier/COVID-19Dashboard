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
can_df <- read_csv('data/covid19.csv')
can_df$date <- as.Date(can_df$date, format = "%d-%m-%Y")

# Define UI for application that draws a histogram
ui <- fluidPage(
    theme = bs_theme(bootswatch = "lux"),
    
    titlePanel("Compnay X's COVID-19 Updates Dashboard" ),
    
    tabsetPanel(
        tabPanel("Home", htmlOutput("hometext"), ),
        tabPanel("Case Counts"), 
        tabPanel("Vaccine Impact")
    
))


# Define server logic required to draw a histogram
server <- function(input, output) {
    output$hometext <- (
        renderText({"
        <h3>Objective</h3>
        The objective of this dashboard is to provide Company X Executives, 
        with a COVID-19 dashboard, that clearly shows the current state of the
        pandemic specfically across regions Compnay X does business in. \n
        
        <h3>Intended Use</h3>
        The dashboard can be used to monitor the current status of the pandemic 
        with respect to case counts and vaccine impacts. The dashboard will provide
        alerts when daily cases in relevant regions, increase by a significant amount 
        over the last week. This can alert executives to closely monitor and potentially 
        make changes to local policies. The dashboard can also be used for supporting longer 
        term decisions around vaccine mandates acording to the Vaccine impact tab. 
            "})
    )
    
}

# Run the application 
shinyApp(ui = ui, server = server)
