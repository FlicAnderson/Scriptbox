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
# .... Perform summary stats! Best run with other scripts in the following order: 
# ....  - script_dataGrabFullLatLonOrGazLatLon_Socotra.R
# ....  (- script_summaryStats-recGrabFullLatLonOrGazLatLon_Socotra.R)
# ....  - script_editTaxa_Socotra.R
# ....  - script_joinMatchEndemicNames_Socotra.R
# ....  - script_summaryStats-recGrabFullLatLonOrGazLatLon_Socotra.R

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
# 818 after pruning out 0-Lat/0-Lon records
# 834 2016/03/23
# 807 20Dec2016

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
# 1853 @ 2016/03/23

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
# [5] "lnamID"             "acceptDetAs"       
# [7] "acceptDetNoAuth"    "detAs"             
# [9] "lat1Dir"            "lat1Deg"           
# [11] "lat1Min"            "lat1Sec"           
# [13] "lat1Dec"            "anyLat"            
# [15] "lon1Dir"            "lon1Deg"           
# [17] "lon1Min"            "lon1Sec"           
# [19] "lon1Dec"            "anyLon"            
# [21] "coordSource"        "coordAccuracy"     
# [23] "coordAccuracyUnits" "coordSourcePlus"   
# [25] "dateDD"             "dateMM"            
# [27] "dateYYYY"           "fullLocation"      
# [29] "familyName"         "member"            
# [31] "genusName"          "recType"           
# [33] "endemicScore"         

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
over10s <- filter(by_sps_sum, uniqueLatLon>10)
#390
write.csv(over10s, file.select(), row.names = FALSE)
fileLocat <- "O://CMEP\ Projects/PROJECTS\ BY\ COUNTRY/Socotra/Socotra\ 2013-2016\ LEVERHULME\ TRUST\ RPG-2012-778/AnalysisData/"
fileName <- "over10Locats-Socotra_"
write.csv(over10s, file=paste0(fileLocat,fileName,Sys.Date(),".csv"), row.names = FALSE)

#number of taxa with over 10 unique named-locations:
filter(by_sps_sum, uniqueLocation>10)
#242

# number of taxa with over 10 occurrences/records:
filter(by_sps_sum, count>10)
# 428 taxa with >10 unique latlon locations


by_expd <- group_by(socotraData, expdName)
expds <- summarize(by_expd, count=n(), 
          collGroups=n_distinct(collector), 
          year=round(mean(dateYYYY, na.rm=TRUE), digits=0)
          ) %>%
        arrange(-count, expdName)
expds

# VERY IMPORTANT!
# CLOSE THE CONNECTION!
odbcCloseAll()
# empty the environment of objects
#rm(list=ls())

# # REMOVE NEEDLESS OBJECTS FROM WORKSPACE!
#         # removes EVERYTHING EXCEPT WHAT YOU WANT TO KEEP 
#         # (eg. Keeps: connections, recGrab, etc):
rm(list=setdiff(ls(), 
                c(
                        "recGrab", 
                        "con_livePadmeArabia", 
                        "livePadmeArabiaCon"
                )
)
)


# RUN THIS AFTER:...
## Socotra Project :: script_editTaxa_Socotra.R
# ==============================================================================
# 10 March 2016
# Author: Flic Anderson
#
# to call: 
# objects created: recGrab(altered)
# saved at: O://CMEP\ Projects/Scriptbox/database_output/script_editTaxa_Socotra.R
# dependent on: "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R"
# dependent on: "O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R"
# dependent on: "O://CMEP\ Projects/Scriptbox/database_output/script_editTaxa_Socotra_replacementInfo.R"
# source("O://CMEP\ Projects/Scriptbox/database_output/script_editTaxa_Socotra.R")
#
# AIM:  Fix some bad taxa, remove lichens, remove ferns, ensure everything is good
# ....  order for analysis. Run this after script_dataGrabFullLatLonOrGazLatLon_Socotra.R
# ....  and before script_joinMatchEndemicNames_Socotra.R


#AND/OR RUN THIS AFTER:...


## Socotra Project :: script_joinMatchEndemicNames_Socotra.R
# ============================================================================ #
# 05 December 2016
# Author: Flic Anderson
#
# dependant on: script_dataGrabFullLatLonOrGazLatLon_Socotra.R; script_endemicAnnotationsPadme.R
# saved at: O://CMEP\-Projects/Scriptbox/data_various/script_joinMatchEndemicNames_Socotra.R
# source("O://CMEP\ Projects/Scriptbox/data_various/script_joinMatchEndemicNames_Socotra.R")
#
# AIM:  Join Ethnoflora endemism scored data (scored by Anna) for Socotra to 
# ....  the Socotra dataset on names; where names do not match, apply a 
# ....  taxonomic fix as necessary. Run after script_editTaxa_Socotra.R (which 
# ....  runs after script_dataGrabFullLatLonOrGazLatLon_Socotra.R)