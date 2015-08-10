# Padme Data:: endemicAnnotationsPadme.R
# ======================================================== 
# (6th July 2015)
# Author: Flic Anderson
# based on: "O:/CMEP Projects/Scriptbox/database_importing/script_ethnographicAnnotationsPadme.R"
# dependent on: "O:/CMEP Projects/Scriptbox/database_importing/script_latinNamesMatcher.R"; 
# ... "O://CMEP\-Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R"


# AIM: to write endemism annotation scores (by Anna Hunt from "Ethnoflora of
# ... Socotra") to categories already input into Padme and match the names in her
# ... spreadsheet to Padme latin names to allow linking of annotation scores to 
# ... Padme's tables by associating matching latin names with their Padme ID, 
# ... matching the column headings to annotation titles and annotation list 
# ... members and write in those scores to the annotation list selection table
# ... and other tables as necessary.

# list of functions defined: importEthnog_xlsx(readEthnogInfo); 

rm(list=ls())

# source functions:
# test location
#source("O:/CMEP\ Projects/Scriptbox/function_TESTPadmeArabiaCon.R")
source("O:/CMEP\ Projects/Scriptbox/function_livePadmeArabiaCon.R")
source("O:/CMEP\ Projects/Scriptbox/script_latinNamesMatcher.R")

# set up connection
#TESTPadmeArabiaCon()
livePadmeArabiaCon()


## ---------------------------- read-in phase ------------------------------ ##
# pull in the tables required 
# ... (Sys.sleep(5) included after every database table pull to prevent issues

# con_TESTPadmeArabia // con_livePadmeArabia
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

# taxa to annotate: 
dat <<- data.frame(idNo=1:nrow(crrntDet), taxaList=crrntDet$Taxon)

# categories possible from SetID 7:
sampleCats <- sqldf("SELECT Anti.annotationSetId, Anti.title, Anlm.display FROM (Anlm LEFT JOIN Anti ON Anlm.annotationTitleId=Anti.id) WHERE Anti.annotationSetId==7")
# any duplicate categories?
if(sum(duplicated(sampleCats))==1){
        print("... there are duplicate categories - action needed!")
#       sampleCats <- sampleCats[!duplicated(sampleCats)]
}

# Endemism & ethnographic scoring data and categories from spreadsheet (importSource) 
# compiled by student Anna Hunt during summer 2014 from Ethnoflora of Socotra

#importSource <- file.choose()
importSource <- "O://CMEP\ Projects//Socotra//Padme\ Data//Socotra SPECIES LIST.xlsx"
# get the extension
extns <- paste0(".", unlist(strsplit(importSource, "[.]"))[2])

# import method options...
# A) extns = database = .mdb
dbImport <- grepl(".mdb", extns)
# B) extns = spreadsheet = .xls/.xlsx
spsImport <- grepl(".xls|.xlsx", extns)    
# C) extns = comma separated value file = .csv
csvImport <- grepl(".csv", extns)

