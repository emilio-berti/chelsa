#!/bin/bash

if [[ -e future-defaults.sh ]]
then
  source future-defaults.sh
fi

function usage { cat << EOF
USAGE
    bash pipe-future.sh

DESCRIPTION
    obtain future annual climatologies using CHELSA 2

    reads defaults from defaults.sh -- see example-defaults.sh for an example which you can just copy

OPTIONS

    --area=STRING           america or europe

    --datadir=DIR           directory where to download input files
                            e.g.: /data/blah/input
                            defaults to: $datadir

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

    --area=*)
      area="${arg#--area=}"
      ;;

    --datadir=*)
      datadir="${arg#--datadir=}"
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
  datadir=$datadir
  area=$area
EOF
fi

if [[ $area == "" ]]
then 
  echo No area specified.
  exit 1
fi

if [[ $area == "europe" ]]
then
  template=$eu_template
elif [[ $area == "america" ]]
then
  template=$am_template
else
  echo "Invalid area: $area"
  exit 1
fi

echo "- Area: $area"

echo ""
echo " ======= Future Bioclim from Chelsa v.2 ======== "

# ------------------------------------------
# ------------------------------------------
if [[ $clean == yes ]] || [[ ! -e "logs/.future-$area" ]]
then
  echo " - Downloading using chelsa-cmip6"
  exp=$(sbatch --parsable -a 1-$(xsv count "$pars") slurm/submit-future.sh "$datadir" "$area" "$pars")
else
  echo " - $area already done."
  exp=alreadydone
fi

# ------------------------------------------
# Calculate Bioclimatic variables
# 
# This is an array job.
# ------------------------------------------
if [[ $exp == alreadydone ]]
then
  dependency_for_proj=""
else
  dependency_for_proj="--dependency=afterok:$exp"
fi

