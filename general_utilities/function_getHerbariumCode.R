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
        
        # does recGrab object exist?  
        exists("recGrab")
        
        # does herbSpxReqDet object exist?  (ie has getDetReqSpx() been run?)
        exists("herbSpxReqDet")

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
        
        #names(herbSpxReqDet)
        
        # it shows herbariumCode: <NA> where there's no herbarium code, 
        # also shows herbspecID: NA - this doesn't matter, since the logic is OK :)
        # inner join doesn't include records with no herbarium code & is therefore inappropriate!
        
        # remove additional herbspecID column
        herbSpxReqDet <<- herbSpxReqDet[,c(1:3,33,4:30)]
        
        # output message
        message(paste0("... herbarium code info added to the ", nrow(herbSpxReqDet), " herbarium specimens requiring species-level determination"))
        
}
