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

# check for recGrab object
# informative error if it doesn't exist
if(!exists("recGrab")) stop("... ERROR: recGrab object doesn't exist")

# file location details:
fileLocat <- "O://CMEP\ Projects/Socotra"
fileName <- "BadRecords_socotra-2016-03-07_newLatLonReqUpdate.csv"

# import source:
importSource <<- paste0(fileLocat, "/", fileName)

# is file a .csv or something else?
# get extension
extns <- paste0(".", unlist(strsplit(importSource, "[.]"))[2])
# check if it's not .csv & give informative error if it doesn't exist
if(!grepl(".csv", extns)) stop("... ERROR: file not in .csv format, please save as .csv and try again")

# check for bad records file
# informative error if it doesn't exist
if(!file.exists(importSource)) stop(paste0("... ERROR: ", importSource, " file does not exist"))

# import csv with edit info
reqEdits <<- read.csv(
        file=importSource, 
        header=TRUE, 
        as.is=TRUE, 
        na.strings=""
)

# change column names "New.AnyLon" and "New.AnyLat" to something without dots
names(reqEdits)[names(reqEdits)=="New.AnyLat"] <- "newLat"
names(reqEdits)[names(reqEdits)=="New.AnyLon"] <- "newLon"

# join recGrab and reqEdits
recGrabTemp <-
        sqldf(
                "SELECT 
                recGrab.*, 
                reqEdits.newLat, 
                reqEdits.newLon  
                FROM recGrab 
                LEFT JOIN reqEdits ON recGrab.recID=reqEdits.recID"
        )

# create new column tempLat/tempLon which uses anyLat/Lon if there is no newLat/Lon (from edit file)
recGrabTemp <- 
        recGrabTemp %>%
        mutate(tempLat=ifelse(!(is.na(newLat)), newLat, anyLat)) %>%
        mutate(tempLon=ifelse(!(is.na(newLon)), newLon, anyLon))

# replace recGrab anyLat/anyLon with tempLat/tempLon to include the fixes
recGrab$anyLat <- recGrabTemp$tempLat
recGrab$anyLon <- recGrabTemp$tempLon

recGrab <<- recGrab

# tidy up
rm(recGrabTemp, reqEdits)

# check it works: 
filter(recGrab, recID=="H-15153") %>% select(lat1Dec, anyLat, lon1Dec, anyLon)
# Lavranos & Radcliffe-Smith herbarium specimen number 690
# Source: local data frame [1 x 4]
# 
# lat1Dec  anyLat lon1Dec  anyLon
# 1 12.23333 12.1896   52.25 52.2458
# if anyLat = 12.1896 and anyLon = 52.2458, everything is FINE :)

filter(recGrab, recID=="F-3460") %>% select(lat1Dec, anyLat, lon1Dec, anyLon)
# Miller field observation of a Pulicaria
# Source: local data frame [1 x 4]
# 
# lat1Dec  anyLat  lon1Dec  anyLon
# 1 12.56667 12.5494 53.38334 53.3857
# if anyLat = 12.5494 and anyLon = 53.3857, everything is FINE :)


##----------------------------------------------------------------------------##


# check for recGrab object
# informative error if it doesn't exist
if(!exists("recGrab")) stop("... ERROR: recGrab object doesn't exist")

# file location details:
fileLocat <- "O://CMEP\ Projects/Socotra"
fileName <- "BadRecords_socotra-2016-03-07_needGazetteerLatLonReplacement.csv"

# import source:
importSource <<- paste0(fileLocat, "/", fileName)

# check for bad records file
# informative error if it doesn't exist
if(!file.exists(importSource)) stop(paste0("... ERROR: ", importSource, " file does not exist"))

# is file a .csv or something else?
# get extension
extns <- paste0(".", unlist(strsplit(importSource, "[.]"))[2])
# check if it's not .csv & give informative error if it doesn't exist
if(!grepl(".csv", extns)) stop("... ERROR: file not in .csv format, please save as .csv and try again")

# import csv with edit info
reqEdits <<- read.csv(
        file=importSource, 
        header=TRUE, 
        as.is=TRUE, 
        na.strings=""
)

