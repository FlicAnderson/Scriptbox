## Socotra Project :: script_dataGrabFullLatLonOrGazLatLon_Socotra.R
# ==============================================================================
# (4th June 2015)
# Author: Flic Anderson
#
# dependent on: "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R"
# saved at: O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R
# source("O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R")
#
# AIM: Pull out records into R for species in Socotra from 
# .... Padme Arabia using SQL via the RODBC connection set up in another script. 
# .... Includes lat/lon from Padme gazetteer where no lat /lon are present &
# .... ignore records which only list locat as "Socotra" or "Socotra Archipelago"
# .... as these would proliferate 1 location (the mid-point for Socotra or the 
# .... islands; unhelpful). 
# .... Then save as CSV file (.csv) for future use.

# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) Load libraries, functions, source scripts
# 1) Build queries 
# 2) Run the queries, add expdID & join results
# 3) Add families, genus, reorder, 
# 4) add taxonomic rank, bin by taxonomy, 
# 5) remove junk locations, fix bad location records, 
# 6) lump subspecific taxa/remove lichens & bad taxa
# 7) Save the output to .csv
# 8) tidy up

# ---------------------------------------------------------------------------- #

# 0) 

# load required packages, install if they aren't installed already
# {RODBC} - ODBC Database Access
if (!require(RODBC)){
  install.packages("RODBC")
  library(RODBC)
} 
# {sqldf} - using SQL query style to manipulate R objects & data frames
if (!require(sqldf)){
        install.packages("sqldf")
        library(sqldf)
} 
# {dplyr} - manipulating data & large data frames as tbl_df objects
if (!require(dplyr)){
        install.packages("dplyr")
        library(dplyr)
}
# open connection to live padme
source("O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R")
livePadmeArabiaCon()




# 1) Build queries

# HERBARIUM SPECIMENS
# source query
source("O://CMEP\ Projects/Scriptbox/database_output/script_herbQry_Socotra.R")

# FIELD RECORDS
# source the query:
source("O://CMEP\ Projects/Scriptbox/database_output/script_fielQry_Socotra.R")

# LITERATURE RECORDS
# source litr query
source("O://CMEP\ Projects/Scriptbox/database_output/script_litrQry_Socotra.R")




# 2) Run the queries, add expdID & join results

# HERBARIUM SPECIMENS
# run query
herbRex <- sqlQuery(con_livePadmeArabia, herbQry) 
        # 2016/03/06 6142
        # 2016/03/16 6296 (after Semhah -> Samha tweak)
        # 2016/03/22 6297 (after %Samha to %Samha% tweak)

# FIELD RECORDS
# run query 
fielRex <- sqlQuery(con_livePadmeArabia, fielQry) 
        # 2016/02/09 28 var - need to remove the id column!
# remove ID field
fielRex$id <- NULL
        # 2016/03/06 24424
        # 2016/03/16 24683 (after Semhah -> Samha tweak)
        # 2016/03/22 24686 (after %Samha to %Samha% tweak)

# LITERATURE RECORDS
# run query
litrRex <- sqlQuery(con_livePadmeArabia, litrQry) 
# add expdName column & set to null as expedition irrelevant for litrRex
litrRex$expdName <- ""
# re-order so expdID in same location as in herb and fiel recsets
litrRex <- litrRex[,c(1,28,2:27)]
        # 2016/03/06 629
        # 2016/03/16 631 (after Semhah -> Samha tweak)
        # 2016/03/22 631 (after %Samha to %Samha% tweak)

# ADD EXPEDITION INFO
# add expedition names to field notes and herbarium specimens: 
source("O:/CMEP Projects/Scriptbox/general_utilities/function_getExpedition.R")
getExpedition()

# show number of records returned
#nrow(herbRex)
#nrow(fielRex)
#nrow(litrRex)

# join field and herbarium data vertically
        # DON'T PANIC: error created ("Warning message: In `[<-.factor`(`*tmp*`, ri, value
        #  = c(NA, NA, NA, NA, NA, NA, NA, : invalid factor level, NA generated)") to do  
        # with data type of collNumFull in recGrab1 (factor) vs in recGrab2 (integer) 
        # but doesn't matter much!

