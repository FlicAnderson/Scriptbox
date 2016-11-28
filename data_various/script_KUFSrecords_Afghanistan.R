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
# .... remove any records without useful spatial data
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
  file="KUFS_cleanedData.csv", 
  na.strings=""  # deals with NA - necessary!
  # header=TRUE, 
  # sep="", 
  # quote="", 
  # fill=TRUE, 
  # encoding="UTF-8", 
  # skipNul=TRUE
)
# 23428 obs x 1 var

# > names(datA_KUFS)
# [1] "Specimen.ID"              "Herbarium.Number.BarCode"
# [3] "Collection"               "Collection.Number"       
# [5] "Type.information"         "Typified.by"             
# [7] "Taxon"                    "Family"                  
# [9] "Collector"                "OrigCollector"           
# [11] "Date"                     "OrigDate"                
# [13] "Country"                  "Admin1"                  
# [15] "Latitude"                 "Longitude"               
# [17] "Altitude.lower"           "Altitude.higher"         
# [19] "Label"                    "det..rev..conf..assigned"
# [21] "DetAuth"                  "DetDate"                 
# [23] "ident..history"           "annotations"             

# look at structure of data
str(datA_KUFS)

# make dplyr objects
datA_KUFS <- tbl_df(datA_KUFS)

# 2)

# check out structure again
glimpse(datA_KUFS)

# Fix date format (eg. "1973-08-29")
# create dateDD, dateMM, dateYYYY fields, create 'orig' field set as the open-refine
# cleaned Date field, NOT OrigDate field which has NOT been cleaned in openrefine, 
# and create dateStatus field to allow subsetting out borked date records for fixing/attention
datA_KUFS$dateDD <- NA
datA_KUFS$dateMM <- NA
datA_KUFS$dateYYYY <- NA
datA_KUFS$orig <- datA_KUFS$Date
datA_KUFS$dateStatus <- NA

# works to find year followed by any of: dash, space, slash or dot. 
# grepl("[19|20][0-9][0-9][- /.]", datA_KUFS)
# match year beginning 19- or 20-, month, day
#grepl("[19|20][0-9][0-9][- /.][0|1][0-9][- /.][0|1|2|3][0-9]", datA_KUFS$orig)

# if pattern matches YYYY MM DD then throw respective bits into datA_KUFS$dateYYYY, datA_KUFS$dateMM, datA_KUFS$dateDD 
# IF NOT: 
# capture year only if this is legit, 
# or if nothing is clearly legit, give dateStatus "problematic"

# set counter
i <- 1

# run loop
for(i in 1:length(datA_KUFS$orig)){
        # if year matches YYYY-MM-DD pattern with dots, spaces, dashes or slashes:
        if((grepl("[19|20][0-9][0-9][- /.][0|1][0-9][- /.][0|1|2|3][0-9]$", datA_KUFS$orig[i])==TRUE) && (as.numeric(as.character(substr(datA_KUFS$orig[i], start=1, stop=4))) > 1800)){
                # cut up the parts & put ito separate columns
                datA_KUFS$dateYYYY[i] <- as.character(substr(datA_KUFS$orig[i], start=1, stop=4))
                datA_KUFS$dateMM[i] <- substr(datA_KUFS$orig[i], start=6,stop=7)
                datA_KUFS$dateDD[i] <- substr(datA_KUFS$orig[i], start=9, stop=10)
                datA_KUFS$dateStatus[i] <- "fine"
        } else {
        # if year matches YYYY-MM-DD pattern with dots, spaces, dashes or slashes:
                # if date STARTS WITH a year, AND is only a year (as.numeric(date)) works & doesn't give NA:
                if(grepl("^([19|20][0-9][0-9])", datA_KUFS$orig[i], perl=TRUE) && (nchar(as.character(datA_KUFS$orig[i]))==4) && (!is.na(as.numeric(datA_KUFS$orig[i]))==TRUE)){
                        # if date starts with a year and is only a year:
                        datA_KUFS$dateYYYY[i] <- as.character(datA_KUFS$orig[i]) 
                        datA_KUFS$dateMM[i] <- NA
                        datA_KUFS$dateDD[i] <- NA
                        datA_KUFS$dateStatus[i] <- "year only"
                } else {
                        if((nchar(as.character(datA_KUFS$orig[i]))==4) && (as.character(datA_KUFS$orig[i]) < 1800)){
                                datA_KUFS$dateStatus[i] <- "year wrong"
                        } else {
                                if(nchar(as.character(datA_KUFS$orig[i]))!=4){
                                        datA_KUFS$dateYYYY[i] <- NA
                                        datA_KUFS$dateMM[i] <- NA
                                        datA_KUFS$dateDD[i] <- NA
                                        datA_KUFS$dateStatus[i] <- "problematic"
                                } else {
                                        # otherwise if date DOES NOT START WITH a year, 
                                        # or is not only datA_KUFS year ie. (as.numeric(date)) 
                                        # does NOT work & gives NA:
                                        datA_KUFS$dateYYYY[i] <- NA
                                        datA_KUFS$dateMM[i] <- NA
                                        datA_KUFS$dateDD[i] <- NA
                                        datA_KUFS$dateStatus[i] <- "problematic"
                                }
                        }
                }
        }
        
        i <- i +1
        
}

