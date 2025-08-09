install.packages("shiny")
install.packages("forecast")
install.packages("ggplot2")
install.packages("dplyr")
install.packages("lubridate")

library(shiny)
library(forecast)
library(ggplot2)
library(dplyr)
library(lubridate)

# Loading data
wti_data=read.csv("data/wti_data.csv")
prod_data=read.csv("data/prod_data.csv")
#Converting Date column back to date format
wti_data$Date=as.Date(wti_data$Date)
prod_data$Date=as.Date(prod_data$Date)
# Merging data for scatterplot
joined_data=inner_join(wti_data, prod_data, by="Date")

# Creating time series
wti_ts=ts(wti_data$Price, start=c(year(min(wti_data$Date)),
                                  month(min(wti_data$Date))),frequency=250)
prod_ts=ts(prod_data$Production, start=c(year(min(prod_data$Date)),
                                         month(min(prod_data$Date))),frequency=12)
#Forecasts
ets_wti=ets(wti_ts)
ets_forecast_wti=forecast(ets_wti, h=500)
ets_prod=ets(prod_ts)
ets_forecast_prod=forecast(ets_prod, h=24)

# UI
ui=fluidPage(
  titlePanel("Crude Oil Strategic Forecasting Dashboard"),
  
  tabsetPanel(
    tabPanel("WTI Price Forecast",
             plotOutput("wtiPlot")),
    
    tabPanel("Production Forecast",
             plotOutput("prodPlot")),
    
    tabPanel("Production vs. Price",
             plotOutput("scatterPlot"),
             verbatimTextOutput("corText"))
  )
)

# Server
server=function(input, output) {
  output$wtiPlot=renderPlot({
    autoplot(ets_forecast_wti) +
      labs(title="Forecast: WTI Crude Oil Price", y="Price (USD)") +
      theme_minimal()
  })
  
  output$prodPlot=renderPlot({
    autoplot(ets_forecast_prod) +
      labs(title="Forecast: U.S. Oil Production", y="Production (1000s barrels") +
      theme_minimal()
  })
  
  output$scatterPlot=renderPlot({
    ggplot(joined_data, aes(x=Price, y=Production)) +
      geom_point(alpha=0.5, color="steelblue") +
      geom_smooth(method="lm", se=TRUE, color="red") +
      labs(title="Production vs. Price", x= "WTI Price (USD)", y="Production") +
      theme_minimal()
  })
  
  output$corText=renderPrint({
    cor.test(joined_data$Price, joined_data$Production)
  })
}

# Run the app
shinyApp(ui=ui, server=server)








