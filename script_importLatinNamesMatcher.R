# Padme Data:: Databasin:: importLatinNamesMatcher.R
# ======================================================== 
# (1st July 2014)
# ~ standalone script


# AIM: to check de-authored names field against [Latin Names].[sortName] in {Live Padme Arabia} to see whether they match
# ... and highlight which ones will require entry into Live Padme BEFORE an import-copy is made, so that when {Import Padme}
# ... is made, it'll contain any new names, and non-matching (mis-spelled) ones will be also highlighted. 


# load RODBC library
if (!require(RODBC)){
  install.packages("RODBC")
  library(RODBC)
} 
# load sqldf library
if (!require(sqldf)){
  install.packages("sqldf")
  library(sqldf)
} 

# source functions:
source("Z:/fufluns/scripts/function_importPadmeCon.R")
source("Z:/fufluns/scripts/function_livePadmeArabiaCon.R")

# source names field (from spreadsheet, or in this case import-database):
# [0UPS].[nameNoAuth]

# check against {LIVE PADME ARABIA} field:
# [Latin Names].[sortName]

# 1) get names from source into dataframe ([0UPS].[nameNoAuth] -> origName) & ([0UPS].[currntDetNoAuth] -> crrntDet)
# 2) get list of names from Padme? ([Latin Names].[sortName] -> nameZ)
# 3) compare origName & crrntDet %in% nameZ
# 4) write list of non-matching names from comparison
# 5) ... use list to research cause of non-match and then create new names and change spellings by hand.  Weed any non-plants out!
# 6) THEN import the datA source to a new {Import Padme} which will have the new names etc and ought to match easily.

# QUESTION: 
# NAME SOURCE TO BE MATCH-TESTED IS:
# (A) {import padme} or similar database? (answered)
# or
# (B) spreadsheet?


# 1) get names from source into dataframe ([0UPS].[nameNoAuth] -> origName) & ([0UPS].[currntDetNoAuth] -> crrntDet)

# currently irrelevant #
#source("Z:/fufluns/databasin/userPrompt_IF.R")
#if(interactive())fun()
# currently irrelevant #

# For source (A) - {import padme} or similar database -
# follow these instructions... 

importPadmeCon()
livePadmeArabiaCon()


# CREATE ORIGINAL ALLPLANTS TABLE
# DO ONCE (already done)
# copy [0UPS] table to allow us to delete non-plants from [0UPS] but still have a copy of them somewhere ready to import if necessary. 
qry <- "SELECT * INTO 0ALLPlants FROM 0UPS"
sqlQuery(con_importPadme, qry)

# CREATE NON-PLANTS ONLY TABLE - can be imported separately if required at a later date
# DO ONCE
# copy [0UPS] table to allow us to delete non-plants from [0UPS] but still have a copy of them somewhere ready to import if necessary. 
qry <- "SELECT * INTO 0NonPlants FROM 0UPS"
sqlQuery(con_importPadme, qry)

# 0UPS will have all non-plants removed.


# pull out the names from the 0UPS imported table
#sqlColumns(con_importPadme, "0UPS")$COLUMN_NAME
# want [nameNoAuth] and also to check through [currntDetNoAuth]
# make objects, pull unique names into them via SQL
# original names & id
qry <- "SELECT id, nameNoAuth FROM [0UPS]"
origName <- sqlQuery(con_importPadme, qry)
# current dets & id
qry <- "SELECT id, currntDetNoAuth FROM [0UPS]"
crrntDet <- sqlQuery(con_importPadme, qry)

# CLOSE THE CONNECTION!
#odbcCloseAll()


# For source (B) - spreadsheet -
# follow these instructions... 
# (UNFINISHED)


# 2) get list of names from Padme? ([Latin Names].[sortName] -> nameZ)

# set up connection to {Live Padme}
#livePadmeArabiaCon()
# pull the names out & store in an object
qry <- "SELECT sortName, id FROM [Latin Names]"
nameZ <- sqlQuery(con_livePadmeArabia, qry)
# to consider the number of unique sortnames in the live database names table:
#qry <- "SELECT DISTINCT sortName FROM [Latin Names]"
#nameZ1 <- sqlQuery(con_livePadmeArabia, qry)


