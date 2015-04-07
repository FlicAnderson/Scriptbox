## Socotra Project :: script_dataGrabExpedition.R
# ======================================================== 
# (7th April 2015)
# Author: Flic Anderson
#
# dependent on: "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R"
# saved at: O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabExpedition.R
# source("O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabExpedition.R")
#
# AIM: Pull out records into R for a particular expedition in Arabia (not only
# ....  Socotra) from Padme Arabia using SQL given a expedName, print to console.  
# .... Then save as CSV file (.csv) for future use. Records ordered by fields
# .... [Herbarium Specimens].[Herbaria], then [Herbarium Specimens].[FlicFound]

# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) Load libraries, functions, source scripts
# 1) Input expedition name
# 2) Build query and insert the IDs into the query code
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
# open connection to live padme
source("O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R")
livePadmeArabiaCon()


# 1) 

###---------------------- USER INPUT REQUIRED HERE --------------------------###
# please input the taxon you're searching for, as shown in the examples below:
# examples: 
#taxonName <- "Cyperaceae" (NB: this will not find things WITHIN Cyperaceae, only det AS Cyperaceae)
#taxonName <- "Coelocarpum"
#taxonName <- "Dracaena cinnabari"
#taxonName <- "Ochradenus"

# please input the location you're searching for, as shown in the examples below:
# examples: 
#taxonName <- "Socotra"
#taxonName <- "Socotran Archipelago"
#taxonName <- "Hadibo"
#locatName <- "Socotra"

# please input the location you're searching for, as shown in the examples below:
# examples: 
#taxonName <- "Socotra"
#taxonName <- "Socotran Archipelago"
#taxonName <- "Hadibo"


###---------------------- USER INPUT REQUIRED HERE --------------------------###

# 2)

# build query
# Adapted from script_dataGrabSpecies.R & various fieldObs scripts
qry2 <- "SELECT Fiel.id,
Team.[name for display] AS collector,
Fiel.[Collector Number] AS collNumFull,
Fiel.[collection number] & '' & Fiel.postfix AS collNum,
Fiel.Expedition,
Lnam.[Full Name] AS detAs,
Geog.fullName AS fullLocation
FROM ((([Field notes] AS [Fiel] LEFT JOIN [Geography] AS [Geog] ON Fiel.Locality=Geog.ID)
LEFT JOIN [Synonyms tree] AS [Snym] ON Fiel.determination = Snym.member)
LEFT JOIN [Latin Names] AS [Lnam] ON Snym.[member of] = Lnam.id)
LEFT JOIN [Teams] AS [Team] ON Fiel.[Collector Key]=Team.id
WHERE Fiel.Expedition=61"


#qry2 <- "SELECT *
#FROM ((([Field notes] AS [Fiel] LEFT JOIN [Geography] AS [Geog] ON Fiel.Locality=Geog.ID)
#LEFT JOIN [Synonyms tree] AS [Snym] ON Fiel.determination = Snym.member)
#LEFT JOIN [Latin Names] AS [Lnam] ON Snym.[member of] = Lnam.id)
#LEFT JOIN [Teams] AS [Team] ON Fiel.[Collector Key]=Team.id
#WHERE Fiel.Expedition=61"

#UNION

qry1 <- "SELECT Herb.id, 
Team.[name for display] AS collector,
Herb.[Collector Number] AS collNumFull, 
Herb.[Collection number] & '' & Herb.postfix AS collNum,
Herb.Expedition,
Lnam.[Full Name] AS detAs,
Geog.fullName AS fullLocation
FROM (((([Herbarium Specimens] AS [Herb] LEFT JOIN [Geography] AS [Geog] ON Herb.Locality=Geog.ID) 
LEFT JOIN [determinations] AS [Dets] ON Herb.id=Dets.[specimen key]) 
LEFT JOIN [Synonyms tree] AS [Snym] ON Dets.[latin name key] = Snym.member) 
LEFT JOIN [Latin Names] AS [Lnam] ON Snym.[member of] = Lnam.id) 
LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id 
WHERE Dets.Current=True AND Herb.Expedition=61
;"

# 3)

# run query
recGrab1 <- sqlQuery(con_livePadmeArabia, qry1)
recGrab2 <- sqlQuery(con_livePadmeArabia, qry2)
# show number of records returned
nrow(recGrab1)
nrow(recGrab2)

# join field and herbarium data vertically
recGrab <- rbind(recGrab1, recGrab2)

# 4)

# show first 6 records returned 
# sorted so Edinburgh specimens, then found specimens float to the top 
head(recGrab[order(recGrab$collNum, na.last=TRUE),])

# 5)

### USER REMINDER: 
# write.csv() function will ask where to save file and what to call it
# enter filename including '.csv', & if asked whether to create file, say 'YES' 
# write to .csv file
# sorted so Edinburgh specimens, then found specimens, displayed ascendingly
write.csv(recGrab[order(recGrab$collNum, na.last=TRUE),], file=file.choose())

# VERY IMPORTANT!
# CLOSE DATABASE CONNECTIONs & REMOVE OBJECTS FROM WORKSPACE!
odbcCloseAll()
rm(list=ls())