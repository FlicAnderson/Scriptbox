# Scriptbox :: function_importNames_xlsx.R
# ======================================================== 
# (18th November 2014)
# Author: Flic Anderson
# ~ function
# 

### FUNCTION: spreadsheet name import method: importNames_xlsx
importNames_xlsx <- function(){  
  # call functions to open connections with import padme and live padme
  #importPadmeCon()
  livePadmeArabiaCon()
  
  # ask user whether taxon names have authorities attached 
  authCheck <<- readline(
    prompt="........ enter 'TRUE' if taxon names HAVE authorities 
        attached (ie. in same column), or 'FALSE' if there is NO authority 
        information attached
        ... "
  )
  # convert the entered text to logical
  authCheck <- as.logical(authCheck)
  
  # IF taxon names HAVE authorities attached, use [Full name] field from database
  if(sum(authCheck)==1){
    nameVar <<- "[Full name]"
  }
  # IF taxon names DO NOT HAVE authorities attached, use [sortName] Padme field
  if(sum(authCheck)!=1){
    nameVar <<- "[sortName]"
  }
  
  # for a subset of columns or rows, enter the indexes required:
  # REQUIRE USER INPUT FOR COLUMN/ROW SUBSET
  rowIndexFirst <<- readline(prompt="........ enter FIRST ROW index to read in from - format '1' ... ")
  rowIndexLast <<- readline(prompt="........ enter LAST ROW index to read in - format '295' (if uncertain as to exact number, overestimate!) ... ")
  # fix character -> numeric problem
  rowIndex <- as.numeric(rowIndexFirst):as.numeric(rowIndexLast)
  
  colIndex <- readline(prompt="........ enter COLUMN index to read in - format '1,2' 
         - 1st column species names, 2nd column for any subspecific epithets 
         (example: column 1 contains 'Adenium obesum', column 2 contains 'subsp. sokotranum')
         ... "
  )
  colIndex <- c(as.numeric(unlist(strsplit(colIndex, split=",")))[1] , as.numeric(unlist(strsplit(colIndex, split=",")))[2])
  #rowIndex <- 1:86
  #colIndex <- c(6,7)
  
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
  # if it's playing up and giving "object 'crrntDet' not found, use this:
  #names(crrntDet)[1] <- "Species_Name"
  #names(crrntDet)[2] <- "Subspecific_Epithet"
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
  #crrntDet[which(is.na(crrntDet[,2])==TRUE),2] <<- ""
  
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
  
  # take off any extra spaces
  #crrntDet[,1] <- gsub("[ ]$", "", crrntDet[,1])
  #crrntDet[,2] <- gsub("[ ]$", "", crrntDet[,2])
  # take off any spaces at beginning
  #crrntDet[,1] <- gsub("^[ ]", "", crrntDet[,1])
  #crrntDet[,2] <- gsub("^[ ]", "", crrntDet[,2])
  
  # recreating the 'full' subspecific names:
  fullnames <- paste(crrntDet[,1], crrntDet[,2])
  #using gsub/etc to remove the NAs:
  # pattern which finds " NA"
  # pattern_NA <- " NA"
  fullnames <- gsub(" NA", "", fullnames)
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
  #nameForm <- nameFormat() 

  # I currently have no idea why following seems to repeat the prints twice...
  # but it seems harmless...
  
  # return whether all names are in correct format or not
  ifelse( # condition
    nameFormat() == TRUE, 
        # I currently have no idea why following seems to repeat the prints twice...
        # but it seems harmless...
    # do if true:
    print("... all names in correct format; carry on with analysis"), 
    # do if false:
    print("... all names NOT in correct format; ACTION REQUIRED")
  )
  ## Unfinished: need to implement a way of fixing format or outputting 
  ## those with formatting issues.  It's probably best to do this by hand
  
  crrntDet$Taxon <<- fullnames
  #dim(crrntDet)
}

# CALL & RUN function
#importNames_xlsx()