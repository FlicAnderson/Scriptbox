## Socotra Project :: script_dataGrabSpecieswithFullLatLon.R
# ======================================================== 
# (28th April 2015)
# Author: Flic Anderson
#
# dependent on: "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R"
# saved at: O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabSpecieswithFullLatLon.R
# source: source("O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabSpecieswithFullLatLon.R")
#
# AIM: Pull out records into R for species in Arabia Socotra from 
# .... Padme Arabia using SQL given a taxonName, print to console.  
# .... Then save as CSV file (.csv) for future use. Records ordered by fields
# .... [Herbarium Specimens].[Herbaria], then [Herbarium Specimens].[FlicFound]

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
if (!require(sqldf)){
        install.packages("sqldf")
        library(sqldf)
} 
# open connection to live padme
source("O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R")
livePadmeArabiaCon()


# 1) 

###---------------------- USER INPUT REQUIRED HERE --------------------------###

# please input the location you're searching for, as shown in the examples below:
# examples: 
#locatName <- "Socotra"
#locatName <- "Socotran Archipelago"
#locatName <- "Hadibo"
locatName <- "Socotra"

###---------------------- USER INPUT REQUIRED HERE --------------------------###

# 2)

# get headings for herbarium specimens and field notes and literature records tables
#Herb <- sqlQuery(con_livePadmeArabia, query="SELECT TOP 1 * FROM [Herbarium specimens]")
#Fiel <- sqlQuery(con_livePadmeArabia, query="SELECT TOP 1 * FROM [Field notes]")
#Litr <- sqlQuery(con_livePadmeArabia, query="SELECT TOP 1 * FROM [literature records]")

