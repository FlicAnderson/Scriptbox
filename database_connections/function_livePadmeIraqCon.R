## FUNCTION :: livePadmeIraqCon()
# ======================================================== 
# (8th July 2015)
# Author: Flic Anderson
#
# to call: livePadmeIraqCon()
# objects created: locat_livePadmeIraq; con_livePadmeIraq (locally global)
# saved at: O://CMEP\-Projects/Scriptbox/function_livePadmeIraqCon.R
#
# FUNCTION AIM: Set up and open connection to import copy of THULIN DATASET database, return confirmation.
#
# --------------------------------------------------------

# CODE # 

# install/load RODBC package if required
if (!require(RODBC)){
  install.packages("RODBC")
  library(RODBC)
} 

#define function
livePadmeIraqCon <- function(){
  # set up connection, needs to point to padmeCODE.mdb, otherwise the imported tables don't show up!
  # locat = location of padme data file
  locat_livePadmeIraq <<- "C:/Padme/iraq/padmecode.mdb"
  # open connection called "con" to file at known location
  # if this is already open it doesn't do any harm if this command is repeated I think
    # "<<-" operator below is used to globally assign the connection so the 'con_' object can be 
    # called outside the local environment i.e. by other scripts  
  con_livePadmeIraq <<- odbcConnectAccess(locat_livePadmeIraq)
  # check the connection is working 
  odbcGetInfo(con_livePadmeIraq)
  # return confirmation it's working:
  print(paste("... source database connection online: ", locat_livePadmeIraq))
}
