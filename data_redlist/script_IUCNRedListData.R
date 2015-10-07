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
datLocat <- "O://CMEP\ Projects/PROJECTS\ BY\ COUNTRY/GLOBAL/IUCN\ Habitat\ Mapping/Red\ List/IUCN-RedlistData_AlgeriaMoroccoLebanon_Plantae_incSspsVars_native_uncertain/export-64526.csv"

# read data
datA <- read.csv(datLocat, header=TRUE)
#str(datA)

# create tbl_df using dplyr
datA <- tbl_df(datA)
datA
#glimpse(datA)


# 2)

# select out useful columns

# check out current columns
names(datA)
# [1] "Species.ID"                "Kingdom"                   "Phylum"                   
# [4] "Class"                     "Order"                     "Family"                   
# [7] "Genus"                     "Species"                   "Authority"                
# [10] "Infraspecific.rank"        "Infraspecific.name"        "Infraspecific.authority"  
# [13] "Stock.subpopulation"       "Synonyms"                  "Common.names..Eng."       
# [16] "Common.names..Fre."        "Common.names..Spa."        "Red.List.status"          
# [19] "Red.List.criteria"         "Red.List.criteria.version" "Year.assessed"            
# [22] "Population.trend"          "Petitioned"

# break down by class
table(datA$Class)
# EQUISETOPSIDA     GNETOPSIDA    ISOETOPSIDA     LILIOPSIDA  MAGNOLIOPSIDA      PINOPSIDA POLYPODIOPSIDA 
#       3              7              5            256            128             12              4 

# if necessary to split spermatophytes/ferns&below apart:
#spermatophytes <- c("LILIOPSIDA", "MAGNOLIOPSIDA", "GNETOPSIDA", "PINOPSIDA")
#fernsEtc <- c("EQUISETOPSIDA", "ISOETOPSIDA", "POLYPODIOPSIDA")

# pull out last assessment for each species
lastAssessed <- 
datA %>%
  # group by species ID 
  group_by(Species.ID) %>%
  # show summary (grouped by species.ID) 
  summarise(
    # taxa is combo of various name fields
    taxon=paste(Genus, Species, Infraspecific.name, Family, sep=" "), 
    # latest is most recent assessement date
    latest=max(Year.assessed)
  ) %>%
  # arrange ascending by taxon
  arrange(taxon) %>%
  print


# 3) 

# pull out species names for 3 threatened categories:
threatenedTaxa <- 
        datA %>%
                group_by(Species.ID) %>%
                filter(Red.List.status=="CR"|Red.List.status=="EN"|Red.List.status=="VU") %>%
                summarise(
                        # taxa is combo of various name fields (trimmed whitespace out)
                        taxon=trimws(paste(Genus, Species, Infraspecific.name, sep=" "))
                ) %>%
                arrange(taxon) %>%
                print


# 4)

# show results


# 5) 

# save output
write.csv(
        threatenedTaxa, 
        file=paste0("O://CMEP\ Projects/PROJECTS\ BY\ COUNTRY/GLOBAL/IUCN\ Habitat\ Mapping/Red\ List/", "IUCNthreatenedTaxa_AlgeriaMoroccoLebanon.csv"), 
        na="", 
        row.names=FALSE
)
  