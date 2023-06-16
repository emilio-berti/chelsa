#!/bin/bash

if [[ -e defaults.sh ]]
then
  source defaults.sh
fi

function usage { cat << EOF
USAGE
    bash pipe-chelsa.sh

DESCRIPTION
    download and process CHELSA v2 with SLURM

    reads defaults from defaults.sh -- see example-defaults.sh for an example which you can just copy

OPTIONS

    --scenario=STRING       present or future

    --area=STRING           europe or america

    --download-dir=DIR      directory where to download input files
                            e.g.: /data/blah/input
                            defaults to: $download_dir                  

    --urls-file=FILE        file with the URLs to download
                            e.g.: /path/to/envidatS3paths-bio.txt
                            defaults to: $urls_file
    
    --verbose | -v          adds verbose output
                            defaults to: no

    --clean                 does EVERYTHING
                            defaults to: no

EOF
}

clean=no
verbose=no

for arg in "$@"
do
  case "$arg" in
    -\?|--help)
      usage
      exit
      ;;

    --scenario=*)
      scenario="${arg#--scenario=}"
      ;;

    --area=*)
      area="${arg#--area=}"
      ;;

    --download-dir=*)
      download_dir="${arg#--download-dir=}"
      ;;

    --urls-file=*)
      urls_file="${arg#--urls-file=}"
      ;;

    --clean)
      clean=yes
      shift
      ;;

    -v|--verbose)
      verbose=yes
      shift
      ;;

    --)
      shift
      break
      ;;

    -*)
      echo "unrecognized option: $1" >&2
      exit 1
      ;;

    *)
      break
      ;;
  esac
done

if [[ $verbose == yes ]]
then
  cat << EOF
  download_dir=$download_dir
  urls_file=$urls_file
  proj=$proj
  eu_proj=$eu_proj
  am_proj=$am_proj
EOF
fi

if [[ $scenario == "" ]]
then
  echo No scenario specified: assuming present
  scenario="present"
fi

if [[ $area == "" ]]
then 
  echo No area specified: assuming whole world.
  area="world"
fi

if [[ $scenario != "present" ]] && [[ $scenario != "future" ]]
then
  echo INVALID SCENARIO $scenario
  exit 1
fi

if [[ $area != "europe" ]] && [[ $area != "america" ]] && [[ $area != "world" ]]
then
  echo INVALID AREA $area
  exit 1
fi

if [[ $scenario == "future" ]]
then
  urls_file=""
  download_dir="data/original/"
fi

if [[ $area == "europe" ]]
then
  proj_file=$eu_proj
elif [[ $area == "america" ]]
then
  proj_file=$am_proj
else
  proj_file=$proj
fi

echo "- Scenario: $scenario"
echo "- Area: $area"
echo "- Crs: $proj_file"
cat $proj_file

mkdir -p $download_dir/$scenario/$area

echo ""
echo " ======= Process Bioclim from Chelsa v.2 ======== "

# ------------------------------------------
# Download CHELSA v2 monthly averages of:
# - tas
# - taxmin
# - tasmax
# - pr
# ------------------------------------------
if [[ $clean == yes ]] || [[ ! -e "logs/.downloaded" ]]
then
  echo " - Downloading CHELSA v.2"
  download=$(sbatch -p transfer --parsable slurm/submit-downloads.sh "$download_dir" "$urls_file" "$scenario" "$area")
else
  echo " - CHELSA already downloaded"
  download=alreadydone
fi

# ------------------------------------------
# Calculate Bioclimatic variables
# 
# This is an array job.
# ------------------------------------------
if [[ $download == alreadydone ]]
then
  dependency_for_bioclim=""
else
  dependency_for_bioclim="--dependency=afterok:$download"
fi

if [[ $clean == yes ]] || [[ ! -e "logs/.bioclimed" ]]
then
  echo " - Launching bioclim jobs..."
  mkdir -p "$download_dir/$scenario/$area/bioclim"
  bioclim=$(sbatch --parsable $dependency_for_bioclim -a 1-$(xsv count "$biopars") slurm/submit-bioclim.sh "$download_dir" "$scenario" "$area" "$utils" "$biopars")
else
  echo " - Bioclimatic variables already calculated"
  bioclim=alreadydone
fi

# ------------------------------------------
# Project and Crop to Area
# 
# This is an array job. 
# ------------------------------------------
if [[ $bioclim == alreadydone ]]
then
  dependency_for_project=""
else
  dependency_for_project="--dependency=afterok:$bioclim"
fi

if [[ "$area" == world ]]
then 
  echo " - Cannot project for area: $area. skipping..."
else
  if [[ $clean == yes ]] || [[ ! -e "logs/.projected-$area-$scenario" ]]
  then
    echo " - Launching projection jobs..."
    mkdir -p "$download_dir/$scenario/$area"
    project=$(sbatch --parsable $dependency_for_project -a 1-$(xsv count "$projpars") slurm/submit-project.sh "$download_dir" "$scenario" "$area" "$projpars")
  else
    echo " - Bioclimatic variables already projected"
    project=alreadydone
  fi
fi

# ------------------------------------------
# Extract Timeseries
#
# Extract timeseries from rasters and save
# a dataframe with cellID, x (lon), y (lat),
# and value for each year.
# ------------------------------------------
if [[ $project == alreadydone ]]
then
  dependency_for_ts=""
else
  dependency_for_ts="--dependency=afterok:$project"
fi

if [[ "$area" == world ]]
then
  echo " - Cannot serialized for area: $area. skipping..."
else
  if [[ $clean == yes ]] || [[ ! -e "logs/.serialized-$area-$scenario" ]]
  then 
    echo " - Launching timeseries jobs..."
    ts=$(sbatch --parsable $dependency_for_ts -a 1-$(xsv count "$tspars") slurm/submit-timeseries.sh "$download_dir" "$scenario" "$area" "$utils" "$tspars")
  else
    echo " - Timeseries already extracted"
    ts=alreadydone
  fi
fi

echo " ================================================ "
echo ""
