# Packages -----------------------------------------------------------------
require(EpiNow2)
require(covidregionaldata)
require(data.table)
require(future)

# Update delays -----------------------------------------------------------

generation_time <- readRDS(here::here("data", "generation_time.rds"))
incubation_period <- readRDS(here::here("delays", "data", "incubation_period.rds"))
reporting_delay <- readRDS(here::here("delays", "data", "onset_to_admission_delay.rds"))

# Get cases  ---------------------------------------------------------------

cases <- data.table::setDT(covidregionaldata::get_national_data(source = "ecdc"))

cases <- cases[, .(region = country, date = as.Date(date), confirm = cases_new)]
cases <- cases[, .SD[date >= (max(date) - lubridate::weeks(8))], by = region]

data.table::setorder(cases, date)

# # Set up cores -----------------------------------------------------
setup_future <- function(jobs) {
  if (!interactive()) {
    ## If running as a script enable this
    options(future.fork.enable = TRUE)
  }
  
  
  plan(tweak(multiprocess, workers = min(future::availableCores(), jobs)),
       gc = TRUE, earlySignal = TRUE)
  
  
  jobs <- max(1, ceiling(future::availableCores() / jobs))
  return(jobs)
}

no_cores <- setup_future(length(unique(cases$region)))


# Run Rt estimation -------------------------------------------------------

regional_epinow(reported_cases = cases,
                generation_time = generation_time,
                delays = list(incubation_period, reporting_delay),
                horizon = 14,
                samples = 2000, warmup = 500,
                cores = no_cores, chains = 2,
                target_folder = "cases/national",
                case_limit = 1,
                summary_dir = "cases/summary",
                return_estimates = FALSE, verbose = FALSE)