# this works:
origNameREQFIX <- sqldf("SELECT [origName].[id], [origName].[nameNoAuth] FROM origName LEFT JOIN nameZ ON nameNoAuth = sortName WHERE ((([nameZ].[id]) Is Null));")
#origNameREQFIX <- sqldf("SELECT * FROM origName LEFT JOIN nameZ ON nameNoAuth = sortName WHERE ((([nameZ].[id]) Is Null));")
#origNameREQFIX <- sqldf("SELECT * FROM origName LEFT JOIN nameZ ON nameNoAuth = sortName WHERE (((id) Is Null));")
crrntDetREQFIX <- sqldf("SELECT [crrntDet].[id], [crrntDet].[currntDetNoAuth] FROM crrntDet LEFT JOIN nameZ ON currntDetNoAuth = sortName WHERE ((([nameZ].[id]) Is Null));")
#crrntDetREQFIX <- sqldf("SELECT currntDetNoAuth, id FROM crrntDet LEFT JOIN nameZ ON currntDetNoAuth = sortName WHERE (((id) Is Null));")

paste("... ", nrow(origNameREQFIX), " names need to be fixed from original names (",locat_importPadme, ")")
paste("... ", nrow(crrntDetREQFIX), " names need to be fixed from determinations (",locat_importPadme, ")")


# 4) write list of non-matching names from comparison
# ensure names of name-columns is the same to allow merge, set both column names to "taxa"
names(origNameREQFIX)[2] <- "taxa"
names(crrntDetREQFIX)[2] <- "taxa"
# merge both into one result to allow batchfix at once
# create object called noMatch for all the things left over (e.g  wrong/new names, lichens and fungi)
#print(noMatch <- merge(crrntDetREQFIX, origNameREQFIX))


# 5) ... use list to research cause of non-match and then create new names and change spellings by hand.  Weed any non-plants out!
# lichens and fungi not added to the datbase yet.  
# write them to a file so they can be kept in case they do need to be imported later.  

#### this works 01st July 2014, 3pm ###
# to fix from current Dets & orig Names together:
allNames <- unique(rbind(origNameREQFIX, crrntDetREQFIX))
# show IDs and Unique Names 
namesOnly <- unique(allNames[2])
# write out to a file to hold the fix-reqs
write.csv(allNames, "Z://fufluns/databasin/FixMe.csv", na="") 
####
# ID numbers and names for rows to pull out: 
allNames
# ID numbers for rows to pull out:
pullRows <- as.factor(allNames$id)
## output the non-match (non-plant?) names to a .csv file to set aside and deal with another time:

# check importPadme connection is open
importPadmeCon()

# CREATE FUNCTION TO REMOVE ALL NON-NON-PLANTS FROM [0NonPlants] to create NON-PLANTS-ONLY
plantRemovr <- function(x){
#testing stage:
  ##SELECT ROWS TO DELETE - check all working ok:
  #qry<- sub(", )$", ")", paste("SELECT * FROM [0NonPlants] WHERE id NOT IN (", paste(pullRows, sep="", ",", collapse=" "), ");"))
#real stage: 
  # DELETE PLANTS FROM 0UPS
  qry<- sub(", )$", ")", paste("DELETE FROM [0NonPlants] WHERE id NOT IN (", paste(pullRows, sep="", ",", collapse=" "), ");"))
  sqlQuery(con_importPadme, qry)
}
# RUN FUNCTION TO REMOVE ALL NON-PLANTS FROM 0NonPlants
plantRemovr()

# CREATE FUNCTION TO REMOVE ALL NON-PLANTS FROM 0UPS
nonPlantRemovr <- function(x){
  #testing stage:
  ##SELECT ROWS TO DELETE - check all working ok:
  #qry<- sub(", )$", ")", paste("SELECT * FROM [0UPS] WHERE id IN (", paste(pullRows, sep="", ",", collapse=" "), ");"))
  #real stage: 
  # DELETE NONPLANTS FROM 0UPS
  qry<- sub(", )$", ")", paste("DELETE FROM [0UPS] WHERE id IN (", paste(pullRows, sep="", ",", collapse=" "), ");"))
  sqlQuery(con_importPadme, qry)
}
# RUN FUNCTION TO REMOVE ALL NON-PLANTS FROM 0UPS
nonPlantRemovr()


# 6) THEN import the datA source to a new {Import Padme} which will have the new names etc and ought to match easily.
# do this in Access, not from scripts

# VERY IMPORTANT!
# CLOSE THE CONNECTION!
odbcCloseAll()
rm(list=ls())

