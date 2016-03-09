## FUNCTION :: function_binJunkRecs.R
# ==============================================================================
# 09 March 2016
# Author: Flic Anderson
#
# to call: binJunkRecs(returnJunk=FALSE, chattyReturn=TRUE)
# objects created: recGrab(altered); recGrabJunk
# saved at: O://CMEP\-Projects/Scriptbox/general_utilities/function_binJunkRecs.R
# dependent on: "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R"
# dependent on: "O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R"
# source("O://CMEP\-Projects/Scriptbox/general_utilities/function_binJunkRecs.R
#
# AIM:  go through recGrab object records, exclude all records with NA, 0 or negative anyLats/anyLons
# ....  report back on numbers (if chattyReturn function argument =TRUE) & preserve recGrabJunk object
# ....  (if returnJunk function argument =TRUE).
#
# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) check inputs & prep for dplyr methods
# 1) filter out good records
# 2) filter out bad records
# 3) update recGrab object to exclude junk records
# 4) bin junk records object (recGrabJunk) as required by function argument

# ---------------------------------------------------------------------------- #

binJunkRecs <- function(returnJunk=TRUE, chattyReturn=TRUE){
        
# 0) CHECK INPUTS & PREP FOR DPLYR METHODS
        
        # check for recGrab object
        # informative error if it doesn't exist
        if(!exists("recGrab")) stop("... ERROR: recGrab object doesn't exist")
        
        # check returnJunk flag input
        # check user input is boolean TRUE/FALSE
        # NB: is.logical() seems to accept NA as logical so is.na() used to avoid that;
        # NA will stop function & throw error
        
        if(!is.na(returnJunk) && is.logical(returnJunk)==TRUE){
                if(chattyReturn==TRUE){
                        cat("... acceptable returnJunk input")   
                }
        } else {if(chattyReturn==TRUE){
                cat("\n", "... returnJunk must be logical: try TRUE or FALSE",  sep="")
                if(is.na(returnJunk)){cat("\n","... returnJunk cannot be NA/missing value", sep="")}
        }
                stop("returnJunk type unacceptable")
        }
        
        # create tbl_df obj
        recGrab <- tbl_df(recGrab)
        
# 1) FILTER OUT GOOD RECORDS
        
        # filter out good records
        recGrabFiltered <<- 
                recGrab %>%
                filter(!is.na(anyLat) & anyLat !=0 & anyLat > 0) %>%
                filter(!is.na(anyLon) & anyLon !=0 & anyLon > 0)
        
        # output messages
        if(chattyReturn==TRUE){
                message(paste0("... ", nrow(recGrabFiltered), " records OK for analyses (anyLat/anyLons valid)  :D"))
        }
        
# 2) FILTER OUT JUNK RECORDS
        
        # how many things excluded from filtered record set?
        #table(recGrab$recID %in% recGrabFiltered$recID)
        # get these indices
        #which(!(recGrab$recID %in% recGrabFiltered$recID))
        
        # filter out junk/excluded records (will keep for looking at if returnJunk=TRUE)
        recGrabJunk <<- recGrab[which(!(recGrab$recID %in% recGrabFiltered$recID)),]
        
        # output messages
        if(chattyReturn==TRUE){
                message(paste0("... ", nrow(recGrabJunk), " records removed (anyLat/anyLons invalid)  :c"))
        }
        
# 3) UPDATE RECGRAB TO EXCLUDE JUNK RECORDS
        
        # re-write recGrab to be only included records
        recGrab <<- recGrabFiltered   
        
# 4) BIN JUNK RECORDS IF SPECIFIED BY FUNCTION ARGUMENT 
        
        if(returnJunk==FALSE){
                rm(recGrabJunk)
        }
        
}