# function to read in actual endemic scores:
importEndemic_xlsx <<- function(){  
        
        # function to import the endemic annotation scores
        readEndemicInfo <<- function(){
                # for a subset of columns or rows, enter the indexes required:
                # headings in row 2
                startRow <- 5           # data starts row 5
                endRow <- 921           # data ends row 921   
                colIndex <- 9:98        # data starts col 9, data ends col 98
                
                # import the ethnographic scores & category names:
                # scores (uses faster read.xlsx2() function)
                ethnogScores <<- read.xlsx2(file=importSource, sheetIndex=1, 
                                            colIndex=colIndex, startRow=5, endRow=921, 
                                            as.data.frame=TRUE, header=FALSE)
                # things to fix (either in excel or here)
                #!!#    # remove "" levels and change to NA
                #!!#    # removed "?" levels and change to NA
                #!!#    # removed "2" levels and change to 1
                #!!#    # removed "1(fruit)" levels and change to 1
                #!!#    # removed "1(resin)" levels and change to 1
                
                # names (uses slightly slower read.xlsx function since more stable)
                ethnogScoreNames <<- read.xlsx(file=importSource, sheetIndex=1, 
                                               colIndex=colIndex, rowIndex=2, 
                                               as.data.frame=FALSE, header=FALSE)
                # change the names to character vector
                ethnogScoreNames <<- as.character(unlist(ethnogScoreNames))
        }
        # import ethnographic info/scores
        readEthnogInfo()
                        
        # make the dataframe from the taxa list (dat) and ethnographic scores
        datA <<- data.frame(dat, ethnogScores)
        dim(datA)
        # add the character vector names
        names(datA)[3:92] <- ethnogScoreNames
        
        dim(datA)
        #str(datA)
        
        # write out/read in to deal with missing & odd data (ie. 0, ?, etc)
        # write datA out to csv
        write.csv(datA, 
                  file="Z://fufluns//databasin//taxaDataGrab//ethnogOutput.csv", 
                  row.names=FALSE, 
                  na=""
                  ) 
        # then read it back in: 
        datA <- read.csv(
                file="Z://fufluns//databasin//taxaDataGrab//ethnogOutput.csv", 
                header=TRUE, 
                check.names=FALSE, 
                na.strings=c("?", "0")
                )
        dim(datA) ; names(datA)
        
        # function to match Latin name IDs from padme w/ datA$taxaList strings
        getPadmeLnamID <<- function(){
                # match the Latin Name IDs to the sample data
                padmeLnamID <<- sqldf("SELECT Lnam.id, datA.taxaList FROM datA LEFT JOIN Lnam ON datA.taxaList=Lnam.sortName")      
        }
        getPadmeLnamID() # run function; match Lnam.ids to datA$taxaList strings
        
        # if there are multiple IDs found for single names:
        if(nrow(padmeLnamID) > nrow(datA)){
                print("... more than one ID number found for each name")
        
                # fuction to find taxa with >1 Lnam.id value
                findTroubles <<- function(){
                        # there is more than one ID number found for each name
                        # order list by taxa to allow multiples to be seen
                        padmeLnamID_ord <<- padmeLnamID[
                                order(padmeLnamID$taxaList, padmeLnamID$id),
                                ]
                        
                        # in the ordered list, write TRUE next to all taxa names
                        # with more than one possible padme ID
                        padmeLnamID_ord$dupl <<- NA
                        for(i in (seq_along(1:nrow(padmeLnamID_ord)))-1){
                                a <- seq_along(2:nrow(padmeLnamID_ord))[i]
                                b <- 2
                                ifelse(
                                        padmeLnamID_ord[a,b]==padmeLnamID_ord[a-1,b], 
                                        c(padmeLnamID_ord[a,3] <<- TRUE, padmeLnamID_ord[a-1,3] <<- TRUE), 
                                        padmeLnamID_ord[a,3] <<- NA
                                )
                        }
                        #write.csv(padmeLnamID_ord, file="Z://fufluns//databasin//taxaDataGrab//taxaNamesPadmeIDs.csv")
                        
                        # show the duplicates
                        padmeLnamID_ord[which(padmeLnamID_ord$dupl=="TRUE"),]
                        # number of taxa duplicated
                        print(paste0(
                                "... ", 
                                length(unique(padmeLnamID_ord$taxaList[
                                        which(padmeLnamID_ord$dupl=="TRUE")])), 
                                " unique taxa with multiple padme Latin Name ID numbers")
                              )
                                
                }
                findTroubles()  # run findTroubles function
                
                # see detailed notes here for what was changed/fixed to obtain
                # 'correct' latin name IDs:
                source("Z:/fufluns/scripts/notes_latinNameCorrections_01-09-2014.R")
                
                # function to fix normal choice-fixes & taxonomically tricky 
                # choice-fixes once manual checking has been done:
                fixTroubles <<- function(){
                        # normal choice-fixes whitelist dataframe: 
                        # = correct IDs and names for the chosen latin name records
                        normalChoiceFixes <- data.frame(
                                correctID= c(2659, 6019, 10608, 4180, 2633, 3254, 3164), 
                                taxaList=c("Acokanthera schimperi", "Capparis spinosa", 
                                           "Corchorus aestuans", "Euphorbia chamaesyce",  
                                           "Pellaea viridis", "Peperomia tetraphylla", 
                                           "Senna sophera")
                        )
                        
                        # tricky choice-fixes whitelist dataframe: 
                        # = correct IDs and names for the chosen latin name records
                        trickyChoiceFixes <- data.frame(
                                correctID=c(2733, 2734, 2864, 10491, 3283, 3170), 
                                taxaList=c("Commiphora planifrons", "Commiphora socotrana", 
                                           "Farsetia stylosa", "Medicago minima" , 
                                           "Ochradenus baccatus", "Tephrosia purpurea")
                        )
                        
                        # padmeLnamID_ord with single-match Padme Latin Name IDs:
                        nrow(padmeLnamID_ord[which(is.na(padmeLnamID_ord$dupl)),])
                        # padmeLnamID_ord with ID numbers in normalChoiceFixes whitelist:
                        nrow(padmeLnamID_ord[which(padmeLnamID_ord$id %in% normalChoiceFixes$correctID),])
                        # padmeLnamID_ord with ID numbers in trickyChoiceFixes whitelist:
                        nrow(padmeLnamID_ord[which(padmeLnamID_ord$id %in% trickyChoiceFixes$correctID),])
                        
                        # whitelisted taxa ID's + already single-matching IDs:
                        correctIDsOnly <<- 
                                rbind(padmeLnamID_ord[which(padmeLnamID_ord$id %in% normalChoiceFixes$correctID),], 
                                      padmeLnamID_ord[which(padmeLnamID_ord$id %in% trickyChoiceFixes$correctID),],
                                      padmeLnamID_ord[which(is.na(padmeLnamID_ord$dupl)),]
                                )
                }
                fixTroubles()   # run fixTroubles() function to hard-code chosen Lnams
                
                # match the Latin Name IDs to the sample data
                padmeLnamID <<- sqldf("SELECT datA.taxaList, correctIDsOnly.id FROM datA LEFT JOIN correctIDsOnly ON datA.taxaList=correctIDsOnly.taxaList")
        } # end if() statement fixing multiple-IDs to single-name issue
                
        #dim(datA); names(datA); dim(padmeLnamID)
        if(nrow(padmeLnamID) == nrow(crrntDet)){
                print("... multiple Latin Name IDs resolved for all taxa, proceeding to bind these to the data")
        }
        
        # if/when they DO match: 
        # stick the Padme Latin Name IDs onto the ethnographic data dataframe:
        datA <- cbind(datA, padmeLnamID=padmeLnamID[,2])
        names(datA)
        # re-order the columns
        datA <<- (datA[, c(1, 2, ncol(datA), 3:(ncol(datA)-1))])
        
        #print(names(datA[1:4]))
        invisible(datA)

        # remove all the useless junk...
        #rm(list=setdiff(ls(), c("con_livePadmeArabia", "importPadmeCon", "livePadmeArabiaCon", "importEthnog_xlsx", "findTroubles", "fixTroubles", "getPadmeLnamID", "matchPadmeLnamID", "readEthnogInfo", "con_livePadmeArabia", "datA", "importSource", "spsImport", "extns", "locat_TESTPadmeArabia", "locat_livePadmeArabia", "Lnam", "Anse", "Anti", "Anno", "Anls", "Anlm")))
}      
#ends importhEthnog_xlsx() function

