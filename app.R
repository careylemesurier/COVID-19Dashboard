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
require(maps)
require(viridis)



# load our data -----------------------------------------------------------
# national level statistics  ----------------------------------------------
scotland_df <- read_csv('data/scotland.csv')
england_df <- read_csv('data/england.csv')
wales_df <- read_csv("data/wales.csv")
north_df <- read_csv("data/north_ireland.csv")

# city level statistics  ---------------------------------------------------
belfast_df <- read_csv("data/belfast.csv")
belfast_df <- merge(belfast_df[, !names(belfast_df) %in% c('hospitalCases')], select(north_df, c('date','hospitalCases')), by='date')

cardiff_df <- read_csv("data/cardiff.csv")
cardiff_df <- merge(cardiff_df[, !names(cardiff_df) %in% c('hospitalCases')], select(wales_df, c('date','hospitalCases')), by='date')
names(cardiff_df)[names(cardiff_df) == 'cumDeaths28DaysByPublishDate'] <- 'cumDeaths28DaysByDeathDate'

edinburgh_df <- read_csv("data/edinburgh.csv")
edinburgh_df <- merge(edinburgh_df[, !names(edinburgh_df) %in% c('hospitalCases')], select(scotland_df, c('date','hospitalCases')), by='date')

birmingham_df <- read_csv("data/birmingham.csv")
birmingham_df <- merge(birmingham_df[, !names(birmingham_df) %in% c('hospitalCases')], select(england_df, c('date','hospitalCases')), by='date')

bristol_df <- read_csv("data/bristol.csv")
bristol_df <- merge(bristol_df[, !names(bristol_df) %in% c('hospitalCases')], select(england_df, c('date','hospitalCases')), by='date')

cambridge_df <- read_csv("data/cambridge.csv")
cambridge_df <- merge(cambridge_df[, !names(cambridge_df) %in% c('hospitalCases')], select(england_df, c('date','hospitalCases')), by='date')

glasgow_df <- read_csv("data/glasgow.csv")
glasgow_df <- merge(glasgow_df[, !names(glasgow_df) %in% c('hospitalCases')], select(scotland_df, c('date','hospitalCases')), by='date')

# change date columns to date type
cities <- list(belfast_df, cardiff_df, edinburgh_df, birmingham_df, bristol_df, cambridge_df, glasgow_df)
for (city_df in cities){
    city_df <- city_df %>%
        mutate(date = as.Date(date, format= "%Y-%m-%d"))
}

# vaccine data  -----------------------------------------------------------
edinburgh_vac_df <- read_csv("data/edinburgh_vac.csv")
birmingham_vac_df <- read_csv("data/birmingham_vac.csv")
bristol_vac_df <- read_csv("data/bristol_vac.csv")
cambridge_vac_df <- read_csv("data/cambridge_vac.csv")
glasgow_vac_df <- read_csv("data/glasgow_vac.csv")

# Location data  -----------------------------------------------------------
city_locations <- data.frame(matrix(ncol = 3, nrow = 0))
col_names <- c("areaName", "lat", "long")
colnames(city_locations) <- col_names

city_locations[nrow(city_locations) + 1,] <- c('Belfast', 54.5973, -5.9301)
city_locations[nrow(city_locations) + 1,] <- c('Cardiff', 51.4837, -3.1681)
city_locations[nrow(city_locations) + 1,] <- c('City of Edinburgh', 55.9533, -3.1883)
city_locations[nrow(city_locations) + 1,] <- c('Birmingham', 52.4862, -1.8904)
city_locations[nrow(city_locations) + 1,] <- c('Bristol, City of', 51.4545, -2.5879)
city_locations[nrow(city_locations) + 1,] <- c('Cambridgeshire', 52.2053, -0.1218)
city_locations[nrow(city_locations) + 1,] <- c('Glasgow City', 55.8642, -4.2518)

# This Weeks data -------------------------------------------------------------------
# initialize dataframe with just the headers of a city df
last7days_df <- belfast_df[0,]

# get latest date in data
today <- max(belfast_df$date)
earliest_date <- today - as.difftime(7, unit="days")

# loop through each city df and replace NA with 0 and concatenate the last 7 days data to the last7days_df
for (city_df in cities){
    filtered_data <- city_df %>%
        filter(date >= earliest_date)
    
    filtered_data[is.na(filtered_data)] <- 0
    
    last7days_df <- rbind(last7days_df, filtered_data)
}

# get totals from last 7 days by city
last7days_df_summarize <- aggregate(cbind(cumCasesByPublishDate,cumDeaths28DaysByDeathDate, hospitalCases, newCasesByPublishDate, newDeaths28DaysByPublishDate)~areaName, last7days_df, sum)

# merge long lat data with last 7 days data
last7days_df_summarize <- merge(last7days_df_summarize, city_locations, by='areaName')

