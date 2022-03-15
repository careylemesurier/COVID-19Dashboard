library(readr)
library(dplyr)

# load our data -----------------------------------------------------------
# national level statistics  ----------------------------------------------
scotland_df <- read_csv('data/scotland.csv')
england_df <- read_csv('data/england.csv')
wales_df <- read_csv("data/wales.csv")
north_df <- read_csv("data/north_ireland.csv")

# city level statistics  ---------------------------------------------------
# vaccine data  -----------------------------------------------------------
edinburgh_vac_df <- read_csv("data/edinburgh_vac.csv") 
birmingham_vac_df <- read_csv("data/birmingham_vac.csv")
bristol_vac_df <- read_csv("data/bristol_vac.csv")
cambridge_vac_df <- read_csv("data/cambridge_vac.csv")
glasgow_vac_df <- read_csv("data/glasgow_vac.csv")
# General data and merge -----------------------------------------------------------
belfast_df <- read_csv("data/belfast.csv")
belfast_df <- merge(belfast_df[, !names(belfast_df) %in% c('hospitalCases')], select(north_df, c('date','hospitalCases')), by='date') 
belfast_df <- belfast_df %>%
  mutate(first_dose = NA) %>%
  mutate(second_dose = NA) %>%
  mutate(third_dose = NA)

cardiff_df <- read_csv("data/cardiff.csv")
cardiff_df <- merge(cardiff_df[, !names(cardiff_df) %in% c('hospitalCases')], select(wales_df, c('date','hospitalCases')), by='date')
names(cardiff_df)[names(cardiff_df) == 'cumDeaths28DaysByPublishDate'] <- 'cumDeaths28DaysByDeathDate'
cardiff_df <- cardiff_df%>%
  mutate(first_dose = NA) %>%
  mutate(second_dose = NA) %>%
  mutate(third_dose = NA)

edinburgh_df <- read_csv("data/edinburgh.csv") %>%
  merge(edinburgh_vac_df) %>%
  mutate(first_dose = cumVaccinationFirstDoseUptakeByVaccinationDatePercentage) %>%
  mutate(second_dose = cumVaccinationSecondDoseUptakeByVaccinationDatePercentage) %>%
  mutate(third_dose = cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage) %>%
  select(-cumVaccinationFirstDoseUptakeByVaccinationDatePercentage, 
         -cumVaccinationSecondDoseUptakeByVaccinationDatePercentage, -cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage)
edinburgh_df <- merge(edinburgh_df[, !names(edinburgh_df) %in% c('hospitalCases')], select(scotland_df, c('date','hospitalCases')), by='date')

birmingham_df <- read_csv("data/birmingham.csv") %>%
  merge(birmingham_vac_df) %>%
  mutate(first_dose = cumVaccinationFirstDoseUptakeByVaccinationDatePercentage) %>%
  mutate(second_dose = cumVaccinationSecondDoseUptakeByVaccinationDatePercentage) %>%
  mutate(third_dose = cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage) %>%
  select(-cumVaccinationFirstDoseUptakeByVaccinationDatePercentage, 
         -cumVaccinationSecondDoseUptakeByVaccinationDatePercentage, -cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage)
birmingham_df <- merge(birmingham_df[, !names(birmingham_df) %in% c('hospitalCases')], select(england_df, c('date','hospitalCases')), by='date')

bristol_df <- read_csv("data/bristol.csv") %>%
  merge(bristol_vac_df) %>%
  mutate(first_dose = cumVaccinationFirstDoseUptakeByVaccinationDatePercentage) %>%
  mutate(second_dose = cumVaccinationSecondDoseUptakeByVaccinationDatePercentage) %>%
  mutate(third_dose = cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage) %>%
  select(-cumVaccinationFirstDoseUptakeByVaccinationDatePercentage, 
         -cumVaccinationSecondDoseUptakeByVaccinationDatePercentage, -cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage)
bristol_df <- merge(bristol_df[, !names(bristol_df) %in% c('hospitalCases')], select(england_df, c('date','hospitalCases')), by='date')

cambridge_df <- read_csv("data/cambridge.csv") %>%
  merge(cambridge_vac_df) %>%
  mutate(first_dose = cumVaccinationFirstDoseUptakeByVaccinationDatePercentage) %>%
  mutate(second_dose = cumVaccinationSecondDoseUptakeByVaccinationDatePercentage) %>%
  mutate(third_dose = cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage) %>%
  select(-cumVaccinationFirstDoseUptakeByVaccinationDatePercentage, 
         -cumVaccinationSecondDoseUptakeByVaccinationDatePercentage, -cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage)
cambridge_df <- merge(cambridge_df[, !names(cambridge_df) %in% c('hospitalCases')], select(england_df, c('date','hospitalCases')), by='date')

glasgow_df <- read_csv("data/glasgow.csv") %>%
  merge(glasgow_vac_df) %>%
  mutate(first_dose = cumVaccinationFirstDoseUptakeByVaccinationDatePercentage) %>%
  mutate(second_dose = cumVaccinationSecondDoseUptakeByVaccinationDatePercentage) %>%
  mutate(third_dose = cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage) %>%
  select(-cumVaccinationFirstDoseUptakeByVaccinationDatePercentage, 
         -cumVaccinationSecondDoseUptakeByVaccinationDatePercentage, -cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage)
glasgow_df <- merge(glasgow_df[, !names(glasgow_df) %in% c('hospitalCases')], select(scotland_df, c('date','hospitalCases')), by='date')

# change date columns to date type
cities <- list(belfast_df, cardiff_df, edinburgh_df, birmingham_df, bristol_df, cambridge_df, glasgow_df)
for (city_df in cities){
  city_df <- city_df %>%
    mutate(date = as.Date(date, format= "%Y-%m-%d"))
}


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
all_cities_df <- birmingham_df[0,]

# Initialize variables for today and one week prior
today <- min(max(birmingham_df$date), max(bristol_df$date), max(cambridge_df$date), 
             max(edinburgh_df$date), max(belfast_df$date), max(glasgow_df$date), max(cardiff_df$date))
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
  filtered_data$first_dose <- replaceNa(filtered_data$first_dose)
  filtered_data$second_dose <- replaceNa(filtered_data$second_dose)
  filtered_data$third_dose <- replaceNa(filtered_data$third_dose)
  
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
today <- max(birmingham_df$date)
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

