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
# 1) 
# 2) Build query 
# 3) Run the query
# 4) Show the output
# 5) Save the output to .csv

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


# 1) 

###---------------------- USER INPUT REQUIRED HERE --------------------------###

# please input the location you're searching for, as shown in the examples below:
# examples: 
#locatName <- "Socotra"
#locatName <- "Socotra Archipelago"
#locatName <- "Hadibo"
#locatName <- "Socotra"

###---------------------- USER INPUT REQUIRED HERE --------------------------###

# 2)

# get headings for herbarium specimens and field notes and literature records tables
#Herb <- sqlQuery(con_livePadmeArabia, query="SELECT TOP 1 * FROM [Herbarium specimens]")
#Fiel <- sqlQuery(con_livePadmeArabia, query="SELECT TOP 1 * FROM [Field notes]")
#Litr <- sqlQuery(con_livePadmeArabia, query="SELECT TOP 1 * FROM [literature records]")

# build HERB query
# Adapted from script_dataGrabSpecieswithFullLatLon.R
qry1 <- paste0("
SELECT 'H-' & Herb.id AS recID, 
Team.[name for display] AS collector,
Herb.[Collector Number] AS collNumFull,
LnSy.[id] AS lnamID, ",
# HERE the Lnam.FullName is replaced by the ACCEPTED NAME (LnSy.[Full Name])
# THIS IS NOT WHAT IT WAS ORIG DET AS BUT THE ACCEPTED UPDATED NAME
"LnSy.[Full Name] AS acceptDetAs,
LnSy.[sortName] AS acceptDetNoAuth,
Lnam.[Full Name] AS detAs,
Herb.[Latitude 1 Direction] AS lat1Dir,
Herb.[Latitude 1 Degrees] AS lat1Deg,
Herb.[Latitude 1 Minutes] AS lat1Min,
Herb.[Latitude 1 Seconds] AS lat1Sec,
Herb.[Latitude 1 Decimal] AS lat1Dec, ",
#IIF no decimal latitude, then use geography/gazetteer latitude, but if it's there, use that as anyLat
"IIf(IsNull(Herb.[Latitude 1 Decimal]),Geog.[Latitude 1 Decimal],Herb.[Latitude 1 Decimal]) AS anyLat,
Herb.[Longitude 1 Direction] AS lon1Dir,
Herb.[Longitude 1 Degrees] AS lon1Deg,
Herb.[Longitude 1 Minutes] AS lon1Min,
Herb.[Longitude 1 Seconds] AS lon1Sec,
Herb.[Longitude 1 Decimal] AS lon1Dec, ",
#IIF no decimal longitude, then use geography/gazetteer longitude, but if it's there, use that as anyLon
"IIf(IsNull(Herb.[Longitude 1 Decimal]),Geog.[Longitude 1 Decimal],Herb.[Longitude 1 Decimal]) AS anyLon,
Herb.[coordinateSource] AS coordSource,
Herb.[coordinateAccuracy] AS coordAccuracy,
Herb.[coordinateAccuracyUnits] AS coordAccuracyUnits,
iif(isnull(Herb.[Latitude 1 Decimal]),'Gazetteer','Record') as coordSourcePlus,
Herb.[Date 1 Days] AS dateDD, 
Herb.[Date 1 Months] AS dateMM, 
Herb.[Date 1 Years] AS dateYYYY,
Geog.fullName AS fullLocation ",
# Joining tables: Herb, Geog, Herbaria, Determinations, Synonyms tree, Latin Names, Teams x2, CoordinateSources
               "FROM ((((((((Determinations AS Dets 
RIGHT JOIN [Herbarium specimens] AS Herb ON Dets.[specimen key] = Herb.id) 
LEFT JOIN [Latin Names] AS Lnam ON Dets.[latin name key] = Lnam.id) 
LEFT JOIN [Synonyms tree] AS Synm ON Lnam.id = Synm.member) 
LEFT JOIN [Latin Names] AS LnSy ON Synm.[member of] = LnSy.id) 
LEFT JOIN Geography AS Geog ON Herb.Locality = Geog.ID) 
LEFT JOIN Teams AS Team ON Herb.[Collector Key] = Team.id) 
LEFT JOIN Herbaria ON Herb.Herbarium = Herbaria.id) 
LEFT JOIN CoordinateSources AS Coor ON Herb.coordinateSource = Coor.id) 
LEFT JOIN Teams AS DtTm ON Dets.[Det by] = DtTm.id ",
# WHERE: 
"WHERE ",
# only pull out records with current dets: 
"Dets.Current=True ",
# REQ: FIX FOR SYNONYMS POPPING UP IN DATA WITH SAME H-IDs

