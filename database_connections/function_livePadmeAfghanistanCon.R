## FUNCTION :: livePadmeAfghanistanCon()
# ======================================================== 
# 25 October 2016
# Author: Flic Anderson
#
# to call: livePadmeAfghanistanCon()
# objects created: locat_livePadmeAfghanistan; con_livePadmeAfghanistan (locally global)
# saved at: O://CMEP\-Projects/Scriptbox/function_livePadmeAfghanistanCon.R
#
# FUNCTION AIM: Set up and open connection to import copy of AFGHAN PADME database, return confirmation.
#
# --------------------------------------------------------

# CODE # 

# install/load RODBC package if required
if (!require(RODBC)){
  install.packages("RODBC")
  library(RODBC)
} 

#define function
livePadmeAfghanistanCon <- function(){
  # set up connection, needs to point to padmeCODE.mdb, otherwise the imported tables don't show up!
  # locat = location of padme data file
  locat_livePadmeAfghanistan <<- "C:/Padme/Afghanistan/padmecode.mdb"
  # open connection called "con" to file at known location
  # if this is already open it doesn't do any harm if this command is repeated I think
    # "<<-" operator below is used to globally assign the connection so the 'con_' object can be 
    # called outside the local environment i.e. by other scripts  
  con_livePadmeAfghanistan <<- odbcConnectAccess(locat_livePadmeAfghanistan)
  # check the connection is working 
  odbcGetInfo(con_livePadmeAfghanistan)
  # return confirmation it's working:
  print(paste("... source database connection online: ", locat_livePadmeAfghanistan))
}
