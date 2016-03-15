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

# load function 
source("O:/CMEP\ Projects/Scriptbox/database_importing/function_latinNamesMatcher.R")

# Alan's Species List

fileLocat <- "O://CMEP\ Projects/PROJECTS\ BY\ COUNTRY/Socotra/Leverhulme\ RPG-2012-778\ Socotra/SOCOTRA FLORA/"

fileName <- "Socotra\ SPECIES\ LIST.csv"


##latinNamesMatcher(fileLocat, fileName, rowIndex, colIndexSp, colIndexSsp, colIndexAuth, oneWordDescription)

latinNamesMatcher(fileLocat, fileName, rowIndex=1:798, colIndexSp=5, colIndexSsp=5, colIndexAuth=6, "socotraProjectNamesMar2016")
#latinNamesMatcher(fileLocat, fileName, rowIndex=800:834, colIndexSp=5, colIndexSsp=5, colIndexAuth=5, "socotraProjectNamesMar2016_ferns")
#latinNamesMatcher(fileLocat, fileName, rowIndex=838:858, colIndexSp=5, colIndexSsp=5, colIndexAuth=6, "socotraProjectNamesMar2016_doubtful")
#latinNamesMatcher(fileLocat, fileName, rowIndex=862:967, colIndexSp=5, colIndexSsp=5, colIndexAuth=6, "socotraProjectNamesMar2016_introduced")

# read in data from file
crrntDet <<- read.csv(
        file=importSource, 
        header=TRUE, 
        as.is=TRUE, 
        na.strings="", 
        nrows=970
)

# subset to only Taxon and Authority columns
alansList <- crrntDet[,5:6]

# tbl_df this
alansList <- tbl_df(alansList)

# make a column from Taxon and Authority to concat them, then sub out NA values
alansList <- 
        alansList %>%
        mutate(taxonWAuthTemp=paste(Taxon, Authority, sep=" ")) %>%
        mutate(taxonWAuth=sub(" NA", "", taxonWAuthTemp))

# pare down to only distinct taxon name with authority, arranged by that.
alansListSet <- 
        alansList %>%
        select(taxonWAuth) %>%
        distinct(taxonWAuth) %>%
        arrange(taxonWAuth)
# 954 taxa





# Analysis Dataset

recGrab <- tbl_df(recGrab)

# pull out names only
analysisSet <- 
        recGrab %>%
        select(acceptDetAs) %>%
        distinct(acceptDetAs) %>%
        arrange(acceptDetAs)
# 870 names


# Compare datasets

# join alansListSet and analysisSet

# 1  2
# a  a
# b  X
# X  c

