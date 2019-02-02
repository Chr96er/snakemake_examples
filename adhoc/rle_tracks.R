library(magrittr)
library(data.table)
library(purrr)

if (!exists("snakemake")) snakemake = initialise_sm(verbose = T, wd = "test")

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
# TODO: the proper way to to this would be to look at the RLE of each "session", group by the length
# and dedupe if the max group count is grater than one
dt_seq[map_int(title_sequence, uniqueN) == 1]

sample_seq = dt_seq[1, title_sequence][[1]]

get_dedupe_count = function(rle_seq, method = c("max_length", "max")) {
  method %<>% .[1]

  data.table(rle = rle_seq$lengths, title = rle_seq$values) %>%
    .[, .(rle_count = .N), rle] %>%
    {if (method == "max_length") .[rle_count == max(rle_count), rle %>% as.numeric %>% max]
      else if (method == "max") .[, rle %>% as.numeric %>% max]}
}

dedupe_seq = function(sequence, method = c("max_length", "max")) {
  rle_seq = sequence %>%
    rle()

  dedupe_subtract = get_dedupe_count(rle_seq) - 1

  rep.int(rle_seq$values, rle_seq$lengths - dedupe_subtract) %>%
    list
}

dt_seq %>%
  .[, .(title_sequence[[1]] %>% dedupe_seq()), rleid]

dt_seq[map_int(title_sequence, uniqueN) > 1, .(
  title_sequence = title_sequence %>%
    unlist %>%
    rle %>%
    .$values %>%
    list %>%
    paste0(collapse = ", ")
), rleid] %>%
  .[, .N, title_sequence] %>%
  .[order(-N)]


# TODO: find full runs of entire albums - requires album track lookup
