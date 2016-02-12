# Scriptbox :: function_latinNamesMatcher.R
# ======================================================== 
# (7th January 2016)
# Author: Flic Anderson
# ~ function
#
# to source: 
# source("O:/CMEP\ Projects/Scriptbox/database_importing/function_latinNamesMatcher.R")
# to run:
#latinNamesMatcher(fileLocat, fileName, rowIndex, colIndexSp, colIndexSsp, colIndexAuth, oneWordDescription)

# ---------------------------------------------------------------------------- #

# AIM: For use in other scripts, non-interactive version of script_latinNamesMatcher.R
# .... User input not required as inputs are now arguments to function itself.
# .... Based heavily on script_latinNamesMatcher.R (& dependents: function_importNames.R
# .... & function_checkNames.R)
# .... Note: still incomplete - doesn't have all cases of sp, ssp & auth combos yet!

# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 
# 0) Set up: Load libraries
# 1) Import/acquisition: source required scripts, deal with indices & taxonomic info
# 2) Check against padme names: get padme names through connection, compare names
# 3) Output fix-requiring names & report: write fix-req names to file, output summary to console
# 4) Tidy up & end: remove unnecessary objects, close connections

# ---------------------------------------------------------------------------- #


### FUNCTION: non-interactive complete check names thing
latinNamesMatcher <- function(fileLocat, fileName, rowIndex, colIndexSp, colIndexSsp, colIndexAuth, oneWordDescription, ...){  
# ARGUMENTS INFO:
        
        # fileLocat is the input & output file location; 
        # NOTE: should be a string
        
        # fileName is the name of the file to run function on (the file for importing); 
        # NOTE: should be a string
        
        # rowIndex contains vertical range of rows to pull in & check (where species names are held)
        
        # colIndexSp holds species names (sp)
        # colIndexSsp holds subspecific names (ssp)
        # NOTE: if there are NO subspecific epithets, enter same column as species names
        # NOTE: if you are unsure, enter same column as species names
        
        # colIndexAuth holds authorities (auth)
        # NOTE: if there is NO authority information, enter: 0
        
        # oneWordDescription should be a string with no spaces
        # NOTE: underscores are ok, make description useful (eg. "SocotraVegSurvey_2008")
        
# 0) SETUP PART
        
        # load RODBC library
        if (!require(RODBC)) {
                install.packages("RODBC")
                library(RODBC)
        }
        # load sqldf library
        if (!require(sqldf)) {
                install.packages("sqldf")
                library(sqldf)
        }
        
        # source functions:
        #source("O:/CMEP\ Projects/Scriptbox/function_importPadmeCon.R")
        source(
                "O:/CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R"
        )

        # test values
        #latinNamesMatcher(fileLocat, fileName, rowIndex=1:800, colIndexSp=5, colIndexSsp=5, colIndexAuth=6, "socotraProjectNames")
        
# 1) IMPORT/ACQUISITION PART 
        
        # call functions to open connections with live padme
        livePadmeArabiaCon()
        
        # import source:
        importSource <<- paste0(fileLocat, "/", fileName)
        
        # is file a .csv or something else?
        # get extension
        extns <- paste0(".", unlist(strsplit(importSource, "[.]"))[2])
        # check if it's not .csv & give informative error if it doesn't exist
        if(!grepl(".csv", extns)) stop("... ERROR: file not in .csv format, please save as .csv and try again")
        
        # if there aren't any authorities, use Lnam.[sortName] field for names
        if(colIndexAuth==0){
                nameVar <<- "[sortName]"
        } else {
                nameVar <<- "[Full name]"
        }
        
        # find any differences in the indices:
        inputFormat <- c(
                (colIndexSp==colIndexSsp),
                (colIndexSp==colIndexAuth), 
                (colIndexSsp==colIndexAuth)
        )
        
        # all in same column
        if(inputFormat[1]==TRUE && inputFormat[2]==TRUE && inputFormat[3]==TRUE){        
                # all in same column
                # set column index:
                colIndex <<- as.numeric(colIndexSp)
                
                # no joins necessary
                # import the file
                #check it pulls out the right data: strings NOT as.factors; ""=>NA
                crrntDet <<- read.csv(
                        file=importSource, 
                        header=TRUE, 
                        as.is=TRUE, 
                        na.strings="", 
                        nrows=as.numeric(length(rowIndex))
                )
                # preserve dataframe structure & call variable "Taxon"
                crrntDet <<- data.frame(Taxon=crrntDet[as.numeric(rowIndex), as.numeric(colIndex)])
                
                # change variable name
                # change the column names using <<- operator to allow the changes to be
                # accessible from outside the function
                names(crrntDet)
                names(crrntDet)[1] <<- "Species_Name"
                names(crrntDet)[1] <- "Species_Name"
                
                # missing values
                # are there any NA values in Species_Name column?
                if(anyNA(crrntDet)){                                    # << this is broken. Fix somehow!
                        # find rows where is.NA for column 2 is TRUE
                        crrntDet[which(is.na(crrntDet[,1])==TRUE),]
                        # set these cells to empty string
                        #crrntDet[which(is.na(crrntDet[,1])),1] <- ""
                        # STILL TO FIGURE OUT WHAT TO DO WITH THESE OR HOW TO REMOVE
                        # remove the rows entirely
                        #        crrntDet <- crrntDet[-which(is.na(crrntDet)),]
                }
                
                # recreating the 'full' subspecific names:
                fullnames <- crrntDet[,1]
                #using gsub/etc to remove the NAs:
                # pattern which finds " NA"
                # pattern_NA <- " NA"
                #fullnames <- gsub(" NA", "", fullnames)
                #using gsub/etc to remove the additional spaces:
                # pattern which finds end spaces:
                # pattern_endspace <- "[ ]$"
                fullnames <- gsub("([ ])+$", "", fullnames)
                
                # I think this belongs here?
                crrntDet$Taxon <<- fullnames
                # a temp one for interactive/building/debugging
                #crrntDet$Taxon <- fullnames
        }
        
        # if ALL columns different:
        if(inputFormat[1]==FALSE && inputFormat[2]==FALSE && inputFormat[3]==FALSE){        
                # ALL columns different
                # set column index (takes account of whether auth is 0 (ie absent)):
                invisible(ifelse(colIndexAuth==0, colIndex <- c(colIndexSp, colIndexSsp), colIndex <- c(colIndexSp, colIndexSsp, colIndexAuth)))
                
                # join columns A (sp) to B (ssp) & C (auth)
        }
        
        # if sp is different:
        if(inputFormat[1]==FALSE && inputFormat[2]==FALSE && inputFormat[3]==TRUE){        
                # sp is different
                # set column index:
                colIndex <- c(colIndexSp, colIndexSsp)
                
                # join columns A (sp) to BC (ssp & auth)
        }
        
        # if auth is different:
        if(inputFormat[1]==TRUE && inputFormat[2]==FALSE && inputFormat[3]==FALSE){        
                # auth is different
                
                # set column index (takes account of whether auth is 0 (ie absent)):
                invisible(ifelse(colIndexAuth==0, colIndex <- c(colIndexSp), colIndex <- c(colIndexSp, colIndexAuth)))
                
                # sp & ssp are the same column, and there is NO Authority:
                
                # import the file
                #check it pulls out the right data: strings NOT as.factors; ""=>NA
                crrntDet <<- read.csv(
                        file=importSource, 
                        header=TRUE, 
                        as.is=TRUE, 
                        na.strings="", 
                        nrows=length(rowIndex)
                )
                # preserve dataframe structure & call variable "Taxon"
                #crrntDet <<- data.frame(Taxon=crrntDet[as.numeric(rowIndex), as.numeric(colIndex)])
                crrntDet <<- data.frame(Taxon=crrntDet[as.numeric(rowIndex), as.numeric(colIndex)[1]], Authority=crrntDet[as.numeric(rowIndex), as.numeric(colIndex[2])])
                
#                 # change variable name of taxon column
#                 # change the column names using <<- operator to allow the changes to be
#                 # accessible from outside the function
#                 if(names(crrntDet)[1]!="Taxon"){
#                         names(crrntDet)[1] <<- "Taxon"   # use global env
#                         names(crrntDet)[1] <- "Taxon"    # use local env
#                 }
#                 
#                 # change variable name of Auth column
#                 # change the column names using <<- operator to allow the changes to be
#                 # accessible from outside the function
#                 if(names(crrntDet)[2]!="Authority"){
#                         names(crrntDet)[2] <<- "Authority"   # use global env
#                         names(crrntDet)[2] <- "Authority"    # use local env
#                 }
                
                # missing values
                # are there any NA values in Species_Name column?
                if(anyNA(crrntDet)){                                    # << this is broken. Fix somehow!
                        # find rows where is.NA for column 2 is TRUE
                        crrntDet[which(is.na(crrntDet[,1])==TRUE),]
                        # set these cells to empty string
                        #crrntDet[which(is.na(crrntDet[,1])),1] <- ""
                        # STILL TO FIGURE OUT WHAT TO DO WITH THESE OR HOW TO REMOVE
                        # remove the rows entirely
                        #        crrntDet <- crrntDet[-which(is.na(crrntDet)),]
                        
                        # maybe something about complete cases?
                }
                
                # ?for output's sake:?
                fullnames <- crrntDet
                
                # recreating the 'full' subspecific names:
                # if Auth is NOT 0, join columns AB (sp & ssp) to C (auth)
                crrntDet$Taxon <<- paste(crrntDet$Taxon, crrntDet$Authority, sep=" ")
                crrntDet$Authority <<- NULL
                
                # remove additional whitespace somehow
                #test <- crrntDet$Taxon 
                #sapply(crrntDet, gsub("\\s+", " ", crrntDet$Taxon))
                #testA <- vapply(crrntDet, gsub("\\s+", " ", test))
                
        }
        
        # if ssp is different: 
        # NOTE: THIS WILL NOT HAPPEN OFTEN AND CAN BE WRITTEN IF/WHEN IT DOES!
        if(inputFormat[1]==FALSE && inputFormat[2]==TRUE && inputFormat[3]==FALSE){        
                # ssp is different
                # set column index:
                colIndex <- c(colIndexSp, colIndexSsp)
                
                # join columns AC (sp & auth) to B (ssp)
                # split columns A & C (regex to split off authors)
                # rejoin columns as A B C...
                # rejoice
        }
        
# 2) CHECKING PADME-COMPARISON PART
        
        # get ALL unique taxon names (with/without authorities) in live database names table 
        # => "nameZ"
        qryB <- paste0("SELECT DISTINCT ", nameVar, ", id FROM [Latin Names]")
        nameZ <<- sqlQuery(con_livePadmeArabia, qryB)

        # RUN CHECK AGAINST PADME NAMES
        # vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
        crrntDetREQFIX <<- data.frame(Taxon=crrntDet[which(crrntDet$Taxon %in% nameZ[,1] == FALSE),])
        # ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        
        # output list of names which need to be fixed/examined
        if(nrow(crrntDetREQFIX)!=0){
                print(paste0(
                        "... ", 
                        nrow(crrntDetREQFIX), 
                        " names need to be fixed in total"
                        )
                )
        }
        if(nrow(crrntDetREQFIX)==0){
                print(paste0(
                        "...", 
                        " no names need to be fixed from determinations, no action required")
                )
        }

# 3) OUTPUT FIX-REQS AND REPORT
       
         if(nrow(crrntDetREQFIX)!=0){
                ## are there any original names?
                # if NO: 
                # write out to a file to hold the fix-reqs
                message("........ creating a .CSV file to hold the names requiring checking/fixing")
                
                # create file name & location string for new temporary fix file
                fixMeLocat <- paste0(
                        fileLocat, 
                        "/", 
                        #"TempFile_", 
                        as.character(oneWordDescription),
                        "_",
                        nrow(crrntDetREQFIX), 
                        "-FixRequiringNames", 
                        #Sys.Date(), 
                        ".csv"
                )
                
                # write out the fix-requiring names into csv file
                write.csv(
                        unique(crrntDetREQFIX), 
                        fixMeLocat, 
                        na=""
                ) 
                
                # print how many names require fixing
                print(paste0(
                        "... ", 
                        nrow(unique(crrntDetREQFIX)),
                        " UNIQUE names requiring manual checking/fixing"
                        )
                )
                
                # print file location
                print(paste0(
                        "... saved to file >> ",
                        fixMeLocat
                        )
                )
         }
        
# 4) TIDY UP & END

        # remove un-needed objects
        #rm(importSource, crrntDet, crrntDetREQFIX, nameZ, nameVar, relvNum)

        # alternate removal method: 
        # This removes EVERYTHING EXCEPT WHAT YOU WANT TO KEEP 
        # (eg. connections, crrntDet, crrntDetREQFIX, etc):
        #rm(list=setdiff(ls(), 
        #                 c(
        #                 "crrntDet", 
        #                 "crrntDetREQFIX", 
        #                 "con_livePadmeArabia", 
        #                 "livePadmeArabiaCon"
        #                 )
        #         )
        # )
        
        # VERY IMPORTANT!
        # CLOSE THE CONNECTION!
        odbcCloseAll()
        
# END OF FUNCTION
}

# TO CALL FUNCTION:
#checkNames_(rowIndex, colIndexSp, colIndexSsp, colIndexAuth, oneWordDescription)
