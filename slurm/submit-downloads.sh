#!/bin/bash

#SBATCH -J ChelsaDownload
#SBATCH --chdir=/work/berti
#SBATCH --output=/work/%u/chelsa/%x.out
#SBATCH --mem-per-cpu=2G
#SBATCH --time=3-00:00:00

download_dir="$1"
urls_file="$2"
scenario="$3"
area="$4"

bash \
  /home/berti/chelsa/scripts/download-chelsa-bio.sh \
  "$download_dir/$scenario/$area" "$urls_file" &&
  touch "/home/berti/chelsa/logs/.downloaded"
