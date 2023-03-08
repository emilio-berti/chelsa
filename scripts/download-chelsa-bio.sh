#!/bin/bash

echo " - Download CHELSA monthly timeseries"

DIR="$1"
if [ -d $DIR ]
then
  cd $DIR
else
  exit 1
fi

URLS_FILE="$2"

# create array
mapfile -t chelsa < "$URLS_FILE"

echo " - Downloading"

# download files that were not already downloaded
for x in "${chelsa[@]}"
do
  z=$(echo "$x" | cut -d "/" -f 10) #drops the url except file name
  if [ ! -f $z ]
  then
    echo "     Downloading $z"
    wget -q $x || exit 1
    fi
done

echo " - Download finished"
echo " - END"
cd -
