# Scriptbox :: function_importNames_db.R
# ======================================================== 
# (19th November 2014)
# Author: Flic Anderson
# ~ function
# 

### FUNCTION: import-copy database name import method: importNames_db
importNames_db <- function(){
  # THIS FUNCTION IS NOT FINISHED AND IS SPECIFIC TO OLD TABLENAME/FIELDNAMES
  message("...THIS FUNCTION IS NOT FINISHED AND IS SPECIFIC TO OLD TABLENAME/FIELDNAMES...")
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

# CALL & RUN function
#importNames_db()