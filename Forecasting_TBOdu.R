############################################
## (Forecasting)
# Modelling and Forecasting of Construction cost - multivariate modelling
################################
# 1.0 Start ------
# Clear all
rm(list=ls()) 
graphics.off() #Closing all previously open graphs

#####################################
## Set work directory
#setwd("D:/Software_Application/Data_a/Learn_R/Project_21_Tawa")

setwd("C:/Users/tbodu/Desktop/Software_Application/Data_a/Learn_R/Project_21_Tawa")
getwd()

# 2.0 load Libraries ------
# Main library

#Preprocessing
library(recipes)

# Time series
library(lubridate)
library(tsibble)

# EDA
library(DataExplorer)

# visualization
library(plotly)
library(ggcorrplot)

# Core
library(tidyverse)
library(timetk)
library(modeltime)
library(tidymodels)
library(zoo)
library(dint)

# Read Data
mydata <- read_csv("6_Tawa_data.csv")

mydata1 <- mydata 

mydata <- mydata %>% 
  select(Time, Time_A, TPI, HPI, INT, UR, CPI, COI, POP)

mydata <- janitor::clean_names(mydata)

mydata$time_a <- mdy(mydata$time_a)

mydata_tsbl <- mydata %>% 
  select(time_a, tpi, hpi, int, ur, cpi, coi, pop) %>% 
  rename(date = time_a) %>% 
  as_tsibble(index = date)

mydata_tsbl %>%  tail() %>% glimpse()  

mydata_tsbl11 <- mydata_tsbl


# Time series preprocessing
preprocess_01_rec <- recipe(tpi ~., data = mydata_tsbl) %>% 
  step_normalize(all_numeric()) %>% 
  step_lag(tpi, lag = 1:4) %>% 
  step_lag(hpi, lag = 1:4) %>%
  step_lag(int, lag = 1:4) %>%
  step_lag(ur, lag = 1:4) %>%
  step_lag(cpi, lag = 1:4) %>%
  step_lag(coi, lag = 1:4) %>%
  step_lag(pop, lag = 1:4) %>%
  step_rm(hpi, int, ur, cpi, coi, pop) %>% 
  step_naomit(all_predictors()) %>% 
  prep()
  
mydata_tsbl1 <-  bake(preprocess_01_rec, mydata_tsbl) %>% 
  as_tsibble(index = date) %>% 
  select(date, tpi, everything())


### 7.0 LAG plots----
lag_plot <-  function(data, col_match){
  mydata_tsbl1 %>% 
    select(tpi, contains(col_match)) %>% 
    as_tibble() %>% 
    select(-date) %>% 
    pivot_longer(-tpi, names_to = "lag", values_to = col_match, names_repair = "unique") %>% 
    mutate(lag = as_factor(lag)) %>% 
    
    ggplot(aes_string(names(.)[[3]], names(.)[[1]])) +
    geom_point(alpha = 0.5) +
    facet_wrap(~ lag) +
    labs(x = col_match, y = "tpi")
}

# tpi - Lag 1 and lag 2
mydata_tsbl1 %>% lag_plot("tpi") + geom_smooth() 

# HPI - lag2
mydata_tsbl1 %>% lag_plot("hpi") + geom_smooth() 

# INT No relationship
mydata_tsbl1 %>% lag_plot("int") + geom_smooth() 

# UR No relationship
mydata_tsbl1 %>% lag_plot("ur") + geom_smooth() 

# CPI  No relationship
mydata_tsbl1 %>% lag_plot("cpi") + geom_smooth() 

# Coi No relationship
mydata_tsbl1 %>% lag_plot("coi") + geom_smooth() 

# pop lag 1
mydata_tsbl1 %>% lag_plot("pop") + geom_smooth() 

# 8.0 Refine Recipe -----
preprocess_02_rec <- recipe(tpi ~., data = mydata_tsbl) %>% 
  step_normalize(all_numeric()) %>% 
  step_lag(tpi, lag = 1) %>% 
  step_lag(hpi, lag = 2) %>% 
  step_lag(coi, lag = 1) %>% 
  step_lag(pop, lag = 1) %>% 
  step_rm(hpi, int, ur, cpi, coi, pop) %>% 
  step_naomit(all_predictors()) %>% 
  prep()

mydata_tsbl2 <-  bake(preprocess_02_rec, mydata_tsbl) %>% 
  as_tsibble(index = date) %>% 
  select(date, tpi, everything())

g <- mydata_tsbl2 %>% 
  as_tibble() %>% 
  select(-date) %>% 
  cor() %>% 
  ggcorrplot(hc.order = TRUE, type = "lower",
             lab = TRUE)

ggplotly(g)


preprocess_03_rec <- recipe(tpi ~., data = mydata_tsbl) %>% 
  step_lag(tpi, lag = 1) %>% 
  step_lag(hpi, lag = 2) %>% 
  step_lag(coi, lag = 1) %>% 
  step_lag(pop, lag = 1) %>% 
  step_rm(hpi, int, ur, cpi, coi, pop) %>% 
  step_naomit(all_predictors()) %>% 
  prep()


