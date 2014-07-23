## Socotra Project :: script_fieldObsCount_geogSocotra.R
# ======================================================== 
# (23rd July 2014)
# Author: Flic Anderson
#
# dependant on: "O://CMEP\ Projects/Scriptbox/function_livePadmeArabiaCon.R"
# saved at: O://CMEP\-Projects/Scriptbox/script_fieldObsCount_geogSocotra.R
#
# AIM: count number of field observations from Socotra in Padme.
#
# --------------------------------------------------------

# CODE # 

# 1) count field observation records from Socotra
# 2) print number of field observations from Socotra

# database query
qry <- "SELECT
Fiel.id,
Team.[name for display] AS collector,
Fiel.[Collector Number] AS collNumFull,
Fiel.[collection number] & '' & Fiel.postfix AS collNum,
Lnam.[Full Name] AS taxonFull,
Lnam.[sortName] AS taxon,
Fiel.[Associated with] AS herbariumSpx,
Geog.fullName AS fullLocation,
Geog.[Latitude 1 Decimal] AS geog_lat,
Geog.[Longitude 1 Decimal] AS geog_lon
FROM ((([Field notes] AS [Fiel] LEFT JOIN [Geography] AS [Geog] ON Fiel.Locality=Geog.ID)
LEFT JOIN [Synonyms tree] AS [Snym] ON Fiel.determination = Snym.member)
LEFT JOIN [Latin Names] AS [Lnam] ON Snym.[member of] = Lnam.id)
LEFT JOIN [Teams] AS [Team] ON Fiel.[Collector Key]=Team.id
WHERE Geog.fullName LIKE '%Socotra%';"

# run the query
field <- sqlQuery(con_livePadmeArabia, qry)

# sleep (2 seconds) to allow query to run
Sys.sleep(2)

# print total
print(paste("Padme contains", nrow(field), "Socotran field observations", sep=" "))

# VERY IMPORTANT!
# CLOSE THE CONNECTION!
odbcCloseAll()
# empty the environment of objects
rm(list=ls())