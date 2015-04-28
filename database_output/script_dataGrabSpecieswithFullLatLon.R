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
Herb <- sqlQuery(con_livePadmeArabia, query="SELECT TOP 1 * FROM [Herbarium specimens]")
Fiel <- sqlQuery(con_livePadmeArabia, query="SELECT TOP 1 * FROM [Field notes]")
Litr <- sqlQuery(con_livePadmeArabia, query="SELECT TOP 1 * FROM [literature records]")

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
Herb.[Longitude 1 Direction] AS lon1Dir,
Herb.[Longitude 1 Degrees] AS lon1Deg,
Herb.[Longitude 1 Minutes] AS lon1Min,
Herb.[Longitude 1 Seconds] AS lon1Sec,
Herb.[Longitude 1 Decimal] AS lon1Dec,
Herb.[Date 1 Days] AS dateDD, 
Herb.[Date 1 Months] AS dateMM, 
Herb.[Date 1 Years] AS dateYY,
Geog.fullName AS fullLocation
FROM (((((([Herbarium Specimens] AS [Herb] LEFT JOIN [Geography] AS [Geog] ON Herb.Locality=Geog.ID) 
  LEFT JOIN [Herbaria] ON Herb.Herbarium=Herbaria.id) 
    LEFT JOIN [determinations] AS [Dets] ON Herb.id=Dets.[specimen key]) 
      LEFT JOIN [Synonyms tree] AS [Snym] ON Dets.[latin name key] = Snym.member) 
        LEFT JOIN [Latin Names] AS [Lnam] ON Snym.[member of] = Lnam.id) 
          LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id) 
            LEFT JOIN [Teams] AS [DetTeam] ON Dets.[Det by] = DetTeam.id 
WHERE Dets.Current=True AND Geog.fullName LIKE '%", locatName, "%' 
AND Herb.[Latitude 1 Direction] IS NOT NULL 
AND Herb.[Latitude 1 Degrees] IS NOT NULL
AND Herb.[Latitude 1 Minutes] IS NOT NULL
AND Herb.[Latitude 1 Seconds] IS NOT NULL
AND Herb.[Longitude 1 Direction] IS NOT NULL 
AND Herb.[Longitude 1 Degrees] IS NOT NULL
AND Herb.[Longitude 1 Minutes] IS NOT NULL
AND Herb.[Longitude 1 Seconds] IS NOT NULL
ORDER BY Team.[name for display];")


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
Fiel.[Longitude 1 Direction] AS lon1Dir,
Fiel.[Longitude 1 Degrees] AS lon1Deg,
Fiel.[Longitude 1 Minutes] AS lon1Min,
Fiel.[Longitude 1 Seconds] AS lon1Sec,
Fiel.[Longitude 1 Decimal] AS lon1Dec,
Fiel.[Date 1 Days] AS dateDD, 
Fiel.[Date 1 Months] AS dateMM, 
Fiel.[Date 1 Years] AS dateYY,
Geog.fullName AS fullLocation
FROM ((([Field notes] AS [Fiel] LEFT JOIN [Geography] AS [Geog] ON Fiel.Locality=Geog.ID)
        LEFT JOIN [Synonyms tree] AS [Snym] ON Fiel.determination = Snym.member)
         LEFT JOIN [Latin Names] AS [Lnam] ON Snym.[member of] = Lnam.id)
          LEFT JOIN [Teams] AS [Team] ON Fiel.[Collector Key]=Team.id
WHERE Geog.fullName LIKE '%", locatName, "%'
AND Fiel.[Latitude 1 Direction] IS NOT NULL 
AND Fiel.[Latitude 1 Degrees] IS NOT NULL
AND Fiel.[Latitude 1 Minutes] IS NOT NULL
AND Fiel.[Latitude 1 Seconds] IS NOT NULL
AND Fiel.[Longitude 1 Direction] IS NOT NULL 
AND Fiel.[Longitude 1 Degrees] IS NOT NULL
AND Fiel.[Longitude 1 Minutes] IS NOT NULL
AND Fiel.[Longitude 1 Seconds] IS NOT NULL
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
Litr.[Longitude 1 Direction] AS lon1Dir,
Litr.[Longitude 1 Degrees] AS lon1Deg,
Litr.[Longitude 1 Minutes] AS lon1Min,
Litr.[Longitude 1 Seconds] AS lon1Sec,
Litr.[Longitude 1 Decimal] AS lon1Dec,
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
AND Litr.[Latitude 1 Direction] IS NOT NULL 
AND Litr.[Latitude 1 Degrees] IS NOT NULL
AND Litr.[Latitude 1 Minutes] IS NOT NULL
AND Litr.[Latitude 1 Seconds] IS NOT NULL
AND Litr.[Longitude 1 Direction] IS NOT NULL 
AND Litr.[Longitude 1 Degrees] IS NOT NULL
AND Litr.[Longitude 1 Minutes] IS NOT NULL
AND Litr.[Longitude 1 Seconds] IS NOT NULL
;")


# 3)

# run query
herbRex <- sqlQuery(con_livePadmeArabia, qry1)
fielRex <- sqlQuery(con_livePadmeArabia, qry2)
litrRex <- sqlQuery(con_livePadmeArabia, qry3)

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