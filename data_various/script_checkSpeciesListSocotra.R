## Socotra Project :: script_checkSpeciesListSocotra.R
# ==============================================================================
# (12th Feb 2016)
# Author: Flic Anderson
#
# dependent on: 
# saved at: O://CMEP\ Projects/Scriptbox/data_various/script_checkSpeciesListSocotra.R
# source("O://CMEP\ Projects/Scriptbox/data_various/script_checkSpeciesListSocotra.R")
#
# AIM: Check names in Alan's sample spreadsheet for the Socotra project against 
# .... Padme Arabia names and output list of those which need checking - likely
# .... these will need some Authority info or spellings corrected, but also there
# .... will definitely need to be updates and corrections made to Padme, including
# .... recent taxonomic changes entered.
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

# load function 
source("O:/CMEP\ Projects/Scriptbox/database_importing/function_latinNamesMatcher.R")


# 1) 

fileLocat <- "O://CMEP\ Projects/Socotra"

fileName <- "SocotraSPECIES-LIST_NOTES.csv"


#latinNamesMatcher(fileLocat, fileName, rowIndex, colIndexSp, colIndexSsp, colIndexAuth, oneWordDescription)
latinNamesMatcher(fileLocat, fileName, rowIndex=1:800, colIndexSp=5, colIndexSsp=5, colIndexAuth=6, "socotraProjectNames")

# need to fix NA auth situation & NA NA situations


# 2)

# test taxa
test1 <- "Peperomia blanda  (Jacq.) Kunth"
test2 <- "Peperomia tetraphylla  Hook. & Arn."
test3 <- "Eulophia petersii (Rchb.f.) Rchb.f."
test4 <- "Cyanixia socotrana (Balf.f.) Goldblatt & J.C.Manning"



# need to integrate the fuzzy names matcher script to suggest matches to make edits
# and corrections easier - maybe do this using dplyr and then mutate(function) new column

# source that function
source("O://CMEP\ Projects/Scriptbox/general_utilities/function_padmeNameMatch.R")
# to call: padmeNameMatch(checkMe=NULL, taxonType="species", authorityPresent=FALSE, taxonSingle=TRUE)
# need to edit it to deal with multiple taxa (create method for taxonSingle=FALSE)

padmeNameMatch(checkMe=test1, taxonType="species", authorityPresent=FALSE, taxonSingle=TRUE)


# dplyr everything necessary

# run mutate (with chaining)

# output



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
