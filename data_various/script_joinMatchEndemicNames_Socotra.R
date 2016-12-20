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
# ....  taxonomic fix as necessary. Run after script_editTaxa_Socotra.R (which 
# ....  runs after script_dataGrabFullLatLonOrGazLatLon_Socotra.R)
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
nonMatchNames <- a[which(a %in% aa == FALSE)]
# [1] "Asparagus africanus var. microcarpus"         "Chlorophytum sp. nov."                       
# [3] "Ischaemum sp. A"                              "Acacia pennivenia"                           
# [5] "Acacia sp. A"                                 "Indigofera socotrana"                        
# [7] "Begonia semhaensis"                           "Maytenus sp. nov. A"                         
# [9] "Erythroxylon socotranum"                      "Andrachne schweinfurthii var. papillosa"     
# [11] "Andrachne schweinfurthii var. schweinfurthii" "Tragia balfouriana"                          
# [13] "Hypericum socotranum subsp. smithii"          "Hypericum socotranum subsp. socotranum"      
# [15] "Boswellia sp. B"                              "Commiphora socotrana"                        
# [17] "Rhus sp. A"                                   "Rhus thyrsiflora"                            
# [19] "Maerua angolensis var. socotrana" = 1            "Hemicrambe townsendii"    
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

source("O://CMEP\ Projects/Scriptbox/general_utilities/function_padmeNameMatch.R")

# # used this loop to find the matches/non-matches: uncomment & re-run to verify matches
# i <- 1
# for(i in 1:length(nonMatchNames)){
#        padmeNameMatch(checkMe=nonMatchNames[i], taxonType="species", authorityPresent=FALSE, taxonSingle=TRUE, chattyReturn=TRUE)
# }
## used output of padmeNameMatch() function from above loop to create fixes for 
## each non-matching name, made into vector nonMatchFix.

nonMatchFix <- c(
        "Asparagus africanus",
        "Chlorophytum sp. nov. A", 
        "Ischaemum sp. A",
        "Vachellia pennivenia",
        "Vachellia sp. A",
        "Indigofera sokotrana",
        "Begonia samhaensis",
        "Maytenus sp. A",
        "Erythroxylum socotranum",
        "Andrachne schweinfurthii",
        "Andrachne schweinfurthii",
        "Tragia balfourii",
        "Hypericum socotranum",
        "Hypericum socotranum",
        "Boswellia bullata",
        "Commiphora socotrana",
        "Searsia sp. A",
        "Searsia thyrsiflora",
        "Maerua angolensis",
        "Hemicrambe fruticosa",
        "Hemicrambe socotrana",
        "Polycarpaea sp. nov.",
        "Portulaca monanthoides",
        "Plocama puberula",
        "Plocama putorioides",
        "Plocama thymoides",
        "Plocama tinctoria",
        "Dirichletia virgata",
        "Adenium obesum",
        "Cryptolepis sp. nov. A",                       
        "Heliotropium aff. sokotranum",
        "Heliotropium shoabense",                   
        "Heliotropium sokotranum",
        "Convolvulus socotrana",
        "Convolvulus semhaensis",
        "Convolvulus kossmatii",
        "Jasminum fluminense",
        "Leucas spiculifolia",                          
        "Micromeria imbricata",
        "Macledium canum",                                 
        "Helichrysum sp. B",
        "Erythroseris amabilis",
        "Rughidia cordata"
        )


