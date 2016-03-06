## Socotra Project :: script_checkSpeciesListSocotra.R
# ==============================================================================
# (12th Feb 2016)
# Author: Flic Anderson
#
# dependent on: 
# saved at: O://CMEP\ Projects/Scriptbox/data_various/script_checkSpeciesListSocotra.R
# source("O://CMEP\ Projects/Scriptbox/data_various/script_checkSpeciesListSocotra.R")
#
# AIM: Check names in Alan's sample spreadsheet for the Socotra project against 
# .... Padme Arabia names and output list of those which need checking - likely
# .... these will need some Authority info or spellings corrected, but also there
# .... will definitely need to be updates and corrections made to Padme, including
# .... recent taxonomic changes entered.
# .... Also names matching will operate as base/check for linking samples/EDINA 
# .... IDs & allowing this data to be pulled into future analyses

# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) Load libraries, functions, source scripts
# 1) 
# 2) 
# 3) 
# 4) 
# 5) 
# 6) end; close connections, tidy up objects 

# ---------------------------------------------------------------------------- #

# 0) 

# load required packages, install if they aren't installed already
# {RODBC} - ODBC Database Access
if (!require(RODBC)){
        install.packages("RODBC")
        library(RODBC)
}
# {dplyr} - manipulating data & large data frames as tbl_df objects
if (!require(dplyr)){
        install.packages("dplyr")
        library(dplyr)
}
# load sqldf library
if (!require(sqldf)) {
        install.packages("sqldf")
        library(sqldf)
}

# open connection to live padme
source("O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R")
livePadmeArabiaCon()

# load function 
source("O:/CMEP\ Projects/Scriptbox/database_importing/function_latinNamesMatcher.R")


# 1) 

fileLocat <- "O://CMEP\ Projects/Socotra"

fileName <- "SocotraSPECIES-LIST_NOTES.csv"


#latinNamesMatcher(fileLocat, fileName, rowIndex, colIndexSp, colIndexSsp, colIndexAuth, oneWordDescription)
latinNamesMatcher(fileLocat, fileName, rowIndex=1:798, colIndexSp=5, colIndexSsp=5, colIndexAuth=6, "socotraProjectNamesMar2016")

#latinNamesMatcher(fileLocat, fileName, rowIndex, colIndexSp, colIndexSsp, colIndexAuth, oneWordDescription)
latinNamesMatcher(fileLocat, fileName, rowIndex=800:834, colIndexSp=5, colIndexSsp=5, colIndexAuth=5, "socotraProjectNamesMar2016_ferns")

#latinNamesMatcher(fileLocat, fileName, rowIndex, colIndexSp, colIndexSsp, colIndexAuth, oneWordDescription)
latinNamesMatcher(fileLocat, fileName, rowIndex=838:858, colIndexSp=5, colIndexSsp=5, colIndexAuth=6, "socotraProjectNamesMar2016_doubtful")

#latinNamesMatcher(fileLocat, fileName, rowIndex, colIndexSp, colIndexSsp, colIndexAuth, oneWordDescription)
latinNamesMatcher(fileLocat, fileName, rowIndex=862:967, colIndexSp=5, colIndexSsp=5, colIndexAuth=6, "socotraProjectNamesMar2016_introduced")

# need to fix NA auth situation & NA NA situations
# also need to strip out the extra whitespace - but best to do this with care
        # best to output original input AND column with how it *should* be (fixed)
        # that allows easier Ctrl+H replace in original document if necessary
        # it probably originates from the concat operation, often seems to be 2 
        # spaces at join


# 2)

# test taxa
test1 <- "Peperomia blanda  (Jacq.) Kunth"
test2 <- "Peperomia tetraphylla  Hook. & Arn."
test3 <- "Eulophia petersii (Rchb.f.) Rchb.f."
test4 <- "Cyanixia socotrana (Balf.f.) Goldblatt & J.C.Manning"
test5 <- "Aloe jawiyon Christie, Hannon & Oakham"
test6 <- "Asparagus sp. A NA"
test7 <- "Chlorophytum graptophyllum  (Baker) A. G. Mill."
test8 <- "Chlorophytum sp. nov. NA"
test9 <- "Dipcadi guichardii  Radcl.-Sm."
test10 <- "Dipcadi kuriensis  A.G.Mill."



