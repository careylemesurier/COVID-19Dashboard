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
library(hash)
library(rsconnect)
library(cowplot)



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

# Combining all Cities Data -------------------------------------------------------------------
# initialize data frame with just the headers of a city df
all_cities_df <- belfast_df[0,]

# Initialize variables for today and one week prior
today <- max(belfast_df$date)
earliest_date <- today - as.difftime(7, unit="days")

replaceNa <- function(x) {
    idx <- !is.na(x)
    x[idx][cumsum(idx)]
}

# loop through each city df; replace NAs and concatenate to the all_cities_df
for (city_df in cities){
    filtered_data <- city_df %>%
        arrange(date)
    
    # set first row nas to 0
    filtered_data[1,is.na(filtered_data[1,])] <- 0
    
    # Use replace na function to replace nas with prior value for cumulative columns
    filtered_data$hospitalCases <- replaceNa(filtered_data$hospitalCases)
    filtered_data$cumCasesByPublishDate <- replaceNa(filtered_data$cumCasesByPublishDate)
    filtered_data$cumDeaths28DaysByDeathDate <- replaceNa(filtered_data$cumDeaths28DaysByDeathDate)
    
    # for daily stat columns replace nas with 0
    filtered_data[is.na(filtered_data)] <- 0
    
    all_cities_df <- rbind(all_cities_df, filtered_data)
}

# create data frame of just data from the last 7 days
last7days_df <- all_cities_df %>%
    filter(date>=earliest_date)

# create summary data frame for the last 7 days:
# get aggregates from last 7 days by city- sums for daily stat columns, latest value for cumulative data
last7days_df_summarize <- aggregate(cbind(newCasesByPublishDate,newDeaths28DaysByPublishDate)~
                                        areaName, last7days_df, sum) %>% arrange(areaName)

last7days_df_summarize$cumCasesByPublishDate <- (last7days_df %>%
                                                     filter(date == today) %>% 
                                                     arrange(areaName))$cumCasesByPublishDate
last7days_df_summarize$cumDeaths28DaysByDeathDate <- (last7days_df %>%
                                                          filter(date == today) %>%
                                                          arrange(areaName))$cumDeaths28DaysByDeathDate
last7days_df_summarize$hospitalCases <- (last7days_df %>%
                                             filter(date == today) %>% 
                                             arrange(areaName))$hospitalCases
# merge long lat data with last 7 days summary data
last7days_df_summarize <- merge(last7days_df_summarize, city_locations, by='areaName')

# Data From 2 Weeks Ago ---------------------------------------------------------------
#so I can get percent increase from last week to this week 

# get latest date in data
today <- max(belfast_df$date)
earliest_date <- today - as.difftime(7, unit="days")
two_weeks_ago_date <- today - as.difftime(14, unit="days")

#get data from 2 weeks ago
two_weeks_ago_df <- all_cities_df %>%
    filter(date<=earliest_date,
           date>=two_weeks_ago_date)

# create summary data frame for the data from 2 weeks ago:
two_weeks_ago_df_summarize <- aggregate(cbind(newCasesByPublishDate, newDeaths28DaysByPublishDate)~
                                            areaName, two_weeks_ago_df, sum)%>% arrange(areaName)

two_weeks_ago_df_summarize$cumCasesByPublishDate <- (two_weeks_ago_df %>%
                                                     filter(date == earliest_date)%>% 
                                                         arrange(areaName))$cumCasesByPublishDate
two_weeks_ago_df_summarize$cumDeaths28DaysByDeathDate <- (two_weeks_ago_df %>%
                                                          filter(date == earliest_date)%>% 
                                                              arrange(areaName))$cumDeaths28DaysByDeathDate
two_weeks_ago_df_summarize$hospitalCases <- (two_weeks_ago_df %>%
                                             filter(date == earliest_date)%>% 
                                                 arrange(areaName))$hospitalCases
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




