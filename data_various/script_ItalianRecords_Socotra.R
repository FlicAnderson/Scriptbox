## Socotra Project :: script_ItalianRecords_Socotra.R
# ==============================================================================
# (21st December 2015)
# Author: Flic Anderson
#
# dependent on: 
# saved at: O://CMEP\ Projects/Scriptbox/data_various/script_ItalianRecords_Socotra.R
# source: source("O://CMEP\ Projects/Scriptbox/data_various/script_ItalianRecords_Socotra.R")
#
# AIM: Load and wrangle data from Italian group for Socotra project. Alter format,
# .... convert coordinate system, prepare records for importing to Padme database
# .... and package for mapping in GIS etc.

# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) Load libraries, functions, source scripts
# 1) Load import copy of data
# 2) Mung/wrangle data into useful format
# 3) Change coordinate system(? - uncertain if poss to do here, otherwise via GIS)
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
  file="KUFS.csv", 
  header=TRUE, 
  sep="", 
  quote="", 
  fill=TRUE, 
  encoding="UTF-8", 
  skipNul=TRUE
  )
# 23428 obs x 1 var

dat_KUFS <- read.xlsx(
        file="KUFS.csv", 
        sheetIndex = 1,
        
        )



# look at structure of data
str(datA_afghanistan)

# make dplyr objects
datA_afghanistan <- tbl_df(datA_afghanistan)

# 2)

# for one set (Afghanistan), pull apart & filter out irrelevant data:

# check out structure again
glimpse(datA_afghanistan)

# # for instance: need to remove fossil data
#   table(datA_afghanistan$basisofrecord)
#   # 47 fossil specimens
# 
# # need to remove NA lat/lons:
#   
#   # number of NA decimal latitudes:
#   nrow(datA_afghanistan[which(is.na(datA_afghanistan$decimallatitude)),])
#   #8708
# 
#   # number of NA decimal longitudes:
#   nrow(datA_afghanistan[which(is.na(datA_afghanistan$decimallongitude)),])
#   #8708
# 
# # need to remove "0" value lat/lons: 
#   
#   # number of "0" value latitudes:
#   nrow(datA_afghanistan[which(datA_afghanistan$decimallatitude==0),])
#   # 771
#   
#   # number of "0" value longitudes:
#   nrow(datA_afghanistan[which(datA_afghanistan$decimallongitude==0),])
#   # 771
  


# create filtered LEBANON dataset:
datA_afghanistan_filtered <- 
        datA_afghanistan %>%
    filter(basisofrecord != "FOSSIL_SPECIMEN") %>%
    filter(!is.na(decimallatitude)) %>%
    filter(!is.na(decimallongitude)) %>%
    filter(decimallatitude != 0) %>%
    filter(decimallongitude != 0) 
# 28208 obs of 42 variables
  
#glimpse(datA_afghanistan_filtered)

# number of distinct taxa
length(unique(datA_afghanistan_filtered$scientificname))
# 2976

# percentage of usable records left:
round(nrow(datA_afghanistan_filtered)/nrow(datA_afghanistan)*100, digits=1)
# 99.8% :P  This is high as georef'd records with no location issues were used

# ## write out as CSV for GIS stuff:
# write.csv(
#         datA_afghanistan_filtered[
#     order(
#       datA_afghanistan_filtered$scientificname, 
#       datA_afghanistan_filtered$basisofrecord, 
#       na.last=TRUE),], 
#   file=paste0(
#     fileLocat, 
#     "GBIF_Afghanistan_filtered_", 
#     Sys.Date(), 
#     ".csv"), 
#   na="", 
#   row.names=FALSE
# )

# replace datA_afghanistan with filtered data (for brevity)
datA_afghanistan <- datA_afghanistan_filtered
rm(datA_afghanistan_filtered)

#datA_afghanistan <- 
#        select()

# # make LatLon column from concat'd AnyLat & AnyLon
datA_afghanistan <- mutate(datA_afghanistan, LatLon=paste(decimallatitude, decimallongitude, sep=" "))  

# display different taxon ranks
table(datA_afghanistan$taxonrank)
# FAMILY      GENUS    KINGDOM      ORDER    SPECIES SUBSPECIES    VARIETY 
# 123          311          7          7      26528       1023        209 

# pull out only Species and Subspecies records (26528 + 1023=> 27551 records)
datA_afghanistan <- 
        datA_afghanistan %>%
        filter(taxonrank=="SPECIES"|taxonrank=="SUBSPECIES") %>%
        # select only useful columns
        select(family, species, infraspecificepithet, taxonrank, scientificname, recordedby, identifiedby, locality, LatLon, decimallatitude, decimallongitude, day, month, year, issue)
        

# group by species & summarize by 1 variable (scientific name)
by_sps <- group_by(datA_afghanistan, scientificname)
summarize(by_sps, avgCollctn=round(mean(year, na.rm=TRUE), digits=0))  # average year of collection by species :)
summarize(by_sps, mednCollctn=round(median(year, na.rm=TRUE), digits=0))  # median year of collection by species :)
summarize(by_sps, maxCollctn=max(year, na.rm=TRUE))  # most recent year of collection by species :)

# group by species and summarize by multiple variables
by_sps <- group_by(datA_afghanistan, scientificname)
by_sps_sum <- summarize(by_sps, 
                        count=n(),
                        collectedBy=n_distinct(recordedby), 
                        mostRecentCollection=max(year, na.rm=TRUE), 
                        uniqueLatLon=n_distinct(LatLon),
                        uniqueLocation=n_distinct(locality)
)
by_sps_sum

#number of taxa with over 10 unique lat+lon locations:
filter(by_sps_sum, uniqueLatLon>10)
# 698 @ 18/Nov/2015

#number of taxa with over 10 unique named-locations:
filter(by_sps_sum, uniqueLocation>10)
# 727 @ 18/Nov/2015

# number of taxa with over 10 occurrences/records:
filter(by_sps_sum, count>10)
# 762 taxa with >10 unique latlon locations @ 18/Nov/2015

# records by family, species & listing ~unique records (where there are >5 unique location points/'dots on map')
filtered_datA_afghanistan <- 
        datA_afghanistan %>%
        mutate(recordInfo=paste(scientificname, recordedby, LatLon)) %>%
        group_by(family, scientificname) %>%        # group by familyName AND scientificname
        arrange(scientificname) %>%         # sort by scientificname
        summarize(count=n(),
                  #collectedBy=n_distinct(recordedby), 
                  #mostRecentCollection=max(year, na.rm=TRUE), 
                  uniqueLatLon=n_distinct(LatLon),
                  AppxUniqueRex=n_distinct(recordInfo)
                  #uniqueLocation=n_distinct(locality)
        ) %>%
        filter(uniqueLatLon>5) # only show taxa where there are over 5 unique Lat/Lon combos
#head
# 1076 taxa (over 5 unique Lat/Lons; 2856 if that's removed)

# write this out to CSV
write.csv(
        filtered_datA_afghanistan,
        file=file.choose(),
        na="", 
        row.names=FALSE
)


# check out http://rcastilho.pt/SDM101/SDM_files/Occurrence_data.R for land/sea point filtering and stuff
# check out http://hydrodictyon.eeb.uconn.edu/people/cmerow/home/r_resources_files/AMNH_R_Conference/Scripts/1_Matt_AielloLammens.R for anti-duplicates and such
# check out http://www.esapubs.org/archive/ecos/C004/004/Rcode.R for species name edits and such