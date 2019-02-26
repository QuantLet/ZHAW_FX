rm(list = ls(all = TRUE))

# please change your working directory setwd('C:/...')
# load the data, functions and packages 

source("ValuePackages.R")
source("ValueFunctions.R")

# Load the data 
load("data/data.RData")

# Specify parameters 
crncy = c("EUR", "CAD", "CNY", "CZK", "JPY", "CHF", "GBP", "SEK")
start_date = "2006-01-01"
end_date = "2017-12-01"

# Run backtest
Backtest = value_strategy(crncy = crncy, start_date = start_date, end_date = end_date)

# Generate plots 
par(mfrow=c(2,1))
chart.CumReturns(Backtest$portfolio, main = "Value cross sectional portfolio - Cumulative return")
title(ylab = "Cumulative return")
chart.Drawdown(Backtest$portfolio, main = "Value cross sectional portfolio - Drawdown")
title(ylab = "Drawdown") 


