## Socotra Project :: script_herbQry_Socotra.R
# ==============================================================================
# 22nd March 2016
# Author: Flic Anderson
#
# dependent on: "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R"
# dependent on: "O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R"
# saved at: O://CMEP\ Projects/Scriptbox/database_output/script_herbQry_Socotra.R
# source("O://CMEP\ Projects/Scriptbox/database_output/script_herbQry_Socotra.R")
#
# AIM: Pull out herbarium records into R for species in Socotra from 
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

# build HERB query
# Adapted from script_dataGrabSpecieswithFullLatLon.R, moved from script_dataGrabFullLatLonOrGazLatLon_Socotra
herbQry <<- paste0("
               SELECT 'H-' & Herb.id AS recID, 
               Herb.[Expedition] AS expdID,
               Team.[name for display] AS collector,
               Herb.[Collector Number] AS collNumFull,
               LnSy.[id] AS lnamID, ",
               # HERE the Lnam.FullName is replaced by the ACCEPTED NAME (LnSy.[Full Name])
               # THIS IS NOT WHAT IT WAS ORIG DET AS BUT THE ACCEPTED UPDATED NAME
               "LnSy.[Full Name] AS acceptDetAs,
               LnSy.[sortName] AS acceptDetNoAuth,
               Lnam.[Full Name] AS detAs,
               Herb.[Latitude 1 Direction] AS lat1Dir,
               Herb.[Latitude 1 Degrees] AS lat1Deg,
               Herb.[Latitude 1 Minutes] AS lat1Min,
               Herb.[Latitude 1 Seconds] AS lat1Sec,
               Herb.[Latitude 1 Decimal] AS lat1Dec, ",
               #IIF no decimal latitude, then use geography/gazetteer latitude, but if it's there, use that as anyLat
               "IIf(IsNull(Herb.[Latitude 1 Decimal]),Geog.[Latitude 1 Decimal],Herb.[Latitude 1 Decimal]) AS anyLat,
               Herb.[Longitude 1 Direction] AS lon1Dir,
               Herb.[Longitude 1 Degrees] AS lon1Deg,
               Herb.[Longitude 1 Minutes] AS lon1Min,
               Herb.[Longitude 1 Seconds] AS lon1Sec,
               Herb.[Longitude 1 Decimal] AS lon1Dec, ",
               #IIF no decimal longitude, then use geography/gazetteer longitude, but if it's there, use that as anyLon
               "IIf(IsNull(Herb.[Longitude 1 Decimal]),Geog.[Longitude 1 Decimal],Herb.[Longitude 1 Decimal]) AS anyLon,
               Herb.[coordinateSource] AS coordSource,
               Herb.[coordinateAccuracy] AS coordAccuracy,
               Herb.[coordinateAccuracyUnits] AS coordAccuracyUnits,
               iif(isnull(Herb.[Latitude 1 Decimal]),'Gazetteer','Record') as coordSourcePlus,
               Herb.[Date 1 Days] AS dateDD, 
               Herb.[Date 1 Months] AS dateMM, 
               Herb.[Date 1 Years] AS dateYYYY,
               Geog.fullName AS fullLocation ",
# Joining tables: Herb, Geog, Herbaria, Determinations, Synonyms tree, Latin Names, Teams x2, CoordinateSources
               "FROM ((((((((Determinations AS Dets 
RIGHT JOIN [Herbarium specimens] AS Herb ON Dets.[specimen key] = Herb.id) 
LEFT JOIN [Latin Names] AS Lnam ON Dets.[latin name key] = Lnam.id) 
LEFT JOIN [Synonyms tree] AS Synm ON Lnam.id = Synm.member) 
LEFT JOIN [Latin Names] AS LnSy ON Synm.[member of] = LnSy.id) 
LEFT JOIN Geography AS Geog ON Herb.Locality = Geog.ID) 
LEFT JOIN Teams AS Team ON Herb.[Collector Key] = Team.id) 
LEFT JOIN Herbaria ON Herb.Herbarium = Herbaria.id) 
LEFT JOIN CoordinateSources AS Coor ON Herb.coordinateSource = Coor.id) 
LEFT JOIN Teams AS DtTm ON Dets.[Det by] = DtTm.id ",
# WHERE: 
"WHERE ",
# only pull out records with current dets: 
"Dets.Current=True ",
# REQ: FIX FOR SYNONYMS POPPING UP IN DATA WITH SAME H-IDs

#       the location string doesn't stop at "Socotra" or "Socotran Archipelago": 
#              (to avoid lots of dots at the lat/lon of "Socotra" etc since that's very
#              unhelpful & doesn't give us a true location, even though it's a precise 
#              lat/lon value.
#              NB: The smaller islands Darsa & Semhah are allowed as they're small 
#              enough to be useful location values. Abd Al Kuri is still a bit too big
"AND ((Geog.fullName LIKE '%Socotra:%' OR Geog.fullName LIKE '%Abd al Kuri:%' OR Geog.fullName LIKE '%Socotra Archipelago: Samha%' OR Geog.fullName LIKE '%Socotra Archipelago: Darsa%') ",
#       OR location string does just say Socotra or the Archipelago BUT has 
#       a valid lat/lon (tested on longitude). 
#               This ensures recently imported datasets with GPS/decimal degrees
#               high-accuracy lat/lon are included!
"OR ((Geog.fullName LIKE '%Socotra Archipelago: Socotra' AND Herb.[Longitude 1 Decimal] IS NOT NULL) OR (Geog.fullName LIKE '%Socotra Archipelago' AND Herb.[Longitude 1 Decimal] IS NOT NULL))) AND ((LnSy.[Synonym of]) Is Null) ",
# ORDER BY ...
"ORDER BY Team.[name for display];")