# 📈 AAPL Time Series Forecasting (ARIMA, ETS, TSLM)

This project demonstrates time series forecasting using multiple models on Apple Inc. (AAPL) stock price data. The analysis includes hyperparameter tuning, cross-validation, model evaluation, and visual comparison of forecasts.

## 🧠 Project Summary

The goal of this project was to:
- Clean and preprocess historical stock data
- Aggregate data to a monthly frequency
- Build and compare multiple forecasting models (ARIMA, ETS, TSLM, Naive, Mean)
- Perform hyperparameter tuning using AICc
- Validate model performance with time series cross-validation
- Forecast future stock prices and compare visual predictions

## 🔧 Tools & Libraries Used
- R
- `forecast`, `tseries`, `zoo`, `ggplot2`, `tsibble`, `lubridate`, `slider`, `tidyverse`

## 📊 Models Applied
- **ARIMA (Auto and Manual Tuning)**
- **ETS (Auto, Additive, Multiplicative)**
- **Naive Forecast**
- **Mean Forecast**
- **TSLM (Time Series Linear Model)**

## 🧪 Techniques Included
- Time series cross-validation (`tsCV`)
- Mean Squared Error (MSE) evaluation
- Forecast accuracy comparison across models
- Visual forecasting using `autoplot` + `autolayer`

## 📁 Dataset
- **AAPL_dataset.csv**  
  Daily stock price data with date and close price columns.
  
  *(Note: File path in script may need updating depending on your local system.)*

## 📈 Output
- Forecast plots with confidence intervals
- Tabular performance metrics for all models
- AICc values to determine optimal models

## 🚀 Getting Started
1. Clone this repo
2. Make sure you have all the listed R packages installed
3. Adjust the file path to the CSV in the R script
4. Run `Final Project(Tuning and cross).R` to reproduce results

---

> 🧪 *This is a basic academic project done during my university coursework. While simple in scope, it helped build a strong foundation in time series analysis and forecasting in R.*

