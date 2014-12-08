## Socotra Project :: script_dataGrabSpecimen.R
# ======================================================== 
# (3rd Decemberr 2014)
# Author: Flic Anderson
#
# dependent on: "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R"
# saved at: O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabSpecimen.R
#
# AIM: Pull out records into R for species in Arabia (not only Socotra) from 
# .... Padme Arabia using SQL given a taxonName, print to console.  
# .... Then save as CSV file (.csv) for future use. Records ordered by fields
# .... [Herbarium Specimens].[Herbaria], then [Herbarium Specimens].[FlicFound]

# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) Load libraries, functions, source scripts
# 1) Input collector name & specimen number
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
# please input the collector and specimen number you're searching for, as shown 
# in the examples below:
# examples: 
botanist <- "Thulin"
specimenToFind <- 8698
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
Herb.[Minor Locality Details],
Herb.[Latitude 1 Degrees] & 'DD ' & Herb.[Latitude 1 Minutes] & 'MM ' & Herb.[Latitude 1 Seconds] & 'SS' AS Latitude1,
Herb.[Longitude 1 Degrees] & 'DD ' & Herb.[Longitude 1 Minutes] & 'MM ' & Herb.[Longitude 1 Seconds] & 'SS' AS Longitude1,
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
WHERE Dets.Current=True AND Team.[name for display] LIKE '%", botanist, "%' AND Herb.[Collection number]='", specimenToFind, "'
 ORDER BY Herbaria.Acronym, Herb.FlicStatus, Team.[name for display], Herb.[Collection number] & '' & Herb.postfix;")

# 3)

# run query
recGrab <- sqlQuery(con_livePadmeArabia, qry)
  # show number of records returned
  nrow(recGrab)
names(recGrab)

# 4)

# show first 6 records returned 
  # sorted so Edinburgh specimens, then found specimens float to the top 
head(recGrab[order(order(recGrab$institute, recGrab$FlicFound, decreasing=TRUE, na.last=TRUE),])

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
