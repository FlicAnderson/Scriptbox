## Socotra Project :: script_listForDetSession_Socotra-Jan2016.R
# ==============================================================================
# (4th June 2015)
# Author: Flic Anderson
#
# dependent on: "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R"
# & "O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R"
# saved at: O://CMEP\ Projects/Scriptbox/database_output/script_listForDetSession_Socotra-Jan2016.R
# source("O://CMEP\ Projects/Scriptbox/database_output/script_listForDetSession_Socotra-Jan2016.R")
#
# AIM: ... TBC
# .... 
# .... 
# .... 
# .... 
# ....  
# .... Then save as CSV file (.csv) for future use.

# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) Load libraries, functions, source scripts
# 1) 
# 2) 
# 3) 
# 4) Show the output
# 5) Save the output to .csv

# ---------------------------------------------------------------------------- #

# 0)

# still need to filter out the herbarium specimens for sorting though.
# KEEP: 
# ones which have geolocation
# ones at E (or no-herbarium-code, since that's probably a lot)
# 

str(herbSpxReqDet)
herbSpxReqDet <- tbl_df(herbSpxReqDet)
herbSpxReqDet

table(herbSpxReqDet$herbariumCode, useNA="ifany")
# BM    E       HNT     K       UPS     <NA> 
#  5    356     8       1       36      257
# we only can determine specimens at E, really

herbSpxReqDetE <- 
        herbSpxReqDet %>%
                filter(herbariumCode=="E"|is.na(herbariumCode))
# herbSpxReqDetE: 613 obs x 35 var

# breakdown by collectors
table(herbSpxReqDetE$collector, useNA="ifany")

# 43 unique collectors including NA
# tho actually it's more like X
# several Banfield strings, several Kilian/Hein, ~10 Miller strings etc

glimpse(herbSpxReqDetE)

# records with a lat or long
sum(is.na(herbSpxReqDetE$AnyLat))
sum(is.na(herbSpxReqDetE$AnyLon))

which(is.na(herbSpxReqDetE$AnyLat))
which(is.na(herbSpxReqDetE$AnyLon))

#herbSpxReqDetE[c(585),]
#glimpse(herbSpxReqDetE[c(585),])

# record H-820, Miller 8719 is actually a SPIRIT ONLY collection!  Not a herbarium specimen.
# this info has been added to the Flic notes columns

# basically remove any without a LatLon
herbSpxReqDetE <- 
        herbSpxReqDetE %>%
        filter(!is.na(AnyLat)|!is.na(AnyLon))
# 612 obs x 35 var

herbSpxReqDetE
# this is the list of things that need further ID. 
# need to remove the duplicates from it somehow though!

# pull out ones which have NO det at all to start with
a <- herbSpxReqDet %>%
        filter(is.na(taxRank))


