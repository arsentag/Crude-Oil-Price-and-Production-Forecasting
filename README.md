# Crude Oil Price and Production Forecasting for Strategic Planning

![R](https://img.shields.io/badge/Built%20With-R%20&%20Shiny-blue?logo=r)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

##  Project Overview

This project presents a full-cycle time series forecasting analysis of **WTI crude oil prices** and **U.S. crude oil production volumes**, built to support strategic planning in the energy sector.

Using data from the [U.S. Energy Information Administration (EIA)](https://www.eia.gov/), the analysis spans several decades of monthly records and includes:
- Exploratory analysis (trend, seasonality, volatility)
- Forecasting with **ETS** and **ARIMA** models
- Correlation testing between price and production
- An **interactive Shiny dashboard** for scenario exploration

The full report is included as a PDF with interpretations, accuracy tables, and insights.

---

##  Tools & Techniques Used

| Category           | Details                                      |
|--------------------|----------------------------------------------|
| Language           | R                                            |
| Forecasting Models | ETS, ARIMA                                   |
| Data Sources       | WTI Price & U.S. Production from EIA         |
| Time Series Tools  | `forecast`, `tseries`, `lubridate`, `zoo`    |
| Dashboard          | Shiny                                        |

---

##  Highlights

-  **WTI Forecasting**: ETS and ARIMA models showed near-identical performance (MAPE ~1.85%), with ARIMA offering slightly better residual independence.
-  **Production Forecasting**: ETS outperformed ARIMA slightly, with more interpretable trend dampening.
-  **Correlation Analysis**: Weak but statistically significant positive correlation found between price and production (both contemporaneous and 1-month lag).
-  **Shiny Dashboard**: Built for interactive forecasting and visual exploration.

---

##  Files Included

- `R Project Final Report.pdf` – Full write-up of the project including methods, visuals, forecasts, and strategic insights.
- `wti_prices.xls` & `production_volume.xls` – Raw datasets.
- `wti_data.csv` & `prod_data.csv` – Cleaned and preprocessed datasets.
- `Crude Oil Project.R` – Source code for the main part of the project.
- `app.R` – Source code for the Shiny dashboard.

---