# NOW run actual read-in
if(spsImport==TRUE) {
        # run the spreadsheet ethnographic notes import function
        importEthnog_xlsx()
        #print(dim(datA))
        #print(names(datA[1:4]))      
}   


## ---------------------- prepare-write phase 1/2 --------------------------- ##

# now we try and write it to the database.

# Socotra Ethnographic Notes categories only (setID=7): 
# Anlm < Anti < Anse

# get list member IDs and titles from the Padme tables SQLselected earlier
listMemberID <- sqldf("SELECT Anlm.id, Anlm.display, Anti.title, Anti.id FROM (Anlm LEFT JOIN Anti ON Anlm.annotationTitleId=Anti.id) LEFT JOIN Anse ON Anti.annotationSetId=Anse.id WHERE Anse.id==7", stringsAsFactors=TRUE)

# make new sequential record ID numbers for Anls table (last highest +1 onwards)
IDlist <- seq(from=(max(Anls$id)+1), length.out=1500)
# make emptyish dataframe to hold the data
AnlsDat <- data.frame(id=1, latinNameId=1, selectionId=1, annotationSetId=1, annotationTitleId=1, annotationTitle=1)

# set row and column counters to 0 before loop begins
rowCount <- 0
colCount <- 0

# works as of 02/09/2014 14:15
# loop horizontally through columns 4:(end-column) in datA
# (column 4 is first ethnographic score column, 1:3 are names-related)
for(i in seq_along(4:ncol(datA))){
        # loop vertically through rows 1:(end-row) in datA
        for(j in seq_len(nrow(datA))){
                
                a <- (a <- seq_len(nrow(datA)))[j]      # a <- row[j]
                b <- (b <- 4:ncol(datA))[i]             # b <- column[i]

                # if cell datA[a,b] is not NA, and == 1 (use scored):
                if(!is.na(datA[a,b]) && datA[a,b]==1){
                        
                        rowCount <- rowCount+1          # increase rowcounter by 1
                        # write to AnlsDat dataframe [rowCount, column] <- thing to write:
                        
                        AnlsDat[rowCount,1] <- IDlist[rowCount]         # use next IDlist (next sequential Anls record ID)
                        AnlsDat[rowCount,2] <- datA$padmeLnamID[a]      # use padme latin name ID
                        AnlsDat[rowCount,4] <- 7                        # set Anls SelectionID (set ID) to 7=ethnographicUsesSocotra
                        AnlsDat[rowCount,5] <- NA                       # set Anls annotationTitleID to NA
                        
                        # if use-category-name (name(column[b] in datA)) is in list from Padme category titles:
                        if(names(datA[b]) %in% listMemberID$display){
                                # set x to index of matching name in listMemberID$display
                                x <- match(names(datA[b]), listMemberID$display) 
                                
                                AnlsDat[rowCount,3] <- listMemberID[x,1]        # set current rowcount $ annotation selection ID
                                AnlsDat[rowCount,6] <- listMemberID[x,2]        # set current rowcount $ annotation title
                                AnlsDat[rowCount,5] <- listMemberID[x,4]        # set current rowcount $ annotation title ID
                                
                        }       #close inner if()loop                        
                }        # close outer if() loop
        }       # close inner row loop i
        
        # increase column counter
        colCount <- colCount +1  
        
}       # close outer col loop j



