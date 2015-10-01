## Socotra Project :: script_dataGrabSpecies.R
# ======================================================== 
# (30th October 2014)
# Author: Flic Anderson
#
# dependent on: "O://CMEP\ Projects/Scriptbox/function_livePadmeArabiaCon.R"
# saved at: O://CMEP\ Projects/Scriptbox/script_dataGrabSpecies.R
# source: source("O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabSpecies.R")
#
# AIM: Pull out records into R for species in Arabia (not only Socotra) from 
# .... Padme Arabia using SQL given a taxonName, print to console.  
# .... Then save as CSV file (.csv) for future use. Records ordered by fields
# .... [Herbarium Specimens].[Herbaria], then [Herbarium Specimens].[FlicFound]

# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) Load libraries, functions, source scripts
# 1) Input species name
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
taxonName <- "Opuntia"

# please input the location you're searching for, as shown in the examples below:
# examples: 
#taxonName <- "Socotra"
#taxonName <- "Socotran Archipelago"
#taxonName <- "Hadibo"
locatName <- "Arabian Peninsula"

###---------------------- USER INPUT REQUIRED HERE --------------------------###

# 2)

# build query
# Adapted from script_dataGrabSpecies.R
qry <- paste0(
"SELECT Herb.id, 
Team.[name for display] AS collector,
Herb.[Collector Number] AS collNumFull, 
Herb.[Collection number] & '' & Herb.postfix AS collNum,
Herbaria.Acronym AS institute, 
Lnam.[id] AS lnamID,
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
WHERE Dets.Current=True AND Lnam.sortName LIKE '%", taxonName, "%' AND Geog.fullName LIKE '%", locatName, "%' 
ORDER BY Herbaria.Acronym, Herb.FlicStatus, Team.[name for display], Herb.[Collection number] & '' & Herb.postfix;")

# pull families data
familyQry <- "SELECT 
  [Latin Names].sortName AS familyName, 
  [names tree].member
  FROM (
    Ranks INNER JOIN [Latin Names] ON Ranks.id = [Latin Names].Rank) 
    INNER JOIN [names tree] ON [Latin Names].id = [names tree].[member of]
WHERE (((Ranks.name)='family'));"
families <- sqlQuery(con_livePadmeArabia, familyQry)

# 3)

# run query
recGrab <- sqlQuery(con_livePadmeArabia, qry)
  # show number of records returned
  nrow(recGrab)

# join family names to data
recGrab <- sqldf("SELECT * FROM recGrab LEFT JOIN families ON recGrab.lnamID=families.member")
names(recGrab)
# remove member column
recGrab <- recGrab[, 1:(ncol(recGrab)-1)]

# 4)

# show first 6 records returned 
  # sorted so Edinburgh specimens, then found specimens float to the top 
head(recGrab[order(order(recGrab$institute, recGrab$FlicFound, decreasing=TRUE, na.last=TRUE)),])

# 5)

### USER REMINDER: 
# write.csv() function will ask where to save file and what to call it
# enter filename including '.csv', & if asked whether to create file, say 'YES' 
  # write to .csv file
  # sorted so Edinburgh specimens, then found specimens, displayed ascendingly
write.csv(recGrab[order(recGrab$institute, recGrab$FlicFound, na.last=TRUE),], file=file.choose())

# VERY IMPORTANT!
# CLOSE DATABASE CONNECTIONs & REMOVE OBJECTS FROM WORKSPACE!
odbcCloseAll()
rm(list=ls())