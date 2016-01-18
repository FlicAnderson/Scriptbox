## FUNCTION :: function_getDetReqSpx.R
# ==============================================================================
# 18 January 2016
# Author: Flic Anderson
#
# to call: getDetReqSpx()
# objects created: herbSpxReqDet; recGrab(altered)
# saved at: O://CMEP\-Projects/Scriptbox/general_utilities/function_getDetReqSpx.R
# dependent on: "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R"
# dependent on: "O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R"
#
# AIM:  Function which pulls out herbarium records which need determinations to 
# ....  species level as herbSpxReqDet object adapted from recGrab object
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

getDetReqSpx <- function(){
        
        # does recGrab object exist?  
        exists("recGrab")
        
        # create tbl_df obj
        recGrab <- tbl_df(recGrab)
        
        # filter out only herbarium specimens
        herbSpx <- filter(recGrab, grepl("H-", recGrab$recID))
        # 6172 specimens
        
        #table(herbSpx$taxRank, useNA="ifany")
        #Division  Family       Genus        Sp.   Sp. Nov.    species  subspecies    variety  <NA>
        #1         245          374          2         18       5246        135        125      26
        
        herbSpxReqDet <<- 
                herbSpx %>%
                filter(
                        taxRank=="Division"|
                                taxRank=="Family"|
                                taxRank=="Genus"|
                                taxRank=="Sp."|
                                taxRank=="Sp. Nov."|
                                is.na(taxRank)
                ) %>%
                arrange(collector, collNumFull) 
        
        # herbSpxReqDet
        # 666 obs requiring species-level determinations
        
        # output message
        message(paste0("... ", nrow(herbSpxReqDet), " herbarium specimens require species-level determination"))
        
}
