## Socotra Project :: script_joinIUCNRedListData_Socotra.R
# ============================================================================ #
# 25 April 2016
# Author: Flic Anderson
#
# dependant on: script_dataGrabFullLatLonOrGazLatLon_Socotra.R
# saved at: O://CMEP\-Projects/Scriptbox/data_redlist/script_joinIUCNRedListData_Socotra.R
# source("O://CMEP\ Projects/Scriptbox/data_redlist/script_joinIUCNRedListData_Socotra.R")
#
# AIM:  Join IUCN Plant Red List data for Socotra to the Socotra dataset on names
# ....  and where names do not match, apply a taxonomic fix as necessary.
#
# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) load libraries and source scripts
# 1) read in csv file of IUCN category data
# 2) attempt join of IUCN data on Socotra analysis dataset
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

# source Socotra data script
# NB: using suppressWarning() to avoid this: 
#Warning message:
#In rbind_all(list(x, ...)) : Unequal factor levels: coercing to character
# it doesn't seem to break anything and it'll take m
suppressWarnings(source("O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R"))


# 1) read in csv file of IUCN category data

iucnDat <- read.csv("O://CMEP\ Projects/Socotra/IUCNPlantRedListCategories_Socotra.csv")

iucnDat <- tbl_df(iucnDat)


# 2) attempt join of IUCN data on Socotra analysis dataset

# filter out names where there are subspecific epithets - these are likely to be
# narrow endemics and will mess with scores a little?

# table(iucnDat$Infraspecific.rank)
#       ssp. var. 
# 353    2    1 

# remove subspecific taxa 
iucnDat <- 
        iucnDat %>%
        filter(iucnDat$Infraspecific.rank!="ssp." & iucnDat$Infraspecific.rank!="var.")

# build scientific names (above subspecific level only) from columns
# Genus + Species (+ Authority)
iucnDat <- 
        iucnDat %>%
                mutate(joinName=paste(iucnDat$Genus, iucnDat$Species)) 
#dim(iucnDat)
# 353 24

# confirm no duplicates
table(duplicated(recGrab$recID))



# 3) pull out non-joining taxa
# initial join
a <- sqldf("SELECT * FROM recGrab LEFT JOIN iucnDat ON recGrab.acceptDetNoAuth=iucnDat.joinName;")

# names which DO match
a <- unique(a[which(!(is.na(a$joinName))),]$joinName)

# how many DO match?
#length(unique(a[which(!(is.na(a$joinName))),]$joinName))
#296

# pull out unique names from iucn data
datA <- unique(iucnDat$joinName)

# check which names from the iucn data DO NOT MATCH socotra data:
datA[which(datA %in% a == FALSE)]

# how many don't match?
length(datA[which(datA %in% a == FALSE)])
# 57

# 4) apply fixes for non-joining taxa

# FERNS TO IGNORE: 
iucnDat <- iucnDat[which(iucnDat$joinName %in% c("Adiantum capillus-veneris","Marsilea coromandelina","Pteris vittata") == FALSE),]


# Things not in our dataset?!
iucnDat <- iucnDat[which(iucnDat$joinName %in% c(
        "Alternanthera sessilis",  # doesn't seem to be any records for it in our dataset
        "Ammannia auriculata", # different taxa?
        "Najas marina", # doesn't seem to be records? check this
        "Persicaria barbata", # doesn't seem to be records? check this
        "Polypogon monspeliensis", # no records?
        "Schoenus nigricans", # no records?
        "Commiphora socotrana", # no records?! This should be in the dataset, it's in padme and in the ethnoflora
        "Ischaemum sp. nov.", # pretty sure this should have a few records at least too
        "Helichrysum sp. nov. B" # pretty sure this should have a few records at least too
        ) == FALSE),]


# Names to update in iucnDat:
toReplace <- c("Acacia pennivenia", # now should be in Vachellia, but ined.
               "Acacia sarcophylla", # should be in Vachellia, also syn of subsp. but for this capped to species
               "Allophylus rhoidiphyllus", # syn
               "Asparagus sp. nov. A", # nov. removed, ined. species concept
               "Babiana socotrana", # syn
               "Chlorophytum sp. nov.", # ined
               "Corchorus erodiodes", # orthog. var.
               "Dicoma cana", # syn
               "Euclea balfourii", # syn 
               "Euclea laurina", # syn 
               "Euphorbia hamaderohensis", # orthog. var.
               "Gaillonia puberula", # syn
               "Gaillonia putorioides", # syn
               "Gaillonia thymoides", # syn
               "Gaillonia tinctoria", # syn
               "Helichrysum sp. nov. A", # removed nov.
               "Helichrysum sp. nov. C", # removed nov.
               "Helichrysum sp. nov. D", # removed nov.
               "Helichrysum sp. nov. E", # removed nov., added the aff. details
               "Heliotropium aff. wagneri", # removed aff.
               "Heliotropium derafontense", # syn
               "Heliotropium socotranum", # orthog. var.
               "Hemicrambe townsendii", # syn
               "Kleinia scotti", # orthog. var. 
               "Launaea sp. nov. A", # removed nov.
               "Leucas flagellifolia", # orthog. var.
               "Leucas spiculifera", # orthog. var.
               "Maytenus sp. nov. A", # removed nov.
               "Micromeria remota", # syn of var, dropped to sps
               "Nanorrhinum kuriense", # spelling
               "Persicaria glabrum", # orth. var.
               "Placopoda virgata", # syn
               "Polygala kuriensis", # orthog. var.
               "Prenanthes amabilis", # syn
               "Rhus sp. nov. A",  # removed nov.
               "Rhus thyrsiflora", # syn
               "Rughidia cordatum", # orthog. var.
               "Seddera fastigiata", # syn
               "Seddera semhahensis", # syn
               "Seddera spinosa", # syn
               "Senna socotrana", # syn
               "Teucrium socotranum", # orthog. var.
               "Tragia balfouriana", # orthog. var.
               "Trichodesma scotti", # orthog. var.
               "Zygocarpum caeruleum" # orthog. var.
               )

