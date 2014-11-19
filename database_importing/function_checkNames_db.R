# Scriptbox :: function_checkNames_db.R
# ======================================================== 
# (19th November 2014)
# Author: Flic Anderson
# ~ function
# 

### FUNCTION: database file name check method: checkNames_db
checkNames_db <- function(){  
  # call functions to open connections with live padme
  livePadmeArabiaCon()
  # get list of all the number of sortnames (no authorities) and Latin Name IDs in the live database names table 
  # => "nameZ"
  
  # ask user whether taxon names have authorities attached 
  authCheck <<- readline(
    prompt="... Enter 'TRUE' if taxon names HAVE authorities 
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
  
  qryA <- paste0("SELECT ", nameVar, ", id FROM [Latin Names]")
  nameZ <<- sqlQuery(con_livePadmeArabia, qryA)
  # where original names field exists along with determinations (leave commented & ignore this if there are no other dets):
  #origNameREQFIX <- sqldf("SELECT [origName].[id], [origName].[nameNoAuth] FROM origName LEFT JOIN nameZ ON nameNoAuth = sortName WHERE ((([nameZ].[id]) Is Null));")
  # for dets where no other original dets exist, list all taxon names from importSource where taxon name is NOT in Padme taxa list (nameZ) 
  # => "crrntDetREQFIX"
  crrntDetREQFIX <<- sqldf("SELECT [crrntDet].[id], [crrntDet].[currntDetNoAuth] FROM crrntDet LEFT JOIN nameZ ON currntDetNoAuth = nameVar WHERE ((([nameZ].[id]) Is Null));")
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

# CALL & RUN function
#checkNames_db()