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

# tidy up the products from the GBIF script esp. & a bit from KUFS
rm(by_sps, by_sps_sum, filtered_datA_afghanistan, datA_afghanistan, datA_KUFS_byDateStatus)

# make datasource column per dataset
datA_GBIF_filtered$datasource <- "GBIF"
datA_KUFS_filtered$datasource <- "KUFS"

# make variable names equivalent
names(datA_GBIF_filtered)
names(datA_KUFS_filtered)

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

### GBIF DATASET INCLUDES NON-HERBARIUM-SPECIMEN RECORDS ###


# 2) MERGE data

### mergeset fields required:
## GBIF == KUFS
# datasource == datasource
# family == Family
# scientificname == Taxon
# recordedBy == Collector
# decimallatitude == Latitude
# decimallongitude == Longitude
# day == dateDD
# month == dateMM
# year == dateYYYY

## edit fields: GBIF

# names(datA_GBIF_filtered)
colnames(datA_GBIF_filtered)[which(names(datA_GBIF_filtered) == "family")] <- "taxonFamily"
colnames(datA_GBIF_filtered)[which(names(datA_GBIF_filtered) == "scientificname")] <- "taxonName"
colnames(datA_GBIF_filtered)[which(names(datA_GBIF_filtered) == "recordedby")] <- "collectorName"
colnames(datA_GBIF_filtered)[which(names(datA_GBIF_filtered) == "decimallatitude")] <- "latDec"
colnames(datA_GBIF_filtered)[which(names(datA_GBIF_filtered) == "decimallongitude")] <- "lonDec"
colnames(datA_GBIF_filtered)[which(names(datA_GBIF_filtered) == "day")] <- "dateDD"
colnames(datA_GBIF_filtered)[which(names(datA_GBIF_filtered) == "month")] <- "dateMM"
colnames(datA_GBIF_filtered)[which(names(datA_GBIF_filtered) == "year")] <- "dateYYYY"
colnames(datA_GBIF_filtered)[which(names(datA_GBIF_filtered) == "basisofrecord")] <- "recordType"
names(datA_GBIF_filtered)

## edit fields: KUFS
# names(datA_KUFS_filtered)
colnames(datA_KUFS_filtered)[which(names(datA_KUFS_filtered) == "Family")] <- "taxonFamily"
colnames(datA_KUFS_filtered)[which(names(datA_KUFS_filtered) == "Taxon")] <- "taxonName"
colnames(datA_KUFS_filtered)[which(names(datA_KUFS_filtered) == "Collector")] <- "collectorName"
colnames(datA_KUFS_filtered)[which(names(datA_KUFS_filtered) == "Latitude")] <- "latDec"
colnames(datA_KUFS_filtered)[which(names(datA_KUFS_filtered) == "Longitude")] <- "lonDec"
datA_KUFS_filtered$recordType <- "PRESERVED_SPECIMEN"   # add recordType to KUFS to match GBIF spx
# fix the datatype of date cols
datA_KUFS_filtered$dateDD <- as.numeric(datA_KUFS_filtered$dateDD)
datA_KUFS_filtered$dateMM <- as.numeric(datA_KUFS_filtered$dateMM) 
datA_KUFS_filtered$dateYYYY <- as.numeric(datA_KUFS_filtered$dateYYYY) 
names(datA_KUFS_filtered)

# remove unnecessary/inappropriate fields

datA_GBIF_joinset <- 
        datA_GBIF_filtered %>%
        select(taxonName, taxonFamily, collectorName, latDec, lonDec, dateDD, dateMM, dateYYYY, recordType, datasource)

datA_KUFS_joinset <- 
        datA_KUFS_filtered %>%
        select(taxonName, taxonFamily, collectorName, latDec, lonDec, dateDD, dateMM, dateYYYY, recordType, datasource)

# merge fields
mergeset <- bind_rows("KUFS"=datA_KUFS_joinset, "GBIF"=datA_GBIF_joinset, .id="setID")
# gives warning: Warning messages:
# 1: In bind_rows_(x, .id) : Unequal factor levels: coercing to character
# 2: In bind_rows_(x, .id) : Unequal factor levels: coercing to character
# 3: In bind_rows_(x, .id) : Unequal factor levels: coercing to character
# BUT this just means that the species names, collector names, family names have
# differing numbers of factor levels, which is expected and fine
# it coerces to char type which is fine for now. 

# don't really require setID field tho, it's repeat of datasource field but I
# wanted to try that arg for bind_rows() since I haven't used it before. Handy.

glimpse(mergeset)




# compare number of taxon names per dataset

# taxon names which don't match
        # how many?
        
        # fix!




# 3) Analyse data




# 4) Show the output




# 5) Save the output to .csv

### USER REMINDER: 
# write.csv() function will ask where to save file and what to call it
# enter filename including '.csv', & if asked whether to create file, say 'YES' 
# write to .csv file
# write.csv(x, file=file.choose())

# file location settings
fileLocat <- "O://CMEP\ Projects/PROJECTS\ BY\ COUNTRY/Afghanistan/ChecklistData/GBIF-KUFS_mergedData/"
fileName <- "AF_GBIF-KUFS-mergedData_"
# write filtered data out to CSV
write.csv(mergeset, file=paste0(fileLocat,fileName,Sys.Date(),".csv"), row.names = FALSE, na="")

# remove all objects from workspace
#rm(list=ls())
