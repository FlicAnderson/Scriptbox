## FUNCTION :: function_getHerbrFamNums.R
# ==============================================================================
# 21 January 2016
# Author: Flic Anderson
#
# to call: getHerbrFamNums()
# objects created: herbSpxReqDet(altered)
# saved at: O://CMEP\-Projects/Scriptbox/general_utilities/function_getHerbrFamNums.R
# dependent on: "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R"
# dependent on: "O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R"
# source("O://CMEP\-Projects/Scriptbox/general_utilities/function_getHerbrFamNums.R")
#
# AIM:  Function which adds Edinburgh herbarium system family number info for 
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

# add herbarium's family numbers to the records
getHerbrFamNums <- function(){
        
        # check for herbSpxReqDet object
        # informative error if it doesn't exist
        if(!exists("herbSpxReqDet")) stop("... ERROR: herbSpxReqDet object doesn't exist")
        
        # to join to families at the genus level
        #GenusIndex <- read.csv("O:/CMEP Projects/Socotra/Herbarium Data/EHerbr-Genera-Family-Index.csv", na.strings = "")
        
        FamilyIndex <- read.csv("O:/CMEP Projects/Socotra/Herbarium Data/EHerbr-Family-FamilyNumber-Index.csv", na.strings = "")
        
        # to solve some missing families due to quirks of taxonomy and filing & such
        #FamilyUpdates <- read.csv("O:/CMEP Projects/Socotra/Herbarium Data/EHerbr-ExFamily-StoredFamily-FamilyNumber-Index.csv", na.strings = "")
        
        
        # THIS SOLUTION IS PARTIAL, AS IT CREATES A NESTED DATA FRAME - DO NOT WANT! :P
        # join E herbarium family numbers onto herbarium specimens object as "herbrFamilyNum" column
        #herbSpxReqDet$familyNumber <- sqldf("SELECT famNum AS herbrFamilyNum FROM herbSpxReqDet LEFT JOIN FamilyIndex ON herbSpxReqDet.familyName=FamilyIndex.StoredFamily")
        
        # join E herbarium family numbers onto herbarium specimens object as familyNumInfo dataframe
        familyNumInfo <- sqldf("SELECT famNum AS herbrFamilyNum FROM herbSpxReqDet LEFT JOIN FamilyIndex ON herbSpxReqDet.familyName=FamilyIndex.StoredFamily")
        
        # rejoin the data
        herbSpxReqDet <- cbind(herbSpxReqDet, familyNumInfo)

        # remove additional herbspecID & origID columns & final column order:
        herbSpxReqDet <<- herbSpxReqDet[,c(
                "recID", 
                "collector", 
                "collNumFull", 
                "herbariumCode", 
                "lnamID", 
                "taxRank", 
                "herbrFamilyNum",
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
                "fullLocation", 
                "FlicFound", 
                "FlicStatus", 
                "FlicNotes", 
                "FlicIssue" 
        )]
        
        # remove needless objects :)
        #rm()
        
        # output message
        message(paste0(
                "... E herbarium family system info added to the ", 
                nrow(herbSpxReqDet), 
                " herbarium specimens requiring species-level determination"
        ))
        
        
# END OF FUNCTION 
}


