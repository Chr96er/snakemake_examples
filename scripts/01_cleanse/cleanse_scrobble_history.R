dt = feather::read_feather("data/processed/00_downloaded/scrobble_history_downloaded.feather")

feather::write_feather(dt, "data/processed/01_cleansed/scrobble_history_cleansed.feather")
