## Socotra Project :: script_joinIUCNRedListData_Socotra.R
# ============================================================================ #
# 25 April 2016
# Author: Flic Anderson
#
# dependant on: script_dataGrabFullLatLonOrGazLatLon_Socotra.R
# saved at: O://CMEP\-Projects/Scriptbox/[folder]/[filename]
# source: source("O://CMEP\-Projects/Scriptbox/[folder]/[filename]")
#
# AIM:  Join IUCN Plant Red List data for Socotra to the Socotra dataset on names
# ....  and where names do not match, apply a taxonomic fix as necessary.
#
# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) load libraries and source scripts
# 1) read in csv file of IUCN category data
# 2) attempt join of IUCN data on Socotra analysis dataset
# 3) pull out non-joining taxa
# 4) apply fixes for non-joining taxa
# 5) perform main join with fixes
# 6) output joined data if required

# ---------------------------------------------------------------------------- #


# 0) load libraries and source scripts

# load any required libraries?
# {dplyr} - manipulating data & large data frames as tbl_df objects
if (!require(dplyr)){
        install.packages("dplyr")
        library(dplyr)
}

# source Socotra data script
source("O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R")


# 1) read in csv file of IUCN category data

iucnDat <- read.csv("O://CMEP\ Projects/Socotra/IUCNPlantRedListCategories_Socotra.csv")

iucnDat <- tbl_df(iucnDat)


# 2) attempt join of IUCN data on Socotra analysis dataset

# filter out names where there are subspecific epithets - these are likely to be
# narrow endemics and will mess with scores a little?

# table(iucnDat$Infraspecific.rank)
#       ssp. var. 
# 353    2    1 

# remove subspecific taxa 
iucnDat <- 
        iucnDat %>%
        filter(iucnDat$Infraspecific.rank!="ssp." & iucnDat$Infraspecific.rank!="var.")

# build scientific names (above subspecific level only) from columns
# Genus + Species (+ Authority)
iucnDat <- 
        iucnDat %>%
                mutate(joinName=paste(iucnDat$Genus, iucnDat$Species)) 
#dim(iucnDat)
# 353 24


# 3) pull out non-joining taxa


# 4) apply fixes for non-joining taxa


# 5) perform main join with fixes


# 6) output joined data if required