# BIND ALL RECORD SOURCES TOGETHER!
recGrab <- rbind(herbRex, fielRex, litrRex)

#nrow(recGrab) 
# 2016/02/24 31184 x 28 (added expdName column)
# 2016/03/06 31195
# 2016/03/16 31610 (after Semhah -> Samha tweak)
# 2016/03/22 31614 (after %Samha to %Samha% tweak)




# 3) Add families, genus, reorder, 

##names(recGrab)
# [1] "recID"              "expdName"             "collector"         
# [4] "collNumFull"        "lnamID"             "acceptDetAs"       
# [7] "acceptDetNoAuth"    "detAs"              "lat1Dir"           
# [10] "lat1Deg"            "lat1Min"            "lat1Sec"           
# [13] "lat1Dec"            "anyLat"             "lon1Dir"           
# [16] "lon1Deg"            "lon1Min"            "lon1Sec"           
# [19] "lon1Dec"            "anyLon"             "coordSource"       
# [22] "coordAccuracy"      "coordAccuracyUnits" "coordSourcePlus"   
# [25] "dateDD"             "dateMM"             "dateYYYY"          
# [28] "fullLocation"    

# ADD FAMILIES
# pull out families from Latin Names table
source('O:/CMEP Projects/Scriptbox/general_utilities/function_getFamilies.R')
getFamilies()
# recGrab 31614 x 29 var

# ADD GENUS
# pull out genus (use non-auth det & then regex the epithet off)
recGrab$genusName <- recGrab$acceptDetNoAuth
recGrab$genusName <- gsub(" .*", "", recGrab$genusName)

# REORDER
# reorder columns so genus is after acceptDetNoAuth but before 'detAs'/unaccepted name:
# NOTE: reorder done longform with names as opp to indices to avoid hassle later!
recGrab <<- recGrab[,c(
        "recID", 
        "expdName",
        "collector", 
        "collNumFull", 
        "lnamID", 
        "familyName", 
        "acceptDetAs", 
        "acceptDetNoAuth", 
        "genusName", 
        "detAs", 
        "lat1Dir", 
        "lat1Deg", 
        "lat1Min", 
        "lat1Sec", 
        "lat1Dec", 
        "anyLat", 
        "lon1Dir", 
        "lon1Deg", 
        "lon1Min", 
        "lon1Sec", 
        "lon1Dec", 
        "anyLon", 
        "coordSource", 
        "coordAccuracy",
        "coordAccuracyUnits", 
        "coordSourcePlus", 
        "dateDD", 
        "dateMM", 
        "dateYYYY",
        "fullLocation"
)]




# 4) add taxonomic rank, bin by taxonomy, 

# ADD TAXONOMIC RANK
# pull out taxonomic rank from Latin Names table & apply to all recGrab records
source("O:/CMEP Projects/Scriptbox/general_utilities/function_getRanks.R")
getRanks()
# 22/03/2016 recGrab 31614 obs x 31 var

# BIN BY TAXONOMY
# keep all records with species-level, subspecies or variety-level 
# (also Sp. Nov. level) records ONLY
source("O:/CMEP Projects/Scriptbox/general_utilities/function_keepTaxRankOnly.R")
keepTaxRankOnly()
# 2016-03-06 leaves 26475 x 31 analysis set records (binned 4720 above sps-level)
# 2016/03/16 leaves 26853 x 31 analysis set records (after Semhah -> Samha tweak); binned 4757 above-sps
# 2016/03/22 leaves 26849 x 31 analysis set records (after %Samha/%Darsa -> %Samha%/%Darsa% tweak); binned 4765 above-sps




# 5) remove junk locations, fix bad location records, 

# REMOVE JUNK-LOCATION RECORDS
# weed out NA or 0-lat/lons.
source("O://CMEP\ Projects/Scriptbox/general_utilities/function_binJunkRecs.R")
binJunkRecs(returnJunk=FALSE, chattyReturn=TRUE)
# 2016-03-10 26011 x 31 after several fixes (removing filter on latDec=0/lonDec=0!)
# 2016/03/16 26388 x 31 (after Semhah -> Samha tweak)
# 2016/03/17 26276
# 2016/03/16 26383 x 31 analysis set records (after %Samha/%Darsa -> %Samha%/%Darsa% tweak); binned 466 trash recs

