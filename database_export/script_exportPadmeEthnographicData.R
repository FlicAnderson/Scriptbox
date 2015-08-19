## Socotra Project :: script_exportPadmeEthnographicData.R
# ============================================================================ #
# 10 August 2015
# Author: Flic Anderson
#
# standalone script // dependant on: [filename]
# saved at: O://CMEP\-Projects/Scriptbox/database_export/script_exportPadmeEthnographicData.R
# source: source("O://CMEP\-Projects/Scriptbox/database_export/script_exportPadmeEthnographicData.R")
#
# AIM:  Export ethnographic annotation data for Socotran specimens
# ....  (ethnographic annotation data was added via ???)
# ....  (removal and export of data based on: 
# ....  fufluns/databasin/ethnographic/script_ethnogAnnotationQuery_Socotra-used.R)
#
# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) 
# 1)  
# 2) 
# 3) 
# 4) 
# 5) 

# ---------------------------------------------------------------------------- #


# 0)

# load required packages, install if they aren't installed already
# {RODBC} - ODBC Database Access
if (!require(RODBC)){
        install.packages("RODBC")
        library(RODBC)
} 
# {sqldf} - performing SQL SELECT queries on R objects
if (!require(sqldf)){
        install.packages("sqldf")
        library(sqldf)
} 
# {dplyr} - manipulating large data frames as tbl_df objects
if (!require(dplyr)){
        install.packages("dplyr")
        library(dplyr)
} 
# {tidyr} - tools for creating & transforming tidy data
#if (!require(tidyr)){
#        install.packages("tidyr")
#        library(tidyr)
#} 


# open connection to live padme
source("O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R")
livePadmeArabiaCon()

# ## Get structure/names of relevant annotations-related tables
# Lnam <- sqlQuery(con_livePadmeArabia, query="SELECT TOP 1 * FROM [Latin Names]")
# Anse <- sqlQuery(con_livePadmeArabia, query="SELECT TOP 1 * FROM [AnnotationSets]")
# Anti <- sqlQuery(con_livePadmeArabia, query="SELECT TOP 1 * FROM [AnnotationTitles]")
# Anno <- sqlQuery(con_livePadmeArabia, query="SELECT TOP 1 * FROM [Annotations]")
# Anls <- sqlQuery(con_livePadmeArabia, query="SELECT TOP 1 * FROM [AnnotationListSelections]")
# Anlm <- sqlQuery(con_livePadmeArabia, query="SELECT TOP 1 * FROM [AnnotationListMembers]")

### WORKINGS ###

# pull in the tables required 
# ... (Sys.sleep(5) included after every database table pull to prevent issues
Lnam <- sqlQuery(con_livePadmeArabia, query="SELECT * FROM [Latin Names]")
#Sys.sleep(5)
Anse <- sqlQuery(con_livePadmeArabia, query="SELECT * FROM [AnnotationSets]")
#Sys.sleep(5)
Anti <- sqlQuery(con_livePadmeArabia, query="SELECT * FROM [AnnotationTitles]")
#Sys.sleep(5)
Anno <- sqlQuery(con_livePadmeArabia, query="SELECT * FROM [Annotations]")
#Sys.sleep(5)
Anls <- sqlQuery(con_livePadmeArabia, query="SELECT * FROM [AnnotationListSelections]")
#Sys.sleep(5)
Anlm <- sqlQuery(con_livePadmeArabia, query="SELECT * FROM [AnnotationListMembers]")
#Sys.sleep(5)


# used pull-out section of this (below) script, not whole thing as that includes summary
# stats & writeouts
source("O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R")
# get all recs as recGrab (17760 obs. of 29 variables)

# remove unrequired record-groups F, L & H
rm(qry1, qry2, qry3, herbRex, fielRex, litrRex)

### pull out annotations for all records' taxa.
# SQLDF this for now after pulling out ALL annotations data into R...

# things that are used?
# qry <- "SELECT 
#         Anse.id, 
#         Anti.title, 
#         Anlm.display, 
#         Lnam.sortName, 
#         Lnam.id AS LnamID 
# FROM ((Anls INNER JOIN Anlm ON Anls.selectionId = Anlm.id) INNER JOIN (Anti 
#         INNER JOIN Anse ON Anti.annotationSetId = Anse.id) ON Anlm.annotationTitleId = Anti.id) 
#         LEFT JOIN Lnam ON Anls.latinNameId = Lnam.id 
# WHERE (((Anse.id)=7) AND ((Anti.title)='Use?'));"

