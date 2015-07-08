## Iraq Darwin Project :: script_pullOutDarwinInitiativeTaxa.R
# ==============================================================================
# 08th July 2015
# Author: Flic Anderson
#
# dependent on: "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeIraqCon.R"
# saved at: O://CMEP\ Projects/Scriptbox/database_output/script_pullOutDarwinInitiativeTaxa.R
# source: source("O://CMEP\ Projects/Scriptbox/database_output/script_pullOutDarwinInitiativeTaxa.R")
#
# AIM: 
# .... 
# .... 
# .... 
# ....  
# .... 
# .... 

# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) Load libraries, functions, source scripts
# 1) 
# 2) Build query 
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
if (!require(sqldf)){
        install.packages("sqldf")
        library(sqldf)
} 
# open connection to live padme
source("O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeIraqCon.R")
livePadmeIraqCon()


# 1)  Assemble query

qry <- "
SELECT 'L-' & Litr.id AS recID, 
Auth.[name for display] AS collector,
Litr.id AS collNumFull, 
Lnam.[sortName] AS detAsNoAuth,
Lnam.[Full Name] AS detAs,",
# Lnam.[Full Name] AS detAs,
# HERE the Lnam.FullName is replaced by the ACCEPTED NAME (LnSy.[Full Name])
# THIS IS NOT WHAT IT WAS ORIG DET AS BUT THE ACCEPTED UPDATED NAME
"LnSy.[Full Name] AS acceptDetAs, 
FROM (((Teams AS Auth 
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
LEFT JOIN [Latin Names] AS LnSy ON Synm.[member of] = LnSy.id 
WHERE LnSy.[Synonym of] IS NULL) 
ORDER BY Litr.id;")
# UNFINISHED - START FROM SCRATCH

qry <- "SELECT 
  [Latin Names].sortName AS familyName, 
  [names tree].member
  FROM (
    Ranks INNER JOIN [Latin Names] ON Ranks.id = [Latin Names].Rank) 
    INNER JOIN [names tree] ON [Latin Names].id = [names tree].[member of]
WHERE (((Ranks.name)='family'));"
families <- sqlQuery(con_livePadmeIraq, qry)
# UNFINISHED - START FROM SCRATCH