# "Crude Price and Production Forecasting for Strategic Planning" Project

# 1) Downloading and Cleaning WTI Crude Prices Data

# Installing and loading packages
install.packages("readxl")
install.packages("dplyr")
install.packages("lubridate")
install.packages("ggplot2")
library(readxl)
library(dplyr)
library(lubridate)
library(ggplot2)

# Defining the URL and downloading file
url = "https://www.eia.gov/dnav/pet/hist_xls/RWTCd.xls"
destfile="/Users/admin/data/wti_prices.xls"

if(!dir.exists("data")) dir.create("data")
download.file(url, destfile, mode="wb")

# Read Excel sheet with actual data (sheet "Data 1")
data_raw = read_excel(destfile,sheet="Data 1", skip=2)

# Cleaning and formatting
wti_data = data_raw %>%
  rename(Date=1,Price=2) %>%
  filter(!is.na(Price)) %>%
  mutate(Date=as.Date(Date)) %>%
  arrange(Date)

# Quick plot
ggplot(wti_data, aes(x=Date,y=Price)) +
  geom_line(color="darkblue") + 
  labs(title="WTI Crude Oil Prices", x="Date", y="Price (USD/barrel)") +
  theme_minimal()


# 2) Downloading and Cleaning Production Data
prod_url = "https://www.eia.gov/dnav/pet/xls/PET_CRD_CRPDN_ADC_MBBL_M.xls"
prod_dest = "data/production_volume.xls"
download.file(prod_url, prod_dest)

# Loading sheet "Data 1", skipping the first 2 header rows
raw_prod = read_excel("/Users/admin/data/production_volume.xls", sheet="Data 1", skip=2)
str(raw_prod$Date) #Checking Date format

# Cleaning and converting data
prod_data = raw_prod %>%
  select(Date=1, Production=2) %>%
  filter(!is.na(Production)) %>%
  mutate(
    Date = as.Date(Date),
    Production=as.numeric(Production)
  ) %>%
  arrange(Date)

# Plot
ggplot(prod_data, aes(x=Date, y=Production)) +
  geom_line(color="firebrick") +
  labs(title="U.S. Monthly Crude Oil Production", x="Date", y="Production (Thousand Barrels)") +
  theme_minimal()

# Price (wti_data) and Production (prod_data) indicators will be forecasted separately, and then joined briefly to run correlation analysis


# 3) Exploratory Data Analysis (EDA)

# EDA on WTI Crude Oil Price
install.packages("zoo")
library(zoo)

# Line Chart of WTI Prices
ggplot(wti_data, aes(x=Date,y=Price)) +
  geom_line(color="gold") + 
  labs(title="WTI Crude Oil Prices", x="Date", y="Price (USD/barrel)") +
  theme_minimal()

# Rolling Average (12-month)
wti_data = wti_data %>%
  mutate(RollingAvg = rollmean(Price, k=12, fill=NA, align="right"))

ggplot(wti_data, aes(x=Date)) +
  geom_line(aes(y=Price),color="steelblue", alpha=0.5) +
  geom_line(aes(y=RollingAvg), color="darkred", size=1) +
  labs(title="WTI Crude Oil Price with 12-Month Rolling Average",
       y="Price (USD/barrel)") +
  theme_minimal()


# Price Volatility (Monthly Change)
wti_data = wti_data %>%
  mutate(MonthlyChange=Price-lag(Price))

ggplot(wti_data, aes(x=Date, y=MonthlyChange)) +
  geom_line(color="darkorange") +
  labs(title="Monthly Change in WTI Crude Price", y="Change in Price (USD)") +
  theme_minimal()

# Histogram of Monthly Price Changes
ggplot(wti_data, aes(x=MonthlyChange)) +
  geom_histogram(binwidth=2, fill="skyblue", color="black") +
  labs(title="Distribution of Monthly WTI Price Changes", x="Change in Price (USD)") +
  theme_minimal()

# Augmented Dickey-Fuller Test (Stationarity Check)
install.packages("tseries")
library(tseries)
adf.test(na.omit(wti_data$Price))
# p-value is 0.09, meaning that time series is non-stationary, needs differencing before modeling

# Seasonality and Autocorrelation
install.packages("forecast")
library(forecast)
library(ggplot2)
library(dplyr)
# Converting WTI Prices to Time Series Object
wti_ts = ts(wti_data$Price, start=c(year(min(wti_data$Date)),month(min(wti_data$Date))), frequency=250)
# Decomposing time series
decomp_wti=stl(wti_ts, s.window="periodic")
autoplot(decomp_wti) +
  labs(title="STL Decomposition of WTI Crude Oil Prices")
# ACF and PACF Plots
par(mfrow=c(1,2)) # 2 plots side by side
acf(wti_ts, main="ACF - Crude Price")
pacf(wti_ts, main="PACF - Crude Price")
par(mfrow=c(1,1)) # Reset layout
# Seasonal Subseries Plot
ggseasonplot(wti_ts, year.labels=TRUE, col=rainbow(20), main="Seasonal Plot - Crude Oil Price")


# EDA on Crude Oil Production

# Line Chart of Production
ggplot(prod_data, aes(x=Date,y=Production)) +
  geom_line(color="darkgreen") +
  labs(title="U.S. Monthly Crude Oil Production",
       y="Production (Thousand Barrels)") +
  theme_minimal()

# 12-Month Rolling Average
library(zoo)

prod_data = prod_data %>%
  mutate(RollingAvg = rollmean(Production, k=12, fill=NA, align="right"))

