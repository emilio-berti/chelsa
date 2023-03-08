suppressPackageStartupMessages(library(terra))
suppressPackageStartupMessages(library(Rcpp))

# BIO01 = mean tas annual
# BIO10 = mean tas warmest quarter
# BIO11 = mean tas coldest annual

# BIO12 = pr total annual
# BIO16 = pr wettest wettest quarter
# BIO17 = pr driest driest quarter

args <- commandArgs(trailingOnly = TRUE)
DATADIR <- args[1]
UTILS <- args[2]
PARS <- args[3]

source(UTILS)

year <- read.csv(PARS)[["year"]]
variable <- read.csv(PARS)[["variable"]]

# process if task exists in an array job
task <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID"))
if (is.na(task)) { 
  stop("This is not an array job; stopping...")
} else { 
  message("")
  message(" === START OF PROCEDURE ===")

  message(" - ", variable[task], ", ", year[task])
  files <- list.files(
    DATADIR,
    full.names = TRUE,
    pattern = as.character(year[task])
  )
  if (variable[task] == "precipitation") {
    files <- files[grepl("_pr_", files)]
    stopifnot(length(files) == 12)
    files <- order_files(files)
    # Precipitation bioclim
    message("  - BIO12 ")
    bio12 <- bio12(files)
    writeRaster(
      bio12,
      paste0(DATADIR, "bioclim/BIO12-", year[task], ".tif")
    )
    message("  - BIO16 ")
    bio16 <- quarter(files, "highest")
    writeRaster(
      bio16[[1]], 
      paste0(DATADIR, "bioclim/BIO16-", year[task], ".tif")
    )
    message("  - BIO17 ")
    bio17 <- quarter(files, "lowest")
    writeRaster(
      bio17[[1]], 
      paste0(DATADIR, "bioclim/BIO17-", year[task], ".tif")
    )
  } else if (variable[task] == "temperature") {
    files <- files[grepl("_tas_", files)]
    stopifnot(length(files) == 12)
    files <- order_files(files)
    # temperature bioclim
    message("  - BIO01")
    bio01 <- bio1(files)
    writeRaster(
      bio01,
      paste0(DATADIR, "bioclim/BIO01-", year[task], ".tif")
    )
    message("  - BIO16 ")
    bio10 <- quarter(files, "highest")
    writeRaster(
      bio10[[1]], 
      paste0(DATADIR, "bioclim/BIO10-", year[task], ".tif")
    )
    message("  - BIO11 ")
    bio11 <- quarter(files, "lowest")
    writeRaster(
      bio11[[1]], 
      paste0(DATADIR, "bioclim/BIO11-", year[task], ".tif")
    )
  }
  message(" === END OF PROCEDURE === ")
} 
