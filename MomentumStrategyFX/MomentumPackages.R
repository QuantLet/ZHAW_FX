# Install and load packages
libraries = c("lubridate", "PerformanceAnalytics", "zoo", "xts", "tis", "TTR", "QuantTools","purrr")
lapply(libraries, function(x) if (!(x %in% rownames(installed.packages()))) {
  install.packages(x)
})
lapply(libraries, library, quietly = TRUE, character.only = TRUE)