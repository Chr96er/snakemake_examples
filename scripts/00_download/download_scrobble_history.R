library(data.table)
library(magrittr)
library(purrr)
library(httr)

sm_config = snakemake@config

api_key = readLines(sm_config$lastfm_api_key)

req = parse_url(sm_config$lastfm_api_url)

res_l = map(1:sm_config$pages, function(current_page) {
  print(glue::glue("Getting page {current_page} of {sm_config$pages}"))
  req$query = list(
    method = "user.getrecenttracks",
    user = "Chr_96er",
    api_key = api_key,
    format = "json",
    limit = 1000,
    page = current_page)

  httr_res = GET(req)

  httr_res %>% content %>% .$recenttracks %>% .$track
})

jsonlite::write_json(res_l, "data/processed/00_downloaded/scrobble_history_cached.json")
