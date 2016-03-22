## Socotra Project :: script_fielQry_Socotra.R
# ==============================================================================
# 22nd March 2016
# Author: Flic Anderson
#
# dependent on: "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R"
# dependent on: "O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R"
# saved at: O://CMEP\ Projects/Scriptbox/database_output/script_fielQry_Socotra.R
# source("O://CMEP\ Projects/Scriptbox/database_output/script_fielQry_Socotra.R")
#
# AIM: Pull out field observation records into R for species in Socotra from 
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

# aka qry0; query to select all records from the temporary table FieldRexTemp, replaces qry2
# NOTE - FieldRexTemp needs to be manually re-created and the query re-added to Padme
# after each padmecode.mdb update!!

fielQry <- "SELECT * FROM FieldRexTemp"

# fielQry <- paste0("INSERT INTO FieldRexTemp ( recID, expdID, collector, collNumFull, lnamID, acceptDetAs, acceptDetNoAuth, detAs, lat1Dir, lat1Deg, lat1Min, lat1Sec, lat1Dec, AnyLat, lon1Dir, lon1Deg, lon1Min, lon1Sec, lon1Dec, AnyLon, coordSource, coordSourcePlus, coordAccuracy, coordAccuracyUnits, dateDD, dateMM, dateYYYY, fullLocation )
# SELECT 
# 'F-' & Fiel.id AS recID, 
# Fiel.Expedition AS expdID, 
# Team.[name for display] AS collector, 
# Fiel.[Collector Number] AS collNumFull, 
# LnSy.id AS lnamID, 
# LnSy.[Full Name] AS acceptDetAs, 
# LnSy.sortName AS acceptDetNoAuth, 
# Lnam.[Full Name] AS detAs, 
# Fiel.[Latitude 1 Direction] AS lat1Dir, 
# Fiel.[Latitude 1 Degrees] AS lat1Deg, 
# Fiel.[Latitude 1 Minutes] AS lat1Min, 
# Fiel.[Latitude 1 Seconds] AS lat1Sec, 
# Fiel.[Latitude 1 Decimal] AS lat1Dec, 
# IIf(IsNull(Fiel.[Latitude 1 Decimal]), Geog.[Latitude 1 Decimal], Fiel.[Latitude 1 Decimal]) AS anyLat, 
# Fiel.[Longitude 1 Direction] AS lon1Dir, 
# Fiel.[Longitude 1 Degrees] AS lon1Deg, 
# Fiel.[Longitude 1 Minutes] AS lon1Min, 
# Fiel.[Longitude 1 Seconds] as lon1Sec, 
# Fiel.[Longitude 1 Decimal] AS lon1Dec, 
# IIf(IsNull(Fiel.[Longitude 1 Decimal]),Geog.[Longitude 1 Decimal],Fiel.[Longitude 1 Decimal]) AS anyLon, 
# Fiel.coordinateSource AS coordSource, 
# IIf(IsNull(Fiel.[Latitude 1 Decimal]),'Gazetteer','Record') AS coordSourcePlus, 
# Fiel.coordinateAccuracy AS coordAccuracy, 
# Fiel.coordinateAccuracyUnits AS coordAccuracyUnits, 
# Fiel.[Date 1 Days] AS dateDD, 
# Fiel.[Date 1 Months] as dateMM, 
# Fiel.[Date 1 Years] as dateYYYY, 
# Geog.fullName AS fullLocation
# FROM (((([Field notes] AS Fiel LEFT JOIN Geography AS Geog ON Fiel.Locality = Geog.ID) LEFT JOIN Teams AS Team ON Fiel.[Collector Key] = Team.id) LEFT JOIN [Latin Names] AS Lnam ON Fiel.determination = Lnam.id) LEFT JOIN [Synonyms tree] AS Snym ON Lnam.id = Snym.member) LEFT JOIN [Latin Names] AS LnSy ON Snym.[member of] = LnSy.id
# WHERE (((Geog.fullName) Like '*Socotra:*' Or (Geog.fullName) Like '*Abd al Kuri:*' Or (Geog.fullName) Like '*Socotra Archipelago: Samha*' Or (Geog.fullName) Like '*Socotra Archipelago: Darsa*') AND ((LnSy.[Synonym of]) Is Null)) OR (((Fiel.[Longitude 1 Decimal]) Is Not Null) AND ((Geog.fullName) Like '*Socotra Archipelago: Socotra') AND ((LnSy.[Synonym of]) Is Null)) OR (((Fiel.[Longitude 1 Decimal]) Is Not Null) AND ((Geog.fullName) Like '*Socotra Archipelago') AND ((LnSy.[Synonym of]) Is Null))
# ORDER BY Team.[name for display];")

# ISSUE: system resources exceeded! in RODBC drivers & Access
#fielRex <- sqlQuery(con_livePadmeArabia, qry2) 
#"HY001 -1011 [Microsoft][ODBC Microsoft Access Driver] System resource exceeded."
# query is now too large!
# FIX: 
# TL;DR - when system resources exceeded, create temp table, run query in 
# Padme/Accesss to put records into newly created temporary table, then pull into R & proceed as normal.
# FIX: 
# Created table [FieldRexTemp] in test copy of Padme Arabia.    
# 
# Output of sqlColumns() here:
# https://gist.github.com/FlicAnderson/ad44350a62eb017387b6
# shows column and data types
# 
# Ran this query:
# https://gist.github.com/FlicAnderson/0a3ab3622c6902733f5b
# to fill the FieldRexTemp table with the query result. 
# Had to do separate steps for create and "INSERT INTO FieldRexTemp 
# SELECT ......;" because otherwise Access gave "system resource exceeded" error.
# 
# Running this worked after that:
# # source & open test connection
# source("O://CMEP\ Projects/Scriptbox/database_connections/function_TESTPadmeArabiaCon.R")
# TESTPadmeArabiaCon()
# # query to select all records from the temporary table FieldRexTemp, replaces qry2
# qry0 <- "SELECT * FROM FieldRexTemp"
# # run query
# fielRex <- sqlQuery(con_TESTPadmeArabia, qry0) 
# # 04/02/2016 24233 obs 28 var - need to remove the id column!
# # remove ID field
# fielRex$id <- NULL
# # 04/02/2016 24233 obs 27 var - OK to continue!