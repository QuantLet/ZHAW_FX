# please change your working directory setwd('C:/...')
# load the data, functions and packages 

source("CarryPackages.R")
source("CarryFunctions.R")

# Load the data 
load("data/Data.RData")

Backtest = carry(crncy=c("JPY", "EUR", "SEK"), start_date ="2011-01-01", end_date = "2019-01-25", nfwd = 1)

  par(mfrow=c(2,1))
  chart.CumReturns(Backtest, legend.loc = "topleft", main = "Carry strategy - Cumulative returns")
  title(ylab = "Cumulative return")
  chart.Drawdown(Backtest, main = "Carry strategy - Drawdowns", ylab ="Value in percent")
  title(ylab = "Drawdown") 


