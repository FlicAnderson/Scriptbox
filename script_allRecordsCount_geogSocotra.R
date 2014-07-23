## Socotra Project :: script_allRecordsCount_geogSocotra.R
# ======================================================== 
# (23rd July 2014)
# Author: Flic Anderson
#
# dependant on: "O://CMEP\ Projects/Scriptbox/function_livePadmeArabiaCon.R"
# saved at: O://CMEP\-Projects/Scriptbox/script_allRecordsCount_geogSocotra.R
#
# AIM: count number of all records from Socotra in Padme. Note: includes herbarium records (all duplicates, non-E specimens, current dets only, and synonyms are included), field observations, and literature records.
#
# --------------------------------------------------------

# CODE # 

# 0) set working directory, load packages, source files etc
# 1) count herbarium and field observation records from Socotra
# 2) count literature records
# 3) combine count for herbarium, field and literature records
# 4) print number of all records from Socotra


# load required packages, install if they aren't installed already

# {RODBC} - ODBC Database Access
if (!require(RODBC)){
  install.packages("RODBC")
  library(RODBC)
} 

#{sqldf} - Perform SQL Selects on R Data Frames
if (!require(sqldf)){
  install.packages("sqldf")
  library(sqldf)
} 

# set working directory
setwd("O://CMEP\ Projects/Scriptbox")

# source padme connection function
source("function_livePadmeArabiaCon.R")
# call padme connection function to open connection to live Padme Arabia
livePadmeArabiaCon()

## {optional: 
## check the connection is working}
#odbcGetInfo(con_livePadmeArabia)

## field records UNION herbarium records => "herbNFieldRex"
# synonyms INCLUDED:
# THIS WORKS 17/04/2014 10:20am
#qry
qry <- "SELECT
Fiel.id,
Team.[name for display] AS collector,
Fiel.[Collector Number] AS collNumFull,
Fiel.[collection number] & '' & Fiel.postfix AS collNum,
Lnam.[Full Name] AS taxonFull,
Lnam.[sortName] AS taxon,
Geog.fullName AS fullLocation,
Geog.[Latitude 1 Decimal] AS geog_lat,
Geog.[Longitude 1 Decimal] AS geog_lon
FROM ((([Field notes] AS [Fiel] LEFT JOIN [Geography] AS [Geog] ON Fiel.Locality=Geog.ID)
LEFT JOIN [Synonyms tree] AS [Snym] ON Fiel.determination = Snym.member)
LEFT JOIN [Latin Names] AS [Lnam] ON Snym.[member of] = Lnam.id)
LEFT JOIN [Teams] AS [Team] ON Fiel.[Collector Key]=Team.id
WHERE Geog.fullName LIKE '%Socotra%'
UNION
SELECT
Herb.id,
Team.[name for display] AS collector,
Herb.[Collector Number] AS collNumFull,
Herb.[Collection number] & '' & Herb.postfix AS collNum,
Lnam.[Full Name] AS taxonFull,
Lnam.[sortName] AS taxon,
Geog.fullName AS fullLocation,
Geog.[Latitude 1 Decimal] AS geog_lat,
Geog.[Longitude 1 Decimal] AS geog_lon
FROM (((((([Herbarium specimens] AS [Herb] LEFT JOIN [Geography] AS [Geog] ON Herb.Locality=Geog.ID)
LEFT JOIN [Herbaria] ON Herb.Herbarium=Herbaria.id)
LEFT JOIN [determinations] AS [Dets] ON Herb.id=Dets.[specimen key])
LEFT JOIN [Synonyms tree] AS [Snym] ON Dets.[latin name key] = Snym.member)
LEFT JOIN [Latin Names] AS [Lnam] ON Snym.[member of] = Lnam.id)
LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id)
LEFT JOIN [Teams] AS [DetTeam] ON Dets.[Det by] = DetTeam.id
WHERE Geog.fullName LIKE '%Socotra%' AND Dets.Current=True
ORDER BY 2
;"

## {if query below won't work, run this to show error message; 
## remove the following once it stops giving an error:
#sqlQuery(con_livePadmeArabia, qry)
## and leave official queryrun only:}

# run the query
herbNFieldRex<- sqlQuery(con_livePadmeArabia, qry)

# sleep (2 seconds) to allow query to run
Sys.sleep(2)


## literature records => "litRex"
# qry1
qry1 <- "SELECT 
Litr.id, 
Lnam.[Full Name] AS taxonFull, 
Lnam.[sortName] AS taxon,
Auth.[name for display] AS collector,
Geog.fullName AS fullLocation, 
Geog.[Latitude 1 Decimal] AS geog_lat,  
Geog.[Longitude 1 Decimal] AS geog_lon 
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
WHERE Geog.fullName LIKE '%Socotra%'
;"

## {if query below won't work, run this to show error message; 
## remove the following once it stops giving an error:
#sqlQuery(con_livePadmeArabia, qry1)
## and leave official queryrun only:}

# run the query
litRex <- sqlQuery(con_livePadmeArabia, qry1)

# sleep (2 seconds) to allow query to run
Sys.sleep(2)

# ?? not sure why I did this vvvv
litRex$collNumFull <- "NA"
litRex$collNum <- "NA" 
# ?? ^^^^^^^^^^^^^^^^^^^^^^^^^^^^

# check column names will match when binding the record sets together
names(herbNFieldRex)
names(litRex)

## ALL RECORDS <= herbNFieldRex + litRex <= Literature + Herbarium + Field Obs
# join all record sources
allRex <- rbind(herbNFieldRex, litRex)


# print total
print(paste("Padme contains", nrow(allRex), "Socotran records from all sources (herbarium specimens, field observations and literature records)", sep=" "))


# VERY IMPORTANT!
# CLOSE THE CONNECTION!
odbcCloseAll()
# empty the environment of objects
rm(list=ls())