ggplot(prod_data, aes(x=Date)) +
  geom_line(aes(y=Production), color="darkgreen", alpha=0.4) +
  geom_line(aes(y=RollingAvg), color="midnightblue", size=1) +
  labs(title="U.S. Crude Oil Production with 12-Month Rolling Average",
       y="Production (Thousand Barrels)") +
  theme_minimal()

# Monthly Change in Production
prod_data = prod_data %>%
  mutate(MonthlyChange=Production-lag(Production))

ggplot(prod_data, aes(x=Date, y=MonthlyChange)) +
  geom_line(color="tomato") +
  labs(title="Monthly Change in U.S. Crude Production",
       y="Change in Production (Thousand Barrels)") +
  theme_minimal()

# Histogram of Monthly Changes
ggplot(prod_data, aes(x=MonthlyChange)) +
  geom_histogram(binwidth=5, fill="lightblue", color="blue") +
  labs(title="Distribution of Monthly Production Changes",
       x="Change in Production (Thousand Barrels)") +
  theme_minimal()

# Stationary Test (ADF)
library(tseries)
adf.test(na.omit(prod_data$Production))
# p-value is 0.9, meaning that time series is non-stationary, needs differencing before modeling

# Seasonality and Autocorrelation
library(forecast)
library(ggplot2)
library(dplyr)
# Converting to Time Series Object
prod_ts=ts(prod_data$Production,
           start=c(year(min(prod_data$Date)), month(min(prod_data$Date))),
           frequency=12)
# STL Decomposition
decomp_prod=stl(prod_ts, s.window="periodic")
autoplot(decomp_prod) +
  labs(title="STL Decomposition of U.S. Crude Oil Production")
# Autocorrelation and Partial Autocorrelation
par(mfrow=c(1,2)) # Set side-by-side layout
acf(prod_ts, main="ACF - Crude Production")
pacf(prod_ts, main="PACF - Crude Production")
par(mfrow=c(1,1)) # Reset layout
# Seasonal Subseries Plot
ggseasonplot(prod_ts, year.labels=TRUE, col=rainbow(20),
             main="Seasonal Plot - Crude Oil Production")


# 4) Time Series Forecasting

#Forecasting WTI Crude Oil Prices
library(forecast)
library(tseries)
library(ggplot2)
#Preparing time series object
wti_ts = ts(wti_data$Price,
            start=c(year(min(wti_data$Date)),month(min(wti_data$Date))), 
            frequency=250)
# ETS model
ets_model=ets(wti_ts)
summary(ets_model)
#Forecasting next 500 days (2 years)
ets_forecast=forecast(ets_model, h=500)
autoplot(ets_forecast) +
  labs(title="WTI Price Forecast - ETS Model", y="Price (USD)")
# ARIMA model
arima_model=auto.arima(wti_ts)
summary(arima_model)
#Forecasting next 500 days (2 years)
arima_forecast=forecast(arima_model,h=500)
autoplot(arima_forecast) +
  labs(title="WTI Price Forecast - ARIMA Model", y="Price (USD)")
# Comparing Accuracy of the models
accuracy(ets_model)
accuracy(arima_model)

#Forecasting U.S. Crude Oil Production
prod_ts=ts(prod_data$Production,
           start=c(year(min(prod_data$Date)), month(min(prod_data$Date))),
           frequency=12)
# ETS Model
ets_prod=ets(prod_ts)
summary(ets_prod)
# Forecasting 24 months ahead
ets_forecast_prod=forecast(ets_prod, h=24)
autoplot(ets_forecast_prod) +
  labs(title="U.S. Crude Production Forecast - ETS Model", 
       y="Production (1000s barrels)") + theme_minimal()
# ARIMA Model
arima_prod=auto.arima(prod_ts)
summary(arima_prod)
# Forecasting 24 months ahead
arima_forecast_prod=forecast(arima_prod, h=24)
autoplot(arima_forecast_prod) +
  labs(title="U.S. Crude Production Forecast - ARIMA Model",
       y="Production (1000s barrels)") + theme_minimal()
# Comparing Accuracy of the models
accuracy(ets_prod)
accuracy(arima_prod)


# 5) Price vs. Production Correlation

# Joining wti_data and prod_data
# Ensuring both datasets are aligned by month
price_df=wti_data %>% select(Date, Price)
prod_df=prod_data %>% select(Date, Production)
joined_data=inner_join(price_df, prod_df, by="Date")

# Scatterplot (Production vs. Price)
ggplot(joined_data, aes(x=Price, y=Production)) +
  geom_point(alpha=0.5, color="steelblue") +
  geom_smooth(method="lm", se=TRUE, color="red") +
  labs(title="Production vs. Price", x="WTI Price (USD)",
       y="U.S. Production (1000s barrels)") +
  theme_minimal()

# Pearson Correlation
cor_test=cor.test(joined_data$Price, joined_data$Production)
cor_test
# Correlation is 0.2055416, weak positive correlation

# Lagged Correlation (e.g., Price → Next Month’s Production)
joined_data=joined_data %>%
  arrange(Date) %>%
  mutate(Lagged_Price=lag(Price, n=1)) # Price leads by 1 month
cor.test(joined_data$Lagged_Price, joined_data$Production)
# Correlation slightly improves (0.2216554), but is still weak positive

# Exporting data to CSV
write.csv(wti_data, "data/wti_data.csv",row.names=FALSE)
write.csv(prod_data, "data/prod_data.csv",row.names=FALSE)

