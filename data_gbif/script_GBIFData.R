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

datA_algeria <- read.csv("O://CMEP\ Projects/IUCN-APSG/HabitatMapping_GBIFData/Algeria_Plantae_0002842-150922153815467/0002842-150922153815467.csv", header=TRUE, sep="\t", quote="", fill=TRUE, encoding="UTF-8", skipNul =TRUE)

datA_lebanon <- read.csv("O://CMEP\ Projects/IUCN-APSG/HabitatMapping_GBIFData/Lebanon_Plantae_0002841-150922153815467/0002841-150922153815467.csv", header=TRUE, sep="\t", quote="", fill=TRUE, encoding="UTF-8", skipNul =TRUE)

datA_morocco <- read.csv("O://CMEP\ Projects/IUCN-APSG/HabitatMapping_GBIFData/Morocco_Plantae_0002839-150922153815467/0002839-150922153815467.csv", header=TRUE, sep="\t", quote="", fill=TRUE, encoding="UTF-8", skipNul =TRUE)

