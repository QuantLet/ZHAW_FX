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
  data = spots[, crncy] # select currencies
  dat_cur = data[index(data)>=start_date & index(data)<=end_date,] # select time frame
  return(dat_cur) 
}#end of function

# Moving averages function 
# This function calculates moving averages for each of selected currencies
# In the mentioned paper, the authors select 3 sets of time-scale each set consisting of 
# a short and long exponentially weighted moving averages. Calculated moving averages and differences 
# between them will be applied for the calculation of the final CTA-momentum signal
# Input variables: 
#   - crncy - selected currencies, for instance c("CAD","EUR","JPY")
#   - start_date, for instance: "2008-01-01"
#   - end_date, for instance: "2018-01-01"
#   - S_k - a vector with short periods for moving averages, for instance, c(4,7,13)
#   - L_k - a vector with long periods for moving averages, for instance, c(4,7,13)
ma_func = function(crncy,start_date, end_date, S_k, L_k){
  fx = select_fx(crncy = crncy, start_date = start_date, end_date = end_date) # obtain spot rates of selected currencies
  ShortMA = LongMA = x_k = list() # create lists for moving averages and differences between them (x_k)
  for(i in 1:length(S_k)){
    ShortMA[[i]] = as.xts(apply(fx, 2,FUN = EMA, n = S_k[i]), order.by = index(fx)) # calculate short MAs
    LongMA[[i]] = as.xts(apply(fx, 2,FUN = EMA, n = L_k[i]), order.by = index(fx)) # calculate long MAs
    x_k[[i]] = ShortMA[[i]] - LongMA[[i]] # calculate differences between short and long MAs
  }
  return(list(ShortMA = ShortMA, LongMA = LongMA, x_k = x_k))
}# end of function


# Normalization function 
# This function is supposed to:
# - generate y_k which is done by normalizing x_k 
# - generate z_k which is done by normalizing y_k 
# Input variables: 
#   - crncy - selected currencies, for instance c("CAD","EUR","JPY")
#   - start_date, for instance: "2008-01-01"
#   - end_date, for instance: "2018-01-01"
#   - S_k - a vector with short periods for moving averages, for instance, c(4,7,13)
#   - L_k - a vector with long periods for moving averages, for instance, c(4,7,13)
#   - n1 - number of days used for running standard deviation of spot rates (applied in normalization of x_k)
#   - n2 - number of days used for running standard deviation of y_k (applied in normalization of y_k)
y_z_norm = function(crncy, start_date, end_date, S_k, L_k, n1, n2){
  fx = select_fx(crncy = crncy, start_date = start_date, end_date = end_date) # obtain selected currencies
  x_k = ma_func(crncy = crncy,start_date = start_date, end_date = end_date, S_k = S_k, L_k = L_k)$x_k # generate differences between MAs using one of previous functions
  moving_sd1 = as.xts(apply(X = fx, MARGIN = 2, FUN = runSD, n = n1), order.by = index(fx)) # calculate running standard deviation for normalization of x_k
  y_k = lapply(x_k, function(x) x/moving_sd1) # normalization
  moving_sd2 = as.xts(apply(X = fx, MARGIN = 2, FUN = runSD, n = n2), order.by = index(fx))# calculate running standard deviation for normalization of y_k
  z_k = lapply(y_k, function(x) x/moving_sd2) # normalization
  return(list(y_k = y_k, z_k = z_k ))# return factors y_k and z_k
}#end of function

# CTA-signal function
# This function generates the final CTA-momentum signal
# Input variables: 
#   - crncy - selected currencies, for instance c("CAD","EUR","JPY")
#   - start_date, for instance: "2008-01-01"
#   - end_date, for instance: "2018-01-01"
#   - S_k - a vector with short periods for moving averages, for instance, c(4,7,13)
#   - L_k - a vector with long periods for moving averages, for instance, c(4,7,13)
#   - n1 - number of days used for running standard deviation of spot rates (applied in normalization of x_k)
#   - n2 - number of days used for running standard deviation of y_k (applied in normalization of y_k)
#   - weights of u_k used to calculate the CTA signal 
signal_CTA = function(crncy, start_date, end_date, S_k, L_k, n1, n2, w){
  # obtain the z-k factor from previous function 
  z = y_z_norm(crncy = crncy,start_date = start_date, end_date = end_date, S_k = S_k, L_k = L_k, n1 = n1, n2 = n2)$z_k
  # calculate the u_k using the response function
  u_k = lapply(z, function(x) x * exp(-(x ^ 2) / 4) / (sqrt(2) * exp(-1 / 2)))
  if (length(w) == 1){
    CTA = Reduce("+", u_k)/3 # calculate the signal using equal weights
  }else{
    score = list()
    for (i in 1:3){
      score[[i]] = u_k[[i]] * w[i] # calculate the signal using preselected weights (w)
    }
    CTA = Reduce("+", score)
  }
  return(CTA = CTA)
}# end of function

# Backtesting function 
# This function perfroms the backtest of strategy presented in the paper for currencies. 
# The backtest is performed for each currency separately and if more than 6 currencies have been selected, 
# the backtest is performed for cross sectional portfolio.
# Input variables: 
#   - crncy - selected currencies, for instance c("CAD","EUR","JPY")
#   - start_date, for instance: "2008-01-01"
#   - end_date, for instance: "2018-01-01"
#   - S_k - a vector with short periods for moving averages, for instance, c(4,7,13)
#   - L_k - a vector with long periods for moving averages, for instance, c(4,7,13)
#   - n1 - number of days used for running standard deviation of spot rates (applied in normalization of x_k)
#   - n2 - number of days used for running standard deviation of y_k (applied in normalization of y_k)
#   - weights of u_k used to calculate the CTA signal 
strategy = function(crncy, start_date, end_date, S_k, L_k, n1, n2, w){
  CTA = signal_CTA(crncy=crncy, start_date=start_date, end_date=end_date, S_k=S_k, L_k=L_k, n1=n1, n2=n2, w=w)
  log_rets = rets.fun(crncy = crncy, start_date = start_date, end_date = end_date)
  # Strategy for each currency separately: 
  signals = as.xts(apply(CTA, 2,function(x) ifelse(x < 0, -1, 1)), order.by = index(CTA))
  strategy_returns = na.omit(lag(signals)*log_rets)
  if (length(crncy)>6){ # if more than 6 currencies have been selected, the function will generate also a Cross Sectional Portfolio
    # in which we go long (short) in 3 currencies with highest (lowest) CTA score and 
    #Firstly, we rank currencies according to calculatet "CTA" scores
    CTA_ranked = as.xts(t(apply(CTA, 1, function(x) rank(x, ties.method = 'random', na.last = 'keep'))), order.by =index(CTA))
    #Secondly we generate signals - 3 buy signals for currencies with highest scores and 3 sell signals for currencies with lowest scores
    signals = as.xts(apply(CTA_ranked, 2,function(x) ifelse(x <= 3, -1, ifelse (x>(length(crncy)-3), 1, 0))), order.by = index(CTA))
    #Finally, we calculate returns of the strategy with a lag = 1
    portfolio_returns = na.omit(as.xts(rowMeans(lag(signals)*log_rets, na.rm = TRUE), order.by = index(signals)))
    return(list(currencies = strategy_returns, portfolio = portfolio_returns))
  } else { 
    return(currencies = strategy_returns)
  }
}
