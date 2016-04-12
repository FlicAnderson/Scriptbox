## FUNCTION :: function_addRecTypeColumn.R
# ==============================================================================
# 12 April 2016
# Author: Flic Anderson
#
# to call: addRecTypeColumn()
# objects created: recGrab(altered);
# saved at: O://CMEP\-Projects/Scriptbox/general_utilities/function_addRecTypeColumn.R
# dependent on: "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R"
# dependent on: "O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R"
# source("O://CMEP\ Projects/Scriptbox/general_utilities/function_addRecTypeColumn.R")
#
# AIM:  go through recGrab object records, for each record add entry to
# ....  recType column on end of dataset to show type of records
# ....  
#
# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) check inputs & prep for dplyr methods
# 1) 
# 2) 
# 3) 
# 4) 

# ---------------------------------------------------------------------------- #

addRecTypeColumn <- function(){
        
        # 0) CHECK INPUTS & PREP FOR DPLYR METHODS



# create tbl_df obj
recGrab <- tbl_df(recGrab)

# add recType column with record type code (H for herbarium specimen, F for field note, L for literature record)
recGrab <- 
        recGrab %>%
                # add column
                mutate(recID, recType=gsub("[-0-9]", "", recID))

recGrab <<- recGrab
}
