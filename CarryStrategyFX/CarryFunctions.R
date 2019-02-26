
# Log returns function
# The function is supposed to calculate log daily returns of spot rates 
# Input variables: 
#   - crncy - selected currencies
#   - start_date, for instance: "2008-01-01"
#   - end_date, for instance: "2018-01-01"
rets.fun = function(crncy, start_date, end_date){
  data = spots[, crncy] # select currencies
  dat_cur = data[index(data)>=start_date & index(data)<=end_date,] # select time frame
  log_rets = CalculateReturns(prices = dat_cur, method = "log") # calculate log returns 
  log_rets[1,] = 0
  return(log_rets)
}# end of function

# Interest rate differentials function 
# Function which aims to calculate interest rate differentials using the Covered Interest Rate Parity (CIP)
# Input variables: 
#   - crncy - selected currencies
#   - start_date, for instance: "2008-01-01"
#   - end_date, for instance: "2018-01-01"
#   - nfwd - maturity for the forward 1 or 6 months 
int.diff = function(crncy, start_date, end_date, nfwd){
  data = spots[, crncy] # select currencies
  data = data[index(data)>=start_date & index(data)<=end_date,] # select time frame
  if(nfwd == 1){ # if one-month interest rate differentials selected
    fwds = fwd1m[index(fwd1m)>=start_date & index(fwd1m)<=end_date,]
    fwds = fwds[, crncy]} 
  else { # if six-month interest rate differentials selected
    fwds = fwd6m[index(fwd6m)>=start_date & index(fwd6m)<=end_date,]
    fwds = fwd6m[, crncy]} # end of if 
  int.diff = log(data)-log(fwds) # calculate interest rate differentials based on Covered Interest Rate Parity 
}# end of function

# Carry Strategy function 
# The main idea of carry strategy is to buy high-yield currencies and sell low-yield currencies
# We assume USD to be our home currency
# Function runs the strategy for each selected currency separately 
# Input variables: 
#   - crncy - selected currencies
#   - start_date 
#   - end_date
#   - nfwd - maturity for the forward 1 or 6 months applied for calculation of interest rate differentials
carry = function(crncy, start_date, end_date, nfwd){
  log_rets = rets.fun(crncy=crncy,start_date=start_date,end_date=end_date) # calculate log returns using previously introduced function
  int.diffs = int.diff(crncy = crncy, start_date = start_date, end_date=end_date, nfwd=nfwd) # calculate interest rate differentials using previous function
  if(length(crncy)==1){
    signal = ifelse(int.diffs<0, -1, 1) # generate trading signal
    rets.single = as.xts(lag(signal)*log_rets) # calculate returns 
    return(ret.single)
  }else{ 
    signals = apply(int.diffs, 2,function(x) ifelse(x < 0, -1, 1)) # generate trading signal for all selected currencies 
    rets = as.xts(lag(signals)*log_rets) # calculate returns for each currency separately 
    return(rets)
  }
}# end of function

# Performance plotting function
# This function allows to plot cumulative return of strategies and drawdown
Perf.plots = function(x){
  p1 = chart.CumReturns(x, main = "Carry strategy - Cumulative return", legend.loc = "topleft", ylab ="Cumulative return")
  p2 = chart.Drawdown(x, main = "Carry strategy - Drawdown", ylab = "Drawdown")
  par(mfrow=c(2,1))
  list(p1,p2)
}


