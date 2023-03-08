#!/bin/bash

#SBATCH -J Bioclim
#SBATCH --chdir=/work/berti
#SBATCH --output=/work/%u/%x-%j.out
#SBATCH --mem-per-cpu=20G
#SBATCH --time=0-10:00:00

array_or_job_id=${SLURM_ARRAY_JOB_ID:-$SLURM_JOB_ID}

download_dir="$1"
scenario="$2"
area="$3"
pars="$4"

Rscript --vanilla \
  /home/berti/chelsa/scripts/bioclim-from-monthly.R \
  "$download_dir/$scenario/$area" "$pars" &&
  touch "/home/berti/logs/.bioclimed"
