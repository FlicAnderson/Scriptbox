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
        
        # check for recGrab object
        # informative error if it doesn't exist
        if(!exists("recGrab")) stop("... ERROR: recGrab object doesn't exist")

        # recreate original herb specimen/field note/lit rec table ID 
        recGrabHerb <- 
                head(recGrab) %>%
                filter(grepl("H-", recID)) %>%
                mutate(recID, origID=gsub("[A-Z]-", "", recID))
        
        # recreate original herb specimen/field note/lit rec table ID 
        recGrabHerb <- 
                testGrab %>%
                filter(grepl("H-", recID)) %>%
                mutate(recID, origID=gsub("[A-Z]-", "", recID))
        
        # recreate original herb specimen/field note/lit rec table ID 
        recGrabFiel <- 
                head(recGrab) %>%
                filter(grepl("F-", recID)) %>%
                mutate(recID, origID=gsub("[A-Z]-", "", recID))
        
        #### TBC ####
        
        # create query to join expedition info
        qry <- "SELECT 
        [Expd].[id] AS expdID,
        [Expd].[expeditionTitle] AS expdName
        FROM [Expeditions] AS Expd;"
        
        # run query, store as 'herbariaInfo' object
        expeditionInfo <- sqlQuery(con_livePadmeArabia, qry)
        
        # join ranks to recGrab records
        recGrab <- sqldf("SELECT * FROM recGrab LEFT JOIN expeditionInfo ON recGrab.origID=expeditionInfo.expdID")
        
        # it shows herbariumCode: <NA> where there's no herbarium code, 
        # also shows herbspecID: NA - this doesn't matter, since the logic is OK :)
        # inner join doesn't include records with no herbarium code & is therefore inappropriate!
        
#         # remove additional herbspecID column & final column order:
#         herbSpxReqDet <<- herbSpxReqDet[,c(
#                 "recID", 
#                 "expdID",
#                 "collector", 
#                 "collNumFull", 
#                 "herbariumCode", 
#                 "lnamID", 
#                 "taxRank", 
#                 "familyName", 
#                 "acceptDetAs", 
#                 "acceptDetNoAuth", 
#                 "genusName", 
#                 "detAs", 
#                 "lat1Dir", 
#                 "lat1Deg", 
#                 "lat1Min", 
#                 "lat1Sec", 
#                 "lat1Dec", 
#                 "anyLat", 
#                 "lon1Dir", 
#                 "lon1Deg", 
#                 "lon1Min", 
#                 "lon1Sec", 
#                 "lon1Dec", 
#                 "anyLon", 
#                 "coordSource", 
#                 "coordAccuracy",
#                 "coordAccuracyUnits", 
#                 "coordSourcePlus", 
#                 "dateDD", 
#                 "dateMM", 
#                 "dateYYYY",
#                 "fullLocation"
#         )]
        
        # output message
        message(paste0(
                "... expedition info added to the ", 
                nrow(recGrab), 
                " records"
        ))
        
}