### make object to hold any rows which hold missing values to be fixed later
# (it wasn't required!)
# NA Latin Name Rows
NAdump <- AnlsDat[which(is.na(AnlsDat$latinNameId)),]
# alert user to missing values
if(nrow(NAdump)>0){
        print(
                paste0(
                        "... ", 
                        nrow(NAdump), 
                        " records have NA (missing values) & need to be fixed. ACTION REQUIRED"))
}
# alert user to pending removal
if(nrow(NAdump)>0){
        print(
                paste0(
                        "... ", 
                        nrow(NAdump), 
                        " records with NA (missing values) have been removed TEMPORARILY & need to be re-added with code re-run; ACTION REQUIRED"))
}
# remove NA rows
AnlsData <- AnlsDat[which(!is.na(AnlsDat$latinNameId)),]
####

# remove the annotation Title field
AnlsData$annotationTitle <- NULL

# check names match
names(Anls)
names(AnlsData)

# remove extra junk
#rm(Anlm, Anse, Anti, Lnam, crrntDet, listMemberID, mockDat, padmeLnamID, sampleCats, IDlist, a, b, colCount, i, importSource, j, rowCount, x)

rm(list=setdiff(ls(), c("con_livePadmeArabia", "AnlsData", "AnlsDat", "Anls", "Anno", "NAdump")))


## ------------------------ write-out phase 1/2 ----------------------------- ##

# write records to [Anls] table:

#### RUN ONCE!!!###
# run 2nd September 2014, 7pm. No problems, 6879 records added #
##print("... STARTED writing annotation records to Padme's [Annotation List Selections] table")
##sqlSave(con_livePadmeArabia, dat=AnlsData, tablename="AnnotationListSelections", append=TRUE, rownames=FALSE, colnames=FALSE, verbose=FALSE, safer=TRUE, test=FALSE)
##print("... COMPLETED writing annotation records to Padme's [Annotation List Selections] table")
##################
# took ~60 seconds

# result:
Anls2 <- sqlQuery(con_livePadmeArabia, query="SELECT * FROM [AnnotationListSelections]")
dim(Anls)
dim(Anls2)

# print results:
print(paste0(
        "... ", 
        nrow(Anls2)-nrow(Anls), 
        " annotation records have been added to Padme's [Annotation List Selections] table")
      )


## ---------------------- prepare-write phase 2/2 --------------------------- ##

# BELOW WON'T WORK FOR "FREE TEXT" ANNOTATIONS, ONLY CATEGORY ONES:

# get the info from AnlsDat
# Anno makes a new row for each unique LatinNamesID & Annotation Title combo
# Eg. Species 1234 has 2 annotation selections from each of annotation titles 24, 25, 26, 
# this would give the following new Anno rows:
#       recID   LnamID  titleID         setID   annotationTextPlain
#       97      1234    24              7       1 and 2
#       98      1234    25              7       2 and 3
#       99      1234    26              7       1 and 3

lastRow <- Anno[nrow(Anno),]

