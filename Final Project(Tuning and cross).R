# Load necessary libraries
library(lubridate)
library(ggplot2)
library(forecast)
library(tseries)
library(zoo)
library(tidyverse)
library(tsibble)
library(slider)

# Load the dataset
file_path <- "C:/Users/Abhiram/Desktop/Drexel/SEM 3/Time Series/AAPL_dataset.csv"
data <- read.csv(file_path)

# Convert the date column to Date
data$date <- as.Date(data$date)

# Remove rows with NA dates if any
data <- data[!is.na(data$date), ]

# Ensure the data is sorted by date
data <- data[order(data$date), ]

# Create a zoo object with the date as the index
zoo_data <- zoo(data$close, order.by = data$date)

# Aggregate the data to monthly using the mean or last value
monthly_data <- aggregate(zoo_data, as.yearmon, mean)  # Using mean, alternatively use "last" for last closing price of each month

# Convert the zoo object to a ts object with monthly frequency
start_year <- year(start(monthly_data))
start_month <- month(start(monthly_data))
ts_data <- ts(coredata(monthly_data), start = c(start_year, start_month), frequency = 12)

# Split the data into training (80%) and holdout (20%) sets, but ensure at least 24 points in training set
train_size <- max(floor(0.8 * length(ts_data)), 24)
train_end <- c(start_year + floor((start_month + train_size - 1) / 12), (start_month + train_size - 1) %% 12 + 1)
holdout_start <- c(start_year + floor((start_month + train_size) / 12), (start_month + train_size) %% 12 + 1)
train_data <- window(ts_data, end = train_end)
holdout_data <- window(ts_data, start = holdout_start)

# Ensure both forecast and holdout data have the same frequency and starting point
holdout_ts <- ts(as.numeric(holdout_data), start = start(holdout_data), frequency = frequency(holdout_data))

# Hyperparameter tuning using AICc
arima_auto_fit <- auto.arima(train_data, ic = "aicc")

# Time series cross-validation
arima_cv_errors <- tsCV(train_data, forecastfunction = function(x) forecast(auto.arima(x, ic = "aicc"), h = 12), h = 12)

# Calculate mean squared error of the cross-validation errors
arima_cv_mse <- mean(arima_cv_errors^2)
print(paste("ARIMA CV MSE:", arima_cv_mse))

# Time series cross-validation for ETS
ets_cv_errors <- tsCV(train_data, forecastfunction = function(x) forecast(ets(x), h = 12), h = 12)

# Calculate mean squared error of the cross-validation errors
ets_cv_mse <- mean(ets_cv_errors^2)
print(paste("ETS CV MSE:", ets_cv_mse))



# Fit ARIMA models
arima_auto_fit <- auto.arima(train_data)
arima_manual_fit1 <- Arima(train_data, order = c(2,1,2), seasonal = c(1,1,1))
arima_manual_fit2 <- Arima(train_data, order = c(3,1,3), seasonal = c(0,1,1))

# Generate forecasts using the ARIMA models
arima_forecast_auto <- forecast(arima_auto_fit, h = length(holdout_data) + 12)
arima_forecast_manual1 <- forecast(arima_manual_fit1, h = length(holdout_data) + 12)
arima_forecast_manual2 <- forecast(arima_manual_fit2, h = length(holdout_data) + 12)

# Evaluate forecast accuracy for ARIMA models
arima_accuracy_auto <- accuracy(arima_forecast_auto, holdout_ts)
arima_accuracy_manual1 <- accuracy(arima_forecast_manual1, holdout_ts)
arima_accuracy_manual2 <- accuracy(arima_forecast_manual2, holdout_ts)

# Calculate AICc values for ARIMA models
aicc_arima_auto <- arima_auto_fit$aicc
aicc_arima_manual1 <- arima_manual_fit1$aicc
aicc_arima_manual2 <- arima_manual_fit2$aicc

print("ARIMA Auto Model Accuracy:")
print(arima_accuracy_auto)
print(paste("AICc:", aicc_arima_auto))

