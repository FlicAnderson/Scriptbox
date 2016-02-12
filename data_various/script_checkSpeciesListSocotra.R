## Socotra Project :: script_checkSpeciesListSocotra.R
# ==============================================================================
# (12th Feb 2016)
# Author: Flic Anderson
#
# dependent on: 
# saved at: O://CMEP\ Projects/Scriptbox/data_various/script_checkSpeciesListSocotra.R
# source("O://CMEP\ Projects/Scriptbox/data_various/script_checkSpeciesListSocotra.R")
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
# 2) 
# 3) 
# 4) 
# 5) 
# 6) end; close connections, tidy up objects 

# ---------------------------------------------------------------------------- #

# 0) 

# load required packages, install if they aren't installed already
# {RODBC} - ODBC Database Access
if (!require(RODBC)){
        install.packages("RODBC")
        library(RODBC)
}
# {dplyr} - manipulating data & large data frames as tbl_df objects
if (!require(dplyr)){
        install.packages("dplyr")
        library(dplyr)
}
# load sqldf library
if (!require(sqldf)) {
        install.packages("sqldf")
        library(sqldf)
}

# open connection to live padme
source("O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R")
livePadmeArabiaCon()

# load function 
source("O:/CMEP\ Projects/Scriptbox/database_importing/function_latinNamesMatcher.R")


# 1) 

fileLocat <- "O://CMEP\ Projects/Socotra"

fileName <- "SocotraSPECIES-LIST_NOTES.csv"


#latinNamesMatcher(fileLocat, fileName, rowIndex, colIndexSp, colIndexSsp, colIndexAuth, oneWordDescription)
latinNamesMatcher(fileLocat, fileName, rowIndex=1:800, colIndexSp=5, colIndexSsp=5, colIndexAuth=6, "socotraProjectNames")

# 2) 




# 3) 




# 4) 



# 5)


# 6)

# end; close connections, tidy up objects

# VERY IMPORTANT!
# CLOSE DATABASE CONNECTIONS
odbcCloseAll()

# REMOVE ALL OBJECTS FROM WORKSPACE!
#rm(list=ls())

# # REMOVE SOME OBJECTS FROM WORKSPACE!
#         # removes EVERYTHING EXCEPT WHAT YOU WANT TO KEEP 
#         # (eg. connections, things, etc):
# rm(list=setdiff(ls(), 
#                 c(
#                 "thing1", 
#                 "thing2", 
#                 "con_livePadmeArabia", 
#                 "livePadmeArabiaCon"
#                 )
#         )
# )

# VERY IMPORTANT!
# CLOSE THE CONNECTION!
#odbcCloseAll()

print("... script_checkSpeciesListSocotra.R complete!")
