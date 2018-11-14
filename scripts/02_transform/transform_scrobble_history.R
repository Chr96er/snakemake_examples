library(magrittr)
library(data.table)
library(purrr)

dt = feather::read_feather("data/processed/01_cleansed/scrobble_history_cleansed.feather") %>%
  setDT()

dt[, date := as.POSIXct(date, format = "%d %b %Y, %H:%M")]

feather::write_feather(dt, "data/processed/02_transformed/scrobble_history_transformed.feather")
