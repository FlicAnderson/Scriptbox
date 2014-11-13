## FUNCTION :: TESTPadmeArabiaCon()
# ======================================================== 
# (3rd June 2014)
# Author: Flic Anderson
#
# to call: TESTPadmeArabiaCon()
# objects created: locat_TESTPadmeArabia; con_TESTPadmeArabia (locally global)
# saved at: O://CMEP\-Projects/Scriptbox/function_TESTPadmeArabiaCon.R
#
# FUNCTION AIM: Set up and open connection to TESTAREA test-database, return confirmation.
#
# --------------------------------------------------------

# CODE # 

# install/load RODBC package if required
if (!require(RODBC)){
  install.packages("RODBC")
  library(RODBC)
} 

#define function
TESTPadmeArabiaCon <- function(){
  # set up connection, needs to point to padmeCODE.mdb, otherwise the imported tables don't show up!
  # locat = location of padme data file
  locat_TESTPadmeArabia <<- "Z:/socotra/TESTAREA_Databasin/padmecode.mdb"
  # open connection called "con" to file at known location
  # if this is already open it doesn't do any harm if this command is repeated I think
    # "<<-" operator below is used to globally assign the connection so the 'con_' object can be 
    # called outside the local environment i.e. by other scripts  
  con_TESTPadmeArabia <<- odbcConnectAccess(locat_TESTPadmeArabia)
  # check the connection is working 
  odbcGetInfo(con_TESTPadmeArabia)
  # return confirmation it's working:
  print(paste("... source database connection online: ", locat_TESTPadmeArabia))
}
