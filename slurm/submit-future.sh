#!/bin/bash

#SBATCH -J ChelsaFuture
#SBATCH --chdir=/work/berti
#SBATCH --output=/work/%u/chelsa/%x-%A-%a.out
#SBATCH --mem-per-cpu=10G
#SBATCH --time=0-01:00:00

array_or_job_id=${SLURM_ARRAY_JOB_ID:-$SLURM_JOB_ID}

datadir="$1"
#datadir="/data/idiv_brose/emilio/chelsa/original/"
area="$2"
#area="america"
pars="$3"
#pars="/home/berti/chelsa/future-pars.csv"

module load GCCcore/12.2.0 Python/3.10.8
source /home/berti/chelsa/chelsa/bin/activate

python3 \
  /home/berti/chelsa/scripts/future.py \
  "$datadir" "$area" "$pars"
#  touch "/home/berti/chelsa/logs/.projected-$area-$scenario"
