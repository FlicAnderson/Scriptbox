## Afghanistan :: script_mapGBIFoccData-juniperusExcelsa-AF.R
# ============================================================================ #
# 29 July 2015
# Author: Flic Anderson
#
# standalone script 
# saved at: O://CMEP\ Projects/Scriptbox/mapping/[script_mapGBIFoccData-juniperusExcelsa-AF.R
# source: source("O://CMEP\ Projects/Scriptbox/mapping/[script_mapGBIFoccData-juniperusExcelsa-AF.R")
#
# AIM:  Pull GBIF data out using Ropensci packages spocc & spoccutils 
# ....  for species Juniperus Excelsa
# ....  from Afghanistan
# ....  with coordinates
# ....  & map these!
#
# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) load libraries
# 1)  
# 2) 
# 3) 
# 4) 
# 5) 

# ---------------------------------------------------------------------------- #


# 0) load libraries

# install/load spocc package if required
if (!require(spocc)){
  install.packages("spocc")
  library(spocc)
} 

# install/load spocc package if required
if (!require(spoccutils)){
  install.packages("spoccutils")
  library(spoccutils)
}


# 1) set options

# get Afghanistan data only
gbifopts = list(country='AF')

# get data for species Juniperus excelsa
spp = "Juniperus excelsa"

# run query
datA <- occ(query=spp, from='gbif', has_coords=TRUE, gbifopts=gbifopts, limit=500)
datA

# create leaflet map
map_leaflet(datA, dest=".", centerview=c(35, 68), zoom=2, title="Map of Juniperus excelsa records in Afghanistan from GBIF")

# creat github gist map
map_gist(datA, description="Map of Juniperus excelsa records in Afghanistan from GBIF", public=TRUE, color='#3CB371', symbol='park')
# creates map gist: https://gist.github.com/FlicAnderson/b1b4b5d72144d3b2cdca 
# <gist>b1b4b5d72144d3b2cdca
# URL: https://gist.github.com/b1b4b5d72144d3b2cdca
# Description: Map of Juniperus excelsa records in Afghanistan from GBIF
# Public: TRUE
# Created/Edited: 2015-07-29T14:41:47Z / 2015-07-29T14:41:47Z
# Files: file239c78386279.geojson
# Truncated?: FALSE


