# Scriptbox :: script_latinNamesMatcher.R
# ======================================================== 
# (1st July 2014)
# Author: Flic Anderson
# ~ standalone script
# saved at: 
# "O:/CMEP\ Projects/Scriptbox/database_importing/script_latinNamesMatcher.R"
# to run: 
# source("O:/CMEP\ Projects/Scriptbox/database_importing/script_latinNamesMatcher.R")


# AIM: to check de-authored names field against [Latin Names].[sortName] in 
# ... {Live Padme Arabia} to see whether they match and highlight which ones 
# ... will require entry into Live Padme BEFORE an import-copy is made, so that 
# ... when {Import Padme} is made, it'll contain any new names, and non-matching
# ... (mis-spelled) ones will be also highlighted. 


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
#source("O:/CMEP\ Projects/Scriptbox/function_importPadmeCon.R")
source("O:/CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R")

# source names field (from spreadsheet, or in this case import-database):
# [0UPS].[nameNoAuth]

# check against {LIVE PADME ARABIA} field:
# [Latin Names].[sortName]

# 1) get names from source into dataframe 
        # ([0UPS].[nameNoAuth] -> origName) 
        # & ([0UPS].[currntDetNoAuth] -> crrntDet)
# 2) get list of names from Padme? ([Latin Names].[sortName] -> nameZ)
# 3) compare origName & crrntDet %in% nameZ
# 4) write list of non-matching names from comparison
# 5) ... use list to research cause of non-match and then create new names and 
        # change spellings by hand.  Weed any non-plants out!
# 6) THEN import the datA source to a new {Import Padme} which will have the new 
        # names etc and ought to match easily.

# QUESTION: 
# NAME SOURCE TO BE MATCH-TESTED IS:
# (A) {import padme} or similar database? (answered)
# or
# (B) spreadsheet?
# or 
# (C) csv file?


# source spreadsheet:
message("........ please choose file to check names from: ")
importSource <- file.choose()
#importSource <- "Z://fufluns//databasin//taxaDataGrab//Socotra SPECIES LIST.xlsx"
# get the extension
extns <- paste0(".", unlist(strsplit(importSource, "[.]"))[2])
# IF extns = database: 
#   A) extns = .mdb
# IF extns = spreadsheet:
#   B) extns = .xls/.xlsx
# IF extns = comma separated value file:
#   C) extns = .csv

# A)
dbImport <- grepl(".mdb", extns)
# B)
spsImport <- grepl(".xls|.xlsx", extns)    
# C)
csvImport <- grepl(".csv", extns)

#ifelse(dbImport <- grepl(".mdb", extns), "importfile is a database file (.mdb)", "importfile is NOT a database file (.mdb)")
#ifelse(spsImport <- grepl(".xls|.xlsx", extns), "importfile is a spreadsheet file (.xls or .xlsx)", "importfile is NOT a spreadsheet file (.xls or .xlsx)")
#ifelse(csvImport <- grepl(".csv", extns), "importfile is a comma separated value file (.csv)", "importfile is NOT a comma separated value file (.csv)")


# 1) get names from source into dataframe 

# For source (A) - {import padme} or similar database -
# ([0UPS].[nameNoAuth] -> origName) & ([0UPS].[currntDetNoAuth] -> crrntDet)

# call function if importSource is a database file
if(dbImport==TRUE){
  print("... using database method to import file...")
  # source script
  source("O:/CMEP\ Projects/Scriptbox/database_importing/function_importNames_db.R")
  # call function
  importNames_db()
}
 

# For source (B) - spreadsheet -
# column of names -> crrntDet

# call function if importSource is a spreadsheet file
if(spsImport==TRUE) {
  print("... using spreadsheet method to import file...")
  # load xlsx package to library
  if (!require(xlsx)){
    install.packages("xlsx")
    library(xlsx)
  }
  # run the spreadsheet import method function
  source("O:/CMEP\ Projects/Scriptbox/database_importing/function_importNames_xlsx.R")
  # RUN & CALL importNames_xlsx() function
  importNames_xlsx()
  # print dimensions of crrntDet
  #dim(crrntDet)       
}


# For source (C) - comma separated value file -
# source importNames_csv() function from file & run if importSource is a csv file
  # file gets: row/column indices for data & whether authority is attached, from user
  # file puts taxa into crrntDet data frame

# CALL & RUN importNames_csv() function if importSource is a csv file
if(csvImport==TRUE){
  print("... using csv method to import file...")
  # run the spreadsheet import method function
  source("O:/CMEP\ Projects/Scriptbox/database_importing/function_importNames_csv.R")
  # CALL & RUN function
  importNames_csv()
  # print dimensions of crrntDet
  #dim(crrntDet) #length(crrntDet)
}



# 2) get list of names from Padme? ([Latin Names].[sortName] -> nameZ)

# Q) Do your taxon names have authorities attached?
# if YES: nameVar <- [sortName]
# if NO:  nameVar <- [Full name]
# Need to improve this so it can run depending on what's entered.  
# For instance prompt user to enter Y/N, and then if Y set variable to use 
# [Latin Names].[sortName], if N set to use [Latin Names].[Full name].


# A) database method

