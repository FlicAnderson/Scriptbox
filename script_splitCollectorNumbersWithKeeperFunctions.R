# CMEP PROJECTS/Scriptbox :: script_splitCollectorNumbersWithKeeperFunctions.R
# ======================================================== 
# (7th July 2014)
# ~ standalone script


# AIM: to pull in collection numbers from an IMPORT COPY OF PADME (!), then split collector numbers into
# ... prefix/suffix/collNum using *Keeper functions then write these into separate fields (pre-existing
# ... in {Import Padme}). 


# open importPadme connection "importPadmeCon"
source("Z:/fufluns/scripts/function_importPadmeCon.R")
importPadmeCon()

# pull in the ID numbers [ID] and collector numbers [no] for the records from the [0UPS] table
qry <- "SELECT [ID], [no] FROM [0UPS]"
collectorNum <- sqlQuery(con_importPadme, qry)

# get names of the new dataframe collectorNum
names(collectorNum)
# set collection number column name to 'orig'
names(collectorNum)[2] <- "orig"

# source *Keeper functions
source("O:/CMEP Projects/Scriptbox/function_prefixKeeper.R")
source("O:/CMEP Projects/Scriptbox/function_collNumKeeper.R")
source("O:/CMEP Projects/Scriptbox/function_suffixKeeper.R")

# run *Keeper functions and split these off into separate new columns in the dataframe for the pulled in data
collectorNum$prefix <- prefixKeeper(collectorNum$orig)
collectorNum$collNum <- collNumKeeper(collectorNum$orig)
collectorNum$postfix <- suffixKeeper(collectorNum$orig)

# check before running update query whether it'll push [""] or [] - do these need to be replaced with something else?
# NAs treated as <NA>
# therefore: 

# remove original collector numbers
collectorNum$orig <- NULL 

# RUN UPDATE
# run update to push the split collector numbers back up to the importPadme table
# add test=TRUE to test only instead of writing
system.time(sqlUpdate(con_importPadme, collectorNum, tablename="0UPS",  index="ID", verbose=TRUE))
# took 0.8 seconds

# close connection to database
odbcCloseAll()
