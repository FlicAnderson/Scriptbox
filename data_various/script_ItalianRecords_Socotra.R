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
# {tidyr} - further data manipulation
if (!require(tidyr)){
        install.packages("tidyr")
        library(tidyr)
}
# {sqldf} - SQL operations on R data frames
if (!require(sqldf)){
        install.packages("sqldf")
        library(sqldf)
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
#head(datA_SocITA[,1:10])

# look at structure of a little of the data
#str(datA_SocITA)
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

# change the names of info.precision and info.source to avoid sqldf problems with the dots later
colnames(locatDat)[which(names(locatDat) == "info.precision")] <- "info_precision"
colnames(locatDat)[which(names(locatDat) == "info.source")] <- "info_source"


# tidy up
rm(info)

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
rm(utmcoor, longlatcoor, xCoords, yCoords)

# {dplyr} function rename() 
# rename(tbl_dfData, newColumnName=oldColumnName)
#rename(locatDat, Lon_dec=coords.x1)
#rename(locatDat, Lat_dec=coords.x2)
# BUT this doesn't work unless the data is already a tbl_df & the newname=oldname order is odd

# show first six rows
#head(locatDat)

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
# separate Direction off Degrees
DMSLon$Lon_dir <- gsub(pattern="[0-9]", replacement="", DMSLon$Lon_deg)
DMSLon$Lon_deg <- gsub(pattern="[A-Z]", replacement="", DMSLon$Lon_deg)


# split Latitude D, M & S
DMSLat=colsplit(
        DMSoutput$dms.lat,
        pattern=":", 
        names=c("Lat_deg", "Lat_min", "Lat_sec")
)
# separate Direction off Degrees
DMSLat$Lat_dir <- gsub(pattern="[0-9]", replacement="", DMSLat$Lat_deg)
DMSLat$Lat_deg <- gsub(pattern="[A-Z]", replacement="", DMSLat$Lat_deg)



# join new DMS format onto locatDat
locatDat <- cbind(locatDat, DMSLon, DMSLat)
# rearrange the columns into this order: 
# NOTE: LATITUDE THEN LONGITUDE NOW!! y then x. BE AWARE!
locatDat <- locatDat[,c("relvNum", "y", "x", "Lat_dir", "Lat_deg", "Lat_min", "Lat_sec", "Lat_dec", "Lon_dir", "Lon_deg", "Lon_min", "Lon_sec", "Lon_dec", "info_precision", "info_source")]

#head(locatDat)



# 4) Show the output

# filter out missing co-ords probably => filtered_SocITA

# create tbl_df object to use dplyr for filtering and manipulation
locatDat <- tbl_df(locatDat)
# 396 obs x 15 var

# # pull all zerolat/lons into one object to investigate later
# zeroGeorefLocatDat <- 
#         locatDat %>%
#         filter(y == 0 | x == 0)
# # Odd thing: for some reason, even when x and y are 0, DMS is non-0 (eg 46E). 
# # *shrugs* Maths :P

# remove "0" lat/lons etc
locatDat <- 
        locatDat %>%
                filter(y != 0 & x != 0)
# goes down to 382 obs x 15 var

# Error hunting...

# map it out!
leaflet() %>%
# use default OpenStreetMap tiles
        addTiles() %>%  
        # add decimal degrees points (filtered ones with no zero-lat/lon)
        addMarkers(lng=locatDat$Lon_dec, lat=locatDat$Lat_dec) %>%
        print

# use table to find wildly out of range points
table(locatDat$Lat_deg)
# 1  12   6 
# 3 378   1 
# 1 and 6 degrees N are not useful!

table(locatDat$Lon_deg)
# 53  54  59 
# 182 196   4 
# 59 degrees E is in the sea!

# pull out dodgy records with these
locatDat[which(locatDat$Lat_deg==1),]
locatDat[which(locatDat$Lat_deg==6),]
# releve numbers with BADLATS:
# 165, 166, 296 
locatDat[which(locatDat$Lon_deg==59),]
# releve numbers with BADLONS:
# 165, 166, 207, 229

# Blacklist those 4 bad georef releves:
filtered_SocITA <- 
        locatDat %>%
        filter(relvNum !=165, relvNum !=166, relvNum !=207, relvNum !=229)
# this filter isn't elegant :c  but it's a hassle to get the logic alright otherwise
# 378 obs x 15 var
 
# map out filtered data to doublecheck!
leaflet() %>%
        # use default OpenStreetMap tiles
        addTiles() %>%  
        # add decimal degrees points (filtered ones with no zero-lat/lon)
        addMarkers(lng=filtered_SocITA$Lon_dec, lat=filtered_SocITA$Lat_dec) %>%
        print

# tidy up
rm(DMSLat, DMSLon, DMSoutput)


# deal with species names
        # latinnamesmatcher.r

# source latinNamesMatcher function (Note: NOT script_latinNamesMatcher.R!)
source("O:/CMEP\ Projects/Scriptbox/database_importing/function_latinNamesMatcher.R")

# Call format:
# latinNamesMatcher(rowIndex, colIndexSp, colIndexSsp, colIndexAuth, "oneWordDescription", ...)
# help:
        # rowIndex contains vertical range of rows to pull in and check (where species names are held)
        # colIndexSp holds species names (sp)
        # colIndexSsp holds subspecific names (ssp)
                # NOTE: if there are NO subspecific epithets, enter same column as species names
                # NOTE: if you are unsure, enter same column as species names
        # colIndexAuth holds authorities (auth)
                # NOTE: if there is NO authority information, enter: 0
        # oneWordDescription should be a string with no spaces
                # NOTE: underscores are ok, make description useful (eg. "SocotraVegSurvey_2008")

# check scientific names
latinNamesMatcher(4:485,2, 2, 0, "SocITA")

# dodgy names
badNames <- c(
        "Olea hochstetteri",     
                # African taxon - not in Ethnoflora, Padme, or Brown/Mies Socotra book
        "Urochloa deflexa",      
                # Species (& indeed that GENUS) not in Ethnoflora or Brown/Mies
        "Hypoestes sokotrana",   
                # Not in Ethnoflora or Brown/Mies, Padme has it (H. socotrana[sic]) as syn of H. pubescens Balf.f.
        "Setaria adhaerens",     
                # PROBABLY should be "Setaria verticillata" according to Flora of the Arabian Peninsula and Socotra Vol 5 pt 1, pg 221. This taxon name ("Setaria adhaerens") not found in Ethnoflora, Padme, or Brown/Mies Socotra book
        "0"
                # probably a typo which erased the actual name...
)

# blacklist badNames
# filtered ....
# TO DO

# deal with 1/0 presence data and link to locatDat
        # join to locatDat then filter out 0/bad latlons again & badNames to write out

# create species dataset
spsDat <- data.frame(datA_SocITA[6:nrow(datA_SocITA),2:ncol(datA_SocITA)])

# rename fields
names(spsDat)[1] <- "taxon"
names(spsDat)[2:ncol(spsDat)] <- relvNum
#names(spsDat)[1:10]
#names(spsDat)

# create longform dataset

# gather presence values into one column
spsDat <- spsDat %>%
        # gather releve numbers into a column (releveNum) 
                # create presence column (presence) 
                        # don't gather taxon names (- taxon)
                                # leave NA values in
        gather(releveNum, presence, -taxon, na.rm=FALSE)

head(spsDat)

# how many records absence, how many presence
table(spsDat$presence)
# NA       1 
# 182458 7226


# convert to tbl_df
spsDat <- tbl_df(spsDat)

# only present taxa
spsDat <- 
        spsDat %>%
                filter(presence==1)



# join releve locations onto the sps data
totalDat <- 
        sqldf(
                "SELECT 
                        taxon, 
                        presence, 
                        releveNum, 
                        y AS Northing_UTM39WGS84, 
                        x AS Easting_UTM39WGS84, 
                        Lat_dir, 
                        Lat_deg, 
                        Lat_min, 
                        Lat_sec, 
                        Lat_dec, 
                        Lon_dir, 
                        Lon_deg, 
                        Lon_min, 
                        Lon_sec, 
                        Lon_dec, 
                        info_precision, 
                        info_source 
                FROM spsDat 
                LEFT JOIN locatDat 
                        ON spsDat.releveNum = locatDat.relvNum"
        )
# 7226 obs x 17 var (07/01/2016)

# view a chunk (10 x 10)
totalDat[2000:2010,1:10]

# filter totalDat to avoid badNames and badLatLons
# Blacklist those 4 bad georef releves:
filtered_SocITA <- 
        totalDat %>%
                filter(
                        Northing_UTM39WGS84 != 0, # no zero
                        Easting_UTM39WGS84 != 0,  # no zero
                        releveNum != 165,  # exclude bad latlons
                        releveNum != 166,  # "
                        releveNum != 207,  # "
                        releveNum != 229,  # "
                        taxon != "Olea hochstetteri",  # remove uncertain taxa
                        taxon != "Urochloa deflexa",    # "
                        taxon != "Hypoestes sokotrana", # " 
                        taxon != "Setaria adhaerens",   # "
                        taxon != "0"                    # this taxon has NO NAME :P
                )
# this filter isn't elegant :c  but it's a hassle to get the logic alright otherwise
# 6893 obs x 17 var



# 5) write out

# # write this out to CSV
# write.csv(
#         filtered_SocITA,
#         #file=file.choose(),
#         file=paste0(
#                 fileLocat, 
#                 "locationData_SocITA_filtered", 
#                 Sys.Date(), 
#                 ".csv"), 
#         na="", 
#         row.names=FALSE
# )


# check out http://rcastilho.pt/SDM101/SDM_files/Occurrence_data.R for land/sea point filtering and stuff
# check out http://hydrodictyon.eeb.uconn.edu/people/cmerow/home/r_resources_files/AMNH_R_Conference/Scripts/1_Matt_AielloLammens.R for anti-duplicates and such
# check out http://www.esapubs.org/archive/ecos/C004/004/Rcode.R for species name edits and such