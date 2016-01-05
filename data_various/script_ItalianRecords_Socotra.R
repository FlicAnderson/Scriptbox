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
# {proj4} - mapping and projection library, for converting UTM to DMS
if (!require(proj4)){
        install.packages("proj4")
        library(proj4)
}
# {rgdal} - also methods for converting UTM to DMS
if (!require(rgdal)){
        install.packages("rgdal")
        library(rgdal)
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
# OR BETTER YET...
# leave argument quote= set to default (quote="\"") instead of disabling with quote=""
# this prevents issues from diacritics etc as found with probable-breaker "Relevé"

# set working directory to avoid ungainly file location strings:
setwd("O://CMEP\ Projects/PROJECTS\ BY\ COUNTRY/Socotra/Leverhulme\ RPG-2012-778\ Socotra/ToImport_ItalianData")
fileLocat <- "O://CMEP\ Projects/PROJECTS\ BY\ COUNTRY/Socotra/Leverhulme\ RPG-2012-778\ Socotra/ToImport_ItalianData"



datA_SocITA <- read.csv(
  file="IMPORTCOPY_Socotra_dataplot_17112015.csv", 
  header=TRUE, # no headers since these things are a bit screwed up
  sep=",", 
  quote="\"",
  fill=TRUE, 
  stringsAsFactors=FALSE,
  encoding="UTF-8", 
  skipNul=TRUE
  )
# 484 obs x 437 var

# show a little of the data
head(datA_SocITA[,1:10])




# look at structure of a little of the data
str(datA_SocITA)


## it's all sideways and messed up
## fix this by transposing using t()
#datA_SocITA <- t(datA_SocITA)

# make dplyr objects
#datA_SocITA <- tbl_df(datA_SocITA)
# not yet...

####testobj <- datA_SocITA




# 2)

# wrangle data by pulling out precision and data source info, X & Y co-ords & 
# releve numbers

# check out structure again
#glimpse(datA_SocITA)

## Releve number
#releveNum <- datA_SocITA[1,]                    # pull out first row
#releveNum <- releveNum[3:length(releveNum)]     # only include releve numbers
## this is OUT OF DATE, since headers are now the releve number, eg. X1=1st, etc


# X co-ords
xCoords <- datA_SocITA[1,]                    # pull out first row
xCoords <- xCoords[3:length(xCoords)]         # only use X co-ord numbers (rm 1st 2 junkCols)

# Y co-ords
yCoords <- datA_SocITA[2,]                    # pull out second row
yCoords <- yCoords[2:length(yCoords)]         # only use Y co-ord numbers (rm 1st 2 junkCols)


## CONVERT UTM Eastings and Northings to Lat & Lon DMS!

# Zones 39 or 40...
# Northern Hemisphere
# X = Eastings?
# Y = Northings?

# req proj4 package.
# or req rgdal package




# Precision info
# split into:
#       precision-size
#       location info source             

precis <- datA_SocITA[3,]               # pull out third row
precis <- precis[3:length(precis)]      # only use precision info

precisSize <- precis
        # keep only first part of string 
        # keep everything before the ';' (eg. "1Km")
#gsub("[0-9A-Za-z]*\;", "", precisSize)         # doesn't work fully yet

precisSource <- precis
        # keep only second part of the string
        # keep only everything after the ';' (eg. "according the map of...")



# actually maybe better to pull out the first 4 rows, 
# then drop first column, then levels=c(X, Y, Precision) or something
# then maybe sth like *apply or whatever to use regex to gsub(pattern, "", data)?

locatInfo <- datA_SocITA[1:3,]
locatInfo <- data.frame(datA_SocITA[1:3,])
locatInfo <- locatInfo[,2:ncol(locatInfo)] # drop useless first column

#transpose rows to columns
locatInfo <- t(locatInfo)
# gives:
#                   1           2           
# Relev.e9..number "X"         "Y"         
# X1               "822460.62" "1396027.91"
# X2               "822478.39" "1396957.73"






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