# check the connection is still open
# informative error if connection not created
if(!exists("con_livePadmeArabia")) stop("... ERROR: connection to the database not open")

# create tbl_df obj
reqEdits <- tbl_df(reqEdits)

# split reqEdits into types (need different queries for herb/fiel/lit)
# filter out only herbarium specimens
herbSpx <- filter(reqEdits, grepl("H-", reqEdits$recID))
# filter out only field records
fielSpx <- filter(reqEdits, grepl("F-", reqEdits$recID))
# filter out only literature records - none there!
#litrSpx <- filter(reqEdits, grepl("L-", reqEdits$recID))


# recreate original record table IDs by record type group 
herbSpx <- 
        herbSpx %>%
        mutate(recID, origID=gsub("H-", "", recID)) %>%
        select(recID, origID, anyLat, anyLon, fullLocati)

fielSpx <- 
        fielSpx %>%
        mutate(recID, origID=gsub("F-", "", recID)) %>%
        select(recID, origID, anyLat, anyLon, fullLocati)

#litrSpx <- 
#        litrSpx %>%
#        mutate(recID, origID=gsub("L-", "", recID)) %>%
#        select(recID, origID, anyLat, anyLon, fullLocati)

# query to rejoin geography info
# herbarium specimen method
herbQry <- "SELECT 'H-' & Herb.id AS recID, 
Geog.[Latitude 1 Decimal] AS newLat,
Geog.[Longitude 1 Decimal] AS newLon,
Geog.fullName AS fullLocation
FROM [Herbarium specimens] AS Herb
LEFT JOIN Geography AS Geog ON Herb.Locality = Geog.ID
;"
# run query to catch (all!) geography info :s
herbAllGeog <- sqlQuery(con_livePadmeArabia, herbQry)
# join newLat & newLon onto reqEdits
recGrabTemp1 <<- 
        sqldf("SELECT 
              reqEdits.recID, 
              reqEdits.anyLat, 
              reqEdits.anyLon, 
              reqEdits.fullLocati, 
              herbAllGeog.newLat, 
              herbAllGeog.newLon, 
              herbAllGeog.fullLocation
              FROM reqEdits
              INNER JOIN herbAllGeog ON reqEdits.recID=herbAllGeog.recID
              ")
# bin huge dataframe
rm(herbAllGeog)
# field records
fielQry <- "SELECT 'F-' & Fiel.id AS recID, 
Geog.[Latitude 1 Decimal] AS newLat,
Geog.[Longitude 1 Decimal] AS newLon,
Geog.fullName AS fullLocation
FROM [Field notes] AS Fiel 
LEFT JOIN [Geography] AS Geog ON Fiel.Locality = Geog.ID
;"
# run query to catch (all!) geography info :s
fielAllGeog <- sqlQuery(con_livePadmeArabia, fielQry)
# join newLat & newLon onto reqEdits
recGrabTemp2 <<- 
        sqldf("SELECT 
              reqEdits.recID, 
              reqEdits.anyLat, 
              reqEdits.anyLon, 
              reqEdits.fullLocati, 
              fielAllGeog.newLat, 
              fielAllGeog.newLon, 
              fielAllGeog.fullLocation
              FROM reqEdits
              INNER JOIN fielAllGeog ON reqEdits.recID=fielAllGeog.recID
              ")
# bin huge dataframe
rm(fielAllGeog)

# bind herbarium and field records back together
recGrabTemp <- bind_rows(tbl_df(recGrabTemp1), tbl_df(recGrabTemp2))
rm(recGrabTemp1, recGrabTemp2)

# join the new lat/lons to recGrab as additional columns
recGrabTemp3 <- 
        sqldf("SELECT recGrab.*, recGrabTemp.newLat, recGrabTemp.newLon FROM recGrab LEFT JOIN recGrabTemp ON recGrab.recID=recGrabTemp.recID")

# create new column tempLat/tempLon which uses anyLat/Lon if there is no newLat/Lon (from edit file)
recGrabTemp4 <- 
        recGrabTemp3 %>%
        mutate(tempLat=ifelse(!(is.na(newLat)), newLat, anyLat)) %>%
        mutate(tempLon=ifelse(!(is.na(newLon)), newLon, anyLon))

# replace recGrab anyLat/anyLon with tempLat/tempLon to include the fixes
recGrab$anyLat <- recGrabTemp4$tempLat
recGrab$anyLon <- recGrabTemp4$tempLon

# ensure it's written out to the global env level
recGrab <<- recGrab

# tidy up a bunch of stuff
rm(recGrabTemp3, recGrabTemp4, fielSpx, herbSpx, reqEdits, importSource, extns, fileName, fileLocat, herbQry, fielQry)

#### TEST REQ ###

################################################################################


#### remove additional bad records: 
recGrab <- 
        recGrab %>%
        filter(recID != "H-6388") %>%
        filter(recID != "H-2796") %>%
        filter(recID != "H-3259") %>%
        filter(recID != "F-6343") %>%
        filter(recID != "F-6344") %>%
        filter(recID != "F-6342") %>%
        filter(recID != "F-9858") %>%
        filter(recID != "F-6346") %>%
        filter(recID != "F-6804") %>%
        filter(recID != "F-9857") %>% 
        filter(recID != "F-9859") %>% 
        filter(recID != "F-6341") %>%
        filter(recID != "F-6345") %>%
        filter(recID != "F-6803") %>%
        filter(recID != "F-6347") %>%
        filter(recID != "F-6805") %>%
        filter(recID != "H-57154") %>% 
        filter(recID != "H-55624") %>%
        filter(recID != "H-4418") %>%
        filter(recID != "L-1130") %>% # removing these 4 literature records because they're not particularly valuable here 
        filter(recID != "L-1263") %>%
        filter(recID != "L-773") %>%
        filter(recID != "L-1172")

# ensure these save out to global object
recGrab <<- recGrab

# file location details:
fileLocat <- "O://CMEP\ Projects/Socotra"
fileName <- "BadXY-analysisRecords-Socotra_2016-03-29.csv"

# import source:
importSource <<- paste0(fileLocat, "/", fileName)

# is file a .csv or something else?
# get extension
extns <- paste0(".", unlist(strsplit(importSource, "[.]"))[2])
# check if it's not .csv & give informative error if it doesn't exist
if(!grepl(".csv", extns)) stop("... ERROR: file not in .csv format, please save as .csv and try again")

# check for bad records file
# informative error if it doesn't exist
if(!file.exists(importSource)) stop(paste0("... ERROR: ", importSource, " file does not exist"))

# import csv with edit info
reqEdits <<- read.csv(
        file=importSource, 
        header=TRUE, 
        as.is=TRUE, 
        na.strings="", 
        nrows = 353  
        # nrows=353 avoids the taxa to remove as they are outside land limits & don't have precise information
        # plus they've been removed by filtering out the recIDs above, so it's captured elsewhere.
)

# column names are newLat and newLon anyway, so that's ok

# join recGrab and reqEdits
recGrabTemp <-
        sqldf(
                "SELECT 
                recGrab.*, 
                reqEdits.newLat, 
                reqEdits.newLon  
                FROM recGrab 
                LEFT JOIN reqEdits ON recGrab.recID=reqEdits.recID"
        )

# create new column tempLat/tempLon which uses anyLat/Lon if there is no newLat/Lon (from edit file)
recGrabTemp <- 
        recGrabTemp %>%
        mutate(tempLat=ifelse(!(is.na(newLat)), newLat, anyLat)) %>%
        mutate(tempLon=ifelse(!(is.na(newLon)), newLon, anyLon))

# replace recGrab anyLat/anyLon with tempLat/tempLon to include the fixes
recGrab$anyLat <- recGrabTemp$tempLat
recGrab$anyLon <- recGrabTemp$tempLon

recGrab <<- recGrab

# tidy up
rm(recGrabTemp, reqEdits)

# check it works: 
filter(recGrab, recID=="H-6037") %>% select(lat1Dec, anyLat, lon1Dec, anyLon)
# Miller collection, collNo=12514, Atriplex griffithii
# Source: local data frame [1 x 4]
# 
#lat1Dec anyLat lon1Dec   anyLon
#1      NA   12.1      NA 53.26667 # BAD
#lat1Dec  anyLat lon1Dec   anyLon
#1      NA 12.1219      NA 53.27032 # GOOD
# if anyLat = 12.12189 and anyLon = 53.27032, everything is FINE :)
# if anyLat = 12.1 and anyLon = 53.26667, everything is BROKEN :C

filter(recGrab, recID=="F-32631") %>% select(lat1Dec, anyLat, lon1Dec, anyLon)
# Miller field observation of a Euphorbia schimerpi
# Source: local data frame [1 x 4]
# 
#lat1Dec anyLat lon1Dec anyLon
#1   12.75  12.45    54.5  54.35
#lat1Dec   anyLat lon1Dec   anyLon
#1   12.75 12.44747    54.5 54.30803
# if anyLat = 12.44747 and anyLon = 54.30803, everything is FINE :)
# if anyLat = 12.45 and anyLon = 54.35, everything is BROKEN :C

################################################################################

# file location details:
fileLocat <- "O://CMEP\ Projects/Socotra"
fileName <- "BadXY-analysisRecords-Socotra_2016-03-30.csv"

# import source:
importSource <<- paste0(fileLocat, "/", fileName)

# is file a .csv or something else?
# get extension
extns <- paste0(".", unlist(strsplit(importSource, "[.]"))[2])
# check if it's not .csv & give informative error if it doesn't exist
if(!grepl(".csv", extns)) stop("... ERROR: file not in .csv format, please save as .csv and try again")

# check for bad records file
# informative error if it doesn't exist
if(!file.exists(importSource)) stop(paste0("... ERROR: ", importSource, " file does not exist"))

# import csv with edit info
reqEdits <<- read.csv(
        file=importSource, 
        header=TRUE, 
        as.is=TRUE, 
        na.strings="", 
        nrows = 160  
        # nrows=160 avoids the taxa to remove as they are outside land limits & don't have precise information
        # plus they've been removed by filtering out the recIDs above, so it's captured elsewhere.
)

# change column names "New.AnyLon" and "New.AnyLat" to something without dots
names(reqEdits)[names(reqEdits)=="newLat"] <- "newLat"
names(reqEdits)[names(reqEdits)=="NewLon"] <- "newLon"

# join recGrab and reqEdits
recGrabTemp <-
        sqldf(
                "SELECT 
                recGrab.*, 
                reqEdits.newLat, 
                reqEdits.newLon  
                FROM recGrab 
                LEFT JOIN reqEdits ON recGrab.recID=reqEdits.recID"
        )

# create new column tempLat/tempLon which uses anyLat/Lon if there is no newLat/Lon (from edit file)
recGrabTemp <- 
        recGrabTemp %>%
        mutate(tempLat=ifelse(!(is.na(newLat)), newLat, anyLat)) %>%
        mutate(tempLon=ifelse(!(is.na(newLon)), newLon, anyLon))

# replace recGrab anyLat/anyLon with tempLat/tempLon to include the fixes
recGrab$anyLat <- recGrabTemp$tempLat
recGrab$anyLon <- recGrabTemp$tempLon

recGrab <<- recGrab

# tidy up
rm(recGrabTemp, reqEdits)


# check it works: 
filter(recGrab, recID=="H-74850") %>% select(lat1Dec, anyLat, lon1Dec, anyLon)
# Bilaidi collection, collNo=123, Leucas urticifolia
# Source: local data frame [1 x 4]
#
#
# if anyLat = 12.64882 and anyLon = 53.9828, everything is FINE :)
# if anyLat = 12.65 and anyLon = 53.98333359, everything is BROKEN :C

filter(recGrab, recID=="F-607") %>% select(lat1Dec, anyLat, lon1Dec, anyLon)
# Miller field observation of a Euphorbia schimerpi
# Source: local data frame [1 x 4]
# 
#
# if anyLat = 12.66596 and anyLon = 54.05155, everything is FINE :)
# if anyLat = 12.66667 and anyLon = 54.05, everything is BROKEN :C