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

# ------------------------------------------
# Download CHELSA v2 monthly averages of:
# - tas
# - taxmin
# - tasmax
# - pr
# ------------------------------------------
if [[ $clean == yes ]] || [[ ! -e "logs/.downloaded" ]]
then
  download=$(sbatch -p transfer --parsable slurm/submit-downloads.sh "$download_dir" "$urls_file" "$scenario" "$area")
else
  download=alreadydone
fi

# ------------------------------------------
# Calculate Bioclimatic variables
# 
# This is an array job and the array 
# parameter file is created before 
# launching the actual job.
# ------------------------------------------
if [[ $download == alreadydone ]]
then
  dependency_for_bioclim=""
else
  dependency_for_bioclim="--dependency=afterok:$download"
fi

if [[ $clean == yes ]] || [[ ! -e "logs/.bioclimed" ]]
then
  mkdir -p "$download_dir/$scenario/$area/bioclim"
  bioclim=$(sbatch --parsable $dependency_for_bioclim -a 1-$(xsv count "$biopars") slurm/submit-bioclim.sh "$download_dir" "$scenario" "$area" "$utils" "$biopars")
else
  bioclim=alreadydone
fi

