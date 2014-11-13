## Socotra Project :: script_herbSpxCount_geogSocotra.R
# ======================================================== 
# (23rd July 2014)
# Author: Flic Anderson
#
# dependant on: "O://CMEP\ Projects/Scriptbox/function_livePadmeArabiaCon.R"
# saved at: O://CMEP\-Projects/Scriptbox/script_herbSpxCount_geogSocotra.R
#
# AIM: count number of herbarium records from Socotra in Padme. Note: includes all duplicates, non-E specimens, current dets only, and synonyms are included.
#
# --------------------------------------------------------

# CODE # 

# 1) count herbarium records from Socotra
# 2) print number of herbarium records from Socotra

# database query
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
WHERE Geog.fullName LIKE '%Socotra%' AND Dets.Current=True;"

# run the query
herb <- sqlQuery(con_livePadmeArabia, qry)

# sleep (2 seconds) to allow query to run
Sys.sleep(2)

# print total
print(paste("Padme contains", nrow(herb), "Socotran herbarium records", sep=" "))

# VERY IMPORTANT!
# CLOSE THE CONNECTION!
odbcCloseAll()
# empty the environment of objects
rm(list=ls())