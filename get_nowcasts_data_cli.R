## required for cli script
library(optparse)

# Process arguments
opt_parser <- OptionParser(
  option_list=list(
    make_option(c("-p","--path"), type="character", default="./data/source", metavar="data storage path"),
    make_option(c("-v", "--verbose"), action = "store_true", help = "Print extra output"),
    make_option(c("-c", "--cache_timeout"), type="integer",default=0, help = "How long to keep saved delay defs file for")

  )
)
config <- parse_args(opt_parser)

source('get_nowcasts_data.R')

get_nowcasts_data(config$path, config$verbose, config$cache_timeout)
