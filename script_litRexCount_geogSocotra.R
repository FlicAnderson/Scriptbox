## Socotra Project :: script_litRexCount_geogSocotra.R
# ======================================================== 
# (23rd July 2014)
# Author: Flic Anderson
#
# dependant on: "O://CMEP\ Projects/Scriptbox/function_livePadmeArabiaCon.R"
# saved at: O://CMEP\-Projects/Scriptbox/script_litRexCount_geogSocotra.R
#
# AIM: count number of literiture records from Socotra in Padme.
#
# --------------------------------------------------------

# CODE # 

# 1) count literature records from Socotra
# 2) print number of literature records from Socotra

# database query
qry1 <- "SELECT 
Litr.id, 
Lnam.[Full Name] AS taxonFull, 
Lnam.[sortName] AS taxon,
Auth.[name for display] AS collector,
Geog.fullName AS fullLocation, 
Geog.[Latitude 1 Decimal] AS geog_lat,  
Geog.[Longitude 1 Decimal] AS geog_lon 
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
WHERE Geog.fullName LIKE '%Socotra%'
;"

# run the query
litRex <- sqlQuery(con_livePadmeArabia, qry)

# sleep (2 seconds) to allow query to run
Sys.sleep(2)

# print total
print(paste("Padme contains", nrow(litRex), "Socotran literature records", sep=" "))

# VERY IMPORTANT!
# CLOSE THE CONNECTION!
odbcCloseAll()
# empty the environment of objects
rm(list=ls())