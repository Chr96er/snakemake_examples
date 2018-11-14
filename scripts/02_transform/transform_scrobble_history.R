library(magrittr)
library(data.table)
library(purrr)

sm = snakemake

dt = feather::read_feather(sm@input[[1]]) %>%
  setDT()

dt[, date := as.POSIXct(date, format = "%d %b %Y, %H:%M")]

feather::write_feather(dt, sm@output[[1]])
