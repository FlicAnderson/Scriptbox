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

# add working names to assist ID potentially
source("O://CMEP\ Projects/Scriptbox/general_utilities/function_getWorkingNames.R")
getWorkingNames()
# herbSpxReqDet 657 obs x 36 var

str(herbSpxReqDet)
herbSpxReqDet <- tbl_df(herbSpxReqDet)
herbSpxReqDet

table(herbSpxReqDet$herbariumCode, useNA="ifany")
# BM    E       HNT     K       UPS     <NA> 
#  5    353     8       1       36      254
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

#herbSpxReqDetE[c(580),]
#glimpse(herbSpxReqDetE[c(580),])

# record H-820, Miller 8719 is actually a SPIRIT ONLY collection!  Not a herbarium specimen.
# this info has been added to the Flic notes columns

# basically remove any without a LatLon
herbSpxReqDetE <- 
        herbSpxReqDetE %>%
        filter(!is.na(AnyLat)|!is.na(AnyLon))
# 606 obs x 36 var

herbSpxReqDetE
# this is the list of things that need further ID. 
# need to remove the duplicates from it somehow though!

collNumKeeper <- function(x){
        gsub("[^0-9]", "", x)
}

herbSpxReqDetE$collNum <- as.numeric(collNumKeeper(herbSpxReqDetE$collNumFull))

# pull out ones which have NO det at all to start with
a <- herbSpxReqDet %>%
        filter(is.na(taxRank))
# doesn't assist much, but having added the working names, shows these are incredibly vague
        # remove the temp object now
        #rm(a)

# prepare records for output

# miller/unmounted list
# numerically
# pull out the Miller records
MillerSpx <- herbSpxReqDetE[which(grepl("*Miller*", herbSpxReqDetE$collector)==TRUE),]
# MillerSpx 336 obs x 37 var

# sort these numerically
MillerSpx <- tbl_df(MillerSpx)
MillerSpx <- 
        MillerSpx %>%
                arrange(collNum) %>%
                select(recID, collector, collNumFull, herbariumCode, taxRank, familyName, acceptDetAs, detAs, workingName, dateDD, dateMM, dateYY, FlicFound, FlicStatus, FlicNotes, FlicIssue, fullLocation) 

# write out MillerSpx
# write >>>MillerSpx<<<to .csv file  
# UNCOMMENT THESE TWO LINES TO WRITE OUT!
message(paste0(" ... saving Miller species-level-det-requiring herbarium records to: O://CMEP\ Projects/Socotra/DeterminationRequired_Miller_herbariumSpecimens-Socotra_", Sys.Date(), ".csv"))
write.csv(MillerSpx, file=paste0("O://CMEP\ Projects/Socotra/DeterminationRequired_Miller_herbariumSpecimens-Socotra_", Sys.Date(), ".csv"), na="", row.names=FALSE)


# non-miller/mounted list
# by family
NonMillerSpx <- herbSpxReqDetE[which(grepl("*Miller*", herbSpxReqDetE$collector)==FALSE),]
# NonMillerSpx 270 obs x 36 var
NonMillerSpx <- tbl_df(NonMillerSpx)
NonMillerSpx <- 
        NonMillerSpx %>%
        arrange(familyName, detAs) %>%
        select(recID, collector, collNumFull, herbariumCode, taxRank, familyName, acceptDetAs, detAs, workingName, dateDD, dateMM, dateYY, FlicFound, FlicStatus, FlicNotes, FlicIssue, fullLocation) 

# write >>>NonMillerSpx<<<to .csv file  
# UNCOMMENT THESE TWO LINES TO WRITE OUT!
message(paste0(" ... saving Non-Miller species-level-det-requiring herbarium records to: O://CMEP\ Projects/Socotra/DeterminationRequired_Miller_herbariumSpecimens-Socotra_", Sys.Date(), ".csv"))
write.csv(NonMillerSpx, file=paste0("O://CMEP\ Projects/Socotra/DeterminationRequired_Non-Miller_herbariumSpecimens-Socotra_", Sys.Date(), ".csv"), na="", row.names=FALSE)
