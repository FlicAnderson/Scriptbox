## Afghanistan Projects :: script_mergeGBIF-KUFSrecords_Afghanistan.R
# ==============================================================================
# (10th October 2016)
# Author: Flic Anderson
#
# dependent on: 
#       O://CMEP\ Projects/Scriptbox/data_various/script_KUFSrecords.R
#       O://CMEP\ Projects/Scriptbox/data_gbif/script_GBIFData.R
# saved at: O://CMEP\ Projects/Scriptbox/data_various/script_mergeGBIF-KUFSrecords_Afghanistan.R
# source: source("O://CMEP\ Projects/Scriptbox/data_various/script_mergeGBIF-KUFSrecords_Afghanistan.R")
#
# AIM: Load KUFS herbarium records & GBIF Afghan plant records for Afghanistan
# .... projects; remove any records without useful spatial data, package for 
# .... analysis & mapping in GIS/R and other uses.

# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) Load libraries, functions, source scripts
# 1) Load data
# 2) MERGE data
# 3) Analyse data
# 4) Show the output
# 5) Save the output to .csv

# ---------------------------------------------------------------------------- #

# 0) 

# load required packages, install if they aren't installed already
# {dplyr} - manipulating data & large data frames as tbl_df objects
if (!require(dplyr)){
        install.packages("dplyr")
        library(dplyr)
}

# load other packages, functions, scripts
# ?

# 1)

# load KUFS herbarium records
source("O://CMEP\ Projects/Scriptbox/data_various/script_KUFSrecords_Afghanistan.R")
# load GBIF Afghanistan
source("O://CMEP\ Projects/Scriptbox/data_gbif/script_GBIFData_Afghanistan.R")

# rename GBIF dataset for ease of use
datA_GBIF_filtered <- datA_afghanistan

# tidy up the products from the GBIF script esp.
rm(by_sps, by_sps_sum, filtered_datA_afghanistan, datA_afghanistan)

# make variable names equivalent
names(datA_GBIF_filtered)
names(datA_KUFS_filtered)

# make datasource column per dataset
datA_GBIF_filtered$datasource <- "GBIF"
datA_KUFS_filtered$datasource <- "KUFS"

### current taxonomic setup of datasets:

# GBIF:
# family: 
# species field: binomial, no auth
# infraspecificepithet: epithet, no auth
# taxonrank: taxon level
# scientificname: full binomial plus infrasp, with auth
## to get full no-auth name:         
        # IF datA_...$taxonrank == SUBSPECIES/VARIETY/ETC
        #       paste(datA_...$species, infraspecificepithet)
        
# KUFS:
# Family:
# Taxon: full binomial with auth


### mergeset fields required:
## GBIF == KUFS
# datasource == datasource
# family == Family
# scientificname == Taxon
# recordedBy == Collector
# decimallatitude == Latitude
# decimallongitude == Longitude
# day == day
# month == month
# year == year

# compare number of taxon names per dataset
