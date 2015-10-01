## IUCN Habitat Mapping Project :: script_IUCNRedListData.R
# ==============================================================================
# (1st October 2015)
# Author: Flic Anderson
#
# dependent on: 
# saved at: O://CMEP\ Projects/Scriptbox/data_redlist/script_IUCNRedListData.R
# source: source("O://CMEP\ Projects/Scriptbox/data_redlist/script_IUCNRedListData.R")
#
# AIM: Load and analyse IUCN Red List exported data from website for project
# .... List taxa, show latest IUCN thing, do various bits of analysis. 
# .... Replaces "O://CMEP\-Projects/Scriptbox/general_utilities/script_IUCNData.R"
# .... Then maybe save as CSV file (.csv) for future use?

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

# data location
datLocat <- "O://CMEP\ Projects/IUCN-APSG/Red\ List/IUCN-RedlistData_AlgeriaMoroccoLebanon_Plantae_incSspsVars_native_uncertain/export-64526.csv"

# read data
datA <- read.csv(datLocat, header=TRUE)
#str(datA)

# create tbl_df using dplyr
datA <- tbl_df(datA)
datA


# 2)

# select out useful columns
