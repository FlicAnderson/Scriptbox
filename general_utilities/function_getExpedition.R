## FUNCTION :: function_getExpedition.R
# ==============================================================================
# 24 February 2016      
# Author: Flic Anderson
#
# to call: getExpedition()
# objects created: recGrab(altered)
# saved at: O://CMEP\-Projects/Scriptbox/general_utilities/function_getExpedition.R
# dependent on: "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R"
# dependent on: "O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R"
#
# AIM:  What this script is all about, why it was made, what
# ....  it does, etc.
# .... 
#
#
# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) 
# 1)  
# 2) 
# 3) 
# 4) 
# 5) 

# ---------------------------------------------------------------------------- #


# 0)

getExpedition <- function(){
        
        
        # check the connection is still open
        # informative error if connection not created
        if(!exists("con_livePadmeArabia")) stop("... ERROR: connection to the database not open")

        # check query scripts have run (qry1:herbRex & qry0:fielRex) 
        # informative error if connection not created
        if(!exists("herbRex")) stop("... ERROR: nothing to join expeditions to; herbRex doesn't exist yet")
        if(!exists("fielRex")) stop("... ERROR: nothing to join expeditions to; fielRex doesn't exist yet")
        
        # create query to join expedition info
        qry <- "SELECT 
        [Expd].[id] AS expdID,
        [Expd].[expeditionTitle] AS expdName
        FROM [Expeditions] AS Expd;"
        
        # run query, store as 'herbariaInfo' object
        expeditionInfo <- sqlQuery(con_livePadmeArabia, qry)
        
        
        
        # check for herbRex object
        # informative error if it doesn't exist
        if(exists("herbRex")){
        
                message("... adding expeditions to herbarium records")
                
                # join expedition names to recGrabHerb records
                recGrabHerb <- herbRex
                recGrabHerb <- sqldf(
                        "SELECT * 
                        FROM recGrabHerb 
                        LEFT JOIN expeditionInfo ON recGrabHerb.expdID=expeditionInfo.expdID"
                )
                
                # remove additional expdID column, & leave expdName & final column order:
                herbRex <<- recGrabHerb[,c(
                        "recID", 
                        "expdName",
                        "collector", 
                        "collNumFull", 
                        "lnamID", 
                        "acceptDetAs", 
                        "acceptDetNoAuth", 
                        "detAs", 
                        "lat1Dir", 
                        "lat1Deg", 
                        "lat1Min", 
                        "lat1Sec", 
                        "lat1Dec", 
                        "anyLat", 
                        "lon1Dir", 
                        "lon1Deg", 
                        "lon1Min", 
                        "lon1Sec", 
                        "lon1Dec", 
                        "anyLon", 
                        "coordSource", 
                        "coordAccuracy",
                        "coordAccuracyUnits", 
                        "coordSourcePlus", 
                        "dateDD", 
                        "dateMM", 
                        "dateYYYY",
                        "fullLocation"
                )]
                
                # end of herbarium expeditions-adding method
        }
        
        
        # check for fielRex object
        # informative error if it doesn't exist
        if(exists("fielRex")){
                
                message("... adding expeditions to field observation records")
                
                # join expedition names to recGrabHerb records
                recGrabFiel <- fielRex
                recGrabFiel <- sqldf(
                        "SELECT * 
                        FROM recGrabFiel 
                        LEFT JOIN expeditionInfo ON recGrabFiel.expdID=expeditionInfo.expdID"
                )
                
                # remove additional expdID column, & leave expdName & final column order:
                fielRex <<- recGrabFiel[,c(
                        "recID", 
                        "expdName",
                        "collector", 
                        "collNumFull", 
                        "lnamID", 
                        "acceptDetAs", 
                        "acceptDetNoAuth", 
                        "detAs", 
                        "lat1Dir", 
                        "lat1Deg", 
                        "lat1Min", 
                        "lat1Sec", 
                        "lat1Dec", 
                        "anyLat", 
                        "lon1Dir", 
                        "lon1Deg", 
                        "lon1Min", 
                        "lon1Sec", 
                        "lon1Dec", 
                        "anyLon", 
                        "coordSource", 
                        "coordAccuracy",
                        "coordAccuracyUnits", 
                        "coordSourcePlus", 
                        "dateDD", 
                        "dateMM", 
                        "dateYYYY",
                        "fullLocation"
                )]
                
                # end of field observations expeditions-adding method
        } 
        
        # output message
        message(paste0(
                "... expedition info added to ", 
                #nrow(recGrab), 
                nrow(herbRex)+nrow(fielRex),
                " records"
        ))
        
}