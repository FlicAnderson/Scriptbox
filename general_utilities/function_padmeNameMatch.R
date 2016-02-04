## FUNCTION :: function_padmeNameMatch.R
# ==============================================================================
# 25 August 2015
# Author: Flic Anderson
#
# to call: padmeNameMatch(checkMe=NULL, taxonType="species", authorityPresent=FALSE, taxonSingle=TRUE)
# objects created: [object1]; [object2] (locally global)
# saved at: O://CMEP\ Projects/Scriptbox/general_utilities/function_padmeNameMatch.R
# source("O://CMEP\ Projects/Scriptbox/general_utilities/function_padmeNameMatch.R")
#
# AIM:  Takes a user string taxon name & checks it against Latin Names table in 
# ....  Padme Arabia.  Confirms if exact match and suggests closest fuzzy match.
#
# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) load any requirements
# 1) check inputs are valid 
# 2) methods for taxon type options  (OPTIONAL & INCOMPLETE)
# 3) methods for authority options  (OPTIONAL & INCOMPLETE)
# 4) methods for single vs multiple taxa to check (INCOMPLETE)
# 5) database connections
# 6) fuzzy match checkMe taxa against Padme Latin Names
# 7) return matches & state of matches (exact, fuzzy, no match)
# 8) tidy: remove useless objects/close connections

# ---------------------------------------------------------------------------- #


# 0)
# load RODBC library
if (!require(RODBC)){
        install.packages("RODBC")
        library(RODBC)
} 
if (!require(stringdist)){
        install.packages("stringdist")
        library(stringdist)
} 


padmeNameMatch <- function(checkMe=NULL, taxonType="species", authorityPresent=FALSE, taxonSingle=TRUE){
        
 # 1)
        
        # check arguments are present & conform to options
        
        #args: 
        
        #checkMe: string input to check
        
        testThis <- checkMe
        
        # taxonType
        taxonType <- as.character(taxonType)
        
        possTaxonTypes <- c("family", "genus", "species", "subspecies", "variety")
        
        # check user input taxonType is acceptable from possTaxonTypes
        if(taxonType %in% possTaxonTypes){
                cat("\n", "... accepted taxon type")
        } else {
                cat("\n", "... taxonType not accepted; try one of: family, genus, species, subspecies, variety")
                stop("taxonType unacceptable")
                }
 
        
        # authorityPresent
        # check user input is boolean TRUE/FALSE
        # NB: is.logical() seems to accept NA as logical so is.na() used to avoid that;
        # NA will stop function & throw error
        
        if(!is.na(authorityPresent) && is.logical(authorityPresent)==TRUE){
                cat("\n", "... acceptable authorityPresent")       
        } else {
                cat("\n", "... authorityPresent must be logical: try TRUE or FALSE")
                if(is.na(authorityPresent)){cat("\n","... authorityPresent cannot be NA/missing value")}
                stop("authorityPresent type unacceptable")
        }
                
        
        # taxonSingle
        if(taxonSingle==FALSE){
                stop("... support for multiple taxa has not been written yet. Ask Flic about this")
        } else {
                cat("\n", "... single taxon check in progress")
        }
        
                
 # 2)   TO DO  
 
        
 # 3)   TO DO
        
        # set nameVar to pull out sortName by default (no auth)
        nameVar <<- "[sortName]"
                
        #        if(colIndexAuth==0){
        #                nameVar <<- "[sortName]"
        #        } else {
        #                nameVar <<- "[Full name]"
        #        }
        
 # 4)   TO FINISH:     
        
        # Single name vs Multiple names
        
        #taxonSingle
        # default: TRUE (will check one taxon)
        # options: FALSE (will accept various types of input)
        
        # (A) single taxon
                # (1) taxon options:  family, genus, species, subspecies, variety
                # (2) authority options: authority attached, authority separate, authority absent
        # (B) multiple taxa
                # (1) taxon options:  family, genus, species, subspecies, variety
                # (2) authority options: authority attached, authority separate, authority absent

        
 # 5)   
        
        # open database connections to Padme Arabia if not already open
        
        if(exists("con_livePadmeArabia")){
                cat("\n", "... database connection to Padme Arabia already open")
        } else {
                source("O:/CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R")
                invisible(livePadmeArabiaCon())
                cat("\n", "... opened database connection to Padme Arabia")
        }
        
 # 6)   # matching methods
        
        # pull out all distinct names {RODBC}
        nameGetQry <- paste0("SELECT DISTINCT ", nameVar, ", id FROM [Latin Names]")
        Lnams <- sqlQuery(con_livePadmeArabia, nameGetQry)
 
        # matching function {stringdist}:
        latMatch = function(string, stringVector){
                stringVector <- as.vector(stringVector)
                stringVector[amatch(string, stringVector, maxDist=Inf)]
        }
        
        # store output of matching function latMatch() as variable to return
        possMatch <<- latMatch(testThis, Lnams[,1])

 # 7)   # check if user's checkMe input is in Lnams & output match details
        if(checkMe %in% Lnams[,1]){
                cat("\n", "... checking complete:", testThis[1], "is an EXACT MATCH in Padme Arabia  :D")
        } else {
                cat("\n", "... entered name(s)", testThis[1], "NOT EXACT MATCH in Padme Arabia  :c")
                cat("\n", "... >>> did you mean:", possMatch, "?")
        }
        
        
 # 8) tidy phase
        rm(nameVar, possMatch, envir=.GlobalEnv)
        # NOTE: envir=.GlobalEnv argument added to remove following warning messages:
        #  Warning messages:
        #       1: In rm(nameVar, possMatch) : object 'nameVar' not found
        #       2: In rm(nameVar, possMatch) : object 'possMatch' not found
        # They weren't previously removed as they were in the global environment
        # since they'd been assigned by the '<<-' operator
}
