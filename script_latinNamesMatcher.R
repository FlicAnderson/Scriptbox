# Scriptbox :: script_latinNamesMatcher.R
# ======================================================== 
# (1st July 2014)
# Author: Flic Anderson
# ~ standalone script
# 


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
source("O:/CMEP\ Projects/Scriptbox/function_importPadmeCon.R")
source("O:/CMEP\ Projects/Scriptbox/function_livePadmeArabiaCon.R")

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
# follow these instructions... 
# ([0UPS].[nameNoAuth] -> origName) & ([0UPS].[currntDetNoAuth] -> crrntDet)

### FUNCTION: import-copy database name import method: importNames_db
importNames_db <- function(){
# call functions to open connections with import padme and live padme
  importPadmeCon()
  livePadmeArabiaCon()
# deal with non-plants issue, where lichens and things complicate matters:  
  # create original ALLPlants table
    # DO ONCE (already done)
    # copy [0UPS] table to allow us to delete non-plants from [0UPS] but still 
        #have a copy of them somewhere ready to import if necessary. 
    qry <- "SELECT * INTO 0ALLPlants FROM 0UPS"
    sqlQuery(con_importPadme, qry)
  # CREATE NON-PLANTS ONLY TABLE - can be imported separately if required at a 
        #later date, will contain non-import 'non-plants' e.g lichens
    # DO ONCE
    # copy [0UPS] table to allow us to delete non-plants from [0UPS] but still 
        #have a copy of them somewhere ready to import if necessary. 
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
}

# call function if importSource is a database file
if(dbImport==TRUE){
  print("...using database method to import file")
  importNames_db()
  # print dimensions of crrntDet
  print(dim(crrntDet))
}

 

# For source (B) - spreadsheet -
# follow these instructions... 
# column of names -> crrntDet

### FUNCTION: spreadsheet name import method: importNames_xlsx
importNames_xlsx <- function(){  
        # call functions to open connections with import padme and live padme
        #importPadmeCon()
        livePadmeArabiaCon()
        # for a subset of columns or rows, enter the indexes required:
        # REQUIRE INPUT FOR COLUMN/ROW SUBSET
        rowIndex <- readline(prompt="... Enter row index to read in - format '1:5' ... ")
        colIndex <- readline(prompt="... Enter column index to read in - format 'c(1,2)' - 1st column species names, 2nd column for any subspecific epithets... ")
        #rowIndex <- 4:921
        #colIndex <- c(4,6)  
        
        # import the file
        #check it pulls out the right data: 
        crrntDet <<- read.xlsx(file=importSource, sheetIndex=1, 
                               colIndex=colIndex, rowIndex=rowIndex, 
                               header=TRUE)
        
        # change variable names
        # change the column names using <<- operator to allow the changes to be
        # accessible from outside the function
        names(crrntDet)
        names(crrntDet)[1] <<- "Species_Name"
        names(crrntDet)[2] <<- "Subspecific_Epithet"
        names(crrntDet)
        
        # missing values
        # are there any NA values in Species_Name column?
        anyNA(crrntDet[,1])
        # are there any NA values in Subspecific_Epithet column?
        anyNA(crrntDet[,2])
        # yes!
        # find rows where is.NA for column 2 is TRUE
        crrntDet[which(is.na(crrntDet[,2])==TRUE),]
        # set these cells to empty string
        crrntDet[which(is.na(crrntDet[,2])==TRUE),2] <<- ""
        
        # case problems
        # ensure subspecific epithets are all lowercase
        crrntDet[,2] <<- tolower(crrntDet[,2])
        #crrntDet
        # with ssp
        #exampl1 <- crrntDet[1,]
        # without ssp
        #exampl2 <- crrntDet[2,]
        
        # using paste to complete the species names
        # (underscores used in examples below to show inserted spaces)
        #exampl3 <- paste(exampl1[,1], exampl1[,2])
        #[1] "Peperomia blanda_var. leptostachya"
        #exampl4 <- paste(exampl2[,1], exampl2[,2])
        #[1] "Peperomia tetraphylla_"
        
        # recreating the 'full' subspecific names:
        fullnames <- paste(crrntDet[,1], crrntDet[,2])
        #using gsub/etc to remove the additional spaces:
        # pattern which finds end spaces:
        # pattern_endspace <- "[ ]$"
        fullnames <- gsub("[ ]$", "", fullnames)
        
        # pattern which checks they're in the right format: 
        # pattern_rightformat <- "^[A-Za-z]+( [a-z])?"
        
        # is format of data [crrntDet[,1]: 
        # if sum(allT/FsFromThat)=0 then it IS        
        #pattern <- "^[A-Za-z]+( [a-z])?"
        
        # define function to check if formats are right
        nameFormat <- function(){
                sum(grepl("^[A-Z][a-z]( [a-z])?", fullnames))==length(fullnames)
        }
        #run function:
        # I currently have no idea why this seems to repeat the prints twice...
        # but it seems harmless...
        nameForm <- nameFormat() 
        
        # return whether all names are in correct format or not
        ifelse( # condition
                nameForm == TRUE, 
                # do if true:
                print("... all names in correct format; carry on with analysis"), 
                # do if false:
                print("... all names NOT in correct format; ACTION REQUIRED")
        )
        ## Unfinished: need to implement a way of fixing format or outputting 
        ## those with formatting issues.  It's probably best to do this by hand
        
        crrntDet$Taxon <<- fullnames
        dim(crrntDet)
}


