## Oman Project :: script_fielQry_Oman.R
# ==============================================================================
# 15 November 2018
# Author: Flic Anderson
#
# dependent on: "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R"
# dependent on: "O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R"
# saved at: O://CMEP\ Projects/Scriptbox/database_output/script_fielQry_Socotra.R
# source("O://CMEP\ Projects/Scriptbox/database_output/script_fielQry_Oman.R")
#
# AIM: Pull out field observation records into R for species in Oman from 
# .... Padme Arabia using SQL via the RODBC connection set up in another script. 
# .... Includes lat/lon from Padme gazetteer where no lat /lon are present 
 

# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 1) Build query 

# ---------------------------------------------------------------------------- #

# 1)

# aka qry0; query to select all records from the temporary table FieldRexTempOman, replaces qry2
# NOTE - FieldRexTempOman needs to be manually re-created and the query re-added to Padme
# after each padmecode.mdb update!!

fielQry <- "SELECT * FROM FieldRexTempOman"

# Presuming below issue still exists, so keeping this method in place to avoid it

# ISSUE: system resources exceeded! in RODBC drivers & Access
#fielRex <- sqlQuery(con_livePadmeArabia, qry2) 
#"HY001 -1011 [Microsoft][ODBC Microsoft Access Driver] System resource exceeded."
# query is now too large!
# FIX: 
# TL;DR - when system resources exceeded, create temp table, run query in 
# Padme/Accesss to put records into newly created temporary table, then pull into R & proceed as normal.
# FIX: 
# Created table [FieldRexTempOman] in Padme Arabia.    
# 
# Ran this query:
# https://gist.github.com/FlicAnderson/42febe6f5e897cce0013ceb596f2666c
# to fill the FieldRexTempOman table with the query result. 
# Had to do separate steps for create and "INSERT INTO FieldRexTempOman 
# SELECT ......;" because otherwise Access gave "system resource exceeded" error.

# TESTPadmeArabiaCon()
# # query to select all records from the temporary table FieldRexTemp, replaces qry2
# qry0 <- "SELECT * FROM FieldRexTemp"
# # run query
# fielRex <- sqlQuery(con_TESTPadmeArabia, qry0) 
# # 04/02/2016 24233 obs 28 var - need to remove the id column!
# # remove ID field
# fielRex$id <- NULL
# # 04/02/2016 24233 obs 27 var - OK to continue!