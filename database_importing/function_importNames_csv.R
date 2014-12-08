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
  
  # ask user whether taxon names have authorities attached 
  authCheck <<- readline(
    prompt="........ enter 'TRUE' if taxon names HAVE authorities 
    attached (ie. in same column), or 'FALSE' if there is NO authority 
    information attached... "
  )
  # convert the entered text to logical
  authCheck <- as.logical(authCheck)
  
  # IF taxon names HAVE authorities attached, use [Full name] field from database
  if(sum(authCheck)==1){
    nameVar <- "[Full name]"
  }
  # IF taxon names DO NOT HAVE authorities attached, use [sortName] Padme field
  if(sum(authCheck)!=1){
    nameVar <- "[sortName]"
  }
  
  # for a subset of columns or rows, enter the indexes required:
  # REQUIRE USER INPUT FOR COLUMN/ROW SUBSET
  rowIndexUser <<- readline(prompt="........ enter ROW index to read in - format '1:5' (if uncertain as to exact number, overestimate!) ... ")
  # fix character -> numeric problem
  inp <- as.numeric(strsplit(rowIndexUser, ":")[[1]]) 
  rowIndexUser <- inp[1]:inp[2]
  colIndexUser <<- readline(prompt="........ enter COLUMN index to read in - format '1,2' - 1st column species names, 2nd column for any subspecific epithets (example: column 1 contains 'Adenium obesum', column 2 contains 'subsp. sokotranum')... "
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

# CALL & RUN function
#importNames_csv()