if(dbImport==TRUE){
  print("... using database method to extract and check names... ")
  # source database name check method script
  source("O:/CMEP\ Projects/Scriptbox/database_importing/function_checkNames_db.R")
  # run the database name check method function
  checkNames_db()
}


# B) spreadsheet method
# source checkNames_xlsx() function from file & run if importSource is a xlsx file
# file gets: row/column indices for data & whether authority is attached, from user
# file puts taxa into crrntDet data frame

if(spsImport==TRUE) {
  print("... using spreadsheet method to extract and check names... ")
  # run the spreadsheet name check method function
  source("O:/CMEP\ Projects/Scriptbox/database_importing/function_checkNames_xlsx.R")
  # CALL & RUN function
  checkNames_xlsx()
}   


# C) csv methods
# source checkNames_csv() function from file & run if importSource is a csv file
# file gets: row/column indices for data & whether authority is attached, from user
# file puts taxa into crrntDet data frame

# CALL & RUN checkNames_csv() function if importSource is a csv file
if(csvImport==TRUE) {
  print("... using comma-separated-values file method to extract and check names... ")
  # run the csv name check method function
  source("O:/CMEP\ Projects/Scriptbox/database_importing/function_checkNames.R")
  # CALL & RUN function
  checkNames_csv() 
}   





# A) 
if(dbImport==TRUE && nrow(crrntDetREQFIX)!=0){
  # 4A) write list of non-matching names from comparison
  # ensure names of name-columns is the same to allow merge, set both column names to "taxa"
  #names(origNameREQFIX)[2] <- "taxa"
  names(crrntDetREQFIX) [2] <- "taxa"
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
  write.csv(allNames, fixMeLocat <- file.choose(), na="") 
  print(paste0("...", " names requiring manual checking/fixing saved to file >> ",fixMeLocat))
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


  # 6) THEN import the datA source to a new {Import Padme} which will have the 
  #new names etc and ought to match easily.
  # do this in Access, not from scripts
}



# 4B) spreadsheet
if(spsImport==TRUE && nrow(crrntDetREQFIX)!=0){
        ## are there any original names?
        # if NO: 
        # write out to a file to hold the fix-reqs
        message("........ choose or create a .CSV file to hold the names requiring checking/fixing")
        fixMeLocat <- file.choose()
        write.csv(
                crrntDetREQFIX, 
                file=fixMeLocat,
                row.names=FALSE,
                na=""
        ) 
        print(paste0(
                "... ", 
                nrow(crrntDetREQFIX),
                " names requiring manual checking/fixing saved to file >> ",
                fixMeLocat)
        )
        # if YES
        # ensure names of name-columns is the same/NULL to allow merge, set both
        # column names to "taxa" then merge both into one result to allow 
        # batchfix at once; create object for all the things left over 
        # (e.g  wrong/new names, lichens and fungi)
        # => "noMatch"
        #print(noMatch <- merge(crrntDetREQFIX, origNameREQFIX))
        # to fix from current Dets & orig Names together:
        #allNames <- unique(rbind(origNameREQFIX, crrntDetREQFIX))
        # show IDs and Unique Names 
        #namesOnly <- unique(allNames[2])
        # write out to a file to hold the fix-reqs
        #write.csv(allNames, "Z://fufluns/databasin/FixMe.csv", na="") 
} 


# 4C) csv method
if(csvImport==TRUE && length(crrntDetREQFIX)!=0){
        ## are there any original names?
        # if NO: 
        # write out to a file to hold the fix-reqs
        message("........ choose or create a .CSV file to hold the names requiring checking/fixing")
        fixMeLocat <- file.choose()
        write.csv(
                unique(crrntDetREQFIX), 
                fixMeLocat <- file.choose(), 
                na=""
        ) 
        print(paste0(
                "... ", 
                length(unique(crrntDetREQFIX)),
                " UNIQUE names requiring manual checking/fixing saved to file >> ",
                fixMeLocat)
        )
        
  # if YES
  # ensure names of name-columns is the same/NULL to allow merge, set both 
  #column names to "taxa" then merge both into one result to allow batchfix at 
  #once; create object for all the things left over (e.g  wrong/new names, lichens and fungi)
  # => "noMatch"
  #print(noMatch <- merge(crrntDetREQFIX, origNameREQFIX))
  # to fix from current Dets & orig Names together:
  #allNames <- unique(rbind(origNameREQFIX, crrntDetREQFIX))
  # show IDs and Unique Names 
  #namesOnly <- unique(allNames[2])
  # write out to a file to hold the fix-reqs
  #write.csv(allNames, "Z://fufluns/databasin/FixMe.csv", na="") 
} 

# VERY IMPORTANT!
# CLOSE THE CONNECTION!
odbcCloseAll()

        
# Instead of lots of rm()s, should use this to remove everything EXCEPT what you
# want to keep (e.g. connections, crrntDet, crrntDetREQFIX, etc):
rm(list=setdiff(ls(), c("crrntDet", "crrntDetREQFIX", "importSource", "locat_livePadmeArabia", 
                        "con_livePadmeArabia", "importPadmeCon", 
                        "livePadmeArabiaCon", "TESTPadmeArabiaCon"
                        )
                )
   )

print("... name checking complete!")