# Scriptbox :: function_checkNames_csv.R
# ======================================================== 
# (18th November 2014)
# Author: Flic Anderson
# ~ function
# 

### FUNCTION: csv file name check method: checkNames_csv
checkNames_csv <- function(){  
  # get list of all the number of unique taxon names (with/without authorities) in the live database names table 
  # => "nameZ"
  qryB <- paste0("SELECT DISTINCT ", nameVar, ", id FROM [Latin Names]")
  nameZ <<- sqlQuery(con_livePadmeArabia, qryB)
  # where original names field exists along with determinations (leave commented & ignore this if there are no other dets):
  # => "origNameREQFIX"
  #origNameREQFIX <- origName[which(origDet$Taxon %in% nameZ$sortName == FALSE),]
  # for dets where no other original dets exist, list all taxon names from importSource where taxon name is NOT in Padme taxa list (nameZ) 
  # => "crrntDetREQFIX"
  
  # vvvvvvvvvvvvvv  THIS ROW NEEDS CHECKING!!!  vvvvvvvvvvvvvvvvvv
  crrntDetREQFIX <<- crrntDet[which(crrntDet$Taxon %in% nameZ[,1] == FALSE),]
  # ^^^^^^^^^^^^^^  THIS ROW NEEDS CHECKING!!!  ^^^^^^^^^^^^^^^^^^
  #line above replaces line below:
  #crrntDetREQFIX <<- crrntDet[which(crrntDet$Taxon %in% nameZ$sortName == FALSE),]
  
  # output list of names which need to be fixed/examined
  if(nrow(crrntDetREQFIX)!=0){
    print(paste0(
      "... ", 
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
    
  #print(paste0("...", length(origNameREQFIX), " names need to be fixed from original names << ",importSource))
}

# CALL & RUN function
#checkNames_csv()