# Data From 2 Weeks Ago ---------------------------------------------------------------
#so I can get percent increase from last week to this week 

two_weeks_ago_df <- belfast_df[0,]

# get latest date in data
today <- max(belfast_df$date)
earliest_date <- today - as.difftime(7, unit="days")
two_weeks_ago_date <- today - as.difftime(14, unit="days")

# loop through each city df adn get data from 2 weeks ago
for (city_df in cities){
    filtered_data <- city_df %>%
        filter(date <= earliest_date,
               date >= two_weeks_ago_date)
    
    filtered_data[is.na(filtered_data)] <- 0
    two_weeks_ago_df <- rbind(two_weeks_ago_df, filtered_data)
}

two_weeks_ago_df_summarize <- aggregate(cbind(cumCasesByPublishDate,cumDeaths28DaysByDeathDate, hospitalCases, newCasesByPublishDate, newDeaths28DaysByPublishDate)~areaName, two_weeks_ago_df, sum)

# percent increase data --------------------------------------------------------------------
col_names <- colnames(two_weeks_ago_df_summarize)
percent_increase_df <- data.frame(matrix(ncol = 6, nrow = 7))
colnames(percent_increase_df) <- col_names

percent_increase_df$newCasesByPublishDate <- ((last7days_df_summarize$newCasesByPublishDate - two_weeks_ago_df_summarize$newCasesByPublishDate)/two_weeks_ago_df_summarize$newCasesByPublishDate)*100
percent_increase_df$newDeaths28DaysByPublishDate <- ((last7days_df_summarize$newDeaths28DaysByPublishDate - two_weeks_ago_df_summarize$newDeaths28DaysByPublishDate)/ two_weeks_ago_df_summarize$newDeaths28DaysByPublishDate)*100
percent_increase_df$hospitalCases <- ((last7days_df_summarize$hospitalCases - two_weeks_ago_df_summarize$hospitalCases)/two_weeks_ago_df_summarize$hospitalCases)*100
percent_increase_df$cumCasesByPublishDate <- ((last7days_df_summarize$cumCasesByPublishDate - two_weeks_ago_df_summarize$cumCasesByPublishDate)/two_weeks_ago_df_summarize$cumCasesByPublishDate)*100
percent_increase_df$cumDeaths28DaysByDeathDate <- ((last7days_df_summarize$cumDeaths28DaysByDeathDate - two_weeks_ago_df_summarize$cumDeaths28DaysByDeathDate)/two_weeks_ago_df_summarize$cumDeaths28DaysByDeathDate)*100
percent_increase_df$areaName <- two_weeks_ago_df_summarize$areaName

is.nan.data.frame <- function(x)
    do.call(cbind, lapply(x, is.nan))

percent_increase_df[is.nan(percent_increase_df)] <- 0





# Define UI for application 
ui <- fluidPage(
    theme = bs_theme(bootswatch = "lux"),
    
    titlePanel("Compnay X's COVID-19 Updates Dashboard" ),
    
    tabsetPanel(
        tabPanel("Home", htmlOutput("homePage")),
        tabPanel("Case Counts", 
            fluidPage(
                htmlOutput("casePage"),
                fluidRow(
                    column(6,
                           radioButtons(inputId = "metric", 
                                       label = "Select metric: ", 
                                       selected = "New Daily Cases",
                                       choices = c("New Daily Cases", "New Daily Deaths"))
                           ),
                    column(6,
                           selectInput(inputId = "city", 
                                       label = "Select city: ", 
                                       selected = "Belfast",
                                       choices = city_locations$areaName)
                           )
                ),
                fluidRow(
                    column(6,plotlyOutput("map_plot")),
                    column(6,plotlyOutput("case_line_plot"))
                )
            )
        ),
        tabPanel("Vaccine Impact", 
                 fluidPage(
                     htmlOutput("vaccinePage"),
                     actionButton("bristol_vac", "Bristol"),
                     actionButton("cambridge_vac", "Cambridge"),
                     actionButton("edinburgh_vac", "Edingburgh"),
                     actionButton("birmingham_vac", "Birmingham"),
                     actionButton("glasgow_vac", "Glasgow"),
                     fluidRow(
                         plotOutput("proportions")
                     )
                 )
        )
        
        
    
))


