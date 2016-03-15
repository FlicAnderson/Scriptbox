## Socotra Project :: script_compareSpeciesList_Socotra.R
# ==============================================================================
# 15th March 2016
# Author: Flic Anderson
#
# dependent on: 
# saved at: O://CMEP\ Projects/Scriptbox/data_various/script_compareSpeciesList_Socotra.R
# source("O://CMEP\ Projects/Scriptbox/data_various/script_compareSpeciesList_Socotra.R")
#
# AIM: Check unique names in Alan's sample spreadsheet for the Socotra project against 
# .... unique analysis dataset names and output list of those which are not in each set.
# .... Based somewhat on script_checkSpecieslistSocotra.R & script_editTaxa_Socotra.R
# .... 
# .... 
# .... Also names matching will operate as base/check for linking samples/EDINA 
# .... IDs & allowing this data to be pulled into future analyses

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