## FUNCTION :: function_keepTaxRankOnly.R
# ==============================================================================
# 25 February 2016
# Author: Flic Anderson
#
# to call: keepTaxRankOnly()
# objects created: recGrab(altered)
# saved at: O://CMEP\-Projects/Scriptbox/general_utilities/function_keepTaxRankOnly.R
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

keepTaxRankOnly <- function(){
        
        # does recGrab object exist?  
        # informative error if recGrab doesn't exist
        if(!exists("recGrab")) stop("... ERROR: recGrab object doesn't exist")
        
        # create tbl_df obj
        recGrab <- tbl_df(recGrab)
        
        #table(recGrab$taxRank, useNA="ifany")
        # Class    Division      Family       forma       Genus 
        # 1          12         273           4        4136 
        # Sp.    Sp. Nov.     species sub complex   Subfamily 
        # 4          20       25588           3           2 
        # subspecies    variety     <NA> 
        #  431          422         288 
        
        # pull out records which will be excluded
        excludedRex <- 
                recGrab %>%
                filter(
                        taxRank=="Class"|
                                taxRank=="Division"|
                                taxRank=="Family"|
                                taxRank=="forma"|
                                taxRank=="Genus"|
                                taxRank=="Sp."|
                                #taxRank=="Sp. Nov."|
                                taxRank=="Subfamily"|
                                taxRank=="sub complex"|
                                is.na(taxRank)
                ) %>%
                arrange(collector, collNumFull)
        
        # output messages
        message(paste0("... ", nrow(excludedRex), " records removed (above sp-level determinations)  :c"))
        # 7423 records excluded 2016-02-25
        # 4720 records excluded 2016-03-06
        
        # amend recGrab object to contain only records with dets at species-level or below
        recGrab <<- 
                recGrab %>%
                filter(
                        taxRank=="species"|
                        taxRank=="subspecies"|
                        taxRank=="variety"|
                        taxRank=="Sp. Nov."
                ) %>%
                arrange(acceptDetAs, collector, collNumFull)
        
        # quick and dirty fix for output message not 'seeing' altered recGrab within function 
        # there should be a more elegant way but it's not vastly crucial & it's merely output
        recGrabEd <- 
                recGrab %>%
                filter(
                        taxRank=="species"|
                                taxRank=="subspecies"|
                                taxRank=="variety"|
                                taxRank=="Sp. Nov."
                ) %>%
                arrange(acceptDetAs, collector, collNumFull)
        
        # output messages
        message(paste0("... ", nrow(recGrabEd), " records OK for analyses (sp-level or below)  :D"))
        # 26441 records remain for analyses
        # 26475 records remain for analyses 2016-03-06

}