#       the location string doesn't stop at "Socotra" or "Socotran Archipelago": 
#              (to avoid lots of dots at the lat/lon of "Socotra" etc since that's very
#              unhelpful & doesn't give us a true location, even though it's a precise 
#              lat/lon value.
#              NB: The smaller islands Darsa & Semhah are allowed as they're small 
#              enough to be useful location values. Abd Al Kuri is still a bit too big
"AND ((Geog.fullName LIKE '%Socotra:%' OR Geog.fullName LIKE '%Abd al Kuri:%' OR Geog.fullName LIKE '%Semhah' OR Geog.fullName LIKE '%Darsa') ",
#       OR location string does just say Socotra or the Archipelago BUT has 
#       a valid lat/lon (tested on longitude). 
#               This ensures recently imported datasets with GPS/decimal degrees
#               high-accuracy lat/lon are included!
"OR ((Geog.fullName LIKE '%Socotra Archipelago: Socotra' AND Herb.[Longitude 1 Decimal] IS NOT NULL) OR (Geog.fullName LIKE '%Socotra Archipelago' AND Herb.[Longitude 1 Decimal] IS NOT NULL))) AND ((LnSy.[Synonym of]) Is Null) ",
# ORDER BY ...
"ORDER BY Team.[name for display];")


# build FIEL query
# Adapted from script_dataGrabSpecieswithFullLatLon.R & various fieldObs scripts
qry2 <- paste0("
SELECT 'F-' & Fiel.id AS recID,
Team.[name for display] AS collector,
Fiel.[Collector Number] AS collNumFull,
LnSy.[id] AS lnamID, ",
# HERE the Lnam.FullName is replaced by the ACCEPTED NAME (LnSy.[Full Name])
# THIS IS NOT WHAT IT WAS ORIG DET AS BUT THE ACCEPTED UPDATED NAME
# NOTE::: THIS MAY NOT BE LEGIT FOR LITERATURE RECORDS OR FIELD RECORDS 
# SINCE THEY CANNOT BE UPDATED!!  THINK ABOUT THIS!!!
"LnSy.[Full Name] AS acceptDetAs,
LnSy.[sortName] AS acceptDetNoAuth,
Lnam.[Full Name] AS detAs,
Fiel.[Latitude 1 Direction] AS lat1Dir,
Fiel.[Latitude 1 Degrees] AS lat1Deg,
Fiel.[Latitude 1 Minutes] AS lat1Min,
Fiel.[Latitude 1 Seconds] AS lat1Sec,
Fiel.[Latitude 1 Decimal] AS lat1Dec,",
#IIF no decimal latitude, then use geography/gazetteer latitude, but if it's there, use that as anyLat
"IIf(IsNull(Fiel.[Latitude 1 Decimal]),Geog.[Latitude 1 Decimal],Fiel.[Latitude 1 Decimal]) AS anyLat,
Fiel.[Longitude 1 Direction] AS lon1Dir,
Fiel.[Longitude 1 Degrees] AS lon1Deg,
Fiel.[Longitude 1 Minutes] AS lon1Min,
Fiel.[Longitude 1 Seconds] AS lon1Sec,
Fiel.[Longitude 1 Decimal] AS lon1Dec,", 
#IIF no decimal longitude, then use geography/gazetteer longitude, but if it's there, use that as anyLon
"IIf(IsNull(Fiel.[Longitude 1 Decimal]),Geog.[Longitude 1 Decimal],Fiel.[Longitude 1 Decimal]) AS anyLon,
Fiel.[coordinateSource] AS coordSource,
iif(isnull(Fiel.[Latitude 1 Decimal]),'Gazetteer','Record') as coordSourcePlus,
Fiel.[coordinateAccuracy] AS coordAccuracy,
Fiel.[coordinateAccuracyUnits] AS coordAccuracyUnits,
Fiel.[Date 1 Days] AS dateDD, 
Fiel.[Date 1 Months] AS dateMM, 
Fiel.[Date 1 Years] AS dateYYYY,
Geog.fullName AS fullLocation ",
# Joining tables: Field notes, geography, synonyms tree, latin names x2, teams
"FROM (((([Field notes] AS Fiel 
LEFT JOIN Geography AS Geog ON Fiel.Locality = Geog.ID) 
LEFT JOIN Teams AS Team ON Fiel.[Collector Key] = Team.id) 
LEFT JOIN [Latin Names] AS Lnam ON Fiel.determination = Lnam.id) 
LEFT JOIN [Synonyms tree] AS Snym ON Lnam.id = Snym.member) 
LEFT JOIN [Latin Names] AS LnSy ON Snym.[member of] = LnSy.id ",
# WHERE: 
"WHERE ",
#       the location string doesn't stop at "Socotra" or "Socotran Archipelago": 
#              (to avoid lots of dots at the lat/lon of "Socotra" etc since that's very
#              unhelpful & doesn't give us a true location, even though it's a precise 
#              lat/lon value.
#              NB: The smaller islands Darsa & Semhah are allowed as they're small 
#              enough to be useful location values. Abd Al Kuri is still a bit too big
"(((Geog.fullName LIKE '%Socotra:%' OR Geog.fullName LIKE '%Abd al Kuri:%' OR Geog.fullName LIKE '%Semhah' OR Geog.fullName LIKE '%Darsa') ", 
#       OR      location string does just say Socotra or the Archipelago BUT has 
#               a valid lat/lon (tested on longitude). 
#               This ensures recently imported datasets with GPS/decimal degrees
#               high-accuracy lat/lon are included!
"OR ((Geog.fullName LIKE '%Socotra Archipelago: Socotra' AND Fiel.[Longitude 1 Decimal] IS NOT NULL) OR (Geog.fullName LIKE '%Socotra Archipelago' AND Fiel.[Longitude 1 Decimal] IS NOT NULL))) AND ((LnSy.[Synonym of]) Is Null))",
# ORDER BY ...
"ORDER BY Team.[name for display];")