mydata_tsbl3 <-  bake(preprocess_03_rec, mydata_tsbl) %>% 
  as_tsibble(index = date) %>% 
  select(date, tpi, everything())

mydata_tsbl4 <- as_tibble(mydata_tsbl3)

mydata_tsbl4 <- mydata_tsbl4 %>% 
  rename(value = tpi)

##
# Train and test 
splits <- mydata_tsbl4 %>% 
  time_series_split(assess = 8, cumulative = TRUE)

splits %>% 
  tk_time_series_cv_plan() %>% 
  plot_time_series_cv_plan(date, value)

### Models
# Recipe
recipe_spec_1 <- recipe(value~., training(splits)) %>% 
  step_normalize(all_numeric(), -value)
  
recipe_spec_1 %>% prep() %>% juice() %>% glimpse() 

recipe_spec_2 <- recipe_spec_1 %>% 
  update_role(date, new_role = "ID")

recipe_spec_2 %>% prep() %>%  summary() 

# Models
 
wflw_fit_lm <-  workflow() %>% 
  add_model(
    linear_reg() %>% set_engine("lm")
    ) %>% 
  add_recipe(recipe_spec_2) %>% 
  fit(training(splits))

wflw_fit_nn <- workflow() %>% 
  add_model(
    mlp() %>% set_engine("nnet")
  ) %>% 
  add_recipe(recipe_spec_2) %>% 
  fit(training(splits))

#### Assessing forecast
#  
models_tbl <-  modeltime_table(
  wflw_fit_lm,
  wflw_fit_nn
)

models_tbl

# Calibrate testing data
calibration_tbl <- models_tbl %>%
  modeltime_calibrate(testing(splits))

# Measure test accuracy
calibration_tbl %>%
  modeltime_accuracy() 

calibration_tbl %>% 
  modeltime_forecast(
    new_data = testing(splits),
    actual_data = mydata_tsbl4,
    keep_data = TRUE,
      ) %>% 
  plot_modeltime_forecast(.legend_show = F)


# Extract model forecast
a_lm <-  calibration_tbl$.calibration_data[[1]]
b_nn <- calibration_tbl$.calibration_data[[2]]

a_lm <-  a_lm %>% 
  rename(actual = .actual) %>% 
  rename(forecast_lm = .prediction)

b_nn <- b_nn %>% 
  rename(actual = .actual) %>% 
  rename(forecast_nn = .prediction) %>% 
  select(date, forecast_nn)
  

b_df <- full_join(a_lm, b_nn, by = "date")

b_df <- b_df %>% 
  select(-.residuals)

write.csv(b_df, file = "1_multi-forecast.csv", row.names = TRUE, fileEncoding = "UTF-8")



final_data <- b_df


final_data %>% 
  ggplot(aes(x=date)) +
  geom_line(aes(y=actual), color= "blue1") +
  geom_line(aes(y= forecast_lm), color= "red3") +
  geom_line(aes(y=  forecast_nn), color = "green1") +
  labs(title = "Comparison of actual share value against forecast from two models", 
       subtitle = "From first quarter 2020 Until fourth quarter 2021",
       x = "Time", y = "Share price (?)") +
  theme(legend.title = element_text(family = "Times", face = "bold", size = 10)) +
  theme(legend.title = element_text(family = "Times", size = 8)) +
  theme(axis.title = element_text(family = "Times", face = "bold", size = 25),
        axis.text = element_text(family = "Times", size = 20)) +
  theme(plot.title = element_text(family = "Times", face = "bold", size = 25), 
        plot.subtitle = element_text(family = "Times", face = "bold", size = 20),
        plot.caption = element_text(family = "Times", face = "bold", size = 15),
        panel.grid = element_blank()) 


df <- final_data %>% 
  gather(key = "variable", value = "value", -date)

theme_set(theme_bw())


p <-  ggplot(final_data, aes(x = date)) +
  geom_line(aes(y = actual, colour = "Actual")) +
  geom_line(aes(y = forecast_lm, colour = "Linear regression")) +
  geom_line(aes(y = forecast_nn, colour = "Neural network")) +
  scale_colour_manual(values = c("blue", "red", "orange")) +
  labs(y = "Share price (?)", x = "Time", colour = "Legend") +
  theme(legend.position = c(0.3, 0.85)) +
  theme(legend.title = element_text(family = "Times", face = "bold", size = 10)) +
  theme(legend.title = element_text(family = "Times", size = 8)) +
  theme(axis.title = element_text(family = "Times", face = "bold", size = 25),
        axis.text = element_text(family = "Times", size = 20)) +
  theme(plot.title = element_text(family = "Times", face = "bold", size = 30), 
        plot.subtitle = element_text(family = "Times", face = "bold", size = 25),
        plot.caption = element_text(family = "Times", face = "bold", size = 15),
        panel.grid = element_blank()) 


p


library(svglite)

ggsave(file="2_Scatter.svg", plot=p, width=10, height=10)


