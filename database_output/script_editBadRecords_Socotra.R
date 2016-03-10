## Socotra Project :: script_editBadRecords_Socotra.R
# ==============================================================================
# 09 March 2016
# Author: Flic Anderson
#
# to call: 
# objects created: recGrab(altered)
# saved at: O://CMEP\ Projects/Scriptbox/database_output/script_editBadRecords_Socotra.R
# dependent on: "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R"
# dependent on: "O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R"
# source("O://CMEP\ Projects/Scriptbox/database_output/script_editBadRecords_Socotra.R")
#
# AIM:  Edit records for Socotra analysis to update them with better lat/lon info (checked by Marine Pouget)
# ....  as part of the record output process before running full analyses.
#
# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0)
# 1) 
# 2) 
# 3) 
# 4) 

# ---------------------------------------------------------------------------- #

fileLocat <- "O://CMEP\ Projects/Socotra"

fileName <- "BadRecords_socotra-2016-03-07_newLatLonReqUpdate.csv"

# import source:
importSource <<- paste0(fileLocat, "/", fileName)

# is file a .csv or something else?
# get extension
extns <- paste0(".", unlist(strsplit(importSource, "[.]"))[2])
# check if it's not .csv & give informative error if it doesn't exist
if(!grepl(".csv", extns)) stop("... ERROR: file not in .csv format, please save as .csv and try again")

# check for recGrab object
# informative error if it doesn't exist
if(!exists("recGrab")) stop("... ERROR: recGrab object doesn't exist")

reqEdits <<- read.csv(
        file=importSource, 
        header=TRUE, 
        as.is=TRUE, 
        na.strings=""
)

# change column names "New.AnyLon" and "New.AnyLat" to something without dots
names(reqEdits)[names(reqEdits)=="New.AnyLat"] <- "newLat"
names(reqEdits)[names(reqEdits)=="New.AnyLon"] <- "newLon"