# call function if importSource is a spreadsheet file
if(spsImport==TRUE) {
        print("... using spreadsheet method to import file")
        # load xlsx package to library
        if (!require(xlsx)){
                install.packages("xlsx")
                library(xlsx)
        }
        # run the spreadsheet import method function
        importNames_xlsx()
        # print dimensions of crrntDet
        dim(crrntDet)       
}
        

# For source (C) - comma separated value file -
# follow these instructions... 
# ??? -> crrntDet

### FUNCTION: csv file name import method: importNames_csv
importNames_csv <- function(){  
  # call functions to open connections with live padme
    livePadmeArabiaCon()
  # for a subset of columns or rows, enter the indexes required:
  # REQUIRE USER INPUT FOR COLUMN/ROW SUBSET
    rowIndexUser <<- readline(prompt="... Enter row index to read in - enter in format '1:10' ... ")
      # fix character -> numeric problem
      inp <- as.numeric(strsplit(rowIndexUser, ":")[[1]]) 
      rowIndexUser <- inp[1]:inp[2]
    colIndexUser <<- readline(prompt="... Enter column index to read in - format '1,2' - 1st column species names, 2nd column for any subspecific epithets... ")
      # fix character -> numeric problem
      colIndexUser <- as.numeric(strsplit(colIndexUser, ",")[[1]])
    # OR REANABLE THESE TO HARD-CODE INDICES  
    #rowIndex <- 1:10
    #colIndex <- 21
  # import the file
  #check it pulls out the right data: strings NOT as.factors; ""=>NA
  crrntDet <<- read.csv(file=importSource, header=TRUE, as.is=TRUE, na.strings="")
  # preserve dataframe structure & call variable "Taxon"
  crrntDet <<- data.frame(Taxon=crrntDet[as.numeric(rowIndexUser), as.numeric(colIndexUser)])
}

# call function if importSource is a csv file
if(csvImport==TRUE){
  print("... using csv method to import file")
  # run the spreadsheet import method function
  importNames_csv()
  # print dimensions of crrntDet
  #dim(crrntDet) 
  #length(crrntDet)
}


# 2) get list of names from Padme? ([Latin Names].[sortName] -> nameZ)


# A) database method
### FUNCTION: database file name check method: checkNames_db
checkNames_db <- function(){  
        # call functions to open connections with live padme
        livePadmeArabiaCon()
        # get list of all the number of sortnames (no authorities) and Latin Name IDs in the live database names table 
        # => "nameZ"
        qryA <- "SELECT sortName, id FROM [Latin Names]"
        nameZ <<- sqlQuery(con_livePadmeArabia, qryA)
        # where original names field exists along with determinations (leave commented & ignore this if there are no other dets):
        #origNameREQFIX <- sqldf("SELECT [origName].[id], [origName].[nameNoAuth] FROM origName LEFT JOIN nameZ ON nameNoAuth = sortName WHERE ((([nameZ].[id]) Is Null));")
        # for dets where no other original dets exist, list all taxon names from importSource where taxon name is NOT in Padme taxa list (nameZ) 
        # => "crrntDetREQFIX"
        crrntDetREQFIX <<- sqldf("SELECT [crrntDet].[id], [crrntDet].[currntDetNoAuth] FROM crrntDet LEFT JOIN nameZ ON currntDetNoAuth = sortName WHERE ((([nameZ].[id]) Is Null));")
        #I don't remember what this does but it can probably be deleted:
        #crrntDetREQFIX <- sqldf("SELECT currntDetNoAuth, id FROM crrntDet LEFT JOIN nameZ ON currntDetNoAuth = sortName WHERE (((id) Is Null));")  
        # output list of names which need to be fixed/examined
        if(nrow(crrntDetREQFIX)!=0){
                print(paste0(
                        "...", 
                        nrow(crrntDetREQFIX), 
                        " names need to be fixed from determinations << ",
                        importSource)
                )
        }
        if(nrow(crrntDetREQFIX)==0){
                print(paste0(
                        "...", 
                        " no names need to be fixed from determinations, no action required")
                )
        }
        #print(paste0("...", nrow(origNameREQFIX), " names need to be fixed from original names << ",importSource))
}


