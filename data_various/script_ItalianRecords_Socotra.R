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
# # {proj4} - mapping and projection library, for converting UTM to DMS
# if (!require(proj4)){
#         install.packages("proj4")
#         library(proj4)
# }
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
  header=FALSE, # no headers since these things are a bit screwed up
  sep=",", 
  quote="\"",
  fill=TRUE, 
  stringsAsFactors=FALSE,
  encoding="UTF-8", 
  skipNul=TRUE
  )
# 484 obs x 437/?398? var

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
relvNum <- datA_SocITA[1,3:ncol(datA_SocITA)]  # only use releve numbers (rm 1st 2 junkCols)
relvNum <- as.vector(relvNum, mode="numeric")

xCoords <- datA_SocITA[2,3:ncol(datA_SocITA)]  # only use X co-ord numbers (rm 1st 2 junkCols)
xCoords <- as.vector(xCoords, mode="numeric")

yCoords <- datA_SocITA[3,3:ncol(datA_SocITA)]  # only use Y co-ord numbers (rm 1st 2 junkCols)
yCoords <- as.vector(yCoords, mode="numeric")


precision <- datA_SocITA[4,3:ncol(datA_SocITA)]  # precision info (rm 1st 2 junkCols)
precision <- as.vector(precision, mode="character")

# Precision info
# split into:
#       precision-size
#       location info source             


precisSize <- precision
        # keep only first part of string 
        # keep everything before the ';' (eg. "1Km")
#gsub("[0-9A-Za-z]*\;", "", precisSize)         # doesn't work fully yet

# try strsplit()
precisSize <- unlist(strsplit(precision, "; "))

precisSource <- precision
        # keep only second part of the string
        # keep only everything after the ';' (eg. "according the map of...")



# put everything together in one dataframe that's set out nicely:
locatDat <- data.frame(relvNum=relvNum, x=xCoords, y=yCoords, precision=precision)


## CONVERT UTM Eastings and Northings to Lat & Lon DMS!

# Zones 39 or 40...
# Northern Hemisphere
# X = Eastings?
# Y = Northings?

# req proj4 package (THIS WASN'T EASY TO USE!)
# or req rgdal package (THIS WAS BETTER!)


# using proj4:
# # create a matrix from columns X & Y and use project as in the question
# project(as.matrix(dataset[,c("X","Y")]), "+proj=utm +zone=51 ellps=WGS84")
# #             [,1]    [,2]
# # [1,]   -48636.65 1109577
# # [2,]   213372.05 5546301
# # ...
#project(as.matrix(locatDat[, c("x", "y")]), "+proj=utm +zone=39")

# using rgdal
library(rgdal)

# NB: presuming zone 39 was used, even though some of the Eastern side of 
# Socotra seems to fall into zone 40.  I think it's still possible to use 39 projection tho

# create spatial points object using coordinate reference system string UTM & zone specification
utmcoor <- SpatialPoints(cbind(locatDat$x, locatDat$y), proj4string=CRS("+proj=utm +zone=39"))
# transform coordinates to longitude, latitude (x, y)
longlatcoor <- spTransform(utmcoor, CRS("+proj=longlat"))
# bind longs and lats to the rest of the data
locatDat <- cbind(locatDat, longlatcoor)
# fix names of new columns
names(locatDat)[5]<- "Lon_dec"
names(locatDat)[6] <- "Lat_dec"
# show first six rows
head(locatDat)


# Precision info
# using {reshape2} package with colsplit() function...
# split into:
#       precision-size
#       location info source  

locatDat <- transform(
                locatDat, 
                precision=colsplit(
                        precision, 
                        pattern="; ", 
                        names=c("value", "source")
                        )
                )

head(locatDat)


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