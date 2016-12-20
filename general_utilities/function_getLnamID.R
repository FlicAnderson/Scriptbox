## FUNCTION :: function_getLnamID.R
# ==============================================================================
# 16 December 2016
# Author: Flic Anderson
#
# to call: getLnamID(checkMe=NULL, authorityPresent=FALSE)
# objects created: Lnams; (locally global)
# saved at: O://CMEP\ Projects/Scriptbox/general_utilities/function_getLnamID.R
# source("O://CMEP\ Projects/Scriptbox/general_utilities/function_getLnamID.R")
#
# AIM:  Takes a user string taxon name & gathers LnamID, sortName & Full Name  
# ....  from Padme Arabia. Returns this as Lnams datafame.
#
# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) load any requirements
# 1) check inputs are valid 
# 2) 
# 3) 

# ---------------------------------------------------------------------------- #


# 0)

# load RODBC library
if (!require(RODBC)){
        install.packages("RODBC")
        library(RODBC)
} 

getLnamID <- function(checkMe=NULL, authorityPresent=FALSE){


        # if this is a data frame (ie dim(checkMe) IS NOT NULL, take 1st
        if(!(is.null(dim(checkMe)))){
                message("taking checkMe as checkMe[1,1] - if this is wrong, manually sort that")
                checkMe <<- checkMe[1,1]
        }
        # if this is a vector, take 1st
        if(length(checkMe)>1){
                checkMe <<- checkMe[1]
        }
        # if it's length 1, then we're good
        if(length(checkMe)==1){
                message("checkMe is fine")
        }
        
        # tranfer to char
        testThis <<- checkMe
        testThis <<- as.character(checkMe)

        # with auth or without?
        if(authorityPresent==FALSE){nameVar <<- "[sortName]"}  # << default
        if(authorityPresent==TRUE){nameVar <<- "[Full name]"}
        
        # check the connection is still open
        # informative error if connection not created
        if(!exists("con_livePadmeArabia")) stop("... ERROR: connection to the database not open")
        
        # build query
        nameGetQry <- paste0("SELECT * FROM [Latin Names] WHERE ", nameVar, "='", testThis, "';")
        Lnams <<- sqlQuery(con_livePadmeArabia, nameGetQry)

        # throw up errors if returns unexpected number of records
        if(dim(Lnams)[1]>1){
                stop("query fetches >1 record")
        }
        if(dim(Lnams)[1]<1){
                stop("query returns NO records")
        }

        # remove useless fields
        Lnams <<- Lnams[,c(1,15,52)]

        # rename id as lnamID for consistency
        Lnams$lnamID <- Lnams$id
        Lnams$id <- NULL
        
        # reorder
        Lnams <<- Lnams[,c(3,2,1)]
        Lnams <- Lnams[,c(3,2,1)]
        
        # change names so they don't confuse matters
        names(Lnams)[1] <<- "lnamID"
        names(Lnams)[2] <<- "acceptDetNoAuth"
        names(Lnams)[3] <<- "acceptDetAs"
        # change names so they don't confuse matters
        names(Lnams)[1] <- "lnamID"
        names(Lnams)[2] <- "acceptDetNoAuth"
        names(Lnams)[3] <- "acceptDetAs"
        
        
        # return dataframe for checked name
        return(Lnams)

}
