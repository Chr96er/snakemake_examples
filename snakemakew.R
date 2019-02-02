library(magrittr)
library(glue)
library(purrr)
# TODO: check snakemake installed and install if not

#' Snakemake wrapper
#'
#' @rdname snakemake
#' @param rules rules to run
#' @param dryRun boolean flag indicating test run
#' @param forceall boolean indicating whether to force run even if no changes
#' @param code_changes boolean indicating whether to run upon code changes
#' @param cores number of cores to use
#' @param args any additional valid snakemake arguments are being passed
#'
#' @export
snakemaker = function(rules, dryrun = F, forceall = F, code_changes = F, cores = "all",
                      snakefile = "Snakefile", args = c("-p"), async = F, profile = "test") {
  if (dryrun) {
    args %<>% c("--dryrun")
  }

  if (forceall) {
    args %<>% c("--forceall")
  }

  if (code_changes) {
    args %<>% c("--list-code-changes")
  }

  cores = dplyr::case_when(
    cores == "all" ~ parallel::detectCores()
  )

  args %<>%  c(glue::glue("--cores {cores}"))

  args %<>% c(glue::glue("--profile {profile}"))

  if (async && "future" %in% installed.packages()) {
    library(future)
    plan(multiprocess)
    future(run_snakemake(args))
  } else {
    run_snakemake(args)
  }
}

run_snakemake = function(args) {
  system2("snakemake", args)
}

create_dag = function(args = c("-p"), filename = "dag.svg") {
  args %<>% c("--dag")
  tmpfile = tempfile()
  system2("snakemake", args, stdout = tmpfile)
  system2("dot", c("-Tsvg", tmpfile), stdout = filename)
}

load_snakefile = function(snakefile = "Snakefile") {
  yaml::read_yaml(snakefile)
}

initialise_sm = function(input = list(), output = list(), config = list(), environment = list(),
                         wd = ".", snakefile = "Snakefile", rule = 1, verbose = F) {

  if (verbose) {
    cat(glue("Initialising snakemake with default parameters
             ..."))
  }
  if (is.numeric(rule)) {
    rule = get_rule(snakefile, index = rule)
  }
  # TODO: get wd from environment file

  sf = load_snakefile(snakefile)
  setClass("Snakemake", representation(input = "list", output = "list", config = "list"))
  sm = new("Snakemake", config = list("test"))

  if (!is.null(rule)) {
    sf_rule = sf[[glue("rule {rule}")]]

    c("input", "output", "script", "shell", "params", "version", "benchmark", "group") %>%
      map(., function(current_param) {
        attributes(sm)[[current_param]] <<-
          if (exists(current_param) && length(get(current_param))) {
            get(current_param)
          } else {
            sf_rule[[current_param]] %>%
              {if (current_param %in% c("input", "output")) prepend_wd(., wd)} %>%
              list()
          }
      })
  }

  ## if sm doesn't have config / environment / working directory -> add (also prepend wd to inputs/outputs)

  cat(glue(
    "Initialised snakemake with the following parameters:
              - inputs: {sm@input}
              - output: {sm@output}
              - config: {sm@config}"
  ))
  sm
}

prepend_wd = function(paths, wd) {
  map_chr(paths, ~ file.path(wd, .x))
}

extract_rulename = function(rulename) {
  rulename %<>%
    gsub(pattern = "^rule (.*)", replacement = "\\1")
}

get_rule = function(snakefile = "Snakefile", index = 1) {
  load_snakefile(snakefile)[index] %>%
    names %>%
    extract_rulename()
}
