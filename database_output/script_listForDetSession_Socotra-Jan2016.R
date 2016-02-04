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

# add Edinburgh herbarium family codes to add retrieval of specimens
source("O://CMEP\ Projects/Scriptbox/general_utilities/function_getHerbrFamNums.R")
getHerbrFamNums()

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
sum(is.na(herbSpxReqDetE$anyLon))
sum(is.na(herbSpxReqDetE$anyLon))

which(is.na(herbSpxReqDetE$anyLat))
which(is.na(herbSpxReqDetE$anyLon))

#herbSpxReqDetE[c(580),]
#glimpse(herbSpxReqDetE[c(580),])

# record H-820, Miller 8719 is actually a SPIRIT ONLY collection!  Not a herbarium specimen.
# this info has been added to the Flic notes columns

# basically remove any without a LatLon
herbSpxReqDetE <- 
        herbSpxReqDetE %>%
        filter(!is.na(anyLat)|!is.na(anyLon))
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
                arrange(FlicFound, collNum) %>%
                select(recID, collector, collNumFull, herbariumCode, taxRank, herbrFamilyNum, familyName, acceptDetAs, detAs, workingName, dateDD, dateMM, dateYYYY, FlicFound, FlicStatus, FlicNotes, FlicIssue, fullLocation) 

# write out MillerSpx
# write >>>MillerSpx<<<to .csv file  
# UNCOMMENT THESE TWO LINES TO WRITE OUT!
message(paste0(" ... saving Miller species-level-det-requiring herbarium records to: O://CMEP\ Projects/Socotra/DeterminationRequired_Miller_herbariumSpecimens-Socotra_", Sys.Date(), ".csv"))
write.csv(MillerSpx, file=paste0("O://CMEP\ Projects/Socotra/SpecimensRequiringDeterminations/DeterminationRequired_Miller_herbariumSpecimens-Socotra_", Sys.Date(), ".csv"), na="", row.names=FALSE)


# non-miller/mounted list
# by family
NonMillerSpx <- herbSpxReqDetE[which(grepl("*Miller*", herbSpxReqDetE$collector)==FALSE),]
# NonMillerSpx 270 obs x 36 var
NonMillerSpx <- tbl_df(NonMillerSpx)
NonMillerSpx <- 
        NonMillerSpx %>%
        arrange(familyName, detAs, collector) %>%
        select(recID, collector, collNumFull, herbariumCode, taxRank, herbrFamilyNum, familyName, acceptDetAs, detAs, workingName, dateDD, dateMM, dateYYYY, FlicFound, FlicStatus, FlicNotes, FlicIssue, fullLocation) 

# write >>>NonMillerSpx<<<to .csv file  
# UNCOMMENT THESE TWO LINES TO WRITE OUT!
message(paste0(" ... saving Non-Miller species-level-det-requiring herbarium records to: O://CMEP\ Projects/Socotra/DeterminationRequired_Miller_herbariumSpecimens-Socotra_", Sys.Date(), ".csv"))
write.csv(NonMillerSpx, file=paste0("O://CMEP\ Projects/Socotra/SpecimensRequiringDeterminations/DeterminationRequired_Non-Miller_herbariumSpecimens-Socotra_", Sys.Date(), ".csv"), na="", row.names=FALSE)

# ################################################################################
# 
# DATA INFO (probably tl;dr, but useful info)
# 
# ######
# 
# File 1: DeterminationRequired_Miller_herbariumSpecimens-Socotra-2016-01-21.csv
# 
# This contains all of Tony's collections which require further determination (336 records)
# 
# These records are sorted on FlicFound, then collection number.
# 
# These should mostly correspond with the boxes of his unmounted stuff, but there are a couple of the earlier ones (a handful of 8000s numbers and a few 10,000s numbers ) which are listed as "in herbarium" in the FlicStatus column - this means they'll be in the herbarium for sure.  Most of the rest of those specimens which have been found by me (FlicFound column says "found" in it) will be unmounted material, but occasionally there have been ones we've found mounted and unmounted.  We might as well determine the unmounted material if we can - if you'd prefer to pull out all the ones which are in the herbarium, it should be relatively easy to sort the FlicStatus column to find the various combinations and locations they've been found at.  
# 
# File 2: DeterminationRequired_Non-Miller_herbariumSpecimens-Socotra-2016-01-21.csv
# 
# This is the non-Miller stuff requiring further determination (270 records, but a few less specimens than that - see note below)  
# 
# These records are sorted on familyName, detAs, then collector.  
# 
# Mostly mounted, however some like the Alexander collections are in unmounted NM (non-Miller) boxes.  
# 
# NOTE: there is some remaining duplication in the Banfield herbarium specimens records.  This is visible in the spreadsheet where the same collection number appears on consecutive rows.  Often one of these records is often listed as being at 'E' herbarium and the other has no herbarium code information.  They don't show up in Martin's duplicate merging tool though, so I need to fight these in the next few days.  For the meantime, I've left these in just in case, and I'll try and remove them on Tuesday if there are too many of them to be useful.  
# 
# 
# Columns are: 
#         
#       collector - the recorded collector in Padme for this specimen
#       collNumFull - the main collection number as recorded in Padme
#       herbariumCode - E or missing info in Padme.  Not everything that's listed as E is probably here, and some things that are listed are probably not here, so treat with caution!
#       taxRank - this is the level to which Padme records this specimen as being determined to.
#	herbrFamilyNum - this is theoretically the E herbarium's family number to make finding mounted specimens easier.  Some families don't have one because the match between Padme's families and the herbarium family index isn't perfect.  I plan to update the script to fix this at some future point, but I'm sure we're capable of figuring this out as necessary.
#	familyName - this is the family name Padme has assigned to this taxon (if it's wrong, make a note & I'll check and update Padme for future). Some of these say Sp. Nov. but they may not be very 'nov.' at all after a few decades. Beware!
#	acceptDetAs - this is the alleged 'accepted' name according to Padme.  This differs from:
#	detAS - the taxon name recorded on the record at entry (ie original/loosely-current det)
#	workingName - if any working name was given for the specimen (sometimes unhelpful, like "Tree")
#	(3x date fields) - self-explanatory collection date info
#       FlicFound - this column records [for Miller records only] whether I've seen this material during my sifting
#	FlicStatus - details of where I've seen it and what stage it's at (ie "in unmounted", "in herbarium", "in spirit collection", "in online collection" or a combination of several.  Note, this is not exhaustive and was done over a year ago, so may not be 100% current, but a good place to start looking.
#	FlicNotes - this contains notes which may have been on flimsies, or if there seemed to be collection number issues or the specimen is somewhere unexpected.   Again, this information is not necessarily current, so treat as a starting point.  All the random brackets are to do with the ways the flimsies were put together and may help when locating and creating duplicates later, ie ((2)) represents 2 nested sets of duplicates in nested flimsies.  Ignore this if it causes confusion, but should give a good guide how much material to expect.
#       FlicIssue - details various types of issues which may have been noted for this specimen, including gems such as "{HERBARIUM: suspected issue: folder missing}" or the dreaded "{UNMOUNTED: suspected issue: mixed collection}"
#       FullLocation - this is the full location string the specimen has in Padme, useful if you need to know *where* the specimen came from to narrow down a det.  Just expand the column to show the full location, most specific part is at the end.  If necessary (particularly if printing), you could select the column, then run Find and Replace on that column to remove the string "ASIA-TEMPERATE: Arabian Peninsula: Republic of Yemen: Socotra Archipelago" and just show the useful specific part such as ": Socotra: Jebel Ma'lih".
