## FUNCTION :: function_getWorkingNames.R
# ==============================================================================
# 20 January 2016
# Author: Flic Anderson
#
# to call: getWorkingNames.R()
# objects created: herbSpxReqDet(altered)
# saved at: O://CMEP\-Projects/Scriptbox/general_utilities/function_getWorkingNames.R
# dependent on: "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R"
# dependent on: "O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R"
# source("O://CMEP\-Projects/Scriptbox/general_utilities/function_getWorkingNames.R")
#
# AIM:  Function which pulls out working name field info for 
# ....  required herbarium specimen records needing sps-level dets 
# ....  (herbSpxReqDet object adapted from recGrab object, previously created/
# ....  adapted from function_getFlicsFields.R & others & running on   
# ....  data from recGrab output of script_dataGrabFullLatLonOrGazLatLon_Socotra.R 
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

getWorkingNames <- function(){
        
        # check for herbSpxReqDet object
        # informative error if it doesn't exist
        if(!exists("herbSpxReqDet")) stop("... ERROR: herbSpxReqDet object doesn't exist")
        
        # check the connection is still open
        # informative error if connection not created
        if(!exists("con_livePadmeArabia")) stop("... ERROR: connection to the database not open")
        
        # recreate original herbarium specimen table ID (AGAIN!) 
        herbSpxReqDet <- 
                herbSpxReqDet %>%
                mutate(recID, origID=gsub("H-", "", recID))
        # create query to get/join herbarium specimens info
        qry <- "SELECT 
        [Herbarium specimens].[id] AS herbspecID,
        [Herbarium specimens].[workingName]
        FROM [Herbarium specimens];"
        
        # run query, store as 'herbariaInfo' object
        workingNamesInfo <- sqlQuery(con_livePadmeArabia, qry)
        
        # join ranks to recGrab records
        herbSpxReqDet <- sqldf("SELECT * FROM herbSpxReqDet LEFT JOIN workingNamesInfo ON herbSpxReqDet.origID=workingNamesInfo.herbspecID")
        
        #names(herbSpxReqDet)
        
        # remove additional herbspecID & origID columns & final column order:
        herbSpxReqDet <<- herbSpxReqDet[,c(
                "recID", 
                "collector", 
                "collNumFull", 
                "herbariumCode", 
                "lnamID", 
                "taxRank", 
                "familyName", 
                "acceptDetAs", 
                "acceptDetNoAuth", 
                "workingName",
                "genusName", 
                "detAs", 
                "lat1Dir", 
                "lat1Deg", 
                "lat1Min", 
                "lat1Sec", 
                "lat1Dec", 
                "AnyLat", 
                "lon1Dir", 
                "lon1Deg", 
                "lon1Min", 
                "lon1Sec", 
                "lon1Dec", 
                "AnyLon", 
                "coordSource", 
                "coordAccuracy",
                "coordAccuracyUnits", 
                "coordSourcePlus", 
                "dateDD", 
                "dateMM", 
                "dateYY",
                "fullLocation", 
                "FlicFound", 
                "FlicStatus", 
                "FlicNotes", 
                "FlicIssue" 
        )]
        
        # remove huge needless object :)
        rm(workingNamesInfo)
        
        # output message
        message(paste0(
                "... working name info added to the ", 
                nrow(herbSpxReqDet), 
                " herbarium specimens requiring species-level determination"
        ))
        
# END OF FUNCTION 
}