# build LITR query
# adapted from script_dataGrabSpecieswithFullLatLon.R
qry3 <- paste0("
SELECT 'L-' & Litr.id AS recID, 
Auth.[name for display] AS collector,
Litr.id AS collNumFull, 
LnSy.[id] AS lnamID, ",
# HERE the Lnam.FullName is replaced by the ACCEPTED NAME (LnSy.[Full Name])
# THIS IS NOT WHAT IT WAS ORIG DET AS BUT THE ACCEPTED UPDATED NAME
# NOTE::: THIS MAY NOT BE LEGIT FOR LITERATURE RECORDS OR FIELD RECORDS 
# SINCE THEY CANNOT BE UPDATED!!  THINK ABOUT THIS!!!
"LnSy.[Full Name] AS acceptDetAs,
LnSy.[sortName] AS acceptDetNoAuth,
Lnam.[Full Name] AS detAs,
Litr.[Latitude 1 Direction] AS lat1Dir,
Litr.[Latitude 1 Degrees] AS lat1Deg,
Litr.[Latitude 1 Minutes] AS lat1Min,
Litr.[Latitude 1 Seconds] AS lat1Sec,
Litr.[Latitude 1 Decimal] AS lat1Dec,", 
#IIF no decimal latitude, then use geography/gazetteer latitude, but if it's there, use that as anyLat
"IIf(IsNull(Litr.[Latitude 1 Decimal]),Geog.[Latitude 1 Decimal],Litr.[Latitude 1 Decimal]) AS anyLat,
Litr.[Longitude 1 Direction] AS lon1Dir,
Litr.[Longitude 1 Degrees] AS lon1Deg,
Litr.[Longitude 1 Minutes] AS lon1Min,
Litr.[Longitude 1 Seconds] AS lon1Sec,
Litr.[Longitude 1 Decimal] AS lon1Dec,", 
#IIF no decimal longitude, then use geography/gazetteer longitude, but if it's there, use that as anyLon
"IIf(IsNull(Litr.[Longitude 1 Decimal]),Geog.[Longitude 1 Decimal],Litr.[Longitude 1 Decimal]) AS anyLon,
Litr.[coordinateSource] AS coordSource,
iif(isnull(Litr.[Latitude 1 Decimal]),'Gazetteer','Record') as coordSourcePlus,
Litr.[coordinateAccuracy] AS coordAccuracy,
Litr.[coordinateAccuracyUnits] AS coordAccuracyUnits,
Litr.[Date 1 Days] AS dateDD, 
Litr.[Date 1 Months] AS dateMM, 
Litr.[Date 1 Years] AS dateYYYY,
Geog.fullName AS fullLocation ",
# Joining tables: Literature records, Teams, References, Literature Record Locations, geography, latin names x2
"FROM (((Teams AS Auth 
RIGHT JOIN ([References] AS Refr 
RIGHT JOIN ([Latin Names] AS Lnam 
RIGHT JOIN [literature records] AS Litr 
ON Lnam.id = Litr.determination) 
ON Refr.id = Litr.Reference) 
ON Auth.id = Refr.Authors) 
LEFT JOIN (Geography AS Geog 
RIGHT JOIN LiteratureRecordLocations AS LRLo 
ON Geog.ID = LRLo.locality) 
ON Litr.id = LRLo.litrecid) 
LEFT JOIN [Synonyms tree] AS Synm ON Lnam.id = Synm.member) 
LEFT JOIN [Latin Names] AS LnSy ON Synm.[member of] = LnSy.id ",
# WHERE: 
"WHERE ", 
#       the location string doesn't stop at "Socotra" or "Socotran Archipelago": 
#              (to avoid lots of dots at the lat/lon of "Socotra" etc since that's very
#              unhelpful & doesn't give us a true location, even though it's a precise 
#              lat/lon value.
#              NB: The smaller islands Darsa & Semhah are allowed as they're small 
#              enough to be useful location values. Abd Al Kuri is still a bit too big
"(((Geog.fullName LIKE '%Socotra:%' OR Geog.fullName LIKE '%Abd al Kuri:%' OR Geog.fullName LIKE '%Semhah' OR Geog.fullName LIKE '%Darsa')", 
#       OR location string does just say Socotra or the Archipelago BUT has 
#       a valid lat/lon (tested on longitude). 
#               This ensures recently imported datasets with GPS/decimal degrees
#               high-accuracy lat/lon are included!
"OR ((Geog.fullName LIKE '%Socotra Archipelago: Socotra' AND Litr.[Longitude 1 Decimal] IS NOT NULL) OR (Geog.fullName LIKE '%Socotra Archipelago' AND Litr.[Longitude 1 Decimal] IS NOT NULL))) AND LnSy.[Synonym of] IS NULL) ",
# ORDER BY ...
"ORDER BY Litr.id;")



