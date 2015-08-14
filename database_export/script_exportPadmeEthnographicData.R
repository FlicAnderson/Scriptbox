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
#source("O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R")
# get all recs as recGrab (17760 obs. of 27 variables)

### pull out annotations for these records' taxa.
# SQLDF this for now after pulling out ALL annotations data into R...

# things that are used?
qry <- "SELECT 
        Anse.id, 
        Anti.title, 
        Anlm.display, 
        Lnam.sortName, 
        Lnam.id AS LnamID 
FROM ((Anls INNER JOIN Anlm ON Anls.selectionId = Anlm.id) INNER JOIN (Anti 
        INNER JOIN Anse ON Anti.annotationSetId = Anse.id) ON Anlm.annotationTitleId = Anti.id) 
        LEFT JOIN Lnam ON Anls.latinNameId = Lnam.id 
WHERE (((Anse.id)=7) AND ((Anti.title)='Use?'));"

str(sqldf(qry))
# 'data.frame':        706 obs. of  5 variables:
#         $ Anse.id      : int  7 7 7 7 7 7 7 7 7 7 ...
# $ Anti.title   : chr  "Use?" "Use?" "Use?" "Use?" ...
# $ Anlm.display : chr  "Used" "Used" "Used" "Used" ...
# $ Lnam.sortName: chr  "Angkalanthus oligophylla" "Anisotes diversifolius" "Asystasia gangetica" "Ballochia amoena" ...
# $ LnamID       : int  2596 2597 2598 2599 2600 2601 2602 2603 2604 2607 ...


# ALL things: (overwrites qry)
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
a <- sqldf(qry)
table(a$Anti.title)
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

# pull out particular category (e.g. Fishing
a[which(a$Anti.title=="Fishing"),]

datA <- head(recGrab)

tester <- sqldf("SELECT * FROM datA LEFT JOIN a ON datA.lnamID==a.LnamID")
# tester is long data.  6 records -> 22 rows now due to multiple uses per taxon.
# Could be widened to avoid replication of lat/lon points? - think about this!

# POTENTIAL PROBLEM: 
# Need to re-check how ethnographic data was applied to taxon names & ensure it's CORRECT.  
# Was anything missed? Why? Was this because it wasn't in the ethnoflora and therefore no data exists?
# Was it due to a query error?
