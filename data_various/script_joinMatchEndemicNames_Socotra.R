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
# O://CMEP Projects/Socotra/EthnographicData2014/scoredAsEndemics_SPECIES-LIST/EndemicTaxaOnly_Socotra_*(sys.date)*.csv
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
if (!require(sqldf)){
        install.packages("sqldf")
        library(sqldf)
}


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

fileLocat <- "O://CMEP\ Projects/Socotra/EthnographicData_2014/scoredAsEndemics_SPECIES-LIST/"
#fileName <- "EndemicTaxaOnly_Socotra.csv"
fileName <- "EndemicTaxaOnly_Socotra_2016-12-09.csv"

endemics <- read.csv(file=paste0(fileLocat,fileName))

# confirm no duplicates
table(duplicated(endemics$species))
# None :)
# this is because endemics currently includes subspecies, which was creating the
# dups issue due to bad handling (the ssp/var field had been left off, causing dups)

# join endemics onto recgrab

names(endemics)
# > names(endemics)
# [1] "fullTax"      "endemicScore"

# remove space at end of endemics names

endemics$fullTax <- gsub("*( $)", "", as.character(endemics$fullTax))

names(recGrab)
# "acceptDetNoAuth" 
# 
# recGrab$acceptDetNoAuth == endemics$fullTax

# make new field in recGrab: endemicScore == 0
recGrab$endemicScore <- 0
#dim(recGrab)[2]
#[1] 33
# 33 is good (12Dec), endemicScore is new column on orig 32

# ensure that when endemics is joined that recGrab endemicScore is set to 1
# # create a testing set
# a <- recGrab[, c(7, 33)]
# a <- unique(a)
# a <- a[780:800,]
# 
# i <- 1
# for(i in 1:nrow(a)){
#       if (as.character(a$acceptDetNoAuth)[i] %in% as.character(endemics$fullTax)) {
#        a$endemicScore[i] <- 1
#       } 
# }

# loop to tag endemicScores to 1 for taxa in endemic list
i <- 1
for(i in 1:nrow(recGrab)){
        if (as.character(recGrab$acceptDetNoAuth)[i] %in% as.character(endemics$fullTax)) {
                recGrab$endemicScore[i] <- 1
        } 
}

table(recGrab$endemicScore)
# this worked

# consider which endemics AREN'T in here...
a <- as.character(unique(endemics$fullTax))
aa <- as.character(unique(recGrab$acceptDetNoAuth))
# find species in endemics list which aren't matched to recGrab
a[which(a %in% aa == FALSE)]
# [1] "Asparagus africanus var. microcarpus"         "Chlorophytum sp. nov."                       
# [3] "Ischaemum sp. A"                              "Acacia pennivenia"                           
# [5] "Acacia sp. A"                                 "Indigofera socotrana"                        
# [7] "Begonia semhaensis"                           "Maytenus sp. nov. A"                         
# [9] "Erythroxylon socotranum"                      "Andrachne schweinfurthii var. papillosa"     
# [11] "Andrachne schweinfurthii var. schweinfurthii" "Tragia balfouriana"                          
# [13] "Hypericum socotranum subsp. smithii"          "Hypericum socotranum subsp. socotranum"      
# [15] "Boswellia sp. B"                              "Commiphora socotrana"                        
# [17] "Rhus sp. A"                                   "Rhus thyrsiflora"                            
# [19] "Maerua angolensis var. socotrana"             "Hemicrambe townsendii"                       
# [21] "Nesocrambe socotrana"                         "Polycarpaea spicata var. capillaris"         
# [23] "Portulaca sedifolia"                          "Gaillonia puberula"                          
# [25] "Gaillonia putorioides"                        "Gaillonia thymoides"                         
# [27] "Gaillonia tinctoria"                          "Placopoda virgata"                           
# [29] "Adenium obesum subsp. sokotranum"             "Cryptolepis sp. nov."                        
# [31] "Heliotropium aff. socotranum"                 "Heliotropium derafontense"                   
# [33] "Heliotropium socotranum"                      "Seddera fastigiata"                          
# [35] "Seddera semhahensis"                          "Seddera spinosa"                             
# [37] "Jasminum fluminense subsp. socotranum"        "Leucas spiculifera"                          
# [39] "Micromeria remota"                            "Dicoma cana"                                 
# [41] "Helichrysum socotranum"                       "Prenanthes amabilis"                         
# [43] "Rughidia cordatum"



########## TO DO!!!!##########




# writeout resulting records

#fileLocat <- "O://CMEP\ Projects/Socotra/EthnographicData2014/scoredAsEndemics_SPECIES-LIST/"
#fileName <- "EndemicTaxa_Socotra.csv"
#write.csv(file=paste0(fileLocat,fileName,Sys.Date(),".csv"))