# Define UI for application ------------------------------------------------------------------------
ui <- fluidPage(
    theme = bs_theme(bootswatch = "lux"),
    
    titlePanel("Compnay X's COVID-19 Updates Dashboard" ),
    
    tabsetPanel(
        tabPanel("Home", 
            fluidPage(
                fluidRow(htmlOutput("homePage")),
                fluidRow(
                    column(2,
                           radioButtons(inputId = "metric_home", 
                                        label = "Select metric: ", 
                                        selected = "New Cases",
                                        choices = c("New Cases", 
                                                    "New Deaths", 
                                                    "Current Hospitalizations"))),
                    column(10,plotlyOutput("wekly_update"))))),
        tabPanel("Case Counts", 
            fluidPage(
                fluidRow(uiOutput("casePage")),
                fluidRow(
                    column(4,
                           radioButtons(inputId = "metric", 
                                       label = "Select metric: ", 
                                       selected = "New Cases",
                                       choices = c("New Cases", 
                                                   "New Deaths", 
                                                   "Current Hospitalizations",
                                                   "Total Cases",
                                                   "Total Deaths"))
                           ),
                    
                    column(4,
                           selectInput(inputId = "city", 
                                       label = "Select city: ", 
                                       selected = "Belfast",
                                       choices = city_locations$areaName)),
                    column(4,#align="right",
                           dateRangeInput(inputId = 'date_range',
                                          label = "Select date range: ",
                                          start = earliest_date,
                                          end = today,
                                          min = min(all_cities_df$date),
                                          max = today)
                           )
                ),
                fluidRow(
                    column(6,fluidRow(
                        column(9,plotlyOutput("map_plot")),
                        column(3, align="center",plotOutput(outputId = "map_plot_legend", width = "100%", height="100%")))),
                    column(6,plotlyOutput("case_line_plot"))
                )
            )
        ),
        tabPanel("Vaccination Rates", 
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
    titlePanel("Cases, Deaths, and Hospitalizations"),
    fluidRow(
        p("This section is intended to provide a more detailed look into the changing conditions of the 
        pandemic. Users can navigate through the various cities, metrics, and dates to assess the
        current status of the pandemic, and compare that to historic data for reference. \n
        
        The Map Visual (left) shows the relative 
        size of the chosen metric for each city, this week, with the selected city indicated in blue.
        The Line Graph (right), shows the chosen metric, for the selected city, over
        the date range selected.\n")
    )
)

homePage <- fluidPage(
    fluidRow(h3("Objective")),
    fluidRow(
        p("This dashboard provides Company X Executives, with key information and updates on
        the COVID-19 pandemic, specfically across UK cities Compnay X does business in. \n")),
    fluidRow(
        h3("Intended Use")),
    fluidRow(
        p("The dashboard can be used to monitor the current status of the pandemic 
        with respect to case counts and vaccine impacts, targeted to just the cities of Intrest 
        for Company X. The information on this dashboard can help executives at Company X closely 
        monitor changes to make informed and efficient policy changes. The dashboard can also be 
        used for supporting longer term decisions around vaccine mandates acording to the Vaccine 
        Impact tab.")),
    fluidRow(
        h3("Weekly Update ")),
    fluidRow(
        p(" The figures below show the relative increase in the selected metric from last week to 
          this week. "))
    )



# Define server logic ------------------------------------------------------------------------
server <- function(input, output) {
    # homepage text
    output$homePage <- renderUI(homePage)
    output$casePage <- renderUI(casePage)

    # case count plot
    output$map_plot <- renderPlotly({
        selected_city <- input$city
        selected_metric <- input$metric
        
        last7days_df_summarize$selected = ifelse(last7days_df_summarize$areaName==selected_city,"1","2")
        
        world_map <- map_data("world")
        
        if (selected_metric=="New Cases"){
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
                                            "<br>New Cases this week: ", newCasesByPublishDate))) +
                scale_color_manual(guide = "none",
                                   values=c("#6bb9fc","black")) +
                scale_size_continuous(name = paste("Number of",selected_metric)) +
                theme(legend.position='right')
        }
        else if (selected_metric=="New Deaths"){
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
                                            "<br>Total Deaths this week: ", newDeaths28DaysByPublishDate))) +
                scale_color_manual(guide = "none",
                                   values=c("#6bb9fc","black")) +
                scale_size_continuous(name=paste("Number of",selected_metric)) +
                theme(legend.position='right')
        }
        else if (selected_metric=="Current Hospitalizations"){
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
                               size = hospitalCases, 
                               colour = selected,
                               text = paste("City: ", areaName,
                                            "<br>Hospitalizations this week: ", hospitalCases))) +
                scale_color_manual(guide = "none",
                                   values=c("#6bb9fc","black")) +
                scale_size_continuous(name=paste("Number of",selected_metric)) +
                theme(legend.position='right')
        }
        else if (selected_metric=="Total Cases"){
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
                               size = cumCasesByPublishDate, 
                               colour = selected,
                               text = paste("City: ", areaName,
                                            "<br>Total Cases: ", cumCasesByPublishDate))) +
                scale_color_manual(guide = "none",
                                   values=c("#6bb9fc","black")) +
                scale_size_continuous(name=paste("Number of",selected_metric)) +
                theme(legend.position='right')
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
                               size = cumDeaths28DaysByDeathDate, 
                               colour = selected,
                               text = paste("City: ", areaName,
                                            "<br>Total Deaths: ", cumDeaths28DaysByDeathDate))) +
                scale_color_manual(guide = "none",
                                   values=c("#6bb9fc","black")) +
                scale_size_continuous(name=paste("Number of",selected_metric)) +
                theme(legend.position='right')
        }
        
        map_plotly_plot <- ggplotly(map_p, tooltip="text")%>%
            layout(showlegend = FALSE)
    
    
        return(map_plotly_plot)
    })
    
    # case count map legend
    output$map_plot_legend <- renderPlot({
        selected_city <- input$city
        selected_metric <- input$metric
        
        last7days_df_summarize$selected = ifelse(last7days_df_summarize$areaName==selected_city,"1","2")
        
        world_map <- map_data("world")
        
        if (selected_metric=="New Cases"){
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
                                            "<br>New Cases this week: ", newCasesByPublishDate))) +
                scale_color_manual(guide = "none",
                                   values=c("#6bb9fc","black")) +
                scale_size_continuous(name=selected_metric) +  #paste("Number of",selected_metric)) +
                theme(legend.position='right')
        }
        else if (selected_metric=="New Deaths"){
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
                                            "<br>Total Deaths this week: ", newDeaths28DaysByPublishDate))) +
                scale_color_manual(guide = "none",
                                   values=c("#6bb9fc","black")) +
                scale_size_continuous(name=selected_metric) +  #paste("Number of",selected_metric)) +
                theme(legend.position='right')
        }
        else if (selected_metric=="Current Hospitalizations"){
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
                               size = hospitalCases, 
                               colour = selected,
                               text = paste("City: ", areaName,
                                            "<br>Hospitalizations this week: ", hospitalCases))) +
                scale_color_manual(guide = "none",
                                   values=c("#6bb9fc","black")) +
                scale_size_continuous(name="Hospitalizations") +  #paste("Number of",selected_metric)) +
                theme(legend.position='right')
        }
        else if (selected_metric=="Total Cases"){
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
                               size = cumCasesByPublishDate, 
                               colour = selected,
                               text = paste("City: ", areaName,
                                            "<br>Total Cases: ", cumCasesByPublishDate))) +
                scale_color_manual(guide = "none",
                                   values=c("#6bb9fc","black")) +
                scale_size_continuous(name=selected_metric) +  #paste("Number of",selected_metric)) +
                theme(legend.position='right')
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
                               size = cumDeaths28DaysByDeathDate, 
                               colour = selected,
                               text = paste("City: ", areaName,
                                            "<br>Total Deaths: ", cumDeaths28DaysByDeathDate))) +
                scale_color_manual(guide = "none",
                                   values=c("#6bb9fc","black")) +
                scale_size_continuous(name=selected_metric) +  #paste("Number of",selected_metric)) +
                theme(legend.position='right')
        }
        
        legend <- cowplot::get_legend(map_p)
        return(ggdraw(legend))
    }, height = 150)#, width = 200)
    
    
    # second plot on case update page
    output$case_line_plot <- renderPlotly({
        selected_city <- input$city
        selected_metric <- input$metric
        start_date <- input$date_range[1]
        end_date <- input$date_range[2]
        
        filter_data <- all_cities_df %>% 
            filter(areaName == selected_city,
                   date >= start_date,
                   date <= end_date) 
        
        if (selected_metric=="New Cases"){
            line_p <- ggplot()+
                geom_line(data=filter_data, aes(x=date,y=newCasesByPublishDate), colour="#6bb9fc")+
                labs(x = "Date",y = "New Daily Cases")+
                theme_grey()
        }
        else if (selected_metric=="New Deaths"){
            line_p <- ggplot()+
                geom_line(data=filter_data, aes(x=date,y=newDeaths28DaysByPublishDate), colour="#6bb9fc")+
                labs(x = "Date",y = "New Daily Deaths")+
                theme_grey()
        }
        else if (selected_metric=="Current Hospitalizations"){
            line_p <- ggplot()+
                geom_line(data=filter_data, aes(x=date,y=hospitalCases), colour="#6bb9fc")+
                labs(x = "Date",y = selected_metric)+
                theme_grey()
        }   
        else if (selected_metric=="Total Cases"){
            line_p <- ggplot()+
                geom_line(data=filter_data, aes(x=date,y=cumCasesByPublishDate), colour="#6bb9fc")+
                labs(x = "Date",y = selected_metric)+
                theme_grey()
        }
        else {
            line_p <- ggplot()+
                geom_line(data=filter_data, aes(x=date,y=cumDeaths28DaysByDeathDate), colour="#6bb9fc")+
                labs(x = "Date",y = selected_metric)+
                theme_grey()
        }
        
        line_plotly_plot <- ggplotly(line_p, tooltip="text")
        
        return(line_plotly_plot)
    })
    
    # weekly change updates
    output$wekly_update <- renderPlotly({
        # define dictionary for mapping metrics to metric name
        h <- hash() 
        h[["New Cases"]] <- percent_increase_df$newCasesByPublishDate
        h[["New Deaths"]] <- percent_increase_df$newDeaths28DaysByPublishDate
        h[["Current Hospitalizations"]] <- percent_increase_df$hospitalCases
       
        selected_metric <- h[[input$metric_home]]
        
        # calculate group, label, and prefix columns based on the selected metric, to update the visualization
        percent_increase_df$group <- ifelse(selected_metric<0,"green",ifelse(selected_metric==0,"grey","red"))
        percent_increase_df$label_percent <- round(selected_metric, digits=0)
        percent_increase_df$pos <- ifelse(selected_metric==0,"~ ",
            ifelse(selected_metric>=10,"+",
                   ifelse(selected_metric<=-10,"",
                          ifelse(selected_metric>0,"+ ",
                                 ifelse(selected_metric<0," ","")))))   
            
        fig <- plot_ly()
        
        cities = c('Belfast','Birmingham', 'Bristol, City of','Cambridgeshire','Cardiff','City of Edinburgh','Glasgow City')
        i <- 1
        for (city in cities){
            # Shorten the city name for the tilte for Bristol and Edinburgh
            if (city=='Bristol, City of'){
                city_title<-'Bristol'
            }
            else if (city=='City of Edinburgh'){
                city_title<-'Edinburgh'
            }
            else{
                city_title<-city
            }
            
            fig <- fig %>%
                add_trace(
                    type = "indicator",
                    mode = "number",
                    value = (percent_increase_df %>% filter(areaName==city))$label_percent,
                    number = list(
                        prefix = (percent_increase_df %>% filter(areaName==city))$pos,
                        suffix="%", 
                        font=list(
                            color=(percent_increase_df %>% filter(areaName==city))$group)),
                            #size = 25)),
                    domain = list(x = c((i-1)/7+0.02, i/7-0.02)),
                    title =list(text = city_title,
                                font=list(
                                    color="black",
                                    size = 12))
                ) 
            i <- i+1
        }
        fig <- fig %>% layout(height = 175, title = paste("Relative Change in", input$metric_home, "from Last Week to This Week"))
        return(fig)
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


