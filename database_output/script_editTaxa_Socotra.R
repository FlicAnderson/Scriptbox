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

# remove lichens and chara
recGrab <- 
        recGrab %>%
                filter(genusName != "Amphiloma") %>%
                filter(genusName != "Arthonia") %>%
                filter(genusName != "Batarrea") %>%
                filter(genusName != "Bathelium") %>%
                filter(genusName != "Blastenia") %>%
                filter(genusName != "Buellia") %>%
                filter(genusName != "Callopisma") %>%
                filter(genusName != "Campylopus") %>%
                filter(genusName != "Chiodecton") %>%
                filter(genusName != "Collema") %>%
                filter(genusName != "Corticium") %>%
                filter(genusName != "Dacrymyces") %>%
                filter(genusName != "Eutypa") %>%
                filter(genusName != "Fabronia") %>%
                filter(genusName != "Graphina") %>%
                filter(genusName != "Graphis") %>%
                filter(genusName != "Lecanora") %>%
                filter(genusName != "Lecidea") %>%
                filter(genusName != "Lentinus") %>%
                filter(genusName != "Microglaena") %>%
                filter(genusName != "Normandina") %>%
                filter(genusName != "Opegrapha") %>%
                filter(genusName != "Ostropa") %>%
                filter(genusName != "Parmelia") %>%
                filter(genusName != "Pertusaria") %>%
                filter(genusName != "Philonotis") %>%
                filter(genusName != "Physcia") %>%
                filter(genusName != "Placodium") %>%
                filter(genusName != "Podaxon") %>%
                filter(genusName != "Polyporus") %>%
                filter(genusName != "Pyxine") %>%
                filter(genusName != "Ramalina") %>%
                filter(genusName != "Rinodina") %>%
                filter(genusName != "Roccella") %>%
                filter(genusName != "Schlotheimia") %>%
                filter(genusName != "Sphinctrina") %>%
                filter(genusName != "Stereum") %>%
                filter(genusName != "Sticta") %>%
                filter(genusName != "Stictina") %>%
                filter(genusName != "Symblepharis") %>%
                filter(genusName != "Synechoblastus") %>%
                filter(genusName != "Theloschistes") %>%
                filter(genusName != "Tortula") %>%
                filter(genusName != "Trametes") %>%
                filter(genusName != "Urceolaria") %>%
                filter(genusName != "Usnea") %>%
                filter(genusName != "Valsa") %>%
                filter(genusName != "Weisia") %>%
                filter(genusName != "Chara")


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
# 864 at 2016-03-17

# remove dubious taxa: 
#dubiousList info in script_editTaxa_Socotra_replacementInfo.R
recGrab <- 
        recGrab %>%
        filter(acceptDetAs != "Boswellia nana x socotrana") %>%
        filter(acceptDetAs != "Boswellia aff. ameero Balf.f.") %>%
        filter(acceptDetAs != "Corchorus trilocularis L.") %>%
        filter(acceptDetAs != "Cryptolepis orbicularis Chiov.") %>%
        filter(acceptDetAs != "Cuscuta pretoriana Yunck.") %>%
        filter(acceptDetAs != "Cymbopogon schoenanthus (L.) Spreng") %>%
        filter(acceptDetAs != "Cymodocea rotundata Asch. & Schweinf.") %>%
        filter(acceptDetAs != "Cymodocea serrulata (R.Br.) Asch. & Magnus") %>%
        filter(acceptDetAs != "Cyperus tegetum Roxb.") %>%
        filter(acceptDetAs != "Delphinium sheilae Kit Tan") %>%
        filter(acceptDetAs != "Dipterygium glaucum Decne.") %>%
        filter(acceptDetAs != "Echidnopsis socotrana X insularis") %>%
        filter(acceptDetAs != "Echiochilon persicum (Burm.f.) I.M.Johnst.") %>%
        filter(acceptDetAs != "Eleocharis chaetaria (L.) Roem. & Schult.") %>%
        filter(acceptDetAs != "Eleusine africana Kenn.-O'Byrne") %>%
        filter(acceptDetAs != "Eragrostis patula (Kunth) Steud.") %>%
        filter(acceptDetAs != "Eragrostis pilosa (L.) P.Beauv.") %>%
        filter(acceptDetAs != "Foeniculum vulgare Mill.") %>%
        filter(acceptDetAs != "Glossonema varians (Stocks) Benth. ex Hook.f.") %>%
        filter(acceptDetAs != "Grewia damine Gaertn.") %>%
        filter(acceptDetAs != "Halodule uninervis (Forrsk.) Aschers") %>%
        filter(acceptDetAs != "Helichrysum profusum Balf.f.") %>%
        filter(acceptDetAs != "Juncus maritimus Lam.") %>%
        filter(acceptDetAs != "Limonium guigliae Raimondo & Domina") %>%
        filter(acceptDetAs != "Najas major L.") %>%
        filter(acceptDetAs != "Otostegia fruticosa (Forssk.) Schweinf. ex Penz.") %>%
        filter(acceptDetAs != "Peperomia abyssinica Miq.") %>%
        filter(acceptDetAs != "Striga linearifolia (Schumach. & Thonn.) Hepper") %>%
        filter(acceptDetAs != "Vachellia gerrardii (Benth.) P.J.H.Hurter & Mabb.") %>%
        filter(acceptDetAs != "Vachellia negrii (Pic.Serm.) Kyal. & Boatwr.") %>%
        filter(acceptDetAs != "Vachellia nilotica (L.) P.J.H.Hurter & Mabb.")