AnnoDat <- AnlsDat
# split dataframe down to only latinNameId and annotationTitleId
AnnoDat <- AnnoDat[,c(2, 5)]
names(AnnoDat)[2] <- "annotationTitleID"
# pull out only rows where latinNameId and annotationTitleId are unique
AnnoDat <- unique(AnnoDat)

# create new id numbers following on from highest found in Anno table
AnnoDat$id <- seq(from=max(Anno$id)+1, length.out=nrow(AnnoDat))
AnnoDat$litRefID <- NA
AnnoDat$annotationSetId <- 7
AnnoDat$annotationTextRTF <- NA
AnnoDat$annotationTextPlain <- NA
AnnoDat$annotationTextHTML <- NA
AnnoDat$pandoraKey <- NA
AnnoDat$system <- 0
AnnoDat$edited <- 0
AnnoDat$publicationID <- 0
AnnoDat$rowId <- 0
AnnoDat$annotationTextHTMLPlain <- NA
#AnnoDat$latinNameId
AnnoDat$minValue <- NA
AnnoDat$maxValue <- NA
AnnoDat$listSelections <- NA
AnnoDat$litRecId <- NA
AnnoDat$annotationTextXML <- NA
AnnoDat$Field0 <- NA
AnnoDat$Field01 <- NA

# rearrange columns
AnnoDat <- AnnoDat[, c(3, 4, 5, 2, 6:14, 1, 15:21)]
#AnnoDat[c("id", "AnnoDat$litRefID", "AnnoDat$annotationSetId", "AnnoDat$annotationTitleID", "AnnoDat$annotationTextRTF", "AnnoDat$annotationTextPlain", "AnnoDat$annotationTextHTML", "AnnoDat$pandoraKey", "AnnoDat$system", "AnnoDat$edited", "AnnoDat$publicationID", "AnnoDat$rowId", "AnnoDat$annotationTextHTMLPlain", "AnnoDat$latinNameId", "AnnoDat$minValue", "AnnoDat$maxValue", "AnnoDat$listSelections", "AnnoDat$litRecId", "AnnoDat$annotationTextXML", "AnnoDat$Field0", "AnnoDat$Field01")]

# check data types from the Padme table & save these to use in our upload table
tableDetails <- sqlColumns(channel=con_livePadmeArabia, sqtable="Annotations")
varTypes <- as.character(tableDetails$TYPE_NAME)
names(varTypes) <- as.character(tableDetails$COLUMN_NAME)

# check all names are the same 
#(TRUE if so)
if(sum(names(AnnoDat) %in% tableDetails$COLUMN_NAME)==ncol(AnnoDat)){print("... all names match, proceeding with the write")}

# remove extra nonsense from the workspace
rm(list=setdiff(ls(), c("con_livePadmeArabia", "AnlsDat", "Anls", "Anno", "AnnoDat", "tableDetails", "varTypes", "NAdump")))

# test subset of data
AnnoTest <- data.frame(AnnoDat[1:5,])
#source("Z:/fufluns/scripts/script_ethnographicAnnotationsPadme.R")


## ------------------------ write-out phase 2/2 ----------------------------- ##

# write to [Anno] padme table:

#Run ONCE ONLY
##############
# run 2nd September 2014, 7pm. No problems, 3786 records added #
##print("... STARTED writing annotation records to Padme's [Annotations] table")
##sqlSave(con_livePadmeArabia, dat=AnnoDat, tablename="Annotations", append=TRUE, rownames=FALSE, colnames=FALSE, varTypes=varTypes, verbose=FALSE, fast=FALSE, safer=TRUE, test=FALSE, nastring=NULL)
##print("... COMPLETED writing annotation records to Padme's [Annotations] table")
############
# took ~25 seconds

# results
Anno2 <- sqlQuery(con_livePadmeArabia, query="SELECT * FROM [Annotations]")
dim(Anno)
dim(Anno2)

#  ...  Don't worry, this should not normally equal the number of new annotations you have added.
print(paste0("... ", nrow(Anno2)-nrow(Anno), " annotation records have been added to Padme's [Annotations] table"))

# remember to RE-ENABLE this!
print("... closing all connections to source database")
odbcCloseAll()

# pause 'for effect':
Sys.sleep(4)
print("...")
print("..")
print(".")
print("FINISHED adding ethnographic annotations to Padme! ^__^ ")



###-------------------------------------------------------------------------------------------------------------###

# Flic Anderson (c) 2014, 
# Research Associate at Centre for Middle Eastern Plants, RBGE