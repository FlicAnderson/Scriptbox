## Afghanistan Projects :: script_pullOutAfghanistanChecklistTaxa.R
# ==============================================================================
# 25th October 2016
# Author: Flic Anderson
#
# dependent on: "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeAfghanistanCon.R"
# saved at: O://CMEP\ Projects/Scriptbox/database_output/script_pullOutAfghanistanChecklistTaxa.R
# source: source("O://CMEP\ Projects/Scriptbox/database_output/script_pullOutAfghanistanChecklistTaxa.R")
#
# AIM: Pull out names of all taxa from checklist of names from Breckle/Rafiqpoor
# .... Checklist of Plants of Afghanistan [REF BETTER!] for futher use. Names 
# .... entered into Padme Afghanistan largely by Ahmad Jamshed Khoshbeen (2016)
# .... as part of a Darwin Initiative Fellowship with Centre for Middle Eastern
# .... Plants, RBGE.


# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) Load libraries, functions, source scripts
# 1) Create/run query 
# 2) Joins & general tweaks for usability
# 3) Show the output / summarize
# 4) Save the output to .csv

# ---------------------------------------------------------------------------- #

# 0) 

# load required packages, install if they aren't installed already
# {RODBC} - ODBC Database Access
if (!require(RODBC)){
        install.packages("RODBC")
        library(RODBC)
} 
# {sqldf} - SQL operations on dataframes in R
if (!require(sqldf)){
        install.packages("sqldf")
        library(sqldf)
} 
# {dplyr} - manipulating data & large data frames as tbl_df objects
if (!require(dplyr)){
        install.packages("dplyr")
        library(dplyr)
}


# open connection to live padme
        source("O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeAfghanistanCon.R")
livePadmeAfghanistanCon()



# 1)  Assemble query/ table stuff & run it

#sqlTables(con_livePadmeAfghanistan, tableType = "SYNONYM")

#allNamesAF <- sqlQuery(con_livePadmeAfghanistan, query = "SELECT * FROM [Latin Names]")
# sortName [,48] #taxonNoAuth_AF <- allNamesAF[,48]
# Full Name [,7] #taxonWithAuth_AF <- allNamesAF[,7] 

allNamesAF <- sqlQuery(con_livePadmeAfghanistan, query = "SELECT [id], [Full Name], [sortName], [Rank] FROM [Latin Names]")
namesRanksAF <- sqlQuery(con_livePadmeAfghanistan, query = "SELECT * FROM [Ranks]")

# N.B.: "formattedName" field contains tagged elements of the name eg. <e></e> 
# for epithets <a></a> for authority, <r></r> for any rank stuff like Subfamily 
# or subsp.


# 2) Joins & general tweaks for usability

# join ranks stuff onto names stuff
namesAF <- sqldf("SELECT allNamesAF.*, namesRanksAF.name FROM allNamesAF LEFT JOIN namesRanksAF on allNamesAF.Rank=namesRanksAF.id")
namesAF$Rank <- namesAF$name  # replace rank ID numbers with the names
#head(namesAF)
namesAF$name <- NULL  # remove the extra column called name (prev. ranks.name)

# make dplyr-ready
namesAF <- tbl_df(namesAF)

# group by rank?
# remove family-level and such?



# 3) Summarise & show a little output

table(namesAF$Rank)
#Class    Division     Family     Genus    species   SubDivision   Subfamily  subspecies     variety 
#4           1         150        1202        5274           1           3          18           2 

namesAF_filtered <- 
        namesAF %>%
        filter(Rank %in% c("species", "subspecies", "variety"))
        # NB: filter(Rank==c("species", "subspecies", "variety")) DOES NOT WORK AS YOU'D IMAGINE
        # filter(Rank %in% c(x,y,z)) DOES WORK! USE THIS INSTEAD.


# 4)  write out names - create species list .csv

### USER REMINDER: 
# write.csv() function will ask where to save file and what to call it
# enter filename including '.csv', & if asked whether to create file, say 'YES' 
# write to .csv file

fileLocat <- "O://CMEP\ Projects/PROJECTS\ BY\ COUNTRY/Afghanistan/ChecklistData/"
fileName <- "AF_checklistNamesFromPadme_"

write.csv(namesAF_filtered, file=paste0(fileLocat,fileName,Sys.Date(),".csv"), row.names = FALSE)


# VERY IMPORTANT!
# CLOSE DATABASE CONNECTIONs & REMOVE OBJECTS FROM WORKSPACE!
odbcCloseAll()
rm(list=ls())