# build HERB query
# Adapted from script_dataGrabSpecies.R
qry1 <- paste0("
SELECT Herb.id, 
Team.[name for display] AS collector,
Herb.[Collector Number] AS collNumFull, 
Lnam.[Full Name] AS detAs,
Herb.[Latitude 1 Direction] AS lat1Dir,
Herb.[Latitude 1 Degrees] AS lat1Deg,
Herb.[Latitude 1 Minutes] AS lat1Min,
Herb.[Latitude 1 Seconds] AS lat1Sec,
Herb.[Latitude 1 Decimal] AS lat1Dec,
IIf(IsNull(Herb.[Latitude 1 Decimal]),Geog.[Latitude 1 Decimal],Herb.[Latitude 1 Decimal]) AS AnyLat,
Herb.[Longitude 1 Direction] AS lon1Dir,
Herb.[Longitude 1 Degrees] AS lon1Deg,
Herb.[Longitude 1 Minutes] AS lon1Min,
Herb.[Longitude 1 Seconds] AS lon1Sec,
Herb.[Longitude 1 Decimal] AS lon1Dec,
IIf(IsNull(Herb.[Longitude 1 Decimal]),Geog.[Longitude 1 Decimal],Herb.[Longitude 1 Decimal]) AS AnyLon,
Herb.[coordinateSource] AS coordSource,
iif(isnull(Herb.[Latitude 1 Decimal]),'G','S') as coordSourcePlus,
Herb.[coordinateAccuracy] AS coordAccuracy,
Herb.[coordinateAccuracyUnits] AS coordAccuracyUnits,
Herb.[Date 1 Days] AS dateDD, 
Herb.[Date 1 Months] AS dateMM, 
Herb.[Date 1 Years] AS dateYY,
Geog.fullName AS fullLocation
FROM ((((((([Herbarium Specimens] AS [Herb] LEFT JOIN [Geography] AS [Geog] ON Herb.Locality=Geog.ID) 
  LEFT JOIN [Herbaria] ON Herb.Herbarium=Herbaria.id) 
    LEFT JOIN [determinations] AS [Dets] ON Herb.id=Dets.[specimen key]) 
      LEFT JOIN [Synonyms tree] AS [Snym] ON Dets.[latin name key] = Snym.member) 
        LEFT JOIN [Latin Names] AS [Lnam] ON Snym.[member of] = Lnam.id) 
          LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id) 
            LEFT JOIN [CoordinateSources] AS [Coor] ON Herb.[coordinateSource] = Coor.id)
              LEFT JOIN [Teams] AS [DetTeam] ON Dets.[Det by] = DetTeam.id 
WHERE Dets.Current=True AND Geog.fullName LIKE '%", locatName, "%' 
ORDER BY Team.[name for display];")

#AND Herb.[Latitude 1 Direction] IS NOT NULL 
#AND Herb.[Latitude 1 Degrees] IS NOT NULL
#AND Herb.[Latitude 1 Minutes] IS NOT NULL
#AND Herb.[Longitude 1 Direction] IS NOT NULL 
#AND Herb.[Longitude 1 Degrees] IS NOT NULL
#AND Herb.[Longitude 1 Minutes] IS NOT NULL


# build FIEL query
# Adapted from script_dataGrabSpecies.R & various fieldObs scripts
qry2 <- paste0("
SELECT Fiel.id,
Team.[name for display] AS collector,
Fiel.[Collector Number] AS collNumFull,
Lnam.[Full Name] AS detAs,
Fiel.[Latitude 1 Direction] AS lat1Dir,
Fiel.[Latitude 1 Degrees] AS lat1Deg,
Fiel.[Latitude 1 Minutes] AS lat1Min,
Fiel.[Latitude 1 Seconds] AS lat1Sec,
Fiel.[Latitude 1 Decimal] AS lat1Dec,
IIf(IsNull(Fiel.[Latitude 1 Decimal]),Geog.[Latitude 1 Decimal],Fiel.[Latitude 1 Decimal]) AS AnyLat,
Fiel.[Longitude 1 Direction] AS lon1Dir,
Fiel.[Longitude 1 Degrees] AS lon1Deg,
Fiel.[Longitude 1 Minutes] AS lon1Min,
Fiel.[Longitude 1 Seconds] AS lon1Sec,
Fiel.[Longitude 1 Decimal] AS lon1Dec,
IIf(IsNull(Fiel.[Longitude 1 Decimal]),Geog.[Longitude 1 Decimal],Fiel.[Longitude 1 Decimal]) AS AnyLon,
Fiel.[coordinateSource] AS coordSource,
iif(isnull(Fiel.[Latitude 1 Decimal]),'G','S') as coordSourcePlus,
Fiel.[coordinateAccuracy] AS coordAccuracy,
Fiel.[coordinateAccuracyUnits] AS coordAccuracyUnits,
Fiel.[Date 1 Days] AS dateDD, 
Fiel.[Date 1 Months] AS dateMM, 
Fiel.[Date 1 Years] AS dateYY,
Geog.fullName AS fullLocation
FROM ((([Field notes] AS [Fiel] LEFT JOIN [Geography] AS [Geog] ON Fiel.Locality=Geog.ID)
        LEFT JOIN [Synonyms tree] AS [Snym] ON Fiel.determination = Snym.member)
         LEFT JOIN [Latin Names] AS [Lnam] ON Snym.[member of] = Lnam.id)
          LEFT JOIN [Teams] AS [Team] ON Fiel.[Collector Key]=Team.id
WHERE Geog.fullName LIKE '%", locatName, "%'
ORDER BY Team.[name for display];")


# build LITR query
# adapted from script_litRexCount_geogSocotra.R
qry3 <- paste0("
SELECT Litr.id, 
Auth.[name for display] AS collector,
Litr.id AS collNumFull,
Lnam.[Full Name] AS detAs, 
Litr.[Latitude 1 Direction] AS lat1Dir,
Litr.[Latitude 1 Degrees] AS lat1Deg,
Litr.[Latitude 1 Minutes] AS lat1Min,
Litr.[Latitude 1 Seconds] AS lat1Sec,
Litr.[Latitude 1 Decimal] AS lat1Dec,
IIf(IsNull(Litr.[Latitude 1 Decimal]),Geog.[Latitude 1 Decimal],Litr.[Latitude 1 Decimal]) AS AnyLat,
Litr.[Longitude 1 Direction] AS lon1Dir,
Litr.[Longitude 1 Degrees] AS lon1Deg,
Litr.[Longitude 1 Minutes] AS lon1Min,
Litr.[Longitude 1 Seconds] AS lon1Sec,
Litr.[Longitude 1 Decimal] AS lon1Dec,
IIf(IsNull(Litr.[Longitude 1 Decimal]),Geog.[Longitude 1 Decimal],Litr.[Longitude 1 Decimal]) AS AnyLon,
Litr.[coordinateSource] AS coordSource,
iif(isnull(Litr.[Latitude 1 Decimal]),'G','S') as coordSourcePlus,
Litr.[coordinateAccuracy] AS coordAccuracy,
Litr.[coordinateAccuracyUnits] AS coordAccuracyUnits,
Litr.[Date 1 Days] AS dateDD, 
Litr.[Date 1 Months] AS dateMM, 
Litr.[Date 1 Years] AS dateYY,
Geog.fullName AS fullLocation
FROM (Teams AS [Auth] 
RIGHT JOIN ([References] AS [Refr] 
RIGHT JOIN ([Latin Names] AS [Lnam] 
RIGHT JOIN [literature records] AS [Litr] 
ON Lnam.id = Litr.determination) 
ON Refr.id = Litr.Reference) 
ON Auth.id = Refr.Authors) 
LEFT JOIN (Geography AS [Geog] 
RIGHT JOIN LiteratureRecordLocations AS [LRLo] 
ON Geog.ID = LRLo.locality) 
ON Litr.id = LRLo.litrecid 
WHERE Geog.fullName LIKE '%", locatName, "%'
;")


# 3)

# run query
herbRex <- sqlQuery(con_livePadmeArabia, qry1) #03/06/2015 1843 req DMS, 3647 req DM, 8166 w/ IFF
fielRex <- sqlQuery(con_livePadmeArabia, qry2) #03/06/2015 4602 req DMS, 6754 req DM, 12253 w/ IFF
litrRex <- sqlQuery(con_livePadmeArabia, qry3) #03/06/2015 0 req DMS, 31 req DM, 1866 w/ IFF

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
nrow(recGrab) #03/06/2015 6445 req DMS, 10432 req DM, 22285 w/ IFF
recGrab <- recGrab[order(recGrab$dateYY, recGrab$dateMM, recGrab$dateDD, recGrab$collector, na.last=TRUE),]

# 4)

# # show first 6 records returned 
#   # sorted so Edinburgh specimens, then found specimens float to the top 
# head(recGrab[order(order(recGrab$institute, recGrab$FlicFound, decreasing=TRUE, na.last=TRUE)),])
head(recGrab[order(recGrab$dateYY, recGrab$dateMM, recGrab$dateDD, recGrab$collector, na.last=TRUE),])

# 5)

### USER REMINDER: 
# write.csv() function will ask where to save file and what to call it
# enter filename including '.csv', & if asked whether to create file, say 'YES' 
  # write to .csv file
  # sorted so Edinburgh specimens, then found specimens, displayed ascendingly
write.csv(recGrab[order(recGrab$dateYY, recGrab$dateMM, recGrab$dateDD, recGrab$collector, na.last=TRUE),], file=file.choose(), row.names=FALSE)



# VERY IMPORTANT!
# CLOSE DATABASE CONNECTIONs & REMOVE OBJECTS FROM WORKSPACE!
odbcCloseAll()
rm(list=ls())
