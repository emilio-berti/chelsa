suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(terra))

args <- commandArgs(trailingOnly = TRUE)
DATADIR <- args[1]
SCENARIO <- args[2]
AREA <- args[3]
UTILS <- args[4]
PARS <- args[5]

source(UTILS)
datadir <- file.path(DATADIR, SCENARIO, AREA)

# process if task exists in an array job
task <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID"))
if (is.na(task)) { 
  stop("This is not an array job; stopping...")
} else {
  message("")
  message(" === START OF PROCEDURE ===")

  bio <- read.csv(PARS)[["bio"]][task]
  ff <- list.files(
    datadir,
    pattern = bio,
    full.names = TRUE
  )
  ff <- ff[grepl(".tif", ff)]
  ff <- order_files(files)

  message("  - ", bio)
  
  r <- rast(ff)
  years <- str_split(ff, "/", simplify = TRUE)
  years <- file_names[, ncol(file_names)]
  gsub("[A-Za-z]+[0-9]{2}-|[.]tif", "", years)
  if (any(year != seq(min(year), max(year))) {
    stop("Years are not in order. Exiting...")
  }
  names(r) <- years
  xy <- xyFromCell(r, seq_len(ncell(r)))
  cellID <- cellFromXY(r, xy) %>%
    as_tibble() %>%
    transmute(cellID = value)
  xy <- xy %>% as_tibble()
  ts <- r %>% 
    values() %>% 
    as_tibble()
  res <- bind_cols(cellID, xy, ts)
  write_csv(paste0(datadir, "/", bio, ".csv"))
 
  message(" === END OF PROCEDURE === ")
}
 
