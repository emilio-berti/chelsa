suppressPackageStartupMessages(library(terra))

args <- commandArgs(trailingOnly = TRUE)
DATADIR <- args[1]
SCENARIO <- args[2]
AREA <- args[3]
PARS <- args[4]

input <- file.path(DATADIR, "present", "world", "bioclim")
output <- file.path(DATADIR, SCENARIO, AREA)
if (AREA == "europe") {
  templ <- gsub("original", "templates/europe.tif", DATADIR)
} else if (AREA == "america") {
  templ <- gsub("original", "templates/america.tif", DATADIR)
}
templ <- rast(templ)

# process if task exists in an array job
task <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID"))
if (is.na(task)) { 
  stop("This is not an array job; stopping...")
} else {
  message("")
  message(" === START OF PROCEDURE ===")
  f <- read.csv(PARS)[["file"]][task]
  bio <- gsub("-[0-9]+.tif", "", f)
  year <- gsub("[A-Z0-9]+-|.tif", "", f)
  message(" - ", f)
  r <- rast(file.path(input, f))
  r <- project(r, templ)
  r[is.na(templ)] <- NA
  if (bio %in% c("BIO01", "BIO10", "BIO11")) r <- r / 10
  writeRaster(
    r, 
    paste0(output, "/", bio, "-", year, ".tif"),
    overwrite = TRUE
  )
  message(" === END OF PROCEDURE === ")
} 
