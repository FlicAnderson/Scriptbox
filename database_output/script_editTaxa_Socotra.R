## Socotra Project :: script_editTaxa_Socotra.R
# ==============================================================================
# 10 March 2016
# Author: Flic Anderson
#
# to call: 
# objects created: recGrab(altered)
# saved at: O://CMEP\ Projects/Scriptbox/database_output/script_editTaxa_Socotra.R
# dependent on: "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R"
# dependent on: "O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R"
# dependent on: "O://CMEP\ Projects/Scriptbox/database_output/script_editTaxa_Socotra_replacementInfo.R"
# source("O://CMEP\ Projects/Scriptbox/database_output/script_editTaxa_Socotra.R")
#
# AIM:  
# ....  
#
# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0)
# 1) 
# 2) 
# 3) 
# 4) 

# ---------------------------------------------------------------------------- #

# check for recGrab object
# informative error if it doesn't exist
if(!exists("recGrab")) stop("... ERROR: recGrab object doesn't exist")

# check for recGrab object
# informative error if it doesn't exist
#if(!exists("taxaListSocotra")) stop("... ERROR: taxaListSocotra object doesn't exist")

# Number of taxa:
length(unique(recGrab$acceptDetAs))
# 1256 taxa at 2016-02-25
# 1028 taxa at 2016-02-26 (after filtering out using keepTaxRankOnly() function)
# 818 after pruning out 0-Lat/0-Lon records

# create object
taxaListSocotra <- unique(recGrab$acceptDetAs)
#sort(taxaListSocotra)

recGrab <- tbl_df(recGrab)

# pull out names only
taxaListForChecks <- 
        recGrab %>%
                distinct(acceptDetAs) %>%
                select(acceptDetAs, genusName, familyName) %>%
                arrange(familyName, genusName, acceptDetAs)

# write list of unique taxa
#message(paste0(" ... saving list of accepted taxa names in analysis set to: O://CMEP\ Projects/Socotra/analysisTaxaListSocotra_FlicChecklist_", Sys.Date(), ".csv"))
#write.csv(taxaListForChecks, file=paste0("O://CMEP\ Projects/Socotra/analysisTaxaListSocotra_FlicChecklist_", Sys.Date(), ".csv"), row.names=FALSE)

# Ignore the lichens!
# genusName==
lichens <- c("Amphiloma", "Arthonia", "Batarrea", "Bathelium", "Blastenia", "Buellia", "Callopisma", "Campylopus", "Chiodecton", "Collema", "Corticium", "Dacrymyces", "Eutypa", "Fabronia", "Graphina", "Graphis", "Lecanora", "Lecidea", "Lentinus", "Microglaena", "Normandina", "Opegrapha", "Ostropa", "Parmelia", "Pertusaria", "Philonotis", "Physcia", "Placodium", "Podaxon", "Polyporus", "Pyxine", "Ramalina", "Rinodina", "Roccella", "Schlotheimia", "Sphinctrina", "Stereum", "Sticta", "Stictina", "Symblepharis", "Synechoblastus", "Theloschistes", "Tortula", "Trametes", "Urceolaria", "Usnea", "Valsa", "Weisia")
# Ignore Chara
# genusName==
chara <- c("Chara")

# remove lichens and chara
#recGrab <- 
        recGrab %>%
        filter(genusName !=lichens & genusName !=chara)
        
        i <- 1
        for(i in 1:length(lichens)){
        print(cat(paste0(" genusName != lichens[", i , "] |"), sep=""))
        i <- i + 1
        }
        
#         i <- 1
#         for(i in lichens){
#                 a <- lichens[i]
#                 paste0("genusName != lichens[", a , "] |")
#                 i <- i + 1
#         }
        
        
# substitutions
# using acceptDetAs==
source("O://CMEP\ Projects/Scriptbox/database_output/script_editTaxa_Socotra_replacementInfo.R")

# join taxaFixes onto records
recGrabTemp <- sqldf("SELECT * FROM recGrab LEFT JOIN taxaFixes ON recGrab.acceptDetAs=taxaFixes.toReplace;")

# substitute toReplace taxa with replaceWiths
recGrabTemp <- 
        recGrabTemp %>%
        mutate(tempTaxon=ifelse(!(is.na(replaceWith)), replaceWith, acceptDetAs))

# replace acceptDetAs column with tempTaxon values to include the fixes
recGrab$acceptDetAs <- recGrabTemp$tempTaxon

# reassign recGrab
recGrab <<- recGrab

# Number of taxa:
length(unique(recGrab$acceptDetAs))
# 971

# create object
taxaListSocotra <- unique(recGrab$acceptDetAs)
#sort(taxaListSocotra)

recGrab <- tbl_df(recGrab)

# pull out names only
taxaListForChecks <- 
        recGrab %>%
        distinct(acceptDetAs) %>%
        select(acceptDetAs, genusName, familyName) %>%
        arrange(familyName, genusName, acceptDetAs)

# write list of unique taxa
message(paste0(" ... saving revised list of accepted taxa names in analysis set to: O://CMEP\ Projects/Socotra/analysisTaxaListSocotra_RevisedChecklist_", Sys.Date(), ".csv"))
write.csv(taxaListForChecks, file=paste0("O://CMEP\ Projects/Socotra/analysisTaxaListSocotra_RevisedChecklist_", Sys.Date(), ".csv"), row.names=FALSE)

# tidy up
rm(recGrabTemp, taxaFixes, taxaListForChecks)