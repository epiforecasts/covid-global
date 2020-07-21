
# Packages -----------------------------------------------------------------
require(data.table, quietly = TRUE) 
require(future, quietly = TRUE)
require(forecastHybrid, quietly = TRUE)
## Require for data and nowcasting
require(EpiNow, quietly = TRUE)
require(NCoVUtils, quietly = TRUE)


## Required for forecasting
# require(forecastHybrid, quietly = TRUE)

filename_incubation <- function(path){return(paste0(path, "/nowcast_incubation_defs.rds"))}
filename_delays     <- function(path){return(paste0(path, "/nowcast_delays.rds"))}
filename_cases      <- function(path){return(paste0(path, "/nowcast_cases.rds"))}

get_cases <- function(){
    # Get cases ---------------------------------------------------------------
  
  NCoVUtils::reset_cache()
  
  cases <- NCoVUtils::get_ecdc_cases()
  
  cases <-  NCoVUtils::format_ecdc_data(cases) 
  cases <- data.table::setDT(cases)[!is.na(region)][, 
                                                    `:=`(local = cases, imported = 0)][, cases := NULL]
  
  cases <- data.table::melt(cases, measure.vars = c("local", "imported"),
                            variable.name = "import_status",
                            value.name = "confirm")
  
  ## Remove regions with data issues
  cases <- cases[!region %in% c("Faroe Islands", "Sao Tome and Principe", "Nicaragua")]
  return(cases)
}
get_delays <- function(path){
  # Get linelist ------------------------------------------------------------

      linelist <-
      data.table::fread("https://raw.githubusercontent.com/epiforecasts/NCoVUtils/master/data-raw/linelist.csv")


    delays <- linelist[!is.na(date_onset_symptoms)][,
                                                    .(report_delay = as.numeric(lubridate::dmy(date_confirmation) -
                                                                                  as.Date(lubridate::dmy(date_onset_symptoms))))]

    delays <- delays$report_delay

    # Set up cores -----------------------------------------------------
    if (!interactive()){
      options(future.fork.enable = TRUE)
    }

    future::plan("multiprocess", gc = TRUE, earlySignal = TRUE)

    # Fit the reporting delay -------------------------------------------------

    delay_defs <- EpiNow::get_dist_def(delays,
                                      bootstraps = 100,
                                      samples = 1000)
    return(delay_defs)
}
get_incubation <- function(){
   exp(EpiNow::covid_incubation_period[1, ]$mean)

    ## Get incubation defs
    incubation_defs <- EpiNow::lognorm_dist_def(mean = EpiNow::covid_incubation_period[1, ]$mean,
                                                mean_sd = EpiNow::covid_incubation_period[1, ]$mean_sd,
                                                sd = EpiNow::covid_incubation_period[1, ]$sd,
                                                sd_sd = EpiNow::covid_incubation_period[1, ]$sd_sd,
                                                max_value = 30, samples = 1000)
    return (incubation_defs)
}

get_nowcasts_data <- function (path, verbose, cache_timeout) {
  if(verbose){
    message("getting cases")
  }
  cases <- get_cases(path)
  saveRDS(cases, filename_cases(path))

  if(!file.exists(filename_delays(path)) || file.info(filename_delays(path))$mtime < Sys.time()-cache_timeout){
    if(verbose){
      message("getting delay defs")
    }
    delay_defs <- get_delays()
    saveRDS(delay_defs, filename_delays(path))
  }else if(verbose){
    message("use cached delay_defs")
  }
  # Fit the incubation period -----------------------------------------------
  if(!file.exists(filename_incubation(path)) || file.info(filename_incubation(path))$mtime < Sys.time()-cache_timeout){
    ## Mean delay
    if(verbose){
      message("getting incubation")
    }
    incubation_defs <- get_incubation()
    saveRDS(incubation_defs,  filename_incubation(path))
  }else if(verbose){
    message("use cached incubation")
  }
}
