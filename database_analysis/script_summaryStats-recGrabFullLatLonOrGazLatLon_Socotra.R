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

# check for herbSpxReqDet object
# informative error if it doesn't exist
if(!exists("recGrab")){ 
        #stop("... ERROR: recGrab object doesn't exist")
        
        # pull in data & create recGrab object: 
        source("O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R")
}



# 2)

### SUMMARY STATS ###
# (NOTE: moved on 14/08/2015 from: 
# "O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R" 
# to allow record pull-out and summary stats sections to be in separate scripts 
# and therefore more useful)

# Number of taxa:
length(unique(recGrab$acceptDetAs))
# 1256 taxa at 2016-02-25
# 1028 taxa at 2016-02-26 (after filtering out using keepTaxRankOnly() function)

# create object
taxaListSocotra <- unique(recGrab$acceptDetAs)
#sort(taxaListSocotra)

message(paste0(" ... saving list of accepted taxa names in analysis set to: O://CMEP\ Projects/Socotra/analysisTaxaListSocotra_", Sys.Date(), ".csv"))
# write list of unique taxa
write.csv(sort(taxaListSocotra), file=paste0("O://CMEP\ Projects/Socotra/analysisTaxaListSocotra_", Sys.Date(), ".csv"), row.names=FALSE)

# message(paste0(" ... saving list of accepted taxa names to: O://CMEP\ Projects/Socotra/taxaListSocotra_", Sys.Date(), ".csv"))
# # write list of unique taxa
# write.csv(sort(taxaListSocotra), file=paste0("O://CMEP\ Projects/Socotra/taxaListSocotra_", Sys.Date(), ".csv"), row.names=FALSE)


# Number of unique locations? (unique(paste0(AnyLat + AnyLon)))
length(unique(paste(recGrab$anyLat, recGrab$anyLon)))
# 889 @ 08/06/2015
# 907 @ 18/01/2015
# 716 @ 2016-02-25
# 1845 @ 2016-02-25 - fixed rounding error caused by using qry0 method (fielRexTemp table at Access) without correct data type settings - number type Long Integer

# Number of taxa with >10 unique locations?
# 175 unique named locations OR 255 unique lat+lon combos @ 06/07/2015, see below

# Location with greatest number of taxa?
# ?

# Taxa with greatest number of locations?
# ?


# number of expeditions



# use DPLYR to manipulate data

# load the data into a dataframe tbl data object aka tbl-df
socotraData <- tbl_df(recGrab)

# get names of variables
names(socotraData)
# [1] "recID"              "expdName"            
# [3] "collector"          "collNumFull"       
# [5] "lnamID"             "taxRank"           
# [7] "familyName"         "acceptDetAs"       
# [9] "acceptDetNoAuth"    "genusName"         
# [11] "detAs"              "lat1Dir"           
# [13] "lat1Deg"            "lat1Min"           
# [15] "lat1Sec"            "lat1Dec"           
# [17] "anyLat"             "lon1Dir"           
# [19] "lon1Deg"            "lon1Min"           
# [21] "lon1Sec"            "lon1Dec"           
# [23] "anyLon"             "coordSource"       
# [25] "coordAccuracy"      "coordAccuracyUnits"
# [27] "coordSourcePlus"    "dateDD"            
# [29] "dateMM"             "dateYYYY"          
# [31] "fullLocation"    

#?manip  # gives info on manipulation functions

# select() {dplyr} function:
# pulls out only some variables

# select(datasource, column1, column2, column5)
select(socotraData, acceptDetAs, collector, collNumFull)

# filter(datasource, column1 subset, column5 subset)
filter(socotraData, acceptDetAs=="Aerva revoluta Balf.f.")

# arrange(datasource, column5 in ascending order, desc(column2) in descending order)
arrange(socotraData, acceptDetAs, dateYYYY, collector)

# mutate(datasource, newcolumn=AnyLat + " " + AnyLon)
socotraData <- mutate(socotraData, LatLon=paste(anyLat, anyLon, sep=" "))

# summarize(datasource, summarizingcolumn = summarizing function(column3))
# no easy example here


# group_by(data, grouping variable)
group_by(socotraData, acceptDetAs)

# group by species & summarize by 1 variable
by_sps <- group_by(socotraData, acceptDetAs)
avgSpsCollection <- 
        by_sps %>%
        summarize(AvgYearCol=round(mean(dateYYYY, na.rm=TRUE), digits=0), NoCols=n()) %>%
        arrange(-AvgYearCol) %>% # average year of collection by species :)
        print

# group by species and summarize by multiple variables
socDat <- mutate(socotraData, latLon=paste(anyLat, anyLon, sep=" "))
by_sps <- group_by(socDat, acceptDetAs)
by_sps_sum <- summarize(by_sps, 
                        count=n(),
                        collectedBy=n_distinct(collector), 
                        uniqueLatLon=n_distinct(latLon),
                        uniqueLocation=n_distinct(fullLocation), 
                        mostRecent=max(dateYYYY, na.rm=TRUE)
)
by_sps_sum

# top 10 families by usable records
by_fam <- group_by(recGrab, familyName)
by_fam_gps <- 
        by_fam %>%
        summarize(count=n()) %>%
        arrange(-count)
by_fam_gps

# top 10 species by usable records
by_sps <- group_by(socDat, acceptDetAs)
by_sps_counts <- 
        by_sps %>%
        summarize(count=n()) %>%
        arrange(-count)
by_sps_counts


#number of taxa with over 10 unique lat+lon locations:
filter(by_sps_sum, uniqueLatLon>10)
#398

#number of taxa with over 10 unique named-locations:
filter(by_sps_sum, uniqueLocation>10)
#240

# number of taxa with over 10 occurrences/records:
filter(by_sps_sum, count>10)
# 441 taxa with >10 unique latlon locations


by_expd <- group_by(socotraData, expdName)
expds <- summarize(by_expd, count=n(), 
          collGroups=n_distinct(collector), 
          year=round(mean(dateYYYY, na.rm=TRUE), digits=0)
          ) %>%
        arrange(-count, expdName)

# VERY IMPORTANT!
# CLOSE THE CONNECTION!
odbcCloseAll()
# empty the environment of objects
#rm(list=ls())