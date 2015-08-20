## Socotra Project :: script_IUCNData.R
# ============================================================================ #
# 20 August 2015
# Author: Flic Anderson
#
# standalone script // dependant on: [filename]
# saved at: O://CMEP\-Projects/Scriptbox/general_utilities/script_IUCNData.R
# source: source("O://CMEP\-Projects/Scriptbox/general_utilities/script_IUCNData.R")
#
# AIM:  Link IUCN Red List categories and data exported from IUCN website
# ....  to local records and data for further analysis.
#
# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) load packages
# 1) load IUCN data 
# 2) link latin names?!
# 3) ???

# ---------------------------------------------------------------------------- #


# 0)

# load required packages, install if they aren't installed already

# {dplyr} - manipulating large data frames as tbl_df objects
if (!require(dplyr)){
        install.packages("dplyr")
        library(dplyr)
}



# 1) 

# load the IUCN data

IUCN <- read.csv(file="O://CMEP\ Projects/Socotra/IUCN-Redlist/export-62975.csv", header=TRUE) 

str(IUCN)

tail(IUCN[, c(7,8,9, 18, 19)])

names(IUCN)
# [1] "Species.ID"                "Kingdom"                   "Phylum"                   
# [4] "Class"                     "Order"                     "Family"                   
# [7] "Genus"                     "Species"                   "Authority"                
# [10] "Infraspecific.rank"        "Infraspecific.name"        "Infraspecific.authority"  
# [13] "Stock.subpopulation"       "Synonyms"                  "Common.names..Eng."       
# [16] "Common.names..Fre."        "Common.names..Spa."        "Red.List.status"          
# [19] "Red.List.criteria"         "Red.List.criteria.version" "Year.assessed"            
# [22] "Population.trend"          "Petitioned"  


# 2)

# link latin names