print("ARIMA Manual Model 1 Accuracy:")
print(arima_accuracy_manual1)
print(paste("AICc:", aicc_arima_manual1))

print("ARIMA Manual Model 2 Accuracy:")
print(arima_accuracy_manual2)
print(paste("AICc:", aicc_arima_manual2))

# Fit ETS models
ets_auto_fit <- ets(train_data)
ets_additive_fit <- ets(train_data, model = "AAN")
ets_multiplicative_fit <- ets(train_data, model = "MAM")

# Generate forecasts using the ETS models
ets_forecast_auto <- forecast(ets_auto_fit, h = length(holdout_data) + 12)
ets_forecast_additive <- forecast(ets_additive_fit, h = length(holdout_data) + 12)
ets_forecast_multiplicative <- forecast(ets_multiplicative_fit, h = length(holdout_data) + 12)

# Evaluate forecast accuracy for ETS models
ets_accuracy_auto <- accuracy(ets_forecast_auto, holdout_ts)
ets_accuracy_additive <- accuracy(ets_forecast_additive, holdout_ts)
ets_accuracy_multiplicative <- accuracy(ets_forecast_multiplicative, holdout_ts)

# Calculate AICc values for ETS models
aicc_ets_auto <- ets_auto_fit$aicc
aicc_ets_additive <- ets_additive_fit$aicc
aicc_ets_multiplicative <- ets_multiplicative_fit$aicc

print("ETS Auto Model Accuracy:")
print(ets_accuracy_auto)
print(paste("AICc:", aicc_ets_auto))

print("ETS Additive Model Accuracy:")
print(ets_accuracy_additive)
print(paste("AICc:", aicc_ets_additive))

print("ETS Multiplicative Model Accuracy:")
print(ets_accuracy_multiplicative)
print(paste("AICc:", aicc_ets_multiplicative))

# Fit Naive model
naive_fit <- naive(train_data, h = length(holdout_data) + 12)
naive_forecast <- forecast(naive_fit, h = length(holdout_data) + 12)

# Evaluate forecast accuracy
naive_accuracy <- accuracy(naive_forecast, holdout_data)
print("Naive Model Accuracy:")
print(naive_accuracy)

# Fit Mean model
mean_fit <- meanf(train_data, h = length(holdout_data) + 12)
mean_forecast <- forecast(mean_fit, h = length(holdout_data) + 12)

# Evaluate forecast accuracy
mean_accuracy <- accuracy(mean_forecast, holdout_data)
print("Mean Model Accuracy:")
print(mean_accuracy)

# Fit TSLM model
tslm_fit <- tslm(train_data ~ trend + season)
tslm_forecast <- forecast(tslm_fit, h = length(holdout_data) + 12)

# Evaluate forecast accuracy
tslm_accuracy <- accuracy(tslm_forecast, holdout_data)
print("TSLM Model Accuracy:")
print(tslm_accuracy)

# Plot and compare actual vs forecasted data including future predictions
autoplot(window(ts_data, start = start(train_data))) +
  autolayer(arima_forecast_auto, series = "ARIMA Auto", PI = TRUE) +
  autolayer(arima_forecast_manual1, series = "ARIMA Manual 1", PI = TRUE) +
  autolayer(arima_forecast_manual2, series = "ARIMA Manual 2", PI = TRUE) +
  autolayer(ets_forecast_auto, series = "ETS Auto", PI = TRUE) +
  autolayer(ets_forecast_additive, series = "ETS Additive", PI = TRUE) +
  autolayer(ets_forecast_multiplicative, series = "ETS Multiplicative", PI = TRUE) +
  autolayer(naive_forecast, series = "Naive Forecast", PI = TRUE) +
  autolayer(mean_forecast, series = "Mean Forecast", PI = TRUE) +
  autolayer(tslm_forecast, series = "TSLM Forecast", PI = TRUE) +
  autolayer(holdout_data, series = "Actual Data") +
  labs(title = "Comparison of Forecasts with Future Predictions", x = "Date", y = "Close Price") +
  theme_minimal()