# 3)

# run query
herbRex <- sqlQuery(con_livePadmeArabia, qry1) 
# 03/06/2015 1843 req DMS, 3647 req DM, 8166 w/ IFF, 
# 04/06/2015 6089 rm Socotra w/o latlon
# 05/06/2015 6155 with only accepted names 
# 08/06/2015 6149 (fixed some latin names taxonomy in padme)
# 18/01/2016 6172 (after adding some specimens)

# ISSUE: system resources exceeded! in RODBC drivers & Access
#fielRex <- sqlQuery(con_livePadmeArabia, qry2) 
#"HY001 -1011 [Microsoft][ODBC Microsoft Access Driver] System resource exceeded."
# query is now too large!

# FIX: 
# TL;DR - when system resources exceeded, create temp table, run query in 
# Padme/Accesss to put records into newly created temporary table, then pull into R & proceed as normal.
        # FIX: 
        # Created table [FieldRexTemp] in test copy of Padme Arabia.    
        # 
        # Output of sqlColumns() here:
        # https://gist.github.com/FlicAnderson/ad44350a62eb017387b6
        # shows column and data types
        # 
        # Ran this query:
        # https://gist.github.com/FlicAnderson/0a3ab3622c6902733f5b
        # to fill the FieldRexTemp table with the query result. 
        # Had to do separate steps for create and "INSERT INTO FieldRexTemp 
        # SELECT ......;" because otherwise Access gave "system resource exceeded" error.
        # 
        # Running this worked after that:
        # source("O://CMEP\ Projects/Scriptbox/database_connections/function_TESTPadmeArabiaCon.R") 
        # TESTPadmeArabiaCon() 
        # qry0 <- "SELECT * FROM FieldRexTemp" 
        # fielRex <- sqlQuery(con_TESTPadmeArabia, qry0)
        # 
        # All worked ok, can proceed as normal now.