#str(sqldf(qry))
# 'data.frame':        706 obs. of  5 variables:
#         $ Anse.id      : int  7 7 7 7 7 7 7 7 7 7 ...
# $ Anti.title   : chr  "Use?" "Use?" "Use?" "Use?" ...
# $ Anlm.display : chr  "Used" "Used" "Used" "Used" ...
# $ Lnam.sortName: chr  "Angkalanthus oligophylla" "Anisotes diversifolius" "Asystasia gangetica" "Ballochia amoena" ...
# $ LnamID       : int  2596 2597 2598 2599 2600 2601 2602 2603 2604 2607 ...


# ALL things: 
qry <- "SELECT 
        Anse.id AS Anse_id, 
        Anti.title AS Anti_title, 
        Anlm.display AS Anlm_display, 
        Lnam.sortName AS Lnam_sortName, 
        Lnam.id AS Lnam_id 
FROM ((Anls INNER JOIN Anlm ON Anls.selectionId = Anlm.id) INNER JOIN (Anti 
        INNER JOIN Anse ON Anti.annotationSetId = Anse.id) ON Anlm.annotationTitleId = Anti.id) 
        LEFT JOIN Lnam ON Anls.latinNameId = Lnam.id 
WHERE ((Anse.id)=7);"

str(sqldf(qry))
# 'data.frame':        5703 obs. of  5 variables:
#         $ Anse.id      : int  7 7 7 7 7 7 7 7 7 7 ...
# $ Anti.title   : chr  "Use?" "Use?" "Use?" "Use?" ...
# $ Anlm.display : chr  "Used" "Used" "Used" "Used" ...
# $ Lnam.sortName: chr  "Angkalanthus oligophylla" "Anisotes diversifolius" "Asystasia gangetica" "Ballochia amoena" ...
# $ LnamID       : int  2596 2597 2598 2599 2600 2601 2602 2603 2604 2607 ...

# what's included?
        # NOTE: If this doesn't work, have you commented out the Annotation tables 
        # queries at the top? If so, the sqldf query won't work since it's based on those!
datA_ethnog <- sqldf(qry)


table(datA_ethnog$Anti_title)
# Animal Food- Specific Livestock    Animal/ Livestock Management   Commercial Value 
# 1816                                 167                             97 
# Construction                       Fishing                        Food (Animal) 
# 109                                  12                              1227 
# Food (Human)                       Fuel                           Important on a Specific Island 
# 148                                  430                             221 
# Material Culture                   Medicine                       Specifically Important 
# 258                                  208                             304 

# Use? 
# 706 

# EXAMPLE: pull out particular category (e.g. Fishing)
#datA_ethnog[which(datA_ethnog$Anti.title=="Fishing"),]

datA_records <- head(recGrab)

tester <- sqldf("SELECT * FROM datA_records LEFT JOIN datA_ethnog ON datA_records.lnamID==datA_ethnog.Lnam_id")
# tester is long data.  6 records -> 22 rows now due to multiple uses per taxon.
# Could be widened to avoid replication of lat/lon points? - think about this!
# ZOMG: When you run this sqldf join on recGrab instead, the object is HUGE!!!!
#str(sqldf("SELECT * FROM recGrab LEFT JOIN datA_ethnog ON recGrab.lnamID==datA_ethnog.LnamID"))
# 'data.frame':        159922 obs. of  34 variables:


# POTENTIAL PROBLEM: 
# Need to re-check how ethnographic data was applied to taxon names & ensure it's CORRECT.  
# Was anything missed? Why? Was this because it wasn't in the ethnoflora and therefore no data exists?
# Was it due to a query error?


### output ethnog annotations linked to Latin Names
# needs to look like: 
        # familyName - accepted family name (from Padme taxonomy)
        # acceptDetAs - accepted latin name from current determination (from Padme taxonomy)
        # acceptDetNoAuth - accepted latin name from current determination with no authority string
        # genusName - accepted name genus only
        # detAs - what it's currently determined as in Padme (may be an old name or synonym)
        # USES - high level use category (Anti.title should suffice?; do not include 'Use?')


tester_output <- sqldf("SELECT familyName, acceptDetAs, acceptDetNoAuth, genusName, detAs, Anti_title, Anlm_display FROM tester")

# only unique name + uses (but not the summary category 'Use?')
# NOTE: syntax of names from annotations has changed from Anti.title -> Anti_title
# so beware of this!
tester_output <- tester_output[-which(tester_output$Anti_title=="Use?"),]
tester_output <- unique(tester_output)

