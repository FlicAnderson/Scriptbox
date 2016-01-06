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
# 3) Change coordinate system
# 4) Filter out non-useful records (those without coordinates)
# 5) Show the output
# 6) Save the output to .csv

# ---------------------------------------------------------------------------- #



# 0) 

# load required packages, install if they aren't installed already

# {dplyr} - manipulating data & large data frames as tbl_df objects
if (!require(dplyr)){
  install.packages("dplyr")
  library(dplyr)
}
# {rgdal} - easy methods for converting UTM to DMS
if (!require(rgdal)){
        install.packages("rgdal")
        library(rgdal)
}
# {reshape} - allows columns to be split up easily and data to be wrangled
if (!require(reshape2)){
        install.packages("reshape2")
        library(reshape2)
}
# {leaflet} - for mapping things out nicely
if (!require(leaflet)){
        install.packages("leaflet")
        library(leaflet)
}
# {magrittr} - gives the chaining operator %>%
if (!require(magrittr)){
        install.packages("magrittr")
        library(magrittr)
}



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

#import csv
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
# 484 obs x 398 var

# show a little of the data
head(datA_SocITA[,1:10])

# look at structure of a little of the data
str(datA_SocITA)
# (it's all sideways and messed up...)



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

info <- datA_SocITA[4,3:ncol(datA_SocITA)]  # precision info (rm 1st 2 junkCols)
info <- as.vector(info, mode="character")

# put everything together in one dataframe that's set out nicely:
# AND split precision info into:
#       precision-value
#       location info source     
# using {reshape2} package with colsplit() function...

locatDat <- data.frame(
        relvNum=relvNum, 
        x=xCoords, 
        y=yCoords, 
        info=colsplit(
                info,
                pattern="; ", 
                names=c("precision", "source")
        )
)

# tidy up
#rm(info)

# 3) Change the coordinate system

## CONVERT UTM Eastings and Northings to Lat & Lon DMS!

# Zones 39 or 40...
# Northern Hemisphere
# X = Eastings
# Y = Northings

# NB: presuming zone 39 was used, even though some of the Eastern side of 
# Socotra seems to fall into zone 40.  
# Tried all this with zone 40 & not a single point was on land. Definitely zone 39.


# using rgdal package (tried {proj4} but it wasn't easy to use)
# create spatial points object using coordinate reference system string UTM & zone specification
utmcoor <- SpatialPoints(cbind(locatDat$x, locatDat$y), proj4string=CRS("+proj=utm +zone=39"))
# transform coordinates to longitude, latitude (x, y)
longlatcoor <- spTransform(utmcoor, CRS("+proj=longlat"))
# bind longs and lats to the rest of the data
locatDat <- cbind(locatDat, longlatcoor)
# fix names of new columns
# {base R} version:
#colnames(dataframe)[which(names(dataframe) == "oldColumnName")] <- "newColumnName"
colnames(locatDat)[which(names(locatDat) == "coords.x1")] <- "Lon_dec"
colnames(locatDat)[which(names(locatDat) == "coords.x2")] <- "Lat_dec"
# Note: this version is better than:
# names(data)[3] <- newname or whatever, 
# since order changes cause breakage

# tidy up
# rm(utmcoor, longlatcoor, xCoords, yCoords)

# {dplyr} function rename() 
# rename(tbl_dfData, newColumnName=oldColumnName)
#rename(locatDat, Lon_dec=coords.x1)
#rename(locatDat, Lat_dec=coords.x2)
# BUT this doesn't work unless the data is already a tbl_df & the newname=oldname order is odd

# show first six rows
head(locatDat)

# add Lat Deg/Min/Sec/Dir & Lon... etc columns for ease at import stage
# use edited script developed by Daniela Cianci at http://www.edenextdata.com
        # NOTE: data needs to work with this line for script to work:
        #coord<-data.frame(latitude=locatDat$Lat_dec, longitude=locatDat$Lon_dec)
source("O://CMEP\ Projects/Scriptbox/data_various/script_deg_to_dms.R")

# split Longitude D, M & S
DMSLon=colsplit(
        DMSoutput$dms.lon,
        pattern=":", 
        names=c("Lon_deg", "Lon_min", "Lon_sec")
)

# split Latitude D, M & S
DMSLat=colsplit(
        DMSoutput$dms.lat,
        pattern=":", 
        names=c("Lat_deg", "Lat_min", "Lat_sec")
)

# join new DMS format onto locatDat
locatDat <- cbind(locatDat, DMSLon, DMSLat)
# rearrange the columns into this order: 
# NOTE: LATITUDE THEN LONGITUDE NOW!! y then x. BE AWARE!
locatDat <- locatDat[,c("relvNum", "y", "x", "Lat_deg", "Lat_min", "Lat_sec", "Lat_dec", "Lon_deg", "Lon_min", "Lon_sec", "Lon_dec", "info.precision", "info.source")]

head(locatDat)



# 4) Show the output

# filter out missing co-ords probably => filtered_SocITA

# create tbl_df object to use dplyr for filtering and manipulation
locatDat <- tbl_df(locatDat)

# remove "0" lat/lons etc
filtered_SocITA <- 
        locatDat %>%
                filter(y != 0 & x != 0)

# temp
locatDat <- 
        locatDat %>%
        filter(y != 0 & x != 0)

# pull all zerolat/lons into one object to investigate later
zeroGeorefLocatDat <- 
        locatDat %>%
                filter(y == 0 | x == 0)
  # Odd thing: for some reason, even when x and y are 0, DMS is non-0 (eg 46E). 
  # *shrugs* Maths :P


# Error hunting...


# map it out!

mapDat <- leaflet() %>%
        # use default OpenStreetMap tiles
        addTiles() %>%  
        # add decimal degrees points (filtered ones with no zero-lat/lon)
        addMarkers(lng=filtered_SocITA$Lon_dec, lat=filtered_SocITA$Lat_dec) %>%
        print






# 5) write out

# # write this out to CSV
# write.csv(
#         filtered_datA_SocITA,
#         file=file.choose(),
#         na="", 
#         row.names=FALSE
# )


# check out http://rcastilho.pt/SDM101/SDM_files/Occurrence_data.R for land/sea point filtering and stuff
# check out http://hydrodictyon.eeb.uconn.edu/people/cmerow/home/r_resources_files/AMNH_R_Conference/Scripts/1_Matt_AielloLammens.R for anti-duplicates and such
# check out http://www.esapubs.org/archive/ecos/C004/004/Rcode.R for species name edits and such