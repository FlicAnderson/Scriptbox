## FUNCTION :: function_format.R
# ==============================================================================
# Day Month YYYY
# Author: Flic Anderson
#
# to call: [function]()
# objects created: [object1]; [object2] (locally global)
# saved at: O://CMEP\-Projects/Scriptbox/[folder]/[filename]
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
 
        message("... family names got: object named 'families' - ")
        message("... link to LnSy.lnamID for finding families of accepted names") 
        message("... or Herb.lnamID for not accepted names")
        
        # does recGrab object exist?  
        exists("recGrab")
        
        # create conditional temp variable
        #ifelse(exists("recGrab"),tmp <- "yes", tmp <- "no")
        
        recGrab <- sqldf("SELECT * FROM recGrab LEFT JOIN families ON recGrab.lnamid=families.member")
        #names(recGrab)

        # reorder to put familyName in front of detAsNoAuth, detAs and acceptDetAs
        # also drop 'member'
        recGrab <<- recGrab[,c(1:3,28,5:27)]
        #names(recGrab)
        
}
