## IUCN Habitat Mapping Project :: script_GBIFData.R
# ==============================================================================
# (2nd October 2015)
# Author: Flic Anderson
#
# dependent on: 
# saved at: O://CMEP\ Projects/Scriptbox/data_gbif/script_GBIFData.R
# source: source("O://CMEP\ Projects/Scriptbox/data_gbif/script_GBIFData.R")
#
# AIM: Load and analyse GBIF downloaded exported data from website for project
# .... combine country data, remove any records without useful spatial data
# .... package for mapping in GIS etc.

# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) Load libraries, functions, source scripts
# 1) Load data
# 2) Subset data
# 3) Analyse data
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

# set working directory to avoid ungainly file location strings:
setwd("O://CMEP\ Projects/PROJECTS\ BY\ COUNTRY/GLOBAL/IUCN\ Habitat\ Mapping/HabitatMapping_GBIFData/")
fileLocat <- "O://CMEP\ Projects/PROJECTS\ BY\ COUNTRY/GLOBAL/IUCN\ Habitat\ Mapping/HabitatMapping_GBIFData/"

datA_algeria <- read.csv(
  file="Algeria_Plantae_0002842-150922153815467/0002842-150922153815467.csv", 
  header=TRUE, 
  sep="\t", 
  quote="", 
  fill=TRUE, 
  encoding="UTF-8", 
  skipNul=TRUE
  )
# 48403 obs x 42 var

datA_lebanon <- read.csv(
  file="Lebanon_Plantae_0002841-150922153815467/0002841-150922153815467.csv", 
  header=TRUE, 
  sep="\t", 
  quote="", 
  fill=TRUE, 
  encoding="UTF-8", 
  skipNul=TRUE
  )
# 11869 obs x 42 var

datA_morocco <- read.csv(
  file="Morocco_Plantae_0002839-150922153815467/0002839-150922153815467.csv", 
  header=TRUE, 
  sep="\t", 
  quote="", 
  fill=TRUE, 
  encoding="UTF-8", 
  skipNul=TRUE
  )
# 131056 obs x 42 var

datA_spain <- read.csv(
        file="Spain_0000543-151016162008034/0000543-151016162008034.csv", 
        header=TRUE, 
        sep="\t", 
        quote="", 
        fill=TRUE, 
        encoding="UTF-8", 
        skipNul=TRUE
)
# 2927728 obs x 42 var

datA_egypt <- read.csv(
        file="Egypt_0010477-151016162008034/0010477-151016162008034.csv", 
        header=TRUE, 
        sep="\t", 
        quote="", 
        fill=TRUE, 
        encoding="UTF-8", 
        skipNul=TRUE
)
# 6524 obs x 42 var

datA_tunisia <- read.csv(
        file="Tunisia_0010478-151016162008034/0010478-151016162008034.csv", 
        header=TRUE, 
        sep="\t", 
        quote="", 
        fill=TRUE, 
        encoding="UTF-8", 
        skipNul=TRUE
)
# 10194 obs x 42 var



# look at structure of data
str(datA_lebanon)

# make dplyr objects
datA_algeria <- tbl_df(datA_algeria)
datA_lebanon <- tbl_df(datA_lebanon)
datA_morocco <- tbl_df(datA_morocco)
datA_spain <- tbl_df(datA_spain)
datA_egypt <- tbl_df(datA_egypt)
datA_tunisia <- tbl_df(datA_tunisia)


# 2)

# for one set (Lebanon), pull apart & filter out irrelevant data:

# check out structure again
glimpse(datA_lebanon)

# # for instance: need to remove fossil data
#   table(datA_lebanon$basisofrecord)
#   # 47 fossil specimens
# 
# # need to remove NA lat/lons:
#   
#   # number of NA decimal latitudes:
#   nrow(datA_lebanon[which(is.na(datA_lebanon$decimallatitude)),])
#   #8708
# 
#   # number of NA decimal longitudes:
#   nrow(datA_lebanon[which(is.na(datA_lebanon$decimallongitude)),])
#   #8708
# 
# # need to remove "0" value lat/lons: 
#   
#   # number of "0" value latitudes:
#   nrow(datA_lebanon[which(datA_lebanon$decimallatitude==0),])
#   # 771
#   
#   # number of "0" value longitudes:
#   nrow(datA_lebanon[which(datA_lebanon$decimallongitude==0),])
#   # 771
  


# create filtered LEBANON dataset:
datA_lebanon_filtered <- 
  datA_lebanon %>%
    filter(basisofrecord != "FOSSIL_SPECIMEN") %>%
    filter(!is.na(decimallatitude)) %>%
    filter(!is.na(decimallongitude)) %>%
    filter(decimallatitude != 0) %>%
    filter(decimallongitude != 0) 
  
#glimpse(datA_lebanon_filtered)

# number of distinct taxa
length(unique(datA_lebanon_filtered$scientificname))
# 706

# percentage of usable records left:
round(nrow(datA_lebanon_filtered)/nrow(datA_lebanon)*100, digits=1)
# 20.1% :P

## write out as CSV for GIS stuff:
write.csv(
  datA_lebanon_filtered[
    order(
      datA_lebanon_filtered$scientificname, 
      datA_lebanon_filtered$basisofrecord, 
      na.last=TRUE),], 
  file=paste0(
    fileLocat, 
    "GBIF_lebanon_filtered_", 
    Sys.Date(), 
    ".csv"), 
  na="", 
  row.names=FALSE
)


