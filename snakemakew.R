require(magrittr)
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
snakemake = function(rules, dryrun = F, forceall = F, code_changes = T, cores = "all",
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
  print(glue::glue("--profile {profile}"))

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
