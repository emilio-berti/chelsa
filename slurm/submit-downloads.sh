#!/bin/bash

#SBATCH -J ChelsaDownload
#SBATCH --chdir=/work/berti
#SBATCH --output=/work/%u/%x-%j.out
#SBATCH --mem-per-cpu=2G
#SBATCH --time=3-00:00:00

export MC_CORES=${SLURM_CPUS_PER_TASK:-2}

array_or_job_id=${SLURM_ARRAY_JOB_ID:-$SLURM_JOB_ID}

download_dir="$1"
urls_file="$2"
scenario="$3"

bash \
  /home/berti/demographic-sdm/download-chelsa-bio.sh \
  "$download_dir" "$urls_file" "$scenario" &&
  touch "logs/.downloaded"