source("O://CMEP\ Projects/Scriptbox/database_connections/function_TESTPadmeArabiaCon.R")
TESTPadmeArabiaCon()
qry0 <- "SELECT * FROM FieldRexTemp"
fielRex <- sqlQuery(con_TESTPadmeArabia, qry0) 
# 04/02/2016 24233 obs 28 var - need to remove the id column!
# remove ID field
fielRex$id <- NULL
# 04/02/2016 24233 obs 27 var - OK to continue!


# 03/06/2015 4602 req DMS, 6754 req DM, 12253 w/ IFF
# 04/06/2015 12037 rm Socotra w/o latlon
# 08/06/2015 10962 rm duplicate IDs via accepted names only
litrRex <- sqlQuery(con_livePadmeArabia, qry3) 
# 03/06/2015 0 req DMS, 31 req DM, 1866 w/ IFF
# 04/06/2015 651 rm Socotra w/o latlon
# 08/06/2015 649 with accepted names only

# show number of records returned
nrow(herbRex)
nrow(fielRex)
nrow(litrRex)

# join field and herbarium data vertically
        # DON'T PANIC: error created ("Warning message: In `[<-.factor`(`*tmp*`, ri, value
        #  = c(NA, NA, NA, NA, NA, NA, NA, : invalid factor level, NA generated)") to do  
        # with data type of collNumFull in recGrab1 (factor) vs in recGrab2 (integer) 
        # but doesn't matter much!

recGrab <- rbind(herbRex, fielRex, litrRex)
nrow(recGrab) 
# 03/06/2015 6445 req DMS, 10432 req DM, 22285 w/ IFF
# 04/06/2015 19497 rm Socotra w/o latlon
# 05/06/2015 18843 herb specimens with only accepted names
# 08/06/2015 17762 rm duplicate recIDs; field notes with only accepted names
# 08/06/2015 17760 literature records with only accepted names
# 19/01/2016 17783 x 27 var (a few more herbarium specimens were added)

# sort so recent specimens & collector groups float to the top 
recGrab <- recGrab[order(recGrab$dateYYYY, recGrab$dateMM, recGrab$dateDD, recGrab$collector, na.last=TRUE),]

# 4)

# show first 6 records returned 
        # sort so recent specimens & collector groups float to the top 
head(recGrab[order(recGrab$dateYYYY, recGrab$dateMM, recGrab$dateDD, recGrab$collector, na.last=TRUE),])

# alternate sort & show first 6 records 
# sorted so Edinburgh specimens, then found specimens float to the top 
# head(recGrab[order(order(recGrab$institute, recGrab$FlicFound, decreasing=TRUE, na.last=TRUE)),])

##names(recGrab)
#  [1] "recID"              "collector"          "collNumFull"        "lnamID"             "acceptDetAs"
#  [6] "acceptDetNoAuth"    "detAs"              "lat1Dir"            "lat1Deg"            "lat1Min"    
# [11] "lat1Sec"            "lat1Dec"            "anyLat"             "lon1Dir"            "lon1Deg"  
# [16] "lon1Min"            "lon1Sec"            "lon1Dec"            "anyLon"             "coordSource  
# [21] "coordAccuracy"      "coordAccuracyUnits" "coordSourcePlus"    "dateDD"             "dateMM"      
# [26] "dateYYYY"             "fullLocation"  


# pull out families from Latin Names table
source('O:/CMEP Projects/Scriptbox/general_utilities/function_getFamilies.R')
getFamilies()
# recGrab 17783 x 28 var