#head(tester_output)
# familyName                 acceptDetAs       acceptDetNoAuth  genusName                       detAs
# 1   Leguminosae Indigofera articulata Gouan Indigofera articulata Indigofera Indigofera articulata Gouan
# 4   Leguminosae Indigofera articulata Gouan Indigofera articulata Indigofera Indigofera articulata Gouan
# 5   Leguminosae Indigofera articulata Gouan Indigofera articulata Indigofera Indigofera articulata Gouan
# 8  Boraginaceae       Cordia obtusa Balf.f.         Cordia obtusa     Cordia       Cordia obtusa Balf.f.
# 12 Boraginaceae       Cordia obtusa Balf.f.         Cordia obtusa     Cordia       Cordia obtusa Balf.f.
# 14 Boraginaceae       Cordia obtusa Balf.f.         Cordia obtusa     Cordia       Cordia obtusa Balf.f.
# Anti_title
# 1  Animal Food- Specific Livestock
# 4                    Food (Animal)
# 5   Important on a Specific Island
# 8  Animal Food- Specific Livestock
# 12    Animal/ Livestock Management
# 14                    Construction

### NOW TRY WITH ALL DATA!!!!
# BUT CONSIDER SIZE OF DATA TABLE!
# THINK ABOUT DPLYR USAGE!
# .... "'data.frame': 159922 obs. of  34 variables:"

# Problems: 
# there'll be lots of <NA> uses by the looks; this is due to accepted names 
# being used - if updated name is applied, it may not have been scored if not in
# the ethnoflora. Also if record contains family or genus level dets only, these 
# won't have been scored.  Need to pull these out and fix those problems by hand!
        # possible semi-fix/workaround might be to pull the uses of the 
        # 'detAs' (original det) field instead of 'acceptDetAs' (accepted name) 
        # IF (conditional code required!) Anti_title shows <NA>?
 

datA_records <- recGrab


datA <- sqldf("SELECT * FROM datA_records LEFT JOIN datA_ethnog ON datA_records.lnamID==datA_ethnog.Lnam_id")
# tester is long data.  6 records -> 22 rows now due to multiple uses per taxon.
# Could be widened to avoid replication of lat/lon points? - think about this!
# ZOMG: When you run this sqldf join on recGrab instead, the object is HUGE!!!!
#str(sqldf("SELECT * FROM recGrab LEFT JOIN datA_ethnog ON recGrab.lnamID==datA_ethnog.LnamID"))
# 'data.frame':        159922 obs. of  34 variables:

datA_output <- sqldf("SELECT familyName, acceptDetAs, acceptDetNoAuth, genusName, detAs, Anti_title, Anlm_display FROM datA")

# use dplyr for handling
datB <- tbl_df(datA)
datB

# select only certain columns
datC <- select(datB, familyName, acceptDetAs, acceptDetNoAuth, genusName, detAs, Anti_title, Anlm_display)

# remove extra objects
rm(Anlm, Anls, Anno, Anse, Anti, Lnam, datA, tester, tester_output)

#group by use category title
by_useTitle <- group_by(datC, Anti_title)
# show number of unique taxa (with Authorities) grouped by use category title
summarize(by_useTitle, uniqueTaxa=n_distinct(acceptDetAs))
# Source: local data frame [14 x 2]
# 
# Anti_title                            uniqueTaxa
# 1  Animal Food- Specific Livestock        579
# 2     Animal/ Livestock Management        107
# 3                 Commercial Value         33
# 4                     Construction         77
# 5                          Fishing         10
# 6                    Food (Animal)        633
# 7                     Food (Human)        136
# 8                             Fuel        168
# 9   Important on a Specific Island        132
# 10                Material Culture        136
# 11                        Medicine        137
# 12          Specifically Important        200
# 13                            Use?        650
# 14                              NA        598

# group by use-display-titles
by_useDisplay <- group_by(datC, Anlm_display)
# show number of unique taxa (with Authorities) grouped by use category title
summarize(by_useDisplay, uniqueTaxa=n_distinct(acceptDetAs))
# Source: local data frame [72 x 2]
# 
# Anlm_display uniqueTaxa
# 1                     Abd al Kuri         75
# 2                        Adhesive         36
# 3              Bedding & Stuffing         24
# 4                      Bee forage        148
# 5               Bees nest (Honey)          5
# 6                    Boats/ Rafts          4
# 7             Carefully harvested         39
# 8  Carefully harvested human food         38
# 9                          Cattle        343
# 10                       Charcoal         40
# ..                            ...        ...


