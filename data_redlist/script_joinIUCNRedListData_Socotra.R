## Socotra Project :: script_joinIUCNRedListData_Socotra.R
# ============================================================================ #
# 25 April 2016
# Author: Flic Anderson
#
# dependant on: script_dataGrabFullLatLonOrGazLatLon_Socotra.R
# saved at: O://CMEP\-Projects/Scriptbox/[folder]/[filename]
# source: source("O://CMEP\-Projects/Scriptbox/[folder]/[filename]")
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

# ---------------------------------------------------------------------------- #


# 0) load libraries and source scripts

# load any required libraries?
# {dplyr} - manipulating data & large data frames as tbl_df objects
if (!require(dplyr)){
        install.packages("dplyr")
        library(dplyr)
}

# source Socotra data script
source("O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R")


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


# 3) pull out non-joining taxa
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
c("Adiantum capillus-veneris","Marsilea coromandelina","Pteris vittata")  # we've ruled these out of analysis
# to do: create ignore/filter-out mechanism


# Things not in our dataset?!
c("Alternanthera sessilis",  # doesn't seem to be any records for it in our dataset
  "Ammannia auriculata", # different taxa?
  "Najas marina", # doesn't seem to be records? check this
  "Persicaria barbata", # doesn't seem to be records? check this
  "Persicaria glabrum", # not in padme
  "Polypogon monspeliensis", # no records?
  "Schoenus nigricans" # no records?
)
# to do: create ignore/filter-out mechanism

# Names to update in iucnDat:
toReplace <- c("Acacia pennivenia", # now should be in Vachellia, but ined.
               "Acacia sarcophylla", # should be in Vachellia, also syn of subsp. but for this capped to species
               "Allophylus rhoidiphyllus", # syn
               "Asparagus sp. nov. A", # nov. removed, ined. species concept
               "Babiana socotrana", # syn
               "Chlorophytum sp. nov.", # ined
               "Commiphora socotrana", # can't see any problem with this
               "Corchorus erodiodes", # common spelling error in epithet
               "Dicoma cana", # syn
               "Euclea balfourii", # syn 
               "Euclea laurina", # syn 
               "Euphorbia hamaderohensis", # spelling of epithet
               "Gaillonia puberula", # syn
               "Gaillonia putorioides", # syn
               "Gaillonia thymoides", # syn
               "Gaillonia tinctoria", # syn
               "Helichrysum sp. nov. A", # removed nov.
               "Helichrysum sp. nov. B", # removed nov.
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
                "Commiphora socotrana",
                "Corchorus erodioides", 
                "Macledium canum", 
                "Euclea divinorum",
                "Euclea divinorum",
                "Euphorbia hamaderoensis", 
                "Plocama puberula", 
                "Plocama putorioides",
                "Plocama thymoides",
                "Plocama tinctoria", 
                "Helichrysum sp. A", 
                "Helichrysum sp. B", 
                "Helichrysum sp. C", 
                "Helichrysum sp. D", 
                "Helichrysum sp. E [aff. aciculare]", 
                "Heliotropium wagneri",
                "Heliotropium shoabense",
                "Heliotropium sokotranum", 
                "Hemicrambe fruticosa", 
                "Kleinia scottii", 
                "Launaea sp. A", 
                "Lasiocorys flagellifera", 
                "Leucas spiculifolia", 
                "Maytenus sp. A", 
                "Micromeria imbricata", 
                "Nanorrhinum kuriensis", 
                "Dirichletia virgata", 
                "Polygala kuriense", 
                "Erythroseris amabilis", 
                "Rhus sp. A", 
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

# to do: create fix mechanism


# 5) perform main join with fixes


# 6) output joined data if required