# Number of taxa:
length(unique(recGrab$acceptDetAs))
# 834 at 2016-03-17

# reassign recGrab
recGrab <<- recGrab

### update acceptDetNoAuth & genusName fields with updated names!

# UPDATE ACCEPTDETNOAUTH
# update acceptDetNoAuth

# join Lnam.fullname on recGrab.acceptDetAs 
# join new LnamID of fixed taxon
# then replace acceptDetNoAuth & update recGrab.lnamID
# then join families, then get rank again

qry <- "SELECT [Latin Names].id, [Latin Names].sortName, [Latin Names].[Full Name] 
        FROM [Latin Names]"
lnamInfo <- sqlQuery(con_livePadmeArabia, qry)
names(lnamInfo)[2] <- "LnamSortName"
names(lnamInfo)[3] <- "fullName"
datA <- sqldf("SELECT * FROM recGrab LEFT JOIN lnamInfo ON recGrab.acceptDetAs=lnamInfo.fullName")

table(is.na(datA$fullName))
datA <- datA[which(is.na(datA$fullName)),]
head(datA)

unique(datA$acceptDetAs)
# "Asparagus sp. A ined."          "Boswellia sp. A ined."          "Helichrysum dioscorides ined."  "Heliotropium socotranum Vierh."
# [5] "Indigofera socotrana Vierh."    "Rhus sp. nov. ined."            "Searsia cf. tenuinervis ined."  "Vachellia pennivenia ined."   
# fullname of "Asparagus sp. A ined." is "Asparagus sp. A"
# fullname of "Boswellia sp. A ined." is "Boswellia sp. A"
# fullname of "Helichrysum dioscorides ined." is "Helichrysum dioscorides R.Atkinson & A.G.Mill."
# fullname of "Heliotropium socotranum Vierh." is "Heliotropium socotranum Vierh. orth. var."
# fullname of "Indigofera socotrana Vierh." is "Indigofera sokotrana Vierh."
# fullname of "Rhus sp. nov. ined." is "Rhus sp. nov."
# fullname of "Searsia cf. tenuinervis ined." is "Searsia cf. tenuinervis Moffett"
# fullname of "Vachellia pennivenia ined." is "Vachellia pennivenia"




# # create query
# qry <- "SELECT 
#                 [Latin Names].sortName AS familyName, 
#                 [names tree].member
#                 FROM (
#                 Ranks INNER JOIN [Latin Names] ON Ranks.id = [Latin Names].Rank) 
#                 INNER JOIN [names tree] ON [Latin Names].id = [names tree].[member of]
#                 WHERE (((Ranks.name)='family'))
#                 ;"
# # run query, store as 'families' object
# families <- sqlQuery(con_livePadmeArabia, qry)
# recGrab <- sqldf("SELECT * FROM recGrab LEFT JOIN families ON recGrab.lnamid=families.member")



# ADD GENUS
# pull out genus (use non-auth det & then regex the epithet off)
#recGrab$genusName <- recGrab$acceptDetNoAuth
#recGrab$genusName <- gsub(" .*", "", recGrab$genusName)






# create object
taxaListSocotra <- unique(recGrab$acceptDetAs)
#sort(taxaListSocotra)

recGrab <- tbl_df(recGrab)

# pull out names only
taxaListForChecks <- 
        recGrab %>%
        distinct(acceptDetAs) %>%
        select(acceptDetAs, genusName, familyName) %>%
        arrange(acceptDetAs, genusName, familyName)

# write list of unique taxa
message(paste0("... saving revised list of ", length(taxaListSocotra), " accepted taxa names in analysis set to: O://CMEP\ Projects/Socotra/analysisTaxaListSocotra_Checklist_", Sys.Date(), ".csv"))
write.csv(taxaListForChecks, file=paste0("O://CMEP\ Projects/Socotra/analysisTaxaListSocotra_RevisedChecklist_", Sys.Date(), ".csv"), row.names=FALSE)

# tidy up
rm(recGrabTemp, taxaFixes, taxaListForChecks)