## Socotra Project :: script_litrQry_Socotra.R
# ==============================================================================
# 22nd March 2016
# Author: Flic Anderson
#
# dependent on: "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R"
# dependent on: "O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R"
# saved at: O://CMEP\ Projects/Scriptbox/database_output/script_litrQry_Socotra.R
# source("O://CMEP\ Projects/Scriptbox/database_output/script_litrQry_Socotra.R")
#
# AIM: Pull out literature records into R for species in Socotra from 
# .... Padme Arabia using SQL via the RODBC connection set up in another script. 
# .... Includes lat/lon from Padme gazetteer where no lat /lon are present &
# .... ignore records which only list locat as "Socotra" or "Socotra Archipelago"
# .... as these would proliferate 1 location (the mid-point for Socotra or the 
# .... islands; unhelpful). 

# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) 
# 1) Build query 

# ---------------------------------------------------------------------------- #

# 0) 

# 1) 

# build LITR query
# adapted from script_dataGrabSpecieswithFullLatLon.R; moved from script_dataGrabFullLatLonOrGazLatLon_Socotra
litrQry <- paste0("
               SELECT 'L-' & Litr.id AS recID, 
               Auth.[name for display] AS collector,
               Litr.id AS collNumFull, 
               LnSy.[id] AS lnamID, ",
               # HERE the Lnam.FullName is replaced by the ACCEPTED NAME (LnSy.[Full Name])
               # THIS IS NOT WHAT IT WAS ORIG DET AS BUT THE ACCEPTED UPDATED NAME
               # NOTE::: THIS MAY NOT BE LEGIT FOR LITERATURE RECORDS OR FIELD RECORDS 
               # SINCE THEY CANNOT BE UPDATED!!  THINK ABOUT THIS!!!
               "LnSy.[Full Name] AS acceptDetAs,
               LnSy.[sortName] AS acceptDetNoAuth,
               Lnam.[Full Name] AS detAs,
               Litr.[Latitude 1 Direction] AS lat1Dir,
               Litr.[Latitude 1 Degrees] AS lat1Deg,
               Litr.[Latitude 1 Minutes] AS lat1Min,
               Litr.[Latitude 1 Seconds] AS lat1Sec,
               Litr.[Latitude 1 Decimal] AS lat1Dec,", 
               #IIF no decimal latitude, then use geography/gazetteer latitude, but if it's there, use that as anyLat
               "IIf(IsNull(Litr.[Latitude 1 Decimal]),Geog.[Latitude 1 Decimal],Litr.[Latitude 1 Decimal]) AS anyLat,
               Litr.[Longitude 1 Direction] AS lon1Dir,
               Litr.[Longitude 1 Degrees] AS lon1Deg,
               Litr.[Longitude 1 Minutes] AS lon1Min,
               Litr.[Longitude 1 Seconds] AS lon1Sec,
               Litr.[Longitude 1 Decimal] AS lon1Dec,", 
               #IIF no decimal longitude, then use geography/gazetteer longitude, but if it's there, use that as anyLon
               "IIf(IsNull(Litr.[Longitude 1 Decimal]),Geog.[Longitude 1 Decimal],Litr.[Longitude 1 Decimal]) AS anyLon,
               Litr.[coordinateSource] AS coordSource,
               iif(isnull(Litr.[Latitude 1 Decimal]),'Gazetteer','Record') as coordSourcePlus,
               Litr.[coordinateAccuracy] AS coordAccuracy,
               Litr.[coordinateAccuracyUnits] AS coordAccuracyUnits,
               Litr.[Date 1 Days] AS dateDD, 
               Litr.[Date 1 Months] AS dateMM, 
               Litr.[Date 1 Years] AS dateYYYY,
               Geog.fullName AS fullLocation ",
# Joining tables: Literature records, Teams, References, Literature Record Locations, geography, latin names x2
"FROM (((Teams AS Auth 
RIGHT JOIN ([References] AS Refr 
RIGHT JOIN ([Latin Names] AS Lnam 
RIGHT JOIN [literature records] AS Litr 
ON Lnam.id = Litr.determination) 
ON Refr.id = Litr.Reference) 
ON Auth.id = Refr.Authors) 
LEFT JOIN (Geography AS Geog 
RIGHT JOIN LiteratureRecordLocations AS LRLo 
ON Geog.ID = LRLo.locality) 
ON Litr.id = LRLo.litrecid) 
LEFT JOIN [Synonyms tree] AS Synm ON Lnam.id = Synm.member) 
LEFT JOIN [Latin Names] AS LnSy ON Synm.[member of] = LnSy.id ",
# WHERE: 
"WHERE ", 
#       the location string doesn't stop at "Socotra" or "Socotran Archipelago": 
#              (to avoid lots of dots at the lat/lon of "Socotra" etc since that's very
#              unhelpful & doesn't give us a true location, even though it's a precise 
#              lat/lon value.
#              NB: The smaller islands Darsa & Semhah are allowed as they're small 
#              enough to be useful location values. Abd Al Kuri is still a bit too big
"(((Geog.fullName LIKE '%Socotra:%' OR Geog.fullName LIKE '%Abd al Kuri:%' OR Geog.fullName LIKE '%Socotra Archipelago: Samha%' OR Geog.fullName LIKE '%Socotra Archipelago: Darsa%')", 
#       OR location string does just say Socotra or the Archipelago BUT has 
#       a valid lat/lon (tested on longitude). 
#               This ensures recently imported datasets with GPS/decimal degrees
#               high-accuracy lat/lon are included!
"OR ((Geog.fullName LIKE '%Socotra Archipelago: Socotra' AND Litr.[Longitude 1 Decimal] IS NOT NULL) OR (Geog.fullName LIKE '%Socotra Archipelago' AND Litr.[Longitude 1 Decimal] IS NOT NULL))) AND LnSy.[Synonym of] IS NULL) ",
# ORDER BY ...
"ORDER BY Litr.id;")