##### detailed namefix info:
# "Asparagus africanus var. microcarpus" <-  "Asparagus africanus" # all on Socotra are endemic var
# "Chlorophytum sp. nov." <- "Chlorophytum sp. nov. A" 
# "Ischaemum sp. A" #- matches in Padme Arabia. Fix
# "Acacia pennivenia" <- "Vachellia pennivenia"
# "Acacia sp. A" <- "Vachellia sp. A"
# "Indigofera socotrana" <- "Indigofera sokotrana"
# "Begonia semhaensis" <- "Begonia samhaensis"
# "Maytenus sp. nov. A" <- "Maytenus sp. A"
# "Erythroxylon socotranum" <- "Erythroxylum socotranum"
# "Andrachne schweinfurthii var. papillosa" <- "Andrachne schweinfurthii" #all subsps endemic
# "Andrachne schweinfurthii var. schweinfurthii" <- "Andrachne schweinfurthii" #all subsps endemic
# "Tragia balfouriana" <- "Tragia balfourii"
# "Hypericum socotranum subsp. smithii" <- "Hypericum socotranum" #all subsps endemic
# "Hypericum socotranum subsp. socotranum" <- "Hypericum socotranum" #all subsps endemic
# "Boswellia sp. B" <- "Boswellia bullata"
# # "Commiphora socotrana" # ain't in the recGrab list, tho legit name match.
# "Rhus sp. A" <- # not same sp-concept as Rhus sp. nov.; avoid conflating; should be Searsia sp. A due to taxonomy changes.
# "Rhus thyrsiflora" <- "Searsia thyrsiflora" # taxonomic change
# "Maerua angolensis var. socotrana" <- "Maerua angolensis" # =endemic as all Socotran Maerua records refer to the endemic variety, so we're scoring all as Maerua angolensis & endemic
# "Hemicrambe townsendii" <- "Hemicrambe fruticosa" # syn.
# "Nesocrambe socotrana" <- "Hemicrambe socotrana" # syn. 
# "Polycarpaea spicata var. capillaris" <- "Polycarpaea sp. nov." # endmic var
# "Portulaca sedifolia" <- "Portulaca monanthoides" # taxonomic change
# "Gaillonia puberula" <- "Plocama puberula" # taxonomic change
# "Gaillonia putorioides" <- "Plocama putorioides" # taxonomic change
# "Gaillonia thymoides" <- "Plocama thymoides" # taxonomic change
# "Gaillonia tinctoria" <- "Plocama tinctoria" # taxonomic change
# "Placopoda virgata" <- "Dirichletia virgata" # taxonomic change
# "Adenium obesum subsp. sokotranum" <- "Adenium obesum" #subsps ignored.
# "Cryptolepis sp. nov." <- "Cryptolepis sp. nov. A"                       
# "Heliotropium aff. socotranum" <- "Heliotropium aff. sokotranum" # orthog. variant
# "Heliotropium derafontense" <- "Heliotropium shoabense"                   
# "Heliotropium socotranum" <- "Heliotropium sokotranum" # orthog. variant
# "Seddera fastigiata" <- "Convolvulus socotrana" # taxonomic change
# "Seddera semhahensis" <- "Convolvulus semhaensis"
# "Seddera spinosa" <- "Convolvulus kossmatii"
# "Jasminum fluminense subsp. socotranum" <- "Jasminum fluminense"
# "Leucas spiculifera" <- "Leucas spiculifolia"                          
# "Micromeria remota" <- "Micromeria imbricata"
# "Dicoma cana" <- "Macledium canum"                                 
# "Helichrysum socotranum" <- "Helichrysum sp. B"
# "Prenanthes amabilis" <- "Erythroseris amabilis"
# "Rughidia cordatum" <- "Rughidia cordata"
##########

# update nonMatchNames with their nonMatchFix option
# reset/create  counters
i <- 1  # loop counter endemics
j <- 1  # counter nonMatchNames/nonMatchFix as they correlate
k <- 1  # counter for matching row in endemics to apply namefix to
# run loop
for(i in 1:nrow(endemics)){
        # if taxon matches in nonMatchNames[j]
        k <- which(grepl(pattern=nonMatchNames[j], x=endemics$fullTax))
        endemics$fullTax[k] <- nonMatchFix[j]
        j <- j+1
        if(j>length(nonMatchNames)){stop("end of loop")}
}

# create new set with definitely updated endemic names/scores
endemicsUpdated <- endemics

# update endemicScore to 1 for everything matching now.
# use new endemicset to apply 1 to all matching names
#reset counter
i <- 1
# run loop
for(i in 1:nrow(recGrab)){
        if (as.character(recGrab$acceptDetNoAuth)[i] %in% as.character(endemicsUpdated$fullTax)) {
                recGrab$endemicScore[i] <- 1
        } 
}

#########  unneccesary here but possibly useful elsewhere:
# update namefields for namefixed taxa : this fix probably could apply earlier in the scriptchain - maybe script_editTaxa_Socotra.R?
#
## unneccessary step just now;
# # get lnams & sortName & Full Name of updated tax. 
# source("O://CMEP\ Projects/Scriptbox/general_utilities/function_getLnamID.R")
#
#replaceNamesRow <- getLnamID(checkMe=nonMatchFix[i], authorityPresent=FALSE)
# if (as.character(recGrab$acceptDetNoAuth)[i] == as.character(replaceNamesRow$acceptDetNoAuth)) {
#         recGrab$lnamID[i] <- replaceNamesRow$lnamID
#         recGrab$acceptDetNoAuth[i] <- replaceNamesRow$acceptDetNoAuth
#         recGrab$acceptDetAs[i] <- replaceNamesRow$acceptDetAs
#         recGrab$endemicScore[i] <- 1
# } 
#replaceNames <- bind_rows(replaceNames, replaceNamesRow)
#getLnamID(checkMe="Chlorophytum sp. nov. A", authorityPresent=FALSE)
#######

#table(recGrab$endemicScore)
#0     1 
#10541 15098

# writeout resulting records
message(paste0("... saving revised records with endemicScore for accepted taxa names in analysis set to: O://CMEP Projects/PROJECTS BY COUNTRY/Socotra/Socotra 2013-2016 LEVERHULME TRUST RPG-2012-778/AnalysisData/analysisRecords-incEndemic-Socotra_", Sys.Date(), ".csv"))
fileLocat <- "O://CMEP\ Projects/PROJECTS\ BY\ COUNTRY/Socotra/Socotra\ 2013-2016\ LEVERHULME\ TRUST\ RPG-2012-778/AnalysisData/"
fileName <- "analysisRecords-incEndemic-Socotra_"
write.csv(recGrab, file=paste0(fileLocat,fileName,Sys.Date(),".csv"), row.names = FALSE)

# tidy up
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


# VERY IMPORTANT!
# CLOSE DATABASE CONNECTIONs & REMOVE OBJECTS FROM WORKSPACE!
odbcCloseAll()
#rm(list=ls())
