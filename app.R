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
library(tidyr)
source("clean_data.R")


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
                    column(4,
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
                     actionButton("bristol_vac", "Bristol"),
                     actionButton("cambridge_vac", "Cambridge"),
                     actionButton("edinburgh_vac", "Edingburgh"),
                     actionButton("birmingham_vac", "Birmingham"),
                     actionButton("glasgow_vac", "Glasgow"),
                     actionButton("belfast_vac", "Belfast"),
                     actionButton("cardiff_vac", "Cardiff"),
                     fluidRow(
                         htmlOutput("vaccPage")
                         ),
                     fluidRow(
                         plotlyOutput("proportions")
                     ),
                     fluidRow(
                         plotlyOutput("time_vaccine_plot")
                     )
                 )
        )
        
        
    
))


homePage <- fluidPage(
    fluidRow(h3("Objective")),
    fluidRow(
        p("This dashboard provides Company X Executives, with key information and updates on
        the COVID-19 pandemic, specfically across UK cities Compnay X does business in. \n")),
    fluidRow(
        h3("Intended Use")),
    fluidRow(
        p("The dashboard can be used to monitor the current status of the pandemic 
        with respect to case counts and vaccination rates, targeted to just the cities of Intrest 
        for Company X. The information on this dashboard can help executives at Company X closely 
        monitor changes to make informed and efficient policy changes. The dashboard can also be 
        used for supporting longer term decisions around vaccine mandates acording to the Vaccination 
        Rates tab.")),
    fluidRow(
        h3("Weekly Update ")),
    fluidRow(
        p(" The figures below show the relative increase in the selected metric from last week to 
          this week. "))
    )

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

vaccPage <- fluidPage(
    titlePanel("Vaccination Rates"),
    fluidRow(
        p("This section is intended to provide an overview of the proportion of the population that is 
          vaccinated in each city, broken down by number of doses. A threshold of 80% of the population
          being vaccinated indicates a high vaccination rate (shown in green). The time series plot
          shows how vaccination rates have progressed over the course of the pandemic. Click a city name above
          to view the results. \n")
    )
)


# Define server logic ------------------------------------------------------------------------
server <- function(input, output) {
    # homepage text
    output$homePage <- renderUI(homePage)
    output$casePage <- renderUI(casePage)
    output$vaccPage <- renderUI(vaccPage)
    
    # case count plot
    output$map_plot <- renderPlotly({
        h <- hash() 
        h[["New Cases"]] <- last7days_df_summarize$newCasesByPublishDate
        h[["New Deaths"]] <- last7days_df_summarize$newDeaths28DaysByPublishDate
        h[["Current Hospitalizations"]] <- last7days_df_summarize$hospitalCases
        h[["Total Cases"]] <- last7days_df_summarize$cumCasesByPublishDate
        h[["Total Deaths"]] <- last7days_df_summarize$cumDeaths28DaysByDeathDate
        
        selected_city <- input$city
        selected_metric_name <- input$metric
        selected_metric <- h[[selected_metric_name]]
        selected_metric_name_tooltip <- ifelse(selected_metric_name=="New Cases","New Cases this week",
                                               ifelse(selected_metric_name=="New Deaths","New Deaths this week",selected_metric_name))
        
        last7days_df_summarize$selected = ifelse(last7days_df_summarize$areaName==selected_city,"1","2")
        
        world_map <- map_data("world")
        
        map_p <- ggplot() +
            geom_polygon(data = world_map,
                         aes(x = long, y = lat, group=group),
                         fill="lightgrey", colour = "white") +
            coord_fixed(ratio = 1.3,
                        xlim = c(-10,3),
                        ylim = c(50, 59)) +
            theme_void() +
            geom_point(data = last7days_df_summarize,
                       aes(x = as.numeric(long), y = as.numeric(lat),
                           size = selected_metric,
                           colour = selected,
                           text = paste("City:", areaName,
                                        "<br>", selected_metric_name_tooltip ,":", selected_metric))) +
            scale_color_manual(guide = "none",
                               values=c("#6bb9fc","black")) +
            scale_size_continuous(name=paste("Number of",selected_metric_name)) +
            theme(legend.position='right')+
            guides(color = "none") +
            ggtitle(paste(selected_metric_name_tooltip, "by City")) +
            theme(axis.ticks = element_blank(),
                  panel.background = element_rect(fill = "transparent",colour = NA),
                  title = element_text(colour = "#55595c",
                                       size = 10),
                  axis.line = element_blank(),
                  panel.grid = element_blank())
        
        map_plotly_plot <- ggplotly(map_p, tooltip="text")%>%
            layout(showlegend = FALSE) %>% 
            config(displayModeBar = F)
    
        return(map_plotly_plot)
    })
    
    # case count map legend - ggplotly does not support bubble size legends currently
    # so I needed to make a separate plot of just the legend and render it as a plot not plotly
    output$map_plot_legend <- renderPlot({
        h <- hash() 
        h[["New Cases"]] <- last7days_df_summarize$newCasesByPublishDate
        h[["New Deaths"]] <- last7days_df_summarize$newDeaths28DaysByPublishDate
        h[["Current Hospitalizations"]] <- last7days_df_summarize$hospitalCases
        h[["Total Cases"]] <- last7days_df_summarize$cumCasesByPublishDate
        h[["Total Deaths"]] <- last7days_df_summarize$cumDeaths28DaysByDeathDate
        
        selected_city <- input$city
        selected_metric_name <- input$metric
        selected_metric <- h[[selected_metric_name]]
        
        last7days_df_summarize$selected = ifelse(last7days_df_summarize$areaName==selected_city,"1","2")
        
        world_map <- map_data("world")

        map_p <- ggplot() +
            geom_point(data = last7days_df_summarize, 
                       aes(x = as.numeric(long), 
                           y = as.numeric(lat), 
                           size = selected_metric,
                           colour = selected))+
            scale_size_continuous(name=selected_metric_name) +
            scale_color_manual(guide = "none",
                               values=c("#6bb9fc","black"))+ 
            theme(panel.background = element_rect(fill = "transparent",colour = NA))+
            theme_void() 
        
        legend <- cowplot::get_legend(map_p)
        return(ggdraw(legend))
    }, height = 150)
    
    
    # second plot on case update page
    output$case_line_plot <- renderPlotly({
        selected_city <- input$city
        start_date <- input$date_range[1]
        end_date <- input$date_range[2]
        
        filter_data <- all_cities_df %>% 
            filter(areaName == selected_city,
                   date >= start_date,
                   date <= end_date) 
        
        h <- hash() 
        h[["New Cases"]] <- filter_data$newCasesByPublishDate
        h[["New Deaths"]] <- filter_data$newDeaths28DaysByPublishDate
        h[["Current Hospitalizations"]] <- filter_data$hospitalCases
        h[["Total Cases"]] <- filter_data$cumCasesByPublishDate
        h[["Total Deaths"]] <- filter_data$cumDeaths28DaysByDeathDate
        
        selected_metric_name <- input$metric
        selected_metric <- h[[selected_metric_name]]
        
        
        line_p <- ggplot()+
            geom_line(data=filter_data, aes(x=date,y=selected_metric), colour="#6bb9fc") + 
            labs(x = "Date",y = selected_metric_name)+
            theme_grey() +
            ggtitle(paste(selected_metric_name, "in", selected_city)) +
            theme(title = element_text(colour = "#55595c",
                                       size = 10))
        
        line_plotly_plot <- ggplotly(line_p, tooltip="text") %>% 
            config(displayModeBar = F)
        
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
        percent_increase_df$group <- ifelse(selected_metric<0,"#006400",ifelse(selected_metric==0,"grey","#B22222"))
        percent_increase_df$label_percent <- round(selected_metric, digits=0)
        percent_increase_df$pos <- ifelse(selected_metric==0,"~",ifelse(selected_metric>0,"+",""))
            
        fig <- plot_ly()
        
        cities = c('Belfast','Birmingham', 'Bristol, City of','Cambridgeshire','Cardiff','City of Edinburgh','Glasgow City')
        i <- 1
        for (city in cities){
            # Shorten the city name for the title for Bristol and Edinburgh
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
                            color=(percent_increase_df %>% filter(areaName==city))$group,
                            size = 25)),
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
        shown("Bristol, City of")
    })
    observeEvent(input$cambridge_vac, {
        shown("Cambridgeshire")
    })
    observeEvent(input$edinburgh_vac, {
        shown("City of Edinburgh")
    })
    observeEvent(input$birmingham_vac, {
        shown("Birmingham")
    })
    observeEvent(input$glasgow_vac, {
        shown("Glasgow City")
    })
    observeEvent(input$belfast_vac, {
        shown("Belfast")
    })
    observeEvent(input$cardiff_vac, {
        shown("Cardiff")
    })
    output$proportions <- renderPlotly({
        city <- shown()
        if (!is.null(city)) {
            first_dose_percentage = "NA"
            second_dose_percentage = "NA"
            third_dose_percentage = "NA"
            if (city != "Belfast" && city != "Cardiff") {
                proportion <- all_cities_df %>%
                    filter(areaName==city) %>%
                    tail(1)
                first_dose_percentage = proportion$first_dose
                second_dose_percentage = proportion$second_dose
                third_dose_percentage = proportion$third_dose
            }
            first_dose = paste0("1st Dose: \n", first_dose_percentage, "%") 
            second_dose = paste0("2nd Dose: \n", second_dose_percentage, "%")
            third_dose = paste0("3rd Dose: \n", third_dose_percentage, "%")
            colors = c("General(<=80%)", "General(<=80%)", "General(<=80%)")
            if (first_dose_percentage != "NA") {
                for (i in 1:3) {
                    check = first_dose_percentage
                    if (i == 2) {
                        check = second_dose_percentage
                    }
                    if (i == 3) {
                        check = third_dose_percentage
                    }
                    # If the proportion > 80%, then the color would be green 
                    if (check > 80) {
                        colors[i] = "High(>80%)"
                    }
                }
            }
            
            eg <- tribble(
                ~x, ~y, ~size, 
                "1st Dose", 1, 4, 
                "2nd Dose", 1, 8, 
                "3rd Dose", 1, 12,
            )
            eg$x1 = colors
          
                  
            # Color, discrete
            plot <- ggplot(eg, aes(x = x, y = y, color = x1)) +
                ggtitle(paste("Current Vaccination Rates in", city)) +
                geom_point(size=60)+
                guides(color = FALSE) +
                theme(title = element_text(colour = "#55595c",
                                           size = 10),
                      axis.text = element_blank(),
                      axis.title.x = element_blank(),
                      axis.title.y = element_blank(),
                      axis.ticks = element_blank(),
                      panel.background = element_rect(fill = "transparent",colour = NA)) +
                annotate("text", x = 1, y=1, label=first_dose, colour='white', size=5) +
                annotate("text", x = 2, y=1, label=second_dose, colour='white', size=5) +
                annotate("text", x = 3, y=1, label=third_dose, colour='white', size=5) +
                scale_color_manual(guide = "none",
                               values=c("#B22222","#006400")) 
            plot <- ggplotly(plot) %>% config(displayModeBar = F)
            return (plot)
        }
    })
    output$time_vaccine_plot <- renderPlotly({
        city <- shown()
        if (!is.null(city)) {
            time_df <- all_cities_df %>%
                filter(areaName == city) %>%
                select(date, first_dose, second_dose, third_dose) %>%
                gather(key = "variable", value = "value", -date)

            if (city == "Belfast" || city == "Cardiff") {
                time_df$value = NA
            }
            p <- ggplot(time_df, aes(x=date, y=value))+ 
                ggtitle(paste("Time Series Plot for Vaccination Rates in", city)) +
                ylab("Proportion of Population (%)") +
                xlab("Date") +
                geom_line(aes(color = variable))+ 
                theme_grey()+
                theme(title = element_text(colour = "#55595c",
                                           size = 10),
                      axis.title.x = element_text(colour = "#55595c"),
                      axis.title.y = element_text(colour = "#55595c"),
                      axis.ticks = element_line()) +
                scale_color_manual(guide = "none",
                                   values=c("#8cc5fd","#0379b7", "#001544"))
                
            return (p)
        }
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)


