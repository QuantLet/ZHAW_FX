rm(list = ls(all = TRUE))

# please change your working directory setwd('C:/...')
# load the data, functions and packages 

source("MomentumPackages.R")
source("MomentumFunctions.R")

# Load the data 
load("data/Data.RData")

# Specify parameters 
start_date = "2007-01-01"
end_date = "2019-01-25"
crncy = c("EUR","AUD","NZD","JPY","CZK","PLN","CNY","CHF", "GBP", "CZK")
S_k = c(8,16,32)
L_k = c(24,48,96)
n1 = 63
n2 = 252
w = c(0.3,0.3,0.4)

# Run backtest
Backtest = strategy(crncy = crncy, start_date, end_date, S_k = S_k, L_k = L_k, n1 = n1, n2 = n2, w = w)

# Generate plots 
par(mfrow=c(2,1))
chart.CumReturns(Backtest$portfolio, main = "Momentum cross sectional portfolio - Cumulative return")
title(ylab = "Cumulative return")
chart.Drawdown(Backtest$portfolio, main = "Momentum cross sectional portfolio - Drawdown")
title(ylab = "Drawdown") 

