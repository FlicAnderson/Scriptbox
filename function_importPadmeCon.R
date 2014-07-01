### FUNCTION: importPadmeCon ###
### 3rd June 2014
### Set up and open connection to import copy of THULIN DATASET database, return confirmation.
###

# install/load RODBC package if required
if (!require(RODBC)){
  install.packages("RODBC")
  library(RODBC)
} 

#define function
importPadmeCon <- function(){
  # set up connection, needs to point to padmeCODE.mdb, otherwise the imported tables don't show up!
  # locat = location of padme data file
  locat_importPadme <<- "C:/Padme/import-copy-UPSthulin/padmecode.mdb"
  # open connection called "con" to file at known location
  # if this is already open it doesn't do any harm if this command is repeated I think
    # "<<-" operator below is used to globally assign the connection so the 'con_' object can be 
    # called outside the local environment i.e. by other scripts  
  con_importPadme <<- odbcConnectAccess(locat_importPadme)
  # check the connection is working 
  odbcGetInfo(con_importPadme)
  # return confirmation it's working:
  print(paste("...source database connection online: ", locat_importPadme))
}
###
### to call: importPadmeCon()
### objects created: locat_importPadme; con_importPadme (locally global)