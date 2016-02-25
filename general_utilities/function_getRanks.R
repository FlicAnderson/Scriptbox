## FUNCTION :: function_getRanks.R
# ==============================================================================
# 18 January 2016
# Author: Flic Anderson
#
# to call: getRanks()
# objects created: nameRanks; recGrab(altered)
# saved at: O://CMEP\-Projects/Scriptbox/general_utilities/function_getRanks.R
# dependent on: "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R"
# dependent on: "O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R"
#
# AIM:  Function which adds taxonomic ranks to data in recGrab object  
# ....  previously created/adapted from function_getFamilies.R & running on data  
# ....  from recGrab output of script_dataGrabFullLatLonOrGazLatLon_Socotra.R 
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

getRanks <- function(){
        
        # check for recGrab object
        # informative error if it doesn't exist
        if(!exists("recGrab")) stop("... ERROR: recGrab object doesn't exist")
        
        
        # check the connection is still open
        # informative error if connection not created
        if(!exists("con_livePadmeArabia")) stop("... ERROR: connection to the database not open")
        
        # create query
        qry <- "SELECT 
        [Latin Names].[id] AS tempLnamID,
        [Ranks].[name] AS taxRank
        FROM Ranks INNER JOIN [Latin Names] ON Ranks.id = [Latin Names].Rank
        ;"
        
        # NOTE: ranks done on accepted det LnamIDs - 
        # ie. when recGrab created by using LnSy.[id] AS lnamID, 
        # such as in script_dataGrabFullLatLonOrGazLatLon_Socotra.R
        # the Lnam.FullName is replaced by the ACCEPTED NAME (LnSy.[Full Name])
        # THIS IS NOT WHAT IT WAS ORIG DET AS BUT THE ACCEPTED UPDATED NAME
        # also using LnSy.[Full Name] AS acceptDetAs, LnSy.[sortName] AS acceptDetNoAuth
        
        # run query, store as 'nameRanks' object
        nameRanks <- sqlQuery(con_livePadmeArabia, qry)

        # getRanks()
        if("familyName" %in% names(recGrab)){
                # if getFamilies() has been run already, do this:
                message("... getFamilies() has already been run")
                message("... adding latin name ranks")
                
                # join ranks to recGrab records
                recGrab <- sqldf("SELECT * FROM recGrab LEFT JOIN nameRanks ON recGrab.lnamid=nameRanks.tempLnamID")
                #names(recGrab)
                
                # reorder to put taxRank in front of familyName
                # also drops/removes 'tempLnamID' column
                #recGrab <<- recGrab[,c(1:4,31,5:29)]
                
                recGrab <<- recGrab[,c(
                        "recID", 
                        "expdID",
                        "collector", 
                        "collNumFull", 
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
                
        } else {
                # if getFamilies() has NOT been run already, do this:
                message("... getFamilies() has NOT already been run!") 
                message("... adding latin name ranks anyway")
                
                # join ranks to recGrab records
                recGrab <- sqldf("SELECT * FROM recGrab LEFT JOIN nameRanks ON recGrab.lnamid=nameRanks.tempLnamID")
                #names(recGrab)
                
                # reorder to put taxRank in front of acceptDetAs
                # also drops/removes 'tempLnamID' column
                #recGrab <<- recGrab[,c(1:4,29,5:27)]
                recGrab <<- recGrab[,c(
                        "recID", 
                        "expdID", 
                        "collector", 
                        "collNumFull", 
                        "lnamID", 
                        "taxRank",
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
                
        }

        # output message
        message(paste0("... taxonomic rank info added to the ", nrow(recGrab), " selected records"))
}
