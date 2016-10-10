## Afghanistan Projects :: script_mergeGBIF-KUFSrecords_Afghanistan.R
# ==============================================================================
# (10th October 2016)
# Author: Flic Anderson
#
# dependent on: 
#       O://CMEP\ Projects/Scriptbox/data_various/script_KUFSrecords.R
#       O://CMEP\ Projects/Scriptbox/data_gbif/script_GBIFData.R
# saved at: O://CMEP\ Projects/Scriptbox/data_various/script_mergeGBIF-KUFSrecords_Afghanistan.R
# source: source("O://CMEP\ Projects/Scriptbox/data_various/script_mergeGBIF-KUFSrecords_Afghanistan.R")
#
# AIM: Load KUFS herbarium records & GBIF Afghan plant records for Afghanistan
# .... projects; remove any records without useful spatial data, package for 
# .... analysis & mapping in GIS/R and other uses.

# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) Load libraries, functions, source scripts
# 1) Load data
# 2) MERGE data
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

# load other packages, functions, scripts
# ?

# 1)

