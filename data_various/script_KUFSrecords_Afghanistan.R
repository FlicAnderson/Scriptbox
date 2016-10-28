## Afghanistan Projects :: script_KUFSrecords_Afghanistan.R
# ==============================================================================
# (18th November 2015)
# Author: Flic Anderson
#
# dependent on: 
# saved at: O://CMEP\ Projects/Scriptbox/data_various/script_KUFSrecords.R
# source: source("O://CMEP\ Projects/Scriptbox/data_various/script_KUFSrecords.R")
#
# AIM: Load and analyse KUFS herbarium records for Afghanistan project
# .... remove any records without useful spatial data
# .... package for mapping in GIS etc.

# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) Load libraries, functions, source scripts
# 1) Load data
# 2) Subset data
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
# # {xlsx} - spreadsheets
# if (!require(xlsx)){
#         install.packages("xlsx")
#         library(xlsx)
# }

# 1)

# read the data from tab-sep .csv files. 

## To get rid of warning message:
#     In scan(file = file, what = what, sep = sep, quote = quote, dec = dec,  :
#     embedded nul(s) found in input
# add argument: skipNul=TRUE

## To get rid of warning message:
#     In scan(file, what, nmax, sep, dec, quote, skip, nlines, na.strings,  :
#     EOF within quoted string
# add argument: quote=""

# set working directory to avoid ungainly file location strings:
setwd("O://CMEP\ Projects/PROJECTS\ BY\ COUNTRY/Afghanistan/KUFS\ Records/")
fileLocat <- "O://CMEP\ Projects/PROJECTS\ BY\ COUNTRY/Afghanistan/KUFS\ Records/"

datA_KUFS <- read.csv(
  file="KUFS.csv", 
  na.strings=""  # deals with NA - necessary!
  # header=TRUE, 
  # sep="", 
  # quote="", 
  # fill=TRUE, 
  # encoding="UTF-8", 
  # skipNul=TRUE
)
# 23428 obs x 1 var

#dat_KUFS <- read.xlsx(
#        file="KUFS.csv", 
#        sheetIndex = 1,
#        
#        )

# > names(datA_KUFS)
# [1] "Specimen.ID"              "Herbarium.Number.BarCode" "Collection"               "Collection.Number"        "Type.information"        
# [6] "Typified.by"              "Taxon"                    "Family"                   "Collector"                "Date"                    
# [11] "Country"                  "Admin1"                   "Latitude"                 "Longitude"                "Altitude.lower"          
# [16] "Altitude.higher"          "Label"                    "det..rev..conf..assigned" "ident..history"           "annotations" 

# look at structure of data
str(datA_KUFS)

# make dplyr objects
datA_KUFS <- tbl_df(datA_KUFS)

# 2)

# check out structure again
glimpse(datA_KUFS)

# Fix date format (eg. "1973-08-29")
datA_KUFS$dateDD <- datA_KUFS$Date
datA_KUFS$dateMM <- datA_KUFS$Date
datA_KUFS$dateYYYY <- datA_KUFS$Date

### work on this ####
#strsplit(as.character(a), split="-")
### FINISH THIS!!! #####

# remove numerics from collector name! 
### FINISH THIS!!! #####


# need to remove NA lat/lons:
 
# number of NA decimal latitudes:
nrow(datA_KUFS[which(is.na(datA_KUFS$Latitude)),])
#10316

# number of NA decimal longitudes:
nrow(datA_KUFS[which(is.na(datA_KUFS$Longitude)),])
#10255

# do we need to remove "0" value lat/lons?: 

# number of "0" value latitudes:
nrow(datA_KUFS[which(datA_KUFS$Latitude==0),])
# 0

# number of "0" value longitudes:
nrow(datA_KUFS[which(datA_KUFS$Longitude==0),])
# 0


# create filtered AFGHANISTAN dataset:
datA_KUFS_filtered <- 
        datA_KUFS %>%
        filter(!is.na(Latitude)) %>%
        filter(!is.na(Longitude))
# 13090 obs of 20 variables

   
glimpse(datA_KUFS_filtered)
# 
# # number of distinct taxa
length(unique(datA_KUFS_filtered$Taxon))
# 3087

# # percentage of usable records left:
round(nrow(datA_KUFS_filtered)/nrow(datA_KUFS)*100, digits=1)
# 55.9% :c  This is low as non-georef'd records were removed

# remove non-filtered data
rm(datA_KUFS)






