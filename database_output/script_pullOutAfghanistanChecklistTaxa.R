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


# 1)  Assemble query/ table stuff

#sqlTables(con_livePadmeAfghanistan, tableType = "SYNONYM")

allNamesAF <- sqlQuery(con_livePadmeAfghanistan, query = "SELECT * FROM [Latin Names]")
# sortName [,48] #taxonNoAuth_AF <- allNamesAF[,48]
# Full Name [,7] #taxonWithAuth_AF <- allNamesAF[,7] 

allNamesAF <- sqlQuery(con_livePadmeAfghanistan, query = "SELECT [id], [Full Name], [sortName], [Rank] FROM [Latin Names]")
namesRanksAF <- sqlQuery(con_livePadmeAfghanistan, query = "SELECT * FROM [Ranks]")

# N.B.: "formattedName" field contains tagged elements of the name eg. <e></e> 
# for epithets <a></a> for authority, <r></r> for any rank stuff like Subfamily 
# or subsp.

# join ranks stuff onto names stuff
namesAF <- sqldf("SELECT allNamesAF.*, namesRanksAF.name FROM allNamesAF LEFT JOIN namesRanksAF on allNamesAF.Rank=namesRanksAF.id")
namesAF$Rank <- namesAF$name  # replace rank ID numbers with the names
#head(namesAF)
namesAF$name <- NULL  # remove the extra column called name (prev. ranks.name)