# create filtered ALGERIA dataset:
datA_algeria_filtered <- 
  datA_algeria %>%
  filter(basisofrecord != "FOSSIL_SPECIMEN") %>%
  filter(!is.na(decimallatitude)) %>%
  filter(!is.na(decimallongitude)) %>%
  filter(decimallatitude != 0) %>%
  filter(decimallongitude != 0) 

#glimpse(datA_algeria_filtered)

# percentage of usable records left:
round(nrow(datA_algeria_filtered)/nrow(datA_algeria)*100, digits=1)
# 20.3% :P

## write out as CSV for GIS stuff:
write.csv(
  datA_algeria_filtered[
    order(
      datA_algeria_filtered$scientificname, 
      datA_algeria_filtered$basisofrecord, 
      na.last=TRUE),], 
  file=paste0(
    fileLocat, 
    "GBIF_algeria_filtered_", 
    Sys.Date(), 
    ".csv"), 
  na="", 
  row.names=FALSE
)


# create filtered MOROCCO dataset:
datA_morocco_filtered <- 
  datA_morocco %>%
  filter(basisofrecord != "FOSSIL_SPECIMEN") %>%
  filter(!is.na(decimallatitude)) %>%
  filter(!is.na(decimallongitude)) %>%
  filter(decimallatitude != 0) %>%
  filter(decimallongitude != 0) 

#glimpse(datA_morocco_filtered)

# percentage of usable records left:
round(nrow(datA_morocco_filtered)/nrow(datA_morocco)*100, digits=1)
# 48.6% :P

## write out as CSV for GIS stuff:
write.csv(
  datA_morocco_filtered[
    order(
      datA_morocco_filtered$scientificname, 
      datA_morocco_filtered$basisofrecord, 
      na.last=TRUE),], 
  file=paste0(
    fileLocat, 
    "GBIF_morocco_filtered_", 
    Sys.Date(), 
    ".csv"), 
  na="", 
  row.names=FALSE
)


# create filtered SPAIN (Andalucian region) dataset:
datA_spain_filtered <- 
        datA_spain %>%
        filter(basisofrecord != "FOSSIL_SPECIMEN") %>%
        filter(!is.na(decimallatitude)) %>%
        filter(!is.na(decimallongitude)) %>%
        filter(decimallatitude != 0) %>%
        filter(decimallongitude != 0) %>%
        filter(decimallatitude > 35.9) %>%
        filter(decimallatitude < 38.8) %>%
        filter(decimallongitude > -7.6) %>%
        filter(decimallongitude < -1.6) %>%
        filter(year > 2000)
               


#glimpse(datA_spain_filtered)

# percentage of usable records left:
round(nrow(datA_spain_filtered)/nrow(datA_spain)*100, digits=1)
# 99.9% :P

## write out as CSV for GIS stuff:
write.csv(
        datA_spain_filtered_[
                order(
                        datA_spain_filtered$scientificname, 
                        datA_spain_filtered$basisofrecord, 
                        na.last=TRUE),], 
        file=paste0(
                fileLocat, 
                "GBIF_spain_filtered_", 
                Sys.Date(), 
                ".csv"), 
        na="", 
        row.names=FALSE
)


# create filtered EGYPT dataset:
datA_egypt_filtered <- 
        datA_egypt %>%
        filter(basisofrecord != "FOSSIL_SPECIMEN") %>%
        filter(!is.na(decimallatitude)) %>%
        filter(!is.na(decimallongitude)) %>%
        filter(decimallatitude != 0) %>%
        filter(decimallongitude != 0) 

#glimpse(datA_egypt_filtered)

# percentage of usable records left:
round(nrow(datA_egypt_filtered)/nrow(datA_egypt)*100, digits=1)
# 96.9% :P

## write out as CSV for GIS stuff:
write.csv(
        datA_egypt_filtered[
                order(
                        datA_egypt_filtered$scientificname, 
                        datA_egypt_filtered$basisofrecord, 
                        na.last=TRUE),], 
        file=paste0(
                fileLocat, 
                "datA_egypt_filtered_", 
                Sys.Date(), 
                ".csv"), 
        na="", 
        row.names=FALSE
)


# create filtered TUNISIA dataset:
datA_tunisia_filtered <- 
        datA_tunisia %>%
        filter(basisofrecord != "FOSSIL_SPECIMEN") %>%
        filter(!is.na(decimallatitude)) %>%
        filter(!is.na(decimallongitude)) %>%
        filter(decimallatitude != 0) %>%
        filter(decimallongitude != 0) 

#glimpse(datA_tunisia_filtered)

# percentage of usable records left:
round(nrow(datA_tunisia_filtered)/nrow(datA_tunisia)*100, digits=1)
# 99.5% :P

## write out as CSV for GIS stuff:
write.csv(
        datA_egypt_filtered[
                order(
                        datA_tunisia_filtered$scientificname, 
                        datA_tunisia_filtered$basisofrecord, 
                        na.last=TRUE),], 
        file=paste0(
                fileLocat, 
                "datA_tunisia_filtered_", 
                Sys.Date(), 
                ".csv"), 
        na="", 
        row.names=FALSE
)



# check out http://rcastilho.pt/SDM101/SDM_files/Occurrence_data.R for land/sea point filtering and stuff
# check out http://hydrodictyon.eeb.uconn.edu/people/cmerow/home/r_resources_files/AMNH_R_Conference/Scripts/1_Matt_AielloLammens.R for anti-duplicates and such
# check out http://www.esapubs.org/archive/ecos/C004/004/Rcode.R for species name edits and such