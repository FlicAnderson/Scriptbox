## Socotra Project :: script_summaryStats-recGrabFullLatLonOrGazLatLon_Socotra.R
# ==============================================================================
# 14 August 2015
# Author: Flic Anderson
#
# dependent on: "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R"
# & dependent on: "O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R"
# saved at: O://CMEP\ Projects/Scriptbox/database_analysis/script_summaryStats-recGrabFullLatLonOrGazLatLon_Socotra.R
# source: source("O://CMEP\ Projects/Scriptbox/database_analysis/script_summaryStats-recGrabFullLatLonOrGazLatLon_Socotra.R")
#
# AIM: Using records pulled out in script_dataGrabFullLatLonOrGazLatLon_Socotra.R
# .... Perform summary stats! 
# .... 

# ---------------------------------------------------------------------------- #

# 0)

# load required packages, install if they aren't installed already
# {RODBC} - ODBC Database Access
if (!require(RODBC)){
        install.packages("RODBC")
        library(RODBC)
} 
# {dplyr} - data manupulation
if (!require(dplyr)){
        install.packages("dplyr")
        library(dplyr)
} 
# 
# # open connection to live padme
# source("O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R")
# livePadmeArabiaCon()


# 1)

# pull in data & create recGrab object: 
source("O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R")


# 2)

### SUMMARY STATS ###
# (NOTE: moved on 14/08/2015 from: 
# "O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R" 
# to allow record pull-out and summary stats sections to be in separate scripts 
# and therefore more useful)

# Number of taxa:
length(unique(recGrab$acceptDetAs))
# 1249 taxa at 15 July 2015

# create object
taxaListSocotra <- unique(recGrab$acceptDetAs)
#sort(taxaListSocotra)

message(paste0(" ... saving list of accepted taxa names to: O://CMEP\ Projects/Socotra/taxaListSocotra_", Sys.Date(), ".csv"))
# write list of unique taxa
write.csv(sort(taxaListSocotra), file=paste0("O://CMEP\ Projects/Socotra/taxaListSocotra_", Sys.Date(), ".csv"), row.names=FALSE)


# Number of unique locations? (unique(paste0(AnyLat + AnyLon)))
length(unique(paste(recGrab$AnyLat, recGrab$AnyLon)))
# 889 @ 08/06/2015
# 907 @ 18/01/2015

# Number of taxa with >10 unique locations?
# 175 unique named locations OR 255 unique lat+lon combos @ 06/07/2015, see below

# Location with greatest number of taxa?
# ?

# Taxa with greatest number of locations?
# ?


# use DPLYR to manipulate data

# load the data into a dataframe tbl data object aka tbl-df
socotraData <- tbl_df(recGrab)

# get names of variables
names(socotraData)
# [1] "recID"      "collector"          "collNumFull"        "lnamID"             "taxRank"           
# [6] "familyName" "acceptDetAs"        "acceptDetNoAuth"    "genusName"          "detAs"             
# [11] "lat1Dir"   "lat1Deg"            "lat1Min"            "lat1Sec"            "lat1Dec"           
# [16] "AnyLat"    "lon1Dir"            "lon1Deg"            "lon1Min"            "lon1Sec"           
# [21] "lon1Dec"   "AnyLon"             "coordSource"        "coordAccuracy"      "coordAccuracyUnits"
# [26] "coordSourcePlus" "dateDD"       "dateMM"             "dateYY"             "fullLocation"  

#?manip  # gives info on manipulation functions

# select() {dplyr} function:
# pulls out only some variables

# select(datasource, column1, column2, column5)
select(socotraData, acceptDetAs, collector, collNumFull)

# filter(datasource, column1 subset, column5 subset)
filter(socotraData, acceptDetAs=="Aerva revoluta Balf.f.")

# arrange(datasource, column5 in ascending order, desc(column2) in descending order)
arrange(socotraData, acceptDetAs, dateYY, collector)

# mutate(datasource, newcolumn=AnyLat + " " + AnyLon)
socotraData <- mutate(socotraData, LatLon=paste(AnyLat, AnyLon, sep=" "))

# summarize(datasource, summarizingcolumn = summarizing function(column3))
# no easy example here


# group_by(data, grouping variable)
group_by(socotraData, acceptDetAs)

# group by species & summarize by 1 variable
by_sps <- group_by(socotraData, acceptDetAs)
summarize(by_sps, mean(dateYY, na.rm=TRUE))  # average year of collection by species :)

# group by species and summarize by multiple variables
socDat <- mutate(socotraData, LatLon=paste(AnyLat, AnyLon, sep=" "))
by_sps <- group_by(socDat, acceptDetAs)
by_sps_sum <- summarize(by_sps, 
                        count=n(),
                        collectedBy=n_distinct(collector), 
                        mostRecentCollection=max(dateYY, na.rm=TRUE), 
                        uniqueLatLon=n_distinct(LatLon),
                        uniqueLocation=n_distinct(fullLocation)
)
by_sps_sum

#number of taxa with over 10 unique lat+lon locations:
filter(by_sps_sum, uniqueLatLon>10)
#258

#number of taxa with over 10 unique named-locations:
filter(by_sps_sum, uniqueLocation>10)
#175

# number of taxa with over 10 occurrences/records:
filter(by_sps_sum, count>10)
# 352 taxa with >10 unique latlon locations
# NB: shows Adenium with 193 occurrences, and Adenium obesum with 103 & Adenium 
# obesum subsp sokotranum with 44 occurrences.  These should all come under one 
# taxa - Adenium obesum subsp sokotranum w/ 340 occurences!