# FIX BAD RECORDS (LOCATION)
# alter bad records via script
source("O://CMEP\ Projects/Scriptbox/database_output/script_editBadRecords_Socotra.R")
# 2016/03/16 26383 x 31 still




# 6) lump subspecific taxa/remove lichens & bad taxa

# LUMP SUBSPECIFIC TAXA; REMOVE LICHENS & BAD TAXA
# lump subspecific taxa via script
source("O://CMEP\ Projects/Scriptbox/database_output/script_editTaxa_Socotra.R")
# 834 accepted taxa names
# 26220 x 31 records (removed lichens etc)

#########################################
# to re-do det sessions output, add Flic's fields notes & info to herbarium specimens (in herbSpxReqDet object):
# to get herbarium specimens needing further determination: 
# split off herbarium specimens NOT YET det to species level as herbSpxReqDet object
# source('O:/CMEP Projects/Scriptbox/general_utilities/function_getDetReqSpx.R')
# getDetReqSpx()
# to add herbarium info to herbarium specimens (in herbSpxReqDet object)
# source('O:/CMEP Projects/Scriptbox/general_utilities/function_getHerbariumCode.R')
# getHerbariumCode()
# to add Flic's Fields to herbarium specimen records
# source('O:/CMEP Projects/Scriptbox/general_utilities/function_getFlicsFields.R')
# getFlicsFields()
# make list for dets
# source("O://CMEP\ Projects/Scriptbox/database_output/script_listForDetSession_Socotra-Jan2016.R")
# write >>>herbSpxReqDet<<<to .csv file  
#message(paste0(" ... saving species-level-det-requiring herbarium records to: O://CMEP\ Projects/Socotra/DeterminationRequired_herbariumSpecimens-Socotra_", Sys.Date(), ".csv"))
#write.csv(herbSpxReqDet[order(herbSpxReqDet$collector, herbSpxReqDet$dateYYYY, herbSpxReqDet$collNumFull, herbSpxReqDet$acceptDetAs, na.last=TRUE),], file=paste0("O://CMEP\ Projects/Socotra/DeterminationRequired_herbariumSpecimens-Socotra_", Sys.Date(), ".csv"), na="", row.names=FALSE)
#odbcCloseAll()
#########################################




# 7) Save the output to .csv

# WRITE OUT
# write analysis-ready >>>recGrab<<< to .csv file  
message(paste0(" ... saving ", nrow(recGrab), " records to: O://CMEP\ Projects/Socotra/analysisRecords-Socotra_", Sys.Date(), ".csv"))
write.csv(recGrab[order(recGrab$collector, recGrab$dateYYYY, recGrab$collNumFull, recGrab$acceptDetAs, na.last=TRUE),], file=paste0("O://CMEP\ Projects/Socotra/analysisRecords-Socotra_", Sys.Date(), ".csv"), na="", row.names=FALSE)

# VERY IMPORTANT!
# CLOSE DATABASE CONNECTIONS
odbcCloseAll()




# 8) tidy up

# REMOVE ALL OBJECTS FROM WORKSPACE!
#rm(list=ls())

# # REMOVE SOME OBJECTS FROM WORKSPACE!
#         # removes EVERYTHING EXCEPT WHAT YOU WANT TO KEEP 
#         # (eg. connections, recGrab, etc):
# rm(list=setdiff(ls(), 
#                 c(
#                 "recGrab", 
#                 "taxaListSocotra",
#                 "con_livePadmeArabia", 
#                 "livePadmeArabiaCon"
#                 )
#         )
# )

# VERY IMPORTANT!
# CLOSE THE CONNECTION!
odbcCloseAll()

print(" ... datagrab complete!")

## for summary stats and analysis, go to "O://CMEP\ Projects/Scriptbox/database_analysis/script_summaryStats-recGrabFullLatLonOrGazLatLon_Socotra.R"