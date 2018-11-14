library(magrittr)
library(data.table)
library(purrr)

sm = snakemake

dt = feather::read_feather(sm@input[[1]]) %>%
  setDT

# tracks listened to multiple times in a row
dt[, .(.N, title_sequence = paste0(title, collapse = "->")), .(artist, date %>% as.Date,
                                                               rleid(paste0(artist, album, as.Date(date))))] %>%
  .[N > 1] %>%
  .[order(-N)] %>%
  View

  # double scrobbles are a common issue
  # patterns like AABBCCDDEE or ABBCDDEE are in 99.99% of cases double scrobbles
  # AAB does not necessarily mean double scrobble
  dt_seq = dt[, .(.N, title_sequence = list(title)), .(artist, date %>% as.Date,
                                                       rleid(paste0(artist, album, as.Date(date))))] %>%
  .[N > 1] %>%
  .[order(-N)]

# we're taking a slight shortcut though - any double scrouble will be deduped if there is more
# than one title in the group
# e.g. this filter will only display groups with one unique title - which is fine because I might
# have listened to the track twice. Any other case of double scroll should be deduped though
dt_seq[map_int(title_sequence, uniqueN) == 1]

dt_seq[map_int(title_sequence, uniqueN) > 1, .(
  title_sequence %>%
    unlist %>%
    rle %>%
    .$values %>%
    list
), rleid] %>% View


# TODO: find full runs of entire albums - requires album track lookup
