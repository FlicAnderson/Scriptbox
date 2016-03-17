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

# does recGrab exist?
if(!exists("recGrab")) stop("... ERROR: recGrab object doesn't exist")

# open connection to live padme
#source("O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R")
#livePadmeArabiaCon()

# load function 
#source("O:/CMEP\ Projects/Scriptbox/database_importing/function_latinNamesMatcher.R")

# Alan's Species List

fileLocat <- "O://CMEP\ Projects/PROJECTS\ BY\ COUNTRY/Socotra/Leverhulme\ RPG-2012-778\ Socotra/SOCOTRA FLORA/"

fileName <- "Socotra\ SPECIES\ LIST.csv"

# import source:
importSource <<- paste0(fileLocat, "/", fileName)

##latinNamesMatcher(fileLocat, fileName, rowIndex, colIndexSp, colIndexSsp, colIndexAuth, oneWordDescription)

# read in data from file
sampledSet <<- read.csv(
        file=importSource, 
        header=TRUE, 
        as.is=TRUE, 
        na.strings="", 
        nrows=800
)

# subset to only Order, Family, Taxon and Authority columns
sampledSet <- sampledSet[,c(2,4,5:6)]


# tbl_df this
sampledSet <- tbl_df(sampledSet)

# make a column from Taxon and Authority to concat them, then sub out NA values
sampledSet <- 
        sampledSet %>%
        mutate(taxonTemp=paste(Taxon, Authority, sep=" ")) %>%
        mutate(taxonWAuth=sub(" NA", "", taxonTemp))

# pare down to only distinct taxon name with authority, arranged by that.
sampledSet <- 
        sampledSet %>%
        select(taxonWAuth, Family, Order) %>%
        distinct(taxonWAuth) %>%
        arrange(taxonWAuth)
# 953 taxa (798 after removing ferns, doubtful and non-native)





# Analysis Dataset

recGrab <- tbl_df(recGrab)

# pull out names only
analysisSet <- 
        recGrab %>%
        select(acceptDetAs, familyName) %>%
        distinct(acceptDetAs) %>%
        arrange(acceptDetAs)
# 880 names


# Compare datasets

# join alansListSet and analysisSet

# 1  2
# a  a
# b  X
# X  c

names(sampledSet)
#[1] "taxonWAuth" "Family"     "Order"   
names(analysisSet)
#[1] "acceptDetAs" "familyName" 

# {dplyr} anti_join(): 
        #return all rows from x where there are not matching values in y, keeping just columns from x

notInAnalysisSet <-
        anti_join(sampledSet, analysisSet, by=c("taxonWAuth" = "acceptDetAs")) %>%
        arrange(taxonWAuth)
# 141 (48 not in main sampled set)

notInSampledSet <-
        anti_join(analysisSet, sampledSet, by=c("acceptDetAs" = "taxonWAuth")) %>%
        arrange(acceptDetAs)
# 68 (130 not in main sampledset)

message(paste0(" ... saving ", nrow(notInAnalysisSet), " name comparison lists to: O://CMEP\ Projects/Socotra/nameComparisonList_sampledSetNamesNotInAnalysisSet-Socotra_", Sys.Date(), ".csv"))
write.csv(notInAnalysisSet, file=paste0("O://CMEP\ Projects/Socotra/nameComparisonList_sampledSetNamesNotInAnalysisSet-Socotra_", Sys.Date(), ".csv"), na="", row.names=FALSE)

message(paste0(" ... saving ", nrow(notInSampledSet), " name comparison lists to: O://CMEP\ Projects/Socotra/nameComparisonList_analysisSetNamesNotInSampledSet-Socotra_", Sys.Date(), ".csv"))
write.csv(notInSampledSet, file=paste0("O://CMEP\ Projects/Socotra/nameComparisonList_analysisSetNamesNotInSampledSet-Socotra_", Sys.Date(), ".csv"), na="", row.names=FALSE)
