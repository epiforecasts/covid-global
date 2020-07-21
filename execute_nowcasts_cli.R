## required for cli script
require(optparse)

# Process arguments
opt_parser <- OptionParser(
  option_list=list(
    make_option(c("-p","--path"), type="character", default="./data/source", metavar="data storage path"),
    make_option(c("-v", "--verbose"), action = "store_true", help = "Print extra output"),
    make_option(c("-l", "--locations"), type="character",default="", help = "Optionally restrict to one or more locations")

  )
)
config <- parse_args(opt_parser)

if (config$verbose) {
  message("running in verbose mode")
  message("path set to:")
  message(config$path)
  message("location specified:")
  message(config$locations)
  message("loading stored data")
}

# needed for the file path and name generation
source('get_nowcasts_data.R')

cases <- readRDS(filename_cases(config$path))
delay_defs <- readRDS(filename_delays(config$path))
incubation_defs <- readRDS(filename_incubation(config$path))


# Run regions nested ------------------------------------------------------
if (!interactive()){
#  options(future.fork.enable = TRUE) # forces multiprocess to run as multisession if not set. Normally to
  # play more nicely with r studio but might also temporarily resolve the hanging issue whilst leaving
  # all the cores in play.
}
if(config$verbose){
  options(future.debug = TRUE)
}
cores_per_region <- 1
future::plan(list(tweak("multiprocess",
                        workers = floor(future::availableCores() / cores_per_region)),
                  tweak("multiprocess", workers = cores_per_region)),
                  gc = TRUE, earlySignal = TRUE)

# Run pipeline ----------------------------------------------------

location_filter <- lapply(strsplit(config$locations, ",")[[1]],trimws)
if (config$verbose){
  message("available regions")
  print(unique(cases$region))
  message("filter list")
  print(location_filter)
}
if (length(location_filter) > 0){
  cases  <- cases[cases$region %in% location_filter]
}
message("cases for regions ")
print(unique(cases$region))

EpiNow::regional_rt_pipeline(
  cases = cases,
  delay_defs = delay_defs,
  incubation_defs = incubation_defs,
  target_folder = "national",
  case_limit = 60,
  horizon = 14,
  nowcast_lag = 10,
  approx_delay = TRUE,
  report_forecast = TRUE,
  forecast_model = function(y, ...){EpiSoon::forecastHybrid_model(
    y = y[max(1, length(y) - 21):length(y)],
    model_params = list(models = "aefz", weights = "equal"),
    forecast_params = list(PI.combination = "mean"), ...)},
  verbose = config$verbose
)