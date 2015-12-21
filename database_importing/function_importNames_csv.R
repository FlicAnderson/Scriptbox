# Scriptbox :: function_importNames_csv.R
# ======================================================== 
# (18th November 2014)
# Author: Flic Anderson
# ~ function
# 

### FUNCTION: csv file name import method: importNames_csv
importNames_csv <- function(){  
  # call functions to open connections with live padme
  livePadmeArabiaCon()
  
# to find the subset of columns or rows, get user to enter the indexes required:

# REQUIRE USER INPUT FOR ROW SUBSET
# get first row:
message("........ enter FIRST ROW index to read in from")
message("........ headings are NOT counted, so 1 as first row is fine")
message("........ format: 1")
rowIndexFirst <<- as.numeric(readline(prompt="........ enter FIRST ROW index... "))
# get second row:
message("........ enter LAST ROW index to read in")
message("........ if uncertain as to exact number, overestimate slightly!")
message("........ format: 295")
rowIndexLast <<- as.numeric(readline(prompt="........ enter LAST ROW index... "))
# fix character -> numeric problem
rowIndex <<- rowIndexFirst:rowIndexLast
# rowIndex now contains range of rows to pull in and check.


# get column where species names are held (sp):
# colIndexSp holds sp
message("........ enter species name (sp) COLUMN index")
message("........ for example: column 10 contains 'Adenium obesum'")
message("........ format: 10")
colIndexSp <<- as.numeric(readline(prompt="........ enter species name (sp) COLUMN index... "))

# get column where subspecific names (ssp) are held:
# colIndexSsp holds ssp
message("........ enter subspecific epithets (ssp) COLUMN index")
message("........ for example column 11 contains 'subsp. sokotranum'")
message("........ subspecific names may be in separate column, or same column as species names")
message("........ NOTE: if there are NO subspecific epithets, enter same column as species names")
message("........ NOTE: if you are unsure, enter same column as species names")
message("........ format: 11")
colIndexSsp <<- as.numeric(readline(prompt="........ enter subspecific epithets (ssp) COLUMN index... "))

# get column where authorities are held (auth): 
# colIndexAuth holds auth
message("........ enter COLUMN index for taxon authorities (auth)")
message("........ for example column 12 contains '(Vierh.) Lav.'")
message("........ authorities may be in separate column, or same column as species names")
message("........ format: 12")
message("........ NOTE: if there is NO authority information, enter: 0")
colIndexAuth <<- as.numeric(readline(prompt="........ enter taxon authority name (auth) COLUMN index... "))


# if there aren't any authorities, use Lnam.[sortName] field for names
if(colIndexAuth==0){
        nameVar <<- "[sortName]"
} else {
        nameVar <<- "[Full name]"
}

# find any differences in the indices:
inputFormat <- c((colIndexSp==colIndexSsp),(colIndexSp==colIndexAuth), (colIndexSsp==colIndexAuth))


# all in same column
if(inputFormat[1]==TRUE && inputFormat[2]==TRUE && inputFormat[3]==TRUE){        
        # all in same column
        # set column index:
        colIndex <<- as.numeric(colIndexSp)
        
        # no joins necessary
        # import the file
        #check it pulls out the right data: strings NOT as.factors; ""=>NA
        crrntDet <<- read.csv(file=importSource, header=TRUE, as.is=TRUE, na.strings="", nrows=as.numeric(rowIndexLast))
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
        crrntDet <<- read.csv(file=importSource, header=TRUE, as.is=TRUE, na.strings="", nrows=as.numeric(rowIndexLast))
        # preserve dataframe structure & call variable "Taxon"
        crrntDet <<- data.frame(Taxon=crrntDet[as.numeric(rowIndex), as.numeric(colIndex)])
        
        # change variable name
        # change the column names using <<- operator to allow the changes to be
        # accessible from outside the function
        if(names(crrntDet)[1]!="Taxon"){
        names(crrntDet)[1] <<- "Taxon"   # use global env
        names(crrntDet)[1] <- "Taxon"    # use local env
        }
        
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
        fullnames <- crrntDet

        # if Auth is NOT 0, join columns AB (sp & ssp) to C (auth)
        # To Be Coded...
        
        
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



# # fix character -> numeric problem
# #colIndex <- as.numeric(colIndex)
# 
# 
# # OR REANABLE THESE TO HARD-CODE INDICES  
# #rowIndex <- 1:10
# #colIndex <- 21
# 
# 
# # import the file
# #check it pulls out the right data: strings NOT as.factors; ""=>NA
# crrntDet <<- read.csv(file=importSource, header=TRUE, as.is=TRUE, na.strings="", nrows=rowIndexLast)
# ## preserve dataframe structure & call variable "Taxon"
# crrntDet <<- data.frame(Taxon=crrntDet[as.numeric(rowIndex), as.numeric(colIndex)])
# 
# # change variable names
# # change the column names using <<- operator to allow the changes to be
# # accessible from outside the function
# names(crrntDet)
# names(crrntDet)[1] <<- "Species_Name"
# if(length(colIndex)==2){
#         names(crrntDet)[2] <<- "Additional_Info1"
# }
# if(length(colIndex)==3){
#         names(crrntDet)[3] <<- "Additional_Info2"
# }
# # if it's playing up and giving "object 'crrntDet' not found, use this (single <-, not <<-):
# #names(crrntDet)
# #names(crrntDet)[1] <- "Species_Name"
# #if(length(colIndex)==2){
# #        names(crrntDet)[2] <- "Additional_Info1"
# #}
# #if(length(colIndex)==3){
# #        names(crrntDet)[3] <- "Additional_Info2"
# #}
# names(crrntDet)
# 
# # missing values
# # are there any NA values in Species_Name column?
# anyNA(crrntDet[,1])
# # are there any NA values in Additional_Info column?
# anyNA(crrntDet[,2])
# # yes!
# # find rows where is.NA for column 2 is TRUE
# crrntDet[which(is.na(crrntDet[,2])==TRUE),]
# # set these cells to empty string
# crrntDet[which(is.na(crrntDet[,2])==TRUE),2] <- ""
# 
# # case problems
# # ensure subspecific epithets are all lowercase
# crrntDet[,2] <<- tolower(crrntDet[,2])
# #crrntDet
# # with ssp
# #exampl1 <- crrntDet[1,]
# # without ssp
# #exampl2 <- crrntDet[2,]
# 
# # using paste to complete the species names
# # (underscores used in examples below to show inserted spaces)
# #exampl3 <- paste(exampl1[,1], exampl1[,2])
# #[1] "Peperomia blanda_var. leptostachya"
# #exampl4 <- paste(exampl2[,1], exampl2[,2])
# #[1] "Peperomia tetraphylla_"
# 
# # take off any extra spaces
# #crrntDet[,1] <- gsub("[ ]$", "", crrntDet[,1])
# #crrntDet[,2] <- gsub("[ ]$", "", crrntDet[,2])
# # take off any spaces at beginning
# #crrntDet[,1] <- gsub("^[ ]", "", crrntDet[,1])
# #crrntDet[,2] <- gsub("^[ ]", "", crrntDet[,2])
# 
# # recreating the 'full' subspecific names:
# fullnames <- paste(crrntDet[,1], crrntDet[,2])
# #using gsub/etc to remove the NAs:
# # pattern which finds " NA"
# # pattern_NA <- " NA"
# fullnames <- gsub(" NA", "", fullnames)
# #using gsub/etc to remove the additional spaces:
# # pattern which finds end spaces:
# # pattern_endspace <- "[ ]$"
# fullnames <- gsub("[ ]$", "", fullnames)
# 
# # pattern which checks they're in the right format: 
# # pattern_rightformat <- "^[A-Za-z]+( [a-z])?"
# 
# # is format of data [crrntDet[,1]: 
# # if sum(allT/FsFromThat)=0 then it IS        
# 
# 
# #pattern_spbinomNoAuth: "^[A-Za-z]+( [a-z]*)+$"
# 
# #pattern_spbinomAuth: "^[A-Za-z]+( [a-z]*)+((([A-Za-z]*)[\.])$|( [A-Za-z]*)$|([A-Z][\.][A-Z][\.]([A-Za-z]*)([\.])?)$|([\(]([A-Za-z]*)[\.][\)]( [A-Za-z]*))[\.]?$|( ([A-Za-z])+[\.][a-z][\.])$|( ([A-Z][\.][A-Za-z]+))$|( ([\(]([A-Za-z]*)[\.]?[\)]( [A-Z][\.][A-Za-z]+)))$|(([A-Za-z])+ )[&]([ A-Za-z]+)$|( ([\(]([A-Za-z]*)[\.]?([a-z][\.])?[\)])( ([A-Za-z])+)( ([&]([ A-Za-z]+)))?)$|( [A-Z][\.][A-Za-z]+[\.])$)"
# # also at script/patternspbinomAuth.R or similar.
# 
# #pattern_subspNoAuth: "^[A-Za-z]+( [a-z]*)+( [a-z]*\.)+( [a-z]*)$"
# 
# #pattern_subspAuth: "^[A-Za-z]+( [a-z]*)+( [a-z]*\.)+( [a-z]*)( ([A-Za-z])+[\.][a-z][\.])$"
# 
# ## RE-ENABLE THIS WITH BETTER REGEX!!!
# # # define function to check if formats are right
# # #nameFormat <- function(){
# # #        sum(grepl("^[A-Z][a-z]( [a-z])?(( [A-Z][a-z])|( \([A-Z][a-z](.*))?", fullnames))==length(fullnames)
# # #}
# # #run function:
# # #nameForm <- nameFormat() 
# # 
# # # I currently have no idea why following seems to repeat the prints twice...
# # # but it seems harmless...
# # 
# # # return whether all names are in correct format or not
# # ifelse( # condition
# #         nameFormat(), 
# #         # I currently have no idea why following seems to repeat the prints twice...
# #         # but it seems harmless...
# #         # do if true:
# #         print("... all names in correct format; carry on with analysis"), 
# #         # do if false:
# #         print("... all names NOT in correct format; ACTION REQUIRED")
# # )
# #  ## Unfinished: need to implement a way of fixing format or outputting 
# #  ## those with formatting issues.  It's probably best to do this by hand

print("... name format not checked (TEMPORARY MEASURE), but data loaded in")
print("... this doesn't alter name checking process.")
#   
#crrntDet$Taxon <<- fullnames
#if(exists("crrntDet$Species_Name")){crrntDet$Species_Name <- NULL}

#  #dim(crrntDet)
}

# CALL & RUN function
#importNames_csv()