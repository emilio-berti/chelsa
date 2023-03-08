library(terra)

args <- commandArgs(trailingOnly = TRUE)
DATA_DIR <- args[1]
UTILS_FILE <- args[2]
SCENARIO <- args[3]
AREA <- args[4]
PARS <- read_csv(args[1], show_col_types = FALSE, progress = FALSE)

# process if task exists in an array job
task <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID"))
if (is.na(task)) { 
  stop("This is not an array job; stopping...")
} else { 
  message("")
  message(" === START OF PROCEDURE ===")
  message(" - HMM")
  for (i in seq_len(10)) {
    message(" --- replicate: ", i)
    fithmm(params[task, ][[1]], i)
  }
  message(" === END OF PROCEDURE === ")
} 



list.files(
  "data/original/present/world",
  full.names = TRUE,
  pattern = var
)