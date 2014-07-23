## Socotra Project :: script_herbSpxEonly_geog-Socotra.R
# ======================================================== 
# (23rd July 2014)
# Author: Flic Anderson
#
# dependant on: "O://CMEP\ Projects/Scriptbox/function_livePadmeArabiaCon.R"
# saved at: O://CMEP\-Projects/Scriptbox/script_herbSpxEonly_geog-Socotra.R
#
# AIM: count number of Edinburgh herbarium specimen records from Socotra in Padme. Note: includes current dets only, and synonyms are included.
#
# --------------------------------------------------------

# CODE # 

# 0) load all packages/set working directory/source files and functions
# 1) run query to find all herbarium specimens from Socotra which are Edinburgh (E) specimens
# 2) print number of specimens from E in Padme

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

## herbarium records from E or with blank herbarium field:
qry <- "SELECT
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
WHERE Geog.fullName LIKE '%Socotra%' AND Dets.Current=True AND Herbaria.id=7;"

## {if query below won't work, run this to show error message; 
## remove the following once it stops giving an error:
#sqlQuery(con_livePadmeArabia, qry)
## and leave official queryrun only:}

# run the query
herbEonly <- sqlQuery(con_livePadmeArabia, qry)

# sleep (2 seconds) to allow query to run
Sys.sleep(2)

# report number of specimens from Socotra which are Edinburgh specimens from Padme records 
print(paste("Padme contains records for", nrow(herbEonly), "specimens which are recorded as Edinburgh (E) specimens", sep=" "))


# VERY IMPORTANT!
# CLOSE THE CONNECTION!
odbcCloseAll()
# empty the environment of objects
rm(list=ls())