# pull out genus (use non-auth det & then regex the epithet off)
recGrab$genusName <- recGrab$acceptDetNoAuth
recGrab$genusName <- gsub(" .*", "", recGrab$genusName)

# reorder columns so genus is after acceptDetNoAuth but before 'detAs'/unaccepted name:
# NOTE: reorder done longform with names as opp to indices to avoid hassle later!
recGrab <<- recGrab[,c(
        "recID", 
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

# pull out taxonomic rank from Latin Names table & apply to all recGrab records
source('O:/CMEP Projects/Scriptbox/general_utilities/function_getRanks.R')
getRanks()
# recGrab 17783 obs x 30 var

# split off herbarium specimens NOT YET det to species level as herbSpxReqDet object
source('O:/CMEP Projects/Scriptbox/general_utilities/function_getDetReqSpx.R')
getDetReqSpx()
# recGrab still 17783 x 30 & names() order the same as directly above
# herbSpxReqDet 666 x 30 & names() order still the same


# add herbarium info to herbarium specimens (in herbSpxReqDet object)
source('O:/CMEP Projects/Scriptbox/general_utilities/function_getHerbariumCode.R')
getHerbariumCode()
# recGrab unaltered 17778 x 30
# herbSpxReqDet 657 x 31 var & order changed


# still need to filter out the herbarium specimens for sorting though.
# KEEP: 
# ones which have geolocation
# ones at E (or no-herbarium-code, since that's probably a lot)
# 

# add Flic's fields notes & info to herbarium specimens (in herbSpxReqDet object)
source('O:/CMEP Projects/Scriptbox/general_utilities/function_getFlicsFields.R')
getFlicsFields()
# recGrab unaltered
# herbSpxReqDet 666 x 35 var & order changed

str(herbSpxReqDet)
herbSpxReqDet <- tbl_df(herbSpxReqDet)
herbSpxReqDet

table(herbSpxReqDet$herbariumCode, useNA="ifany")
# BM    E       HNT     K       UPS     <NA> 
#  5    353     8       1       36      254
# we only can determine specimens at E, really


# make list for dets
source("O://CMEP\ Projects/Scriptbox/database_output/script_listForDetSession_Socotra-Jan2016.R")


#########################################


# 5)

# write ALL >>>recGrab<<< to .csv file  
# UNCOMMENT THESE TWO LINES TO WRITE OUT!
#message(paste0(" ... saving records to: O://CMEP\ Projects/Socotra/allRecords-Socotra_", Sys.Date(), ".csv"))
#write.csv(recGrab[order(recGrab$collector, recGrab$dateYYYY, recGrab$collNumFull, recGrab$acceptDetAs, na.last=TRUE),], file=paste0("O://CMEP\ Projects/Socotra/allRecords-Socotra_", Sys.Date(), ".csv"), na="", row.names=FALSE)


# write >>>herbSpxReqDet<<<to .csv file  
# UNCOMMENT THESE TWO LINES TO WRITE OUT!
#message(paste0(" ... saving species-level-det-requiring herbarium records to: O://CMEP\ Projects/Socotra/DeterminationRequired_herbariumSpecimens-Socotra_", Sys.Date(), ".csv"))
#write.csv(herbSpxReqDet[order(herbSpxReqDet$collector, herbSpxReqDet$dateYYYY, herbSpxReqDet$collNumFull, herbSpxReqDet$acceptDetAs, na.last=TRUE),], file=paste0("O://CMEP\ Projects/Socotra/DeterminationRequired_herbariumSpecimens-Socotra_", Sys.Date(), ".csv"), na="", row.names=FALSE)



# VERY IMPORTANT!
# CLOSE DATABASE CONNECTIONS
odbcCloseAll()

# REMOVE ALL OBJECTS FROM WORKSPACE!
#rm(list=ls())

# # REMOVE SOME OBJECTS FROM WORKSPACE!
#         # removes EVERYTHING EXCEPT WHAT YOU WANT TO KEEP 
#         # (eg. connections, recGrab, etc):
# rm(list=setdiff(ls(), 
#                 c(
#                 "recGrab", 
#                 "herbSpxReqDet", 
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