# # ## write out as CSV for GIS stuff:
# # write.csv(
# #         datA_KUFS_filtered[
# #     order(
# #       datA_KUFS_filtered$scientificname, 
# #       datA_KUFS_filtered$basisofrecord, 
# #       na.last=TRUE),], 
# #   file=paste0(
# #     fileLocat, 
# #     "GBIF_Afghanistan_filtered_", 
# #     Sys.Date(), 
# #     ".csv"), 
# #   na="", 
# #   row.names=FALSE
# # )
# 
# # replace datA_KUFS with filtered data (for brevity)
# datA_KUFS <- datA_KUFS_filtered
# rm(datA_KUFS_filtered)
# 
# #datA_KUFS <- 
# #        select()
# 
# # # make LatLon column from concat'd AnyLat & AnyLon
# datA_KUFS <- mutate(datA_KUFS, LatLon=paste(decimallatitude, decimallongitude, sep=" "))  
# 
# # display different taxon ranks
# table(datA_KUFS$taxonrank)
# # FAMILY      GENUS    KINGDOM      ORDER    SPECIES SUBSPECIES    VARIETY 
# # 123          311          7          7      26528       1023        209 
# 
# # pull out only Species and Subspecies records (26528 + 1023=> 27551 records)
# datA_KUFS <- 
#         datA_KUFS %>%
#         filter(taxonrank=="SPECIES"|taxonrank=="SUBSPECIES") %>%
#         # select only useful columns
#         select(family, species, infraspecificepithet, taxonrank, scientificname, recordedby, identifiedby, locality, LatLon, decimallatitude, decimallongitude, day, month, year, issue)
#         
# 
# # group by species & summarize by 1 variable (scientific name)
# by_sps <- group_by(datA_KUFS, scientificname)
# summarize(by_sps, avgCollctn=round(mean(year, na.rm=TRUE), digits=0))  # average year of collection by species :)
# summarize(by_sps, mednCollctn=round(median(year, na.rm=TRUE), digits=0))  # median year of collection by species :)
# summarize(by_sps, maxCollctn=max(year, na.rm=TRUE))  # most recent year of collection by species :)
# 
# # group by species and summarize by multiple variables
# by_sps <- group_by(datA_KUFS, scientificname)
# by_sps_sum <- summarize(by_sps, 
#                         count=n(),
#                         collectedBy=n_distinct(recordedby), 
#                         mostRecentCollection=max(year, na.rm=TRUE), 
#                         uniqueLatLon=n_distinct(LatLon),
#                         uniqueLocation=n_distinct(locality)
# )
# by_sps_sum
# 
# #number of taxa with over 10 unique lat+lon locations:
# filter(by_sps_sum, uniqueLatLon>10)
# # 698 @ 18/Nov/2015
# 
# #number of taxa with over 10 unique named-locations:
# filter(by_sps_sum, uniqueLocation>10)
# # 727 @ 18/Nov/2015
# 
# # number of taxa with over 10 occurrences/records:
# filter(by_sps_sum, count>10)
# # 762 taxa with >10 unique latlon locations @ 18/Nov/2015
# 
# # records by family, species & listing ~unique records (where there are >5 unique location points/'dots on map')
# filtered_datA_KUFS <- 
#         datA_KUFS %>%
#         mutate(recordInfo=paste(scientificname, recordedby, LatLon)) %>%
#         group_by(family, scientificname) %>%        # group by familyName AND scientificname
#         arrange(scientificname) %>%         # sort by scientificname
#         summarize(count=n(),
#                   #collectedBy=n_distinct(recordedby), 
#                   #mostRecentCollection=max(year, na.rm=TRUE), 
#                   uniqueLatLon=n_distinct(LatLon),
#                   AppxUniqueRex=n_distinct(recordInfo)
#                   #uniqueLocation=n_distinct(locality)
#         ) %>%
#         filter(uniqueLatLon>5) # only show taxa where there are over 5 unique Lat/Lon combos
# #head
# # 1094 taxa (over 5 unique Lat/Lons; 2972 if that's removed)






# # write this out to CSV
# write.csv(
#         filtered_datA_KUFS,
#         file=file.choose(),
#         na="", 
#         row.names=FALSE
# )


# check out http://rcastilho.pt/SDM101/SDM_files/Occurrence_data.R for land/sea point filtering and stuff
# check out http://hydrodictyon.eeb.uconn.edu/people/cmerow/home/r_resources_files/AMNH_R_Conference/Scripts/1_Matt_AielloLammens.R for anti-duplicates and such
# check out http://www.esapubs.org/archive/ecos/C004/004/Rcode.R for species name edits and such