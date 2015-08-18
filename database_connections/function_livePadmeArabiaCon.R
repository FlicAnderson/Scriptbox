## FUNCTION :: livePadmeArabiaCon()
# ======================================================== 
# (3rd June 2014)
# Author: Flic Anderson
#
# to call: livePadmeArabiaCon()
# objects created: locat_livePadmeArabia; con_livePadmeArabia (locally global)
# saved at: O://CMEP\-Projects/Scriptbox/function_livePadmeArabiaCon.R
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

livePadmeArabiaCon <- function(){
  
  # set up connection, needs to point to padmeCODE.mdb, otherwise the imported tables don't show up!
  # locat = location of padme data file
  locat_livePadmeArabia <<- "C:/Padme/padmecode.mdb"
  
  # open connection called "con" to file at known location
  # if this is already open it doesn't do any harm if this command is repeated I think
  # "<<-" operator below is used to globally assign the connection so the 'con_' object can be 
  # called outside the local environment i.e. by other scripts  
  con_livePadmeArabia <<- odbcConnectAccess(locat_livePadmeArabia)
  
  # use this for details of connection:
  #odbcGetInfo(con_livePadmeArabia)
  
  # informative error if connection not created
  if(!exists("con_livePadmeArabia")) stop("... ERROR: connection not created")
  # return confirmation if connection works
  if(exists("con_livePadmeArabia")) print(paste("... source database connection online: ", locat_livePadmeArabia))
  
  # NOTE: If this error returned when sourced: 
    # "Error in odbcConnectAccess(locat_livePadmeArabia): 
    # odbcConnectAccess is only usable with 32-bit Windows"
  # then you need to use 32-bit R. In RStudio, check & change this under global options!
  
}