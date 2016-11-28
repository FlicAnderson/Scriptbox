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
names(datA_GBIF_filtered)[1] <- "taxonFamily"
names(datA_GBIF_filtered)[5] <- "taxonName"
names(datA_GBIF_filtered)[6] <- "collectorName"
names(datA_GBIF_filtered)[10] <- "latDec"
names(datA_GBIF_filtered)[11] <- "lonDec"
names(datA_GBIF_filtered)[12] <- "dateDD"
names(datA_GBIF_filtered)[13] <- "dateMM"
names(datA_GBIF_filtered)[14] <- "dateYYYY"
names(datA_GBIF_filtered)[15] <- "recordType"

# > names(datA_GBIF_filtered)
# [1] "taxonFamily"          "species"              "infraspecificepithet" "taxonrank"            "taxonName"            "collectorName"       
# [7] "identifiedby"         "locality"             "LatLon"               "latDec"               "lonDec"               "dateDD"              
# [13] "dateMM"               "dateYYYY"             "recordType"           "issue"                "datasource" 

## edit fields: KUFS

# names(datA_KUFS_filtered)
colnames(datA_KUFS_filtered)[which(names(datA_KUFS_filtered) == "Family")] <- "taxonFamily"
colnames(datA_KUFS_filtered)[which(names(datA_KUFS_filtered) == "Taxon")] <- "taxonName"
colnames(datA_KUFS_filtered)[which(names(datA_KUFS_filtered) == "Collector")] <- "collectorName"

names(datA_KUFS_filtered)[13] <- "latDec"
names(datA_KUFS_filtered)[14] <- "lonDec"
names(datA_KUFS_filtered)[10] <- "dateXXXX"
datA_KUFS_filtered$recordType <- "PRESERVED_SPECIMEN"   # add recordType to KUFS to match GBIF spx
datA_KUFS_filtered$dateDD <- NA
datA_KUFS_filtered$dateMM <- NA
datA_KUFS_filtered$dateYYYY <- NA

# > names(datA_KUFS_filtered)
# [1] "Specimen.ID"              "Herbarium.Number.BarCode" "Collection"               "Collection.Number"        "Type.information"        
# [6] "Typified.by"              "taxonName"                "taxonFamily"              "collectorName"            "dateXXXX"                
# [11] "Country"                  "Admin1"                   "latDec"                   "lonDec"                   "Altitude.lower"          
# [16] "Altitude.higher"          "Label"                    "det..rev..conf..assigned" "ident..history"           "annotations"             
# [21] "datasource"               "recordType"               "dateDD"                   "dateMM"                   "dateYYYY"  


#mergesetAF <- as.data.frame(c("datasource", "taxonFamily", "taxonName", "collectorName", "latDec", "lonDec", "dateDD", "dateMM", "dateYYYY", "recordType"))


# merge fields

# remove unnecessary/inappropriate fields

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



# VERY IMPORTANT!
# CLOSE DATABASE CONNECTIONs & REMOVE OBJECTS FROM WORKSPACE!
odbcCloseAll()
rm(list=ls())
