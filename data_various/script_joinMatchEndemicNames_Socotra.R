## Socotra Project :: script_joinMatchEndemicNames_Socotra.R
# ============================================================================ #
# 05 December 2016
# Author: Flic Anderson
#
# dependant on: script_dataGrabFullLatLonOrGazLatLon_Socotra.R; script_endemicAnnotationsPadme.R
# saved at: O://CMEP\-Projects/Scriptbox/data_various/script_joinMatchEndemicNames_Socotra.R
# source("O://CMEP\ Projects/Scriptbox/data_various/script_joinMatchEndemicNames_Socotra.R")
#
# AIM:  Join Ethnoflora endemism scored data (scored by Anna) for Socotra to 
# ....  the Socotra dataset on names; where names do not match, apply a 
# ....  taxonomic fix as necessary.
#
# ---------------------------------------------------------------------------- #

# "Here are the taxa scored by Anna last year as Endemic from the Ethnoflora.  
# There seem to be 314 endemic taxa. 
# The column endemicScore shows 1 for all endemic taxa, and 0 for non-endemic.  
# 
# The file is at 
# O://CMEP Projects/Socotra/EthnographicData2014/scoredAsEndemics_SPECIES-LIST/EndemicTaxa_Socotra.csv
# (Created using script_endemicAnnotationsPadme.R)"

# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) load libraries and source scripts
# 1) read in csv file of endemic taxa
# 2) attempt join of endemism data on Socotra analysis dataset
# 3) pull out non-joining taxa
# 4) apply fixes for non-joining taxa
# 5) perform main join with fixes
# 6) output joined data if required
# 7) tidy up

# ---------------------------------------------------------------------------- #


# 0) load libraries and source scripts

# load any required libraries?
# {dplyr} - manipulating data & large data frames as tbl_df objects
if (!require(dplyr)){
        install.packages("dplyr")
        library(dplyr)
}

fileLocat <- "O://CMEP\ Projects/Socotra/EthnographicData2014/scoredAsEndemics_SPECIES-LIST/"
fileName <- "EndemicTaxa_Socotra.csv"

read.csv(file=paste0(fileLocat,fileName))

# source main socotra dataset
source("O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R")

# # REMOVE NEEDLESS OBJECTS FROM WORKSPACE!
#         # removes EVERYTHING EXCEPT WHAT YOU WANT TO KEEP 
#         # (eg. Keeps: connections, recGrab, etc):
rm(list=setdiff(ls(), 
                c(
                        "recGrab", 
                        "taxaListSocotra",
                        "con_livePadmeArabia", 
                        "livePadmeArabiaCon"
                )
)
)

# is recGrab object here?
# problems with datagrab script if it doesn't 
# (troubleshoot 1st: check FielRexTemp table exists in Padme
if(!exists("recGrab")){stop()}

#"O://CMEP\ Projects/Socotra/analysisTaxaListSocotra_Checklist_2016-12-05.csv"







# writeout

#fileLocat <- "O://CMEP\ Projects/Socotra/EthnographicData2014/scoredAsEndemics_SPECIES-LIST/"
#fileName <- "EndemicTaxa_Socotra.csv"
#write.csv(file=paste0(fileLocat,fileName,Sys.Date(),".csv"))