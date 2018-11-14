library(magrittr)
library(data.table)
library(purrr)

res_l = jsonlite::read_json("data/processed/00_downloaded/scrobble_history_cached.json")

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

feather::write_feather(dt_res, "data/processed/00_downloaded/scrobble_history_downloaded.feather")
