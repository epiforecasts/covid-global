## required for cli script
require(optparse)

# Process arguments
opt_parser <- OptionParser(
  option_list=list(
    make_option(c("-v", "--verbose"), action = "store_true", help = "Print extra output"),

  )
)
config <- parse_args(opt_parser)

if (config$verbose) {
  message("running in verbose mode")
}
future::plan("sequential")

# Summarise results -------------------------------------------------------

EpiNow::regional_summary(results_dir = "national",
                         summary_dir = "national-summary",
                         target_date = "latest",
                         region_scale = "Country",
                         csv_region_label = "country",
                         log_cases = TRUE)