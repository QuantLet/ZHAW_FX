# Install and load packages
libraries = c("lubridate", "PerformanceAnalytics", "zoo", "xts", "bsts", "imputeTS", "TTR")
lapply(libraries, function(x) if (!(x %in% rownames(installed.packages()))) {
  install.packages(x)
})
lapply(libraries, library, quietly = TRUE, character.only = TRUE)

