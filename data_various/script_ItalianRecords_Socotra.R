## Socotra Project :: script_ItalianRecords_Socotra.R
# ==============================================================================
# (21st December 2015)
# Author: Flic Anderson
#
# dependent on: 
# saved at: O://CMEP\ Projects/Scriptbox/data_various/script_ItalianRecords_Socotra.R
# source: source("O://CMEP\ Projects/Scriptbox/data_various/script_ItalianRecords_Socotra.R")
#
# AIM: Load and wrangle data from Italian group for Socotra project. Alter format,
# .... convert coordinate system, prepare records for importing to Padme database
# .... and package for mapping in GIS etc.

# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) Load libraries, functions, source scripts
# 1) Load import copy of data
# 2) Mung/wrangle data into useful format
# 3) Change coordinate system(? - uncertain if poss to do here, otherwise via GIS)
# 4) Show the output
# 5) Save the output to .csv

# ---------------------------------------------------------------------------- #

# 0) 

# load required packages, install if they aren't installed already
# {dplyr} - manipulating data & large data frames as tbl_df objects
if (!require(dplyr)){
  install.packages("dplyr")
  library(dplyr)
}
#if (!require(xlsx)){
#        install.packages("xlsx")
#        library(xlsx)
#}



# 1)

# read the data from tab-sep .csv files. 

## To get rid of warning message:
#     In scan(file = file, what = what, sep = sep, quote = quote, dec = dec,  :
#     embedded nul(s) found in input
# add argument: skipNul=TRUE

## To get rid of warning message:
#     In scan(file, what, nmax, sep, dec, quote, skip, nlines, na.strings,  :
#     EOF within quoted string
# add argument: quote=""

## To get rid of error message:
#       Error in read.table(file = file, header = header, sep = sep, quote = quote,  : 
#       more columns than column names
# change argument: header=TRUE to header=FALSE

# set working directory to avoid ungainly file location strings:
setwd("O://CMEP\ Projects/PROJECTS\ BY\ COUNTRY/Socotra/Leverhulme\ RPG-2012-778\ Socotra/ToImport_ItalianData")
fileLocat <- "O://CMEP\ Projects/PROJECTS\ BY\ COUNTRY/Socotra/Leverhulme\ RPG-2012-778\ Socotra/ToImport_ItalianData"

datA_SocITA <- read.csv(
  file="IMPORTCOPY_Socotra_dataplot_17112015.csv", 
  header=FALSE, # no headers since these things are a bit screwed up
  sep=",", 
  quote="", 
  fill=TRUE, 
  encoding="UTF-8", 
  skipNul=TRUE
  )
# 484 obs x 437 var

# show a little of the data
head(datA_SocITA[,1:10])




# look at structure of data
str(datA_SocITA)

# make dplyr objects
#datA_SocITA <- tbl_df(datA_SocITA)

# 2)

# wrangle data by pulling out precision and data source info, X & Y co-ords & 
# releve numbers

# check out structure again
glimpse(datA_SocITA)

# Releve number
releveNum <- datA_SocITA[1,]                    # pull out first row
releveNum <- releveNum[3:length(releveNum)]     # only include releve numbers


# X co-ords
xCoords <- datA_SocITA[2,]                    # pull out second row
xCoords <- xCoords[3:length(xCoords)]         # only use X co-ord numbers

# Y co-ords
yCoords <- datA_SocITA[3,]                    # pull out third row
yCoords <- yCoords[3:length(yCoords)]         # only use Y co-ord numbers



# Precision info
# split into:
#       precision-size
#       location info source             

precis <- datA_SocITA[4,]               # pull out fourth row
precis <- precis[3:length(precis)]      # only use precision info

precisSize <- precis
        # keep only first part of string 
        # keep everything before the ';' (eg. "1Km")
gsub("[0-9A-Za-z]*\;", "", precisSize)

precisSource <- precis
        # keep only second part of the string
        # keep only everything after the ';' (eg. "according the map of...")



# actually maybe better to pull out the first 4 rows, 
# then drop first column, then levels=c(X, Y, Precision) or something
# then maybe sth like *apply or whatever to use regex to gsub(pattern, "", data)?


# 3)

# filter out missing co-ords probably => filtered_datA_SocITA


# write this out to CSV
write.csv(
        filtered_datA_SocITA,
        file=file.choose(),
        na="", 
        row.names=FALSE
)


# check out http://rcastilho.pt/SDM101/SDM_files/Occurrence_data.R for land/sea point filtering and stuff
# check out http://hydrodictyon.eeb.uconn.edu/people/cmerow/home/r_resources_files/AMNH_R_Conference/Scripts/1_Matt_AielloLammens.R for anti-duplicates and such
# check out http://www.esapubs.org/archive/ecos/C004/004/Rcode.R for species name edits and such