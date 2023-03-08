# Bioclimatic Variables

This repository contains the code to create bioclimatic variables annual timeseries.
The bioclimatic variables of interest are: 

  1. Mean Temperature of Warmest Quarter (**BIO10**): the warmest quarter of the year is determined (to the nearest month), and the mean temperature of this period is calculated.
  2. Mean Temperature of Coldest Quarter (**BIO11**): the coldest quarter of the year is determined (to the nearest month), and the mean temperature of this period is calculated.
  3. Precipitation of Wettest Period (**BIO13**): the precipitation of the wettest month.
  4. Precipitation of Driest Period (**BIO14**): the precipitation of the driest month.

To calculate these, four climatic variables are needed:

  - Mean temperature (_tas_ in CHELSA).
  - Minimum temperature (_tasmin_).
  - Maximum temperature (_tasmax_).
  - Precipitation (_pr_).

## Interpolation

## Future
I included five Global Circulation Models (GCMs):

  - GFDL-ESM4 (USA).
  - UKESM1-0-LL.
  - MPI-ESM1-2-HR (Germany).
  - IPSL-CM6A-LR (France).
  - MRI-ESM2-0 (Japan).

I included four Shared Socioeconomic Pathways (SSPs):

  - 1-2.6: sustainiability (Taking the Green Road).
  - 2-4.5: business as usual (Middle of the Road).
  - 3-7.0: regional rivalry (A Rocky Road).
  - 5-8.5: fossil-fueled development (Taking the Highway).