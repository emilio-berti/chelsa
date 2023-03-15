#!/bin/bash

#SBATCH -J ChelsaTS
#SBATCH --chdir=/work/berti
#SBATCH --output=/work/%u/chelsa/%x-%A-%a.out
#SBATCH --mem-per-cpu=40G
#SBATCH --time=0-00:20:00

array_or_job_id=${SLURM_ARRAY_JOB_ID:-$SLURM_JOB_ID}

data_dir="$1"
scenario="$2"
area="$3"
utils="$4"
pars="$5"

module load GCC/10.2.0 OpenMPI/4.0.5 R/4.0.4-2

Rscript --vanilla \
  /home/berti/chelsa/scripts/timeseries.R \
  "$data_dir" "$scenario" "$area" "$utils" "$pars" &&
  touch "/home/berti/chelsa/logs/.serialized-$area-$scenario"
