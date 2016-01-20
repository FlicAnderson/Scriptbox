## FUNCTION :: function_getHerbariumCode.R
# ==============================================================================
# 18 January 2016
# Author: Flic Anderson
#
# to call: getHerbariumCode()
# objects created: herbSpxReqDet; recGrab(altered)
# saved at: O://CMEP\-Projects/Scriptbox/general_utilities/function_getHerbariumCode.R
# dependent on: "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R"
# dependent on: "O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R"
#
# AIM:  Function which adds herbarium info to specimen data in recGrab object  
# ....  previously created/adapted from function_getFamilies.R &   
# ....  function_getRanks.R & running on data from recGrab output of 
# ....  script_dataGrabFullLatLonOrGazLatLon_Socotra.R 
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

getHerbariumCode <- function(){
        
        
        # check the connection is still open
        # informative error if connection not created
        if(!exists("con_livePadmeArabia")) stop("... ERROR: connection to the database not open")
        
        # check for recGrab object
        # informative error if it doesn't exist
        if(!exists("recGrab")) stop("... ERROR: recGrab object doesn't exist")
        
        # check for herbSpxReqDet object?  (ie has getDetReqSpx() been run?)
        # informative error if it doesn't exist
        if(!exists("herbSpxReqDet")) stop("... ERROR: herbSpxReqDet object doesn't exist")


        # recreate original herbarium specimen table ID 
        herbSpxReqDet <- 
        herbSpxReqDet %>%
                mutate(recID, origID=gsub("H-", "", recID))
        
        # create query to join herbarium info
        qry <- "SELECT 
        [Herbarium specimens].[id] AS herbspecID,
        [Herbaria].[Acronym] AS herbariumCode
        FROM [Herbarium specimens] 
        INNER JOIN [Herbaria] ON [Herbarium specimens].[Herbarium] = [Herbaria].[id]
        ;"
        
        # run query, store as 'herbariaInfo' object
        herbariaInfo <- sqlQuery(con_livePadmeArabia, qry)
        
        # join ranks to recGrab records
        herbSpxReqDet <- sqldf("SELECT * FROM herbSpxReqDet LEFT JOIN herbariaInfo ON herbSpxReqDet.origID=herbariaInfo.herbspecID")
        
        # it shows herbariumCode: <NA> where there's no herbarium code, 
        # also shows herbspecID: NA - this doesn't matter, since the logic is OK :)
        # inner join doesn't include records with no herbarium code & is therefore inappropriate!
 
        # remove additional herbspecID column & final column order:
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
                "fullLocation"
                )]
        
        # output message
        message(paste0(
                "... herbarium code info added to the ", 
                nrow(herbSpxReqDet), 
                " herbarium specimens requiring species-level determination"
                ))
        
}
