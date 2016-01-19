## FUNCTION :: function_getFlicsFields.R
# ==============================================================================
# 18 January 2016
# Author: Flic Anderson
#
# to call: getFlicsFields()
# objects created: herbSpxReqDet(altered)
# saved at: O://CMEP\-Projects/Scriptbox/general_utilities/function_getFlicsFields.R
# dependent on: "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R"
# dependent on: "O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R"
#
#
# AIM:  Function which pulls out Flic's specific Padme-Arabia fields for 
# ....  required herbarium specimen records needing sps-level dets 
# ....  (herbSpxReqDet object adapted from recGrab object, previously created/
# ....  adapted from function_getFamilies.R & function_getRanks.R & running on   
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

getFlicsFields <- function(){
 
        # check for herbSpxReqDet object
        exists("herbSpxReqDet")
        
        # recreate original herbarium specimen table ID (AGAIN!) 
        herbSpxReqDet <- 
                herbSpxReqDet %>%
                mutate(recID, origID=gsub("H-", "", recID))
        
        # create query to get/join herbarium specimens info
        qry <- "SELECT 
        [Herbarium specimens].[id] AS herbspecID,
        [Herbarium specimens].[FlicFound], 
        [Herbarium specimens].[FlicStatus],
        [Herbarium specimens].[FlicNotes],
        [Herbarium specimens].[FlicIssue]
        FROM [Herbarium specimens];"
        
        # run query, store as 'herbariaInfo' object
        FlicsFieldsInfo <- sqlQuery(con_livePadmeArabia, qry)
        
        # join ranks to recGrab records
        herbSpxReqDet <- sqldf("SELECT * FROM herbSpxReqDet LEFT JOIN FlicsFieldsInfo ON herbSpxReqDet.origID=FlicsFieldsInfo.herbspecID")
        
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
        
        # output message
        message(paste0(
                "... Flic's fields info added to the ", 
                nrow(herbSpxReqDet), 
                " herbarium specimens requiring species-level determination"
        ))
        
        }