if(dbImport==TRUE){
        print("... using database method to extract and check names")
        # run the database name check method function
        checkNames_db()
}




# B) spreadsheet/csv method

### FUNCTION: xlsx file name check method: checkNames_xlsx
checkNames_xlsx <- function(){  
        # get list of all the number of unique sortnames (no authorities) in 
        # the live database names table & => "nameZ"
        qryB <- "SELECT DISTINCT sortName, id FROM [Latin Names]"
        nameZ <<- sqlQuery(con_livePadmeArabia, qryB)
        
        # where original names field exists along with determinations: 
        #(leave commented & ignore this if there are no other dets):
        # => "origNameREQFIX"
        #origNameREQFIX <- origName[which(origDet$Taxon %in% nameZ$sortName 
        #== FALSE),]
        # for dets where no other original dets exist, list all taxon names from
        #importSource where taxon name is NOT in Padme taxa list (nameZ) 
        # => "crrntDetREQFIX"
        
        crrntDetREQFIX <<- crrntDet[which(
                crrntDet$Taxon %in% nameZ$sortName == FALSE),]
        # output list of names which need to be fixed/examined
        if(nrow(crrntDetREQFIX)!=0){
        print(paste0(
                "...", 
                nrow(crrntDetREQFIX), 
                " names need to be fixed from determinations << ",
                importSource)
              )
        }
        if(nrow(crrntDetREQFIX)==0){
                print(paste0(
                        "...", 
                        " no names need to be fixed from determinations, no action required")
                      )
        }
        
        #print(paste0("...", nrow(origNameREQFIX), " names need to be fixed from original names <<",importSource))
}

if(spsImport==TRUE) {
  print("... using spreadsheet method to extract and check names")
  # run the spreadsheet name check method function
  checkNames_xlsx()
}   

# C) csv methods

### FUNCTION: csv file name check method: checkNames_csv
checkNames_csv <- function(){  
  # get list of all the number of unique sortnames (no authorities) in the live database names table 
  # => "nameZ"
  qryB <- "SELECT DISTINCT sortName FROM [Latin Names]"
  nameZ <<- sqlQuery(con_livePadmeArabia, qryB)
  # where original names field exists along with determinations (leave commented & ignore this if there are no other dets):
  # => "origNameREQFIX"
  #origNameREQFIX <- origName[which(origDet$Taxon %in% nameZ$sortName == FALSE),]
  # for dets where no other original dets exist, list all taxon names from importSource where taxon name is NOT in Padme taxa list (nameZ) 
  # => "crrntDetREQFIX"
  crrntDetREQFIX <<- crrntDet[which(crrntDet$Taxon %in% nameZ$sortName == FALSE),]
  # output list of names which need to be fixed/examined
    if(length(crrntDetREQFIX)!=0){
          print(paste0(
                  "...", 
                  length(crrntDetREQFIX), 
                  " names need to be fixed from determinations << ",
                  importSource)
          )
  }
  if(length(crrntDetREQFIX)==0){
          print(paste0(
                  "...", 
                  " no names need to be fixed from determinations, no action required")
          )
  }
  
  
  #print(paste0("...", length(origNameREQFIX), " names need to be fixed from original names << ",importSource))
}

if(csvImport==TRUE) {
  print("... using comma-separated-values file method to extract and check names")
  # run the csv name check method function
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
        write.csv(
                crrntDetREQFIX, 
                fixMeLocat <- "Z://fufluns/databasin/taxaDataGrab/FixMe.csv", 
                na=""
        ) 
        print(paste0(
                "...", 
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
  write.csv(unique(crrntDetREQFIX), fixMeLocat <- file.choose(), na="") 
  print(paste0(
          "...", 
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
rm(list=setdiff(ls(), c("crrntDet", "importSource", "locat_livePadmeArabia", 
                        "con_livePadmeArabia", "importPadmeCon", 
                        "livePadmeArabiaCon", "TESTPadmeArabiaCon"
                        )
                )
   )

print("... name checking complete")