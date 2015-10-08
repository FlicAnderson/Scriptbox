## FUNCTION :: function_getFamilies.R
# ==============================================================================
# 14 August 2015
# Author: Flic Anderson
#
# to call: getFamilies()
# objects created: families; recGrab(altered)
# saved at: O://CMEP\-Projects/Scriptbox/general_utilities/function_getFamilies.R
# dependent on: "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R"
# dependent on: "O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R"
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

getFamilies <- function(){
        
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
        families <- sqlQuery(con_livePadmeArabia, qry)
 
        #message("... family names got: object named 'families' - ")
        #message("... link to LnSy.lnamID for finding families of accepted names") 
        #message("... or Herb.lnamID for not accepted names")
        
        # does recGrab object exist?  
        exists("recGrab")
        
        # create conditional temp variable
        #ifelse(exists("recGrab"),tmp <- "yes", tmp <- "no")
        
        recGrab <- sqldf("SELECT * FROM recGrab LEFT JOIN families ON recGrab.lnamid=families.member")
        #names(recGrab)

        # reorder to put familyName in front of detAsNoAuth, detAs and acceptDetAs
        # also drop 'member'
        recGrab <<- recGrab[,c(1:4,28,5:27)]
        #names(recGrab)
        
}