summarize(by_useTitle, uniqueTaxa=n_distinct(acceptDetAs), uniqueOrigDet=n_distinct(detAs))
# Source: local data frame [14 x 3]
# 
# Anti_title                            uniqueTaxa uniqueOrigDet
# 1  Animal Food- Specific Livestock        579           768
# 2     Animal/ Livestock Management        107           160
# 3                 Commercial Value         33            45
# 4                     Construction         77           114
# 5                          Fishing         10            20
# 6                    Food (Animal)        633           836
# 7                     Food (Human)        136           178
# 8                             Fuel        168           242
# 9   Important on a Specific Island        132           177
# 10                Material Culture        136           200
# 11                        Medicine        137           194
# 12          Specifically Important        200           275
# 13                            Use?        650           857
# 14                              NA        598           649


# filter out taxa without uses
by_acceptTaxa <- group_by(datC, acceptDetAs)
# unique taxon names with no uses.
noUse <- summarize(filter(by_acceptTaxa, is.na(Anti_title)))
noUse
# Source: local data frame [598 x 1]
# 
#                                               acceptDetAs
# 1                                       Abutilon Mill.
# 2                                         Acacia Mill.
# 3                              Acacia negrii Pic.Serm.
# 4                   Acacia oerfota (Forssk.) Schweinf.
# 5                Acacia oerfota var. brevifolia Boulos
# 6                                    Acanthaceae Juss.
# 7                               Acanthochlamys P.C.Kao
# 8                    Achyranthes aspera L. var. aspera
# 9  Achyranthes aspera var. pubescens (Moq.) C.C.Towns.
# 10                             Achyrocline (Less.) DC.
# ..                                                 ...

# lots of the taxa are at family or genus level only
# need to weed these out, presumably. HOW?!

# pull out minimum dataset of names + uses, with 1 name per use
# eg Cordia obtusa, Fishing; Cordia obtusa, Food (animal), Indigofera... etc
datC


# distinct function will only work from dplyr > 0.4.2
if(packageVersion("dplyr") < 0.4) stop("... Update <dplyr> package; it's out of date & doesn't contain 'distinct()' function required.") 


# get distinct rows of datC to find whether category "Animal Food- Specific Livestock" 
# is repeating "Food (Animal)"
datC %>%
        select(-familyName, -genusName, -acceptDetNoAuth, -detAs) %>%
        distinct(acceptDetAs, Anti_title) %>%
        filter(Anti_title=="Animal Food- Specific Livestock"|Anti_title=="Food (Animal)") %>%
print
# It does seem to be repetitive: 

# 1   Indigofera articulata Gouan Animal Food- Specific Livestock         Donkeys
# 2   Indigofera articulata Gouan                   Food (Animal) Forage (Browse)
# 3         Cordia obtusa Balf.f. Animal Food- Specific Livestock          Cattle
# 4         Cordia obtusa Balf.f.                   Food (Animal)      Bee forage
# 5        Reseda viridis Balf.f. Animal Food- Specific Livestock           Goats
# 6        Reseda viridis Balf.f.                   Food (Animal) Forage (Browse)

# so we can probably just use Food (Animal) maybe?

# Anti_title                           
# 1 (DON'T USE)  Animal Food- Specific Livestock
# 9 (DON'T USE)     Important on a Specific Island
# 12 (DON'T USE)            Specifically Important 
# 13 (DON'T USE)                              Use? 
# 14 (DON'T USE)                              NA   

# 2     Animal/ Livestock Management        107           160
# 3                 Commercial Value         33            45
# 4                     Construction         77           114
# 5                          Fishing         10            20
# 6                    Food (Animal)        633           836
# 7                     Food (Human)        136           178
# 8                             Fuel        168           242
# 10                Material Culture        136           200
# 11                        Medicine        137           194

# categories to ignore:
ignoreCats <- c("Animal Food- Specific Livestock", "Important on a Specific Island", "Specifically Important", "Use?", "NA")

outList <- 
        datC %>%
                select(-familyName, -genusName, -acceptDetNoAuth, -detAs) %>%
                distinct(acceptDetAs, Anti_title) %>%
                filter(!(Anti_title %in% ignoreCats)) %>%
print

str(outList)

# write the list out to a CSV!
write.csv(outList, file=file.choose(), row.names=FALSE)




# VERY IMPORTANT!
# CLOSE DATABASE CONNECTIONs & REMOVE OBJECTS FROM WORKSPACE!
odbcCloseAll()
#rm(list=ls())
 