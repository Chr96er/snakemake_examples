rule transform_history:
  input:
    "data/processed/01_cleansed/scrobble_history_cleansed.feather"
  output:
    "data/processed/02_transformed/scrobble_history_transformed.feather"
  script:
    "scripts/02_transform/transform_scrobble_history.R"

rule cleanse_history:
  input:
    "data/processed/00_downloaded/scrobble_history_downloaded.feather"
  output:
    "data/processed/01_cleansed/scrobble_history_cleansed.feather"
  script:
    "scripts/01_cleanse/cleanse_scrobble_history.R"

rule parse_history:
  input:
    "data/processed/00_downloaded/scrobble_history_cached.json"
  output:
    "data/processed/00_downloaded/scrobble_history_downloaded.feather"
  script:
    "scripts/00_download/parse_scrobble_history.R"

rule download_history:
  output:
    "data/processed/00_downloaded/scrobble_history_cached.json"
  script:
    "scripts/00_download/download_scrobble_history.R"


workdir: config["workdir"]
