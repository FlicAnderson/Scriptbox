## Padme Output :: script_summary-dataGrabFullLatLonOrGazLatLon_Oman.R
# ============================================================================ #
# 15 November 2018
# Author: Flic Anderson
#
# dependant on: O://CMEP\-Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Arabia.R
#
# source("O:/CMEP\ Projects/Scriptbox/database_analysis/script_summary-dataGrabFullLatLonOrGazLatLon_Oman.R")
#
# AIM:  Summarises data from script_dataGrabFullLatLonOrGazLatLon_Arabia.R script
# ....  number of unique datapoints, various info on types of records, families, 
# ....  breakdown by collector 
#
# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) install/load packages
# 1) load data
# 2) tbl_df() data for use by dplyr
# 3) 
# 4) 
# 5) 

# ---------------------------------------------------------------------------- #


# 0) load required packages, install if they aren't installed already

# {dplyr} - manipulating data & large data frames as tbl_df objects
if (!require(dplyr)){
  install.packages("dplyr")
  library(dplyr)
}


# 1)  pull in data & create recGrab object: 

source("O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Oman.R")

# remove non-useful stuff
rm(qry1, qry2, qry3, locat_livePadmeArabia, herbRex, fielRex, litrRex, dups)

# 2) diagnostic stuff

# Number of taxa:
#length(unique(recGrab$acceptDetAs))
# 2208 taxa at 15 November 2018

# create object
#taxaListOman <- unique(recGrab$acceptDetAs)
#head(sort(taxaListOman))

# write list of unique taxa
#message(paste0(" ... saving list of accepted taxa names to: O://CMEP\ Projects/taxaListOman_", Sys.Date(), ".csv"))
#write.csv(sort(taxaListOman), file=paste0("O://CMEP\ Projects/taxaListOman_", Sys.Date(), ".csv"), row.names=FALSE)

# Number of unique locations? (unique(paste0(AnyLat + AnyLon)))
#length(unique(paste(recGrab$AnyLat, recGrab$AnyLon)))
# 2713 @ 15 November 2018

# use DPLYR to manipulate data

# load the data into a dataframe tbl data object aka tbl-df
OmanData <- tbl_df(recGrab)

# get names of variables
names(OmanData)

### dplyr showcase START ###

#?manip  # gives info on manipulation functions

# select() {dplyr} function:
  # pulls out only some variables
  # select(datasource, column1, column2, column5)
#  select(OmanData, acceptDetAs, collector, collNumFull)

# filter() {dplyr} function:
  # filter by specific criteria
  # filter(datasource, column1 subset, column5 subset)
#  filter(OmanData, acceptDetAs=="Aerva revoluta Balf.f.")

# arrange() {dplyr} function:
  # sort & order columns, but don't need to stick to original display order of columns
  # arrange(datasource, column5 in ascending order, desc(column2) in descending order)
#  arrange(OmanData, acceptDetAs, dateYYYY, collector)

# mutate() {dplyr} function:
  # create new columns as functions of other columns
  # mutate(datasource, newcolumn=AnyLat + " " + AnyLon)
#  OmanData <- mutate(OmanData, LatLon=paste(AnyLat, AnyLon, sep=" "))

# summarize(datasource, summarizingcolumn = summarizing function(column3))
  # no easy example here

### dplyr showcase END ###


  # 3)

# make LatLon column from concat'd AnyLat & AnyLon
OmanData <- mutate(OmanData, LatLon=paste(AnyLat, AnyLon, sep=" "))  

# group_by(data, grouping variable)
group_by(OmanData, acceptDetAs)

# group by species & summarize by 1 variable
by_sps <- group_by(OmanData, acceptDetAs)
summarize(by_sps, avgCollctn=round(mean(dateYYYY, na.rm=TRUE), digits=0))  # average year of collection by species :)
summarize(by_sps, mednCollctn=round(median(dateYYYY, na.rm=TRUE), digits=0))  # median year of collection by species :)

# group by species and summarize by multiple variables
datA <- mutate(OmanData, LatLon=paste(AnyLat, AnyLon, sep=" "))
by_sps <- group_by(datA, acceptDetAs)
by_sps_sum <- summarize(by_sps, 
                        count=n(),
                        collectedBy=n_distinct(collector), 
                        mostRecentCollection=max(dateYYYY, na.rm=TRUE), 
                        uniqueLatLon=n_distinct(LatLon),
                        uniqueLocation=n_distinct(fullLocation)
)
by_sps_sum

#number of taxa with over 10 unique lat+lon locations:
filter(by_sps_sum, uniqueLatLon>10)
# 597 @ 15 November 2018

#number of taxa with over 10 unique named-locations:
filter(by_sps_sum, uniqueLocation>10)
# 315 @ 15 November 2018

# number of taxa with over 10 occurrences/records:
filter(by_sps_sum, count>10)
# 779 taxa with >10 occurrence records @ 15 November 2018

# Location with greatest number of taxa?
# ?

# Taxa with greatest number of locations?
# ?

# unique datapoints(excl herbarium-dups, badSQL-dups, mult.entry-dups, etc)


# grasses vs non-grasses
OmanData %>% 
  filter(familyName=="Gramineae")
  # 6580 grasses 
# percentage of all records which are grasses :
  round(100*(nrow(OmanData %>% filter(familyName=="Gramineae"))/nrow(OmanData)), digits=1)
  # 23.9% of all records
  

# list taxa & number of unique points (by field, herb, literature)
# split by collector
  
  # to split by source:
  #grepl("H-*", head(OmanData$recID))

  # pull out herbarium records only
OmanData %>%
        filter(grepl("H-*", recID))

# pull out field obs records only
OmanData %>%
        filter(grepl("F-*", recID))

# pull out literature records only
OmanData %>%
        filter(grepl("L-*", recID))


# data > sort by collector


### 23 Oct 2015
# Alan requires output thus:

# For all taxa with >5 unique occurences
# By family
#       list each species       column of unique dots
# possibly add column with 'Y' if there are also over 10 unique occurrences

# for 'unique occurence', maybe do function:
# unique occurrence = different(collector, collectionNumber, date, location, taxon)

# don't need recGrab object any more
rm(recGrab)

#<- mutate(OmanData, LatLon=paste(AnyLat, AnyLon, sep=" "))


# records by family, species & listing ~unique records (where there are >5 unique location points/'dots on map')
filteredOmanData <- 
OmanData %>%
        mutate(recordInfo=paste(acceptDetAs, collector, LatLon)) %>%
        group_by(familyName, acceptDetAs) %>%        # group by familyName AND accepted det
        arrange(acceptDetAs) %>%         # sort by acceptDetAs
        summarize(count=n(),
                  #collectedBy=n_distinct(collector), 
                  #mostRecentCollection=max(dateYYYY, na.rm=TRUE), 
                  uniqueLatLon=n_distinct(LatLon),
                  AppxUniqueRex=n_distinct(recordInfo)
                  #uniqueLocation=n_distinct(fullLocation)
        ) %>%
        filter(uniqueLatLon>5) # only show taxa where there are over 5 unique Lat/Lon combos
        #head

# write this out to CSV
write.csv(
        filteredOmanData,
        file=file.choose(),
        na="", 
        row.names=FALSE
)

## pull out data for 1 taxon:
#OmanData %>% 
#        filter(acceptDetAs=="Asystasia guttata (Forssk.) Brummitt") %>%
#        glimpse


# VERY IMPORTANT!
# CLOSE DATABASE CONNECTIONs & REMOVE OBJECTS FROM WORKSPACE!
odbcCloseAll()
#rm(list=ls())