library(magrittr)
library(data.table)
library(purrr)

sm = snakemake

res_l = jsonlite::read_json(sm@input[[1]])

dt_res = res_l %>%
  unlist(recursive = F) %>%
  map(function(track) {
    data.table(
      artist = track$artist$`#text` %>% unlist,
      album = track$album$`#text` %>% unlist,
      title = track$name %>% unlist,
      date = track$date$`#text` %>% unlist)
  }) %>%
  rbindlist()

feather::write_feather(dt_res, sm@output[[1]])
