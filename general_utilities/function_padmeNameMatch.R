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
        is.character(checkMe)
        
        # check taxonomic name input checkMe is acceptable
        if(is.character(checkMe)==TRUE | is.factor(checkMe)==TRUE){
                cat(" ... checkMe is of OK type: character or factor")
        } else {
                cat(" ... checkMe is not of accepted type; try one of: character or factor")
                stop("checkMe type unacceptable")
        }
        
        testThis <<- checkMe
        
        # take first element only (if char string, first element is only element)
        testThis <<- as.character(checkMe[1])
        # this doesn't work with data.frames :c
        # big problems with the factor levels/level numbers issue
        # it's ok if the thing is assigned crrntDetREQFIX$Taxon, not if just crrntDetREQFIX
        # can then do as.character(checkMe[1]) if it's the former
        # then get: [1] "Peperomia blanda  (Jacq.) Kunth"
        
        # taxonType
        taxonType <- as.character(taxonType)
        
        possTaxonTypes <- c("family", "genus", "species", "subspecies", "variety")
        
        # check user input taxonType is acceptable from possTaxonTypes
        if(taxonType %in% possTaxonTypes){
                cat("\n", " ... accepted taxon type")
        } else {
                cat("\n", " ... taxonType not accepted; try one of: family, genus, species, subspecies, variety")
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
                # ok if checkMe is a factor but not a data frame
                # this should get checked at checkMe input check above
                        # something like:
                        # testThis length x
                        # run script
                        # testThis <- testThis[-remove tested first index]
                        # length testThis = x-1
                        # go to start of loop again
                        # repeat until x is gone?
                stop("... support for multiple taxa has not been written yet. Ask Flic about this")
        } else {
                cat("\n", "... single taxon check in progress")
        }
        

# 2) 
        # methods for taxon type options  (OPTIONAL & INCOMPLETE)                
        # TO DO  
 

# 3) 
        # methods for authority options  
        
        # authorityPresent
        # default: FALSE (doesn't check authority)
        # options: TRUE (will check authority)
                
        # NOTE: this will only check authority in same string as taxon name
        # support for authority in another column not in place currently!
        # in order to do this, perhaps develop from this: 
                #        if(colIndexAuth==0){
                #                nameVar <<- "[sortName]"
                #        } else {
                #                nameVar <<- "[Full name]"
                #        }
        
        if(authorityPresent==FALSE){
                # set nameVar to pull out sortName by default (no auth)
                cat("\n", "... authority information not present") 
                nameVar <<- "[sortName]"
        } else {
                # set nameVar to pull out [Full name] (+auth)
                cat("\n", "... authority information present")
                nameVar <<- "[Full name]"
        }
        
        
 # 4)        
        # methods for single vs multiple taxa to check (INCOMPLETE)
        # TO FINISH
        # Single name vs Multiple names
        
        #taxonSingle
        # default: TRUE (will check one taxon)
        # options: FALSE (will accept various types of input)
        
        # (A) single taxon
                # (1) taxon options:  family, genus, species, subspecies, variety
                # (2) authority options: authority attached, authority separate (NOT COVERED) , authority absent
        # (B) multiple taxa
                # (1) taxon options:  family, genus, species, subspecies, variety
                # (2) authority options: authority attached, authority separate (NOT COVERED), authority absent

        
        # B) 
        # 1) - most are likely to be species
        # 2) - usually will NOT have auth, but need to create method nonetheless
                # link this to section 3 (auth check, sets nameVar)
        

        
 # 5)   
        
        # open database connections to Padme Arabia if not already open
        # current;y getting error:
#         Error in sqlQuery(con_livePadmeArabia, nameGetQry) : 
#                 first argument is not an open RODBC channel 
        # uncertain why
        
        if(exists("con_livePadmeArabia")){
                cat("\n", "... database connection to Padme Arabia already open")
                #invisible(livePadmeArabiaCon())
                #cat("\n", "... database connection to Padme Arabia refreshed")
        } else {
                source("O:/CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R")
                invisible(livePadmeArabiaCon())
                cat("\n", "... opened database connection to Padme Arabia")
        }
        
 # 6)   # matching methods
        
        # pull out all distinct names {RODBC}
        nameGetQry <- paste0("SELECT DISTINCT ", nameVar, ", id FROM [Latin Names]")
        Lnams <<- sqlQuery(con_livePadmeArabia, nameGetQry)
 
        # matching function {stringdist}:
        latMatch = function(string, stringVector){
                stringVector <- as.vector(stringVector)
                stringVector[amatch(string, stringVector, maxDist=Inf)]
        }
        
        # store output of matching function latMatch() as variable to return
        possMatch <<- latMatch(testThis, Lnams[,1])

 # 7)   # check if user's checkMe input is in Lnams & output match details
        if(testThis %in% Lnams[,1]){
                cat("\n", "... checking complete:", testThis[1], "is an EXACT MATCH in Padme Arabia  :D")
        } else {
                cat("\n", "... entered name(s)", testThis[1], "NOT EXACT MATCH in Padme Arabia  :c")
                cat("\n", "... >>> did you mean:", possMatch, "?")
        }
        
        return(possMatch)
        
 # 8) tidy phase
        rm(nameVar, possMatch, envir=.GlobalEnv)
        # NOTE: envir=.GlobalEnv argument added to remove following warning messages:
        #  Warning messages:
        #       1: In rm(nameVar, possMatch) : object 'nameVar' not found
        #       2: In rm(nameVar, possMatch) : object 'possMatch' not found
        # They weren't previously removed as they were in the global environment
        # since they'd been assigned by the '<<-' operator
}
