## Socotra Project :: script_dataGrabSpeciesSocotra.R
# ======================================================== 
# (11th July 2014)
# Author: Flic Anderson
#
# dependant on: "O://CMEP\ Projects/Scriptbox/function_livePadmeArabiaCon.R"
# saved at: O://CMEP\-Projects/Scriptbox/script_dataGrabSpeciesSocotra.R
#
# AIM: Pull out records into R for species in Socotra from Padme Arabia using SQL given various inputa, print to console.  Then save as .csv for future use, in order of status in [Herbarium Specimens].[FlicStatus] field.
#
# --------------------------------------------------------

# CODE # 

# 0) Load libraries, functions, source scripts
# 1) Input species name
# 2) Input location name
# 3) Input any other requirements
# 4) Insert requirements into the query code
# 5) Run the query
# 6) Show the output
# 7) Save the output to .csv


###---------------------- USER INPUT REQUIRED HERE --------------------------###

# please input the taxon you're searching for, as shown in the examples below:
# examples: 

#taxonName <- "Senna%"  # finds all records with 'Senna' as genus & authority  
#taxonName <- "Compositae Giseke"
#taxonName <- "Dirachma socotrana"
#taxonName <- "Helichrysum%"
taxonName <- "Boswellia%"

# please input the location you're searching for, as shown in the examples below:
# examples: 
#locatName <- "Socotra"
locatName <- "Socotra Archipelago"
#locatName <- "Hadibo"

# please input the herbarium you're searching for, as shown in the examples below:
# examples: 
herbariumCode <- "E"
#herbariumCode <- "K"
#herbariumCode <- "BM"

###---------------------- USER INPUT REQUIRED HERE --------------------------###


# load required packages, install if they aren't installed already
# {RODBC} - ODBC Database Access
if (!require(RODBC)){
  install.packages("RODBC")
  library(RODBC)
}

# {RODBC} - ODBC Database Access
if (!require(dplyr)){
        install.packages("dplyr")
        library(dplyr)
}

# open connection to live padme
source("O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R")
livePadmeArabiaCon()

# put together qry
qry <- paste0("
SELECT 'H-' & Herb.id AS recID, 
Team.[name for display] AS collector,
Herb.[Collector Number] AS collNumFull, 
Lnam.[Full Name] AS detAs, ",
# HERE the Lnam.FullName is replaced by the ACCEPTED NAME
# THIS IS NOT WHAT IT WAS ORIG DET AS BUT THE ACCEPTED UPDATED NAME
"LnSy.[Full Name] AS acceptDetAs,
Herb.[Latitude 1 Direction] AS lat1Dir,
Herb.[Latitude 1 Degrees] AS lat1Deg,
Herb.[Latitude 1 Minutes] AS lat1Min,
Herb.[Latitude 1 Seconds] AS lat1Sec,
Herb.[Latitude 1 Decimal] AS lat1Dec, ",
#IIF no decimal latitude, then use geography/gazetteer latitude, but if it's there, use that as AnyLat
"IIf(IsNull(Herb.[Latitude 1 Decimal]),Geog.[Latitude 1 Decimal],Herb.[Latitude 1 Decimal]) AS AnyLat,
Herb.[Longitude 1 Direction] AS lon1Dir,
Herb.[Longitude 1 Degrees] AS lon1Deg,
Herb.[Longitude 1 Minutes] AS lon1Min,
Herb.[Longitude 1 Seconds] AS lon1Sec,
Herb.[Longitude 1 Decimal] AS lon1Dec, ",
#IIF no decimal longitude, then use geography/gazetteer longitude, but if it's there, use that as AnyLon
"IIf(IsNull(Herb.[Longitude 1 Decimal]),Geog.[Longitude 1 Decimal],Herb.[Longitude 1 Decimal]) AS AnyLon,
Herb.[coordinateSource] AS coordSource,
Herb.[coordinateAccuracy] AS coordAccuracy,
Herb.[coordinateAccuracyUnits] AS coordAccuracyUnits,
iif(isnull(Herb.[Latitude 1 Decimal]),'G','S') as coordSourcePlus,
Herb.[Date 1 Days] AS dateDD, 
Herb.[Date 1 Months] AS dateMM, 
Herb.[Date 1 Years] AS dateYY,
Herb.[FlicFound], 
Herb.[FlicStatus],
Herb.[FlicNotes],
Herb.[FlicIssue],
Geog.fullName AS fullLocation ",
# Joining tables: Herb, Geog, Herbaria, Determinations, Synonyms tree, Latin Names, Teams x2, CoordinateSources
"FROM ((((((((Determinations AS Dets 
RIGHT JOIN [Herbarium specimens] AS Herb ON Dets.[specimen key] = Herb.id) 
LEFT JOIN [Latin Names] AS Lnam ON Dets.[latin name key] = Lnam.id) 
LEFT JOIN [Synonyms tree] AS Synm ON Lnam.id = Synm.member) 
LEFT JOIN [Latin Names] AS LnSy ON Synm.[member of] = LnSy.id) 
LEFT JOIN Geography AS Geog ON Herb.Locality = Geog.ID) 
LEFT JOIN Teams AS Team ON Herb.[Collector Key] = Team.id) 
LEFT JOIN Herbaria AS Hrbr ON Herb.Herbarium = Hrbr.id) 
LEFT JOIN CoordinateSources AS Coor ON Herb.coordinateSource = Coor.id) 
LEFT JOIN Teams AS DtTm ON Dets.[Det by] = DtTm.id ",
# WHERE: 
"WHERE ",
# only pull out records with current dets, 
# and location LIKE '%locatName%, 
# and determination LIKE 'taxonName%'
# and the accepted name is not a synonym
# and the herbarium code is 'herbariumCode'
"Dets.Current=True AND Geog.fullName LIKE '%", locatName, "%' AND LnSy.[Full Name] LIKE '", taxonName,"%' AND ((LnSy.[Synonym of]) Is Null) AND Hrbr.Acronym='", herbariumCode, "' ",
# ORDER BY ...
"ORDER BY Team.[name for display];")
#remove the following once it stops giving an error:
#sqlQuery(con_livePadmeArabia, qry)
# and leave this only:
recGrab <- sqlQuery(con_livePadmeArabia, qry)

# number of records returned
nrow(recGrab)

# sort so found/unmounted float to the top when displaying in console
recGrab[order(recGrab$FlicStatus, decreasing=TRUE, na.last=TRUE),]

# write to .csv file
# select where to save it & what to call it (need to add ".R" on end/create file)
write.csv(recGrab[order(recGrab$acceptDetAs, na.last=TRUE),], file=file.choose())

# VERY IMPORTANT!
# CLOSE THE CONNECTION!
odbcCloseAll()
rm(list=ls())

