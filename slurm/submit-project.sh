#!/bin/bash

#SBATCH -J ChelsaProject
#SBATCH --chdir=/work/berti
#SBATCH --output=/work/%u/chelsa/%x-%A-%a.out
#SBATCH --mem-per-cpu=20G
#SBATCH --time=0-01:00:00

array_or_job_id=${SLURM_ARRAY_JOB_ID:-$SLURM_JOB_ID}

download_dir="$1"
scenario="$2"
area="$3"
pars="$4"

module load GCC/10.2.0 OpenMPI/4.0.5 R/4.0.4-2

Rscript --vanilla \
  /home/berti/chelsa/scripts/project.R \
  "$download_dir" "$scenario" "$area" "$pars" &&
  touch "/home/berti/chelsa/logs/.projected"