#print(datA_KUFS)


# reset counter
i <- 1
# deal with things where dateMM contains things higher than 12...
for(i in 1:length(datA_KUFS$orig)){
        if(!is.na(datA_KUFS$dateMM[i]) && (as.numeric(datA_KUFS$dateMM[i]) > 12)){
                # leave year, but remove month and day since they're probably random...
                datA_KUFS$dateMM[i] <- NA
                datA_KUFS$dateDD[i] <- NA
                datA_KUFS$dateStatus[i] <- "problematic"
        }
        i <- i +1
}

# no records where dateDD is higher than 31, so don't need to implement anything for this
#which(as.numeric(datA_KUFS_filtered$dateDD) > 31)
# reset counter
i <- 1
# deal with things where dateDD contains things higher than 31...
for(i in 1:length(datA_KUFS$orig)){
        if(!is.na(datA_KUFS$dateDD[i]) && (as.numeric(datA_KUFS$dateDD[i]) > 31)){
                # leave year, but remove month and day since they're probably random...
                datA_KUFS$dateMM[i] <- NA
                datA_KUFS$dateDD[i] <- NA
                datA_KUFS$dateStatus[i] <- "problematic"
        }
        i <- i +1
}

# blank date records should be tagged separately
# reset counter
i <- 1
# deal with things where date is blank
for(i in 1:length(datA_KUFS$orig)){
        if(is.na(datA_KUFS$orig[i])){
                datA_KUFS$dateStatus[i] <- "blank"
        }
        i <- i +1
}

# # date years before 1800 should be flagged up as possibly wrong
# # reset counter
# i <- 1
# # deal with things where date is blank
# for(i in 1:length(datA_KUFS$orig)){
# 
#         i <- i +1
# }


# things like "Fall 1970" aren't captured but end up with "problematic" tag
# NA origs are given "blank" tag.

# pull apart how many are in each dateStatus group:
datA_KUFS_byDateStatus <- 
        datA_KUFS %>%
        group_by(dateStatus) %>%
        summarise(count=n()) %>%
        print

#    dateStatus count
#         <chr> <int>
# 1       blank   700
# 2        fine 22197
# 3 problematic   435
# 4   year only    96

# remove numerics from collector name! 
# No need, since this was done in open refine

# check: if this runs and nrow(a)>0, then there's an issue in the loops
#a<- as.data.frame(datA_KUFS[which(as.numeric(datA_KUFS$dateYYYY <1800)==TRUE),])
#head(a)

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
        filter(!is.na(Longitude)) %>%
        filter(dateStatus!="problematic")
# 13049 obs of 20 variables
# (removed 41 "problematic" records)

   
glimpse(datA_KUFS_filtered)
# 
# # number of distinct taxa
length(unique(datA_KUFS_filtered$Taxon))
# 3087

# # percentage of usable records left:
round(nrow(datA_KUFS_filtered)/nrow(datA_KUFS)*100, digits=1)
# 55.9% :c  This is low as non-georef'd records were removed
# 55.7% once "problematic" dates removed

# remove non-filtered data
#rm(datA_KUFS)

# check: if this runs and nrow(aa)>0, then there's an issue in the loops
#aa<- as.data.frame(datA_KUFS_filtered[which(as.numeric(datA_KUFS_filtered$dateYYYY <1800)==TRUE),])
#head(aa)


# file location settings
fileLocat <- "O://CMEP\ Projects/PROJECTS\ BY\ COUNTRY/Afghanistan/KUFS\ Records/"
fileName <- "AF_refinedData"
# write filtered data out to CSV
write.csv(datA_KUFS_filtered, file=paste0(fileLocat,fileName,Sys.Date(),".csv"), row.names = FALSE, na="")

# pull apart how many are in each dateStatus group:
#datA_KUFS_byDateStatus <- 
        datA_KUFS_filtered %>%
        group_by(dateStatus) %>%
        summarise(count=n()) %>%
        print

# REMOVE UNNECESSARY OBJECTS FROM WORKSPACE
rm(datA_KUFS, i, fileLocat, fileName)


################################################################################

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








# check out http://rcastilho.pt/SDM101/SDM_files/Occurrence_data.R for land/sea point filtering and stuff
# check out http://hydrodictyon.eeb.uconn.edu/people/cmerow/home/r_resources_files/AMNH_R_Conference/Scripts/1_Matt_AielloLammens.R for anti-duplicates and such
# check out http://www.esapubs.org/archive/ecos/C004/004/Rcode.R for species name edits and such