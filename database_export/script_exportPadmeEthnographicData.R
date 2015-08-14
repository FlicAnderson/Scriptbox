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
if (!require(sqldf)){
        install.packages("sqldf")
        library(sqldf)
} 
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
rm(fielRex, litrRex, herbRex)

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
        Anse.id, 
        Anti.title, 
        Anlm.display, 
        Lnam.sortName, 
        Lnam.id AS LnamID 
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
# 
table(datA_ethnog$Anti.title)
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

tester <- sqldf("SELECT * FROM datA_records LEFT JOIN datA_ethnog ON datA_records.lnamID==datA_ethnog.LnamID")
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


tester_output <- sqldf("SELECT familyName, acceptDetAs, acceptDetNoAuth, genusName, detAs, Anti_title FROM tester")

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
 


# VERY IMPORTANT!
# CLOSE DATABASE CONNECTIONs & REMOVE OBJECTS FROM WORKSPACE!
odbcCloseAll()
#rm(list=ls())