# Log returns function
# The function calculates the log daily returns of spot rates 
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

# Selection of currencies and time frame
# This function limits the initial data set to selected currencies and the time frame
# Input variables: 
#   - crncy - selected currencies
#   - start_date, for instance: "2008-01-01"
#   - end_date, for instance: "2018-01-01"
select_fx = function(crncy, start_date, end_date){
  data = spots[, crncy] # select currencies - spots 
  dat_cur = data[index(data)>=start_date & index(data)<=end_date,] # select time frame
  data = CPI[, c(crncy, "USD")] # select relevant CPI indices (including the CPI for USA)
  cpi.index = data[index(data)>=start_date & index(data)<=end_date,] # select time frame
  return(list(dat_cur = dat_cur, cpi.index = cpi.index))  
}#end of function

# Calculation of real exchange rate 
# This function calculates the real exchange rate using the formula from the paper 
# Input variables: 
#   - crncy - selected currencies
#   - start_date, for instance: "2008-01-01"
#   - end_date, for instance: "2018-01-01"
real_ex = function(crncy, start_date, end_date){
  spot = select_fx(crncy = crncy, start_date = start_date, end_date = end_date)$dat_cur
  cpi.index = select_fx(crncy = crncy, start_date = start_date, end_date = end_date)$cpi.index
  real.ex = spot * (cpi.index[,(1:(dim(cpi.index)[2]-1))]/as.numeric(cpi.index$USD))
  return(real.ex)
}# end of function 

# Calculation of value factor 
# This function calculates the value parameter which will be applied in the generation of signals 
# Input variables: 
#   - crncy - selected currencies
#   - start_date, for instance: "2008-01-01"
#   - end_date, for instance: "2018-01-01"
value_factor = function(crncy, start_date, end_date){
  real.ex = real_ex(crncy = crncy, start_date = start_date, end_date = end_date)
  real.avg = as.xts(apply(real.ex, 2,FUN = EMA, n = 12), order.by = index(real.ex))
  value = log(real.ex)- log(real.avg)
  return(value)
}# end of function 

# Value strategy function 
# This function backtests the strategy based on value factor 
# Input variables: 
#   - crncy - selected currencies
#   - start_date, for instance: "2008-01-01"
#   - end_date, for instance: "2018-01-01"
value_strategy = function(crncy, start_date, end_date){
  value.fx = value_factor(crncy = crncy, start_date = start_date, end_date = end_date) 
  log_rets = rets.fun(crncy = crncy, start_date = start_date, end_date = end_date)
  # strategy for each currency separately: 
  signals = as.xts(apply(value.fx, 2,function(x) ifelse(x < 0, -1, 1)), order.by = index(value.fx))
  strategy_returns = na.omit(lag(signals,1)*log_rets)
  if(length(crncy)>=6){
    value.ranked = as.xts(t(apply(value.fx, 1, function(x) rank(x, ties.method = 'random', na.last = 'keep'))), order.by =index(value.fx)) 
    signals = as.xts(apply(value.ranked, 2,function(x) ifelse(x <= 3, -1, ifelse (x>(length(crncy)-3), 1, 0))), order.by = index(value.ranked))
    portfolio_returns = na.omit(as.xts(rowMeans(lag(signals,2)*log_rets, na.rm = TRUE), order.by = index(signals)))
    return(list(currencies = strategy_returns, portfolio = portfolio_returns)) 
    # return list with returns for each currency separately and the portfolio 
  }else{
    return(currencies = strategy_returns) # return only returns for each currency separately
  }
}# end of function 