# need to integrate the fuzzy names matcher script to suggest matches to make edits
# and corrections easier - maybe do this using dplyr and then mutate(function) new column

# source that function
source("O://CMEP\ Projects/Scriptbox/general_utilities/function_padmeNameMatch.R")
# to call: padmeNameMatch(checkMe=NULL, taxonType="species", authorityPresent=FALSE, taxonSingle=TRUE)
# need to edit it to deal with multiple taxa (create method for taxonSingle=FALSE)

padmeNameMatch(checkMe=test1, taxonType="species", authorityPresent=TRUE, taxonSingle=TRUE)

# dplyr everything necessary

#crrntDet_tbldf <- tbl_df(crrntDet)
#crrntDetREQFIX_tbldf <- tbl_df(crrntDetREQFIX)

#crrntDetREQFIX_tbldf %>% 
#        mutate(Taxon, fixName=padmeNameMatch(checkMe=Taxon, authorityPresent=TRUE))

#padmeNameMatch(checkMe=crrntDetREQFIX_tbldf$Taxon, authorityPresent=TRUE)

# postcodeDistrict <- function(postcode) strsplit(toupper(postcode), " ")[[1]][1]
# newTable <- postcodeTable %>%
#         rowwise() %>%
#         mutate(District = postcodeDistrict(Postcode))

#http://www.expressivecode.org/2014/12/17/mutating-using-functions-in-dplyr/

# dplyr method
source("O://CMEP\ Projects/Scriptbox/general_utilities/function_padmeNameMatch.R")
crrntDetREQFIX_tbldf %>%
        rowwise() %>%
        mutate(bestGuess=padmeNameMatch(checkMe=crrntDetREQFIX_tbldf$Taxon, taxonType="species", authorityPresent=TRUE, taxonSingle=TRUE))
# this just gives Peperomia blanda X 10


# vectorised function  - unfinished
#batchNameMatch <- function(p) sapply(p, padmeNameMatch(checkMe=crrntDetREQFIX_tbldf$Taxon)
#crrntDetREQFIX_tbldf$bestGuess <- batchNameMatch(crrntDetREQFIX_tbldf$Taxon)

# cbind function 
newtable <- cbind(crrntDetREQFIX_tbldf, padmeNameMatch(checkMe=crrntDetREQFIX_tbldf$Taxon, taxonType="species", authorityPresent=TRUE, taxonSingle=TRUE))
# this just gives Peperomia blanda X 10

source("O://CMEP\ Projects/Scriptbox/general_utilities/function_padmeNameMatch.R")
#a <- tbl_df(data.frame(checkMeNames=crrntDetREQFIX[1:10,]))
ad %>%
        rowwise() %>%
        #mutate(bestGuess=padmeNameMatch(checkMe=ad$checkMeNames, taxonType="species", authorityPresent=TRUE, taxonSingle=TRUE, chattyReturn=FALSE))
        mutate(namsChar=as.character(checkMeNames)) %>%
        glimpse


# run mutate (with chaining)



# output



# 3) 




# 4) 



# 5)


# 6)

# end; close connections, tidy up objects

# VERY IMPORTANT!
# CLOSE DATABASE CONNECTIONS
odbcCloseAll()

# REMOVE ALL OBJECTS FROM WORKSPACE!
#rm(list=ls())

# # REMOVE SOME OBJECTS FROM WORKSPACE!
#         # removes EVERYTHING EXCEPT WHAT YOU WANT TO KEEP 
#         # (eg. connections, things, etc):
# rm(list=setdiff(ls(), 
#                 c(
#                 "thing1", 
#                 "thing2", 
#                 "con_livePadmeArabia", 
#                 "livePadmeArabiaCon"
#                 )
#         )
# )

# VERY IMPORTANT!
# CLOSE THE CONNECTION!
#odbcCloseAll()

print("... script_checkSpeciesListSocotra.R complete!")