replaceWith <- c("Vachellia pennivenia", 
                "Vachellia oerfota", 
                "Allophylus rubifolius", 
                "Asparagus sp. A", 
                "Cyanixia socotrana",
                "Chlorophytum sp. nov. A",
                "Corchorus erodioides", 
                "Macledium canum", 
                "Euclea divinorum",
                "Euclea divinorum",
                "Euphorbia hamaderoensis", 
                "Plocama puberula", 
                "Plocama putorioides",
                "Plocama thymoides",
                "Plocama tinctoria", 
                "Helichrysum samhaensis", 
                "Helichrysum nogedensis", 
                "Helichrysum dioscorides", 
                "Helichrysum sp. E [aff. aciculare]", 
                "Heliotropium wagneri",
                "Heliotropium shoabense",
                "Heliotropium sokotranum", 
                "Hemicrambe fruticosa", 
                "Kleinia scottii", 
                "Launaea sp. A", 
                "Leucas flagellifera", 
                "Leucas spiculifolia", 
                "Maytenus sp. A", 
                "Micromeria imbricata", 
                "Nanorrhinum kuriensis", 
                "Persicaria glabra",
                "Dirichletia virgata", 
                "Polygala kuriense", 
                "Erythroseris amabilis", 
                "Rhus sp. nov.", 
                "Searsia thyrsiflora",
                "Rughidia cordata",
                "Convolvulus socotrana",
                "Convolvulus semhaensis", 
                "Convolvulus kossmatii", 
                "Senna sophera", 
                "Teucrium sokotranum", 
                "Tragia balfourii", 
                "Trichodesma scottii", 
                "Zygocarpum coeruleum"
                )

# create data frame of fixes info
taxaFixes <<- data.frame(toReplace, replaceWith)

# join fixes onto iucnDat as a temporary object
iucnTemp <- sqldf("SELECT * FROM iucnDat LEFT JOIN taxaFixes ON iucnDat.joinName=taxaFixes.toReplace;")

# substitute toReplace taxa with replaceWiths
iucnTemp <- 
        iucnTemp %>%
        mutate(tempTaxon=ifelse(!(is.na(replaceWith)), replaceWith, joinName))

# replace joinName column with tempTaxon values to include the fixes
iucnDat$joinName <- iucnTemp$tempTaxon


# 5) perform main join with fixes

message("... adding IUCN category data to analysis records")

# initial join
recGrabPlusIUCN <- sqldf("SELECT * FROM recGrab LEFT JOIN iucnDat ON recGrab.acceptDetNoAuth=iucnDat.joinName;")

# names which DO match
iucnTemp <- unique(recGrabPlusIUCN[which(!(is.na(recGrabPlusIUCN$joinName))),]$joinName)

# how many DO match?
#length(unique(recGrabPlusIUCN[which(!(is.na(recGrabPlusIUCN$joinName))),]$joinName))
#296

# pull out unique names from iucn data
datA <- unique(iucnDat$joinName)

# check which names from the iucn data DO NOT MATCH socotra data:
datA[which(datA %in% iucnTemp == FALSE)]


# fix duplicate issues if exist
if(sum(duplicated(recGrabPlusIUCN$recID))!=0){
        message("... duplicate records exist (caused by taxonomy issues?-TBD) - removing duplicates...") 
        
        # note indices of the second of each duplicated pair
        duplIndices <- which(duplicated(recGrabPlusIUCN$recID))
        
        # remove all records with implicated indices:
        recGrabPlusIUCN <- recGrabPlusIUCN[-c(duplIndices),]
        
        message("... duplicate records removed :)")
} else {
        message("... no duplicate records to deal with :D")
}

# peace of mind check:
#sum(duplicated(recGrabPlusIUCN$recID))


# 6) output joined data if required

# write analysis-ready >>>recGrabPlusIUCN<<< to .csv file  
message(paste0("... saving ", nrow(recGrabPlusIUCN), " records to: O://CMEP\ Projects/Socotra/Socotra_recGrabPlusIUCNCats", Sys.Date(), ".csv"))
write.csv(recGrabPlusIUCN[order(recGrabPlusIUCN$acceptDetAs, na.last=TRUE),], file=paste0("O://CMEP\ Projects/Socotra/Socotra_recGrabPlusIUCNCats_", Sys.Date(), ".csv"), na="", row.names=FALSE)



# 7) tidy up

# REMOVE ALL OBJECTS FROM WORKSPACE!
#rm(list=ls())

# # REMOVE SOME OBJECTS FROM WORKSPACE!
#         # removes EVERYTHING EXCEPT WHAT YOU WANT TO KEEP 
#         # (eg. connections, recGrab, etc):
rm(list=setdiff(ls(), 
                c(
                        "recGrab", 
                        "recGrabPlusIUCN",
                        "taxaListSocotra",
                        "con_livePadmeArabia", 
                        "livePadmeArabiaCon"
                )
        )
)
