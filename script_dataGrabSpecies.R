## Socotra Project :: script_dataGrabSpecies.R
# ======================================================== 
# (30th October 2014)
# Author: Flic Anderson
#
# dependant on: "O://CMEP\ Projects/Scriptbox/function_livePadmeArabiaCon.R"
# saved at: O://CMEP\ Projects/Scriptbox/script_dataGrabSpeciesSocotra.R
#
# AIM: Pull out records into R for species in Arabia (not only Socotra) from Padme Arabia using SQL given a taxonName, print to console.  Then save as .csv for future use, in order of status in [Herbarium Specimens].[Herbaria], then [Herbarium Specimens].[FlicFound] fields.
#
# --------------------------------------------------------

# CODE # 

# 0) Load libraries, functions, source scripts
# 1) Input species name
# 2) Build query and insert the IDs into the query code
# 3) Run the query
# 4) Show the output
# 5) Save the output to .csv


# 0) 

# load required packages, install if they aren't installed already
# {RODBC} - ODBC Database Access
if (!require(RODBC)){
  install.packages("RODBC")
  library(RODBC)
} 

# open connection to live padme
source("O://CMEP\ Projects/Scriptbox/function_livePadmeArabiaCon.R")
livePadmeArabiaCon()


# 1) 

### USER INPUT REQUIRED ###
# example: 
#taxonName <- "Cyperaceae"
#taxonName <- "Coelocarpum"
#taxonName <- "Dracaena cinnabari"
taxonName <- "Coelocarpum"
### USER INPUT REQUIRED ###

# 2)

# build query
# Adapted from script_dataGrabSpecies.R
qry <- paste0(
"SELECT Herb.id, 
Team.[name for display] AS collector,
Herb.[Collector Number] AS collNumFull, 
Herb.[Collection number] & '' & Herb.postfix AS collNum,
Herbaria.Acronym AS institute, 
Lnam.[Full Name] AS detAs,
DetTeam.[name for display] AS detBy,
Geog.fullName, 
Herb.FlicFound, 
Herb.FlicStatus, 
Herb.FlicIssue,
Herb.FlicNotes
FROM (((((([Herbarium Specimens] AS [Herb] LEFT JOIN [Geography] AS [Geog] ON Herb.Locality=Geog.ID) 
LEFT JOIN [Herbaria] ON Herb.Herbarium=Herbaria.id) 
LEFT JOIN [determinations] AS [Dets] ON Herb.id=Dets.[specimen key]) 
LEFT JOIN [Synonyms tree] AS [Snym] ON Dets.[latin name key] = Snym.member) 
LEFT JOIN [Latin Names] AS [Lnam] ON Snym.[member of] = Lnam.id) 
LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id) 
LEFT JOIN [Teams] AS [DetTeam] ON Dets.[Det by] = DetTeam.id 
WHERE Dets.Current=True AND Lnam.sortName LIKE '%", taxonName, "%'
ORDER BY Herbaria.Acronym, Herb.FlicStatus, Team.[name for display], Herb.[Collection number] & '' & Herb.postfix;")
# test the query - keep commented unless testing
#sqlQuery(con, qry)

# 3)

# run query
recGrab <- sqlQuery(con_livePadmeArabia, qry)

# show number of records returned
nrow(recGrab)

# 4)

# sort so found/unmounted float to the top when displaying in console
recGrab[order(recGrab$FlicStatus, decreasing=TRUE, na.last=TRUE),]

# 5)

# reminds user to select where to save file & what to call it (need to add ".csv" on end/create file)
message("... use opened window to choose where to save the CSV file")
message("... enter filename including '.csv', & if asked whether to create file, say 'YES' unless saving over existing file")

# write to .csv file
write.csv(recGrab[order(recGrab$institute, recGrab$FlicFound, na.last=TRUE),], file=file.choose())

# VERY IMPORTANT!
# CLOSE THE CONNECTION!
odbcCloseAll()
rm(list=ls())