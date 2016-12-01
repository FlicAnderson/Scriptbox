## FUNCTION :: function_getFamilies_Afghanistan.R
# ==============================================================================
# 29 November 2016
# Author: Flic Anderson
#
# to call: getFamilies_Afghanistan()
# objects created: families; recGrab(altered)
# saved at: O://CMEP\-Projects/Scriptbox/general_utilities/function_getFamilies_Afghanistan.R
# dependent on: "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeAfghanistanCon.R"
# dependent on: "O://CMEP\ Projects/Scriptbox/database_output/script_pullOutAfghanistanChecklistTaxa.R"
#
# AIM:  Function which adds taxonomic families to data in recGrab object  
# ....  previously created from script_dataGrabFullLatLonOrGazLatLon_Socotra.R 
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

getFamilies_Afghanistan <- function(){
        
        # check for recGrab object
        # informative error if it doesn't exist
        if(!exists("namesAF_filtered")) stop("... ERROR: namesAF object doesn't exist")
        
        # check the connection is still open
        # informative error if connection not created
        if(!exists("con_livePadmeAfghanistan")) stop("... ERROR: connection to the database not open")
        
        # create query
        qry <- "SELECT 
                [Latin Names].sortName AS familyName, 
                [names tree].member
                FROM (
                Ranks INNER JOIN [Latin Names] ON Ranks.id = [Latin Names].Rank) 
                INNER JOIN [names tree] ON [Latin Names].id = [names tree].[member of]
                WHERE (((Ranks.name)='family'))
                ;"
        
        # run query, store as 'families' object
        familiesAF <- sqlQuery(con_livePadmeAfghanistan, qry)
 
        #message("... family names got: object named 'families' - ")
        #message("... link to LnSy.lnamID for finding families of accepted names") 
        #message("... or Herb.lnamID for not accepted names")
        
        # does recGrab object exist?  
        #exists("recGrab")
        
        # create conditional temp variable
        #ifelse(exists("recGrab"),tmp <- "yes", tmp <- "no")
        
        namesAF_filtered <<- sqldf("SELECT * FROM namesAF_filtered LEFT JOIN familiesAF ON namesAF_filtered.lnamID=familiesAF.member")

        # drop needless member column:
        namesAF_filtered$member <<- NULL
        
}
