## Afghanistan Projects :: script_pullOutAfghanistanChecklistTaxa.R
# ==============================================================================
# 25th October 2016
# Author: Flic Anderson
#
# dependent on: "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeAfghanistanCon.R"
# saved at: O://CMEP\ Projects/Scriptbox/database_output/script_pullOutAfghanistanChecklistTaxa.R
# source: source("O://CMEP\ Projects/Scriptbox/database_output/script_pullOutAfghanistanChecklistTaxa.R")
#
# AIM: Pull out names of all taxa from checklist of names from Breckle/Rafiqpoor
# .... Checklist of Plants of Afghanistan [REF BETTER!] for futher use. Names 
# .... entered into Padme Afghanistan largely by Ahmad Jamshed Khoshbeen (2016)
# .... as part of a Darwin Initiative Fellowship with Centre for Middle Eastern
# .... Plants, RBGE.


# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) Load libraries, functions, source scripts
# 1) 
# 2) Create query 
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
source("O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeAfghanistanCon.R")
livePadmeAfghanistanCon()


# 1)  Assemble query
sqlTables(con_livePadmeAfghanistan, tableType = "SYNONYM")

sqlQuery(con_livePadmeAfghanistan, query = "SELECT * FROM [Latin Names];")