casePage <- fluidPage(
    mainPanel(
        h3("Case Count Updates"),
        p("The case count updates for this week, for the cities Company X has corporate 
          offices in are shown below. The sizes of the dots on the map show the relative 
          size of the chosen metric, and the blue dot indicates the selected city\n")
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


# Define server logic 
server <- function(input, output) {
    # homepage text
    output$homePage <- renderUI(homePage)
    output$casePage <- renderUI(casePage)
    
    # case count plot
    output$map_plot <- renderPlotly({
        selected_city <- input$city
        selected_metric <- input$metric
        
        last7days_df_summarize$selected = ifelse(last7days_df_summarize$areaName==selected_city,1,0)
        
        world_map <- map_data("world", region="UK")
        
        if (selected_metric=="New Daily Cases"){
            map_p <-ggplot() +
                geom_polygon(data = world_map, 
                             aes(x = long, y = lat, group=group), 
                             fill="lightgrey", colour = "white") + 
                coord_fixed(ratio = 1.3, 
                            xlim = c(-10,3), 
                            ylim = c(50, 59)) + 
                theme_void() +
                geom_point(data = last7days_df_summarize, 
                           aes(x = as.numeric(long), y = as.numeric(lat), 
                               size = newCasesByPublishDate, 
                               colour = selected,
                               text = paste("City: ", areaName, 
                                            "<br>New Cases this week: ", newCasesByPublishDate,  
                                            "<br>Total Deaths this week: ", newDeaths28DaysByPublishDate))) +
                theme(legend.position="none")
        }
        else{
            map_p <-ggplot() +
                geom_polygon(data = world_map, 
                             aes(x = long, y = lat, group=group), 
                             fill="lightgrey", colour = "white") + 
                coord_fixed(ratio = 1.3, 
                            xlim = c(-10,3), 
                            ylim = c(50, 59)) + 
                theme_void() +
                geom_point(data = last7days_df_summarize, 
                           aes(x = as.numeric(long), y = as.numeric(lat), 
                               size = newDeaths28DaysByPublishDate, 
                               colour = selected,
                               text = paste("City: ", areaName, 
                                            "<br>New Cases this week: ", newCasesByPublishDate,  
                                            "<br>Total Deaths this week: ", newDeaths28DaysByPublishDate))) +
                theme(legend.position="none")
        }
        
        
        map_plotly_plot <- ggplotly(map_p, tooltip="text")
        
        return(map_plotly_plot)
    })
    
    # second plot on case update page
    output$case_line_plot <- renderPlotly({
        selected_city <- input$city
        selected_metric <- input$metric
        
        filter_data <- last7days_df %>% 
            filter(areaName == selected_city)
        
        if (selected_metric=="New Daily Cases"){
            line_p <- ggplot()+
                geom_line(data=filter_data, aes(x=date,y=newCasesByPublishDate), colour="#6bb9fc")+
                labs(x = "Date",y = "Number of Daily New Cases")+
                theme_grey()
        }
        else{
            line_p <- ggplot()+
                geom_line(data=filter_data, aes(x=date,y=newDeaths28DaysByPublishDate), colour="#6bb9fc")+
                labs(x = "Date",y = "Number of Daily New Cases")+
                theme_grey()
        }
            
        
        line_plotly_plot <- ggplotly(line_p, tooltip="text")
        
        return(line_plotly_plot)
    })
    
    
    # Vaccine Page text
    shown <- reactiveVal()
    observeEvent(input$bristol_vac, {
        shown(bristol_vac_df)
    })
    observeEvent(input$cambridge_vac, {
        shown(cambridge_vac_df)
    })
    observeEvent(input$edinburgh_vac, {
        shown(edinburgh_vac_df)
    })
    observeEvent(input$birmingham_vac, {
        shown(birmingham_vac_df)
    })
    observeEvent(input$glasgow_vac, {
        shown(glasgow_vac_df)
    })
    output$proportions <- renderPlot({
        df <- shown()
        if (!is.null(df$date)) {
            proportion <- df%>%
                na.omit() %>%
                mutate(first_does = cumVaccinationFirstDoseUptakeByVaccinationDatePercentage) %>%
                mutate(second_does = cumVaccinationSecondDoseUptakeByVaccinationDatePercentage) %>%
                mutate(third_does = cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage) %>%
                select(first_does, second_does, third_does) %>%
                head(1)
            first_does = proportion$first_does 
            second_does = proportion$second_does 
            third_does = proportion$third_does 
            eg <- tribble(
                ~x, ~y, ~size, ~x1,
                "First Does", 1, 4, 1,
                "Second Does", 1, 8, 2,
                "Third Does", 1, 12, 3
            )
            # Color, discrete
            plot <- ggplot(eg, aes(x = x, y = y, color = x1)) +
                geom_point(size = 50) +
                guides(color = FALSE) +
                theme(axis.text.y = element_blank(),
                      axis.title = element_blank(),
                      axis.ticks = element_blank(),
                      panel.background = element_rect(fill = "transparent",colour = NA)) +
                annotate("text", x = 1, y=1, label=first_does) +
                annotate("text", x = 2, y=1, label=second_does) +
                annotate("text", x = 3, y=1, label=third_does)
                return (plot)
        }
    })

}

# Run the application 
shinyApp(ui = ui, server = server)
