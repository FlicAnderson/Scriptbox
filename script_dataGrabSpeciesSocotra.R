## Socotra Project :: script_dataGrabSpeciesSocotra.R
# ======================================================== 
# (11th July 2014)
# Author: Flic Anderson
#
# dependant on: "O://CMEP\ Projects/Scriptbox/function_livePadmeArabiaCon.R"
# saved at: O://CMEP\-Projects/Scriptbox/script_dataGrabSpeciesSocotra.R
#
# AIM: Pull out records into R for species in Socotra from Padme Arabia using SQL given a [Latin Name].[id], print to console.  Then save as .csv for future use, in order of status in [Herbarium Specimens].[FlicStatus] field.
#
# --------------------------------------------------------

# CODE # 

# 0) Load libraries, functions, source scripts
# 1) Input species name
# 2) Get Latin Names ID for species name
# 3) Need to 'get higher' taxon ID? 
# 4) Insert the IDs into the query code
# 5) Run the query
# 6) Show the output
# 7) Save the output to .csv


### WARNING: THIS IS STILL PROGRAMMED FOR Dichrostachys dehiscens !!! ###
### NOT STARTED/FINISHED GENERALISING YET ### 

# Coelocarpum
# [Latin Names].id = 2384
#  **OR** 
# [Latin Names].[next higher name] = 2384


# load required packages, install if they aren't installed already
# {RODBC} - ODBC Database Access
if (!require(RODBC)){
  install.packages("RODBC")
  library(RODBC)
} 

# open connection to live padme
source("O://CMEP\ Projects/Scriptbox/function_livePadmeArabiaCon.R")
livePadmeArabiaCon()

# DOES INCLUDE SYNONYMS!
# Adapted from databasin9.R
# THIS WORKS 11th July 2014 11am
qry <- "SELECT Herb.id, 
Team.[name for display] AS collector,
Herb.[Collector Number] AS collNumFull, 
Herb.[Collection number] & '' & Herb.postfix AS collNum,
Herbaria.Acronym, 
Lnam.[Full Name] AS detAs,
DetTeam.[name for display] AS detBy,
Geog.fullName, 
Herb.FlicFound, 
Herb.FlicStatus, 
Herb.FlicNotes
FROM (((((([Herbarium Specimens] AS [Herb] LEFT JOIN [Geography] AS [Geog] ON Herb.Locality=Geog.ID) 
LEFT JOIN [Herbaria] ON Herb.Herbarium=Herbaria.id) 
LEFT JOIN [determinations] AS [Dets] ON Herb.id=Dets.[specimen key]) 
LEFT JOIN [Synonyms tree] AS [Snym] ON Dets.[latin name key] = Snym.member) 
LEFT JOIN [Latin Names] AS [Lnam] ON Snym.[member of] = Lnam.id) 
LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id) 
LEFT JOIN [Teams] AS [DetTeam] ON Dets.[Det by] = DetTeam.id 
WHERE Geog.fullName LIKE '%Socotra%' AND Dets.Current=True AND AND (Lnam.id = 2384 OR Lnam.[next higher name] = 2384)
ORDER BY Herb.FlicStatus, Team.[name for display], Herb.[Collection number] & '' & Herb.postfix;"
#remove the following once it stops giving an error:
#sqlQuery(con, qry)
# and leave this only:
recGrab <- sqlQuery(con_livePadmeArabia, qry)

# number of records returned
nrow(recGrab)
# sort so found/unmounted float to the top when displaying in console
recGrab[order(recGrab$FlicStatus, decreasing=TRUE, na.last=TRUE),]

# write to .csv file
# select where to save it & what to call it (need to add ".R" on end/create file)
write.csv(recGrab[order(recGrab$FlicStatus, decreasing=TRUE, na.last=TRUE),], file=file.choose())

# VERY IMPORTANT!
# CLOSE THE CONNECTION!
odbcCloseAll()
rm(list=ls())

