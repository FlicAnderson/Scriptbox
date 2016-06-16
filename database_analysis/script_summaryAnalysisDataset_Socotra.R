## Socotra Project :: script_summaryAnalysisDataset_Socotra.R
# ==============================================================================
# 02 June 2016
# Author: Flic Anderson
#
# dependent on: "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R"
# saved at: O://CMEP\ Projects/Scriptbox/database_analysis/script_summaryAnalysisDataset_Socotra.R
# source: source("O://CMEP\ Projects/Scriptbox/database_analysis/script_summaryAnalysisDataset_Socotra.R")
#
# AIM: Using records pulled out in script_dataGrabFullLatLonOrGazLatLon_Socotra.R
# .... Perform summary stats! 
# .... 

# ---------------------------------------------------------------------------- #

# 0)


# load and prep
# {dplyr} - manipulating data & large data frames as tbl_df objects
if (!require(dplyr)){
        install.packages("dplyr")
        library(dplyr)
}
# {sqldf} - using SQL query style to manipulate R objects & data frames
if (!require(sqldf)){
        install.packages("sqldf")
        library(sqldf)
}

# open connection to live padme
source("O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R")
livePadmeArabiaCon()

# read in
recGrab <- read.csv("O://CMEP\ Projects/Socotra/analysisRecords-Socotra_2016-04-26.csv")


source("O://CMEP\ Projects/Scriptbox/general_utilities/function_addRecTypeColumn.R")
addRecTypeColumn()

recGrab <-tbl_df(recGrab)

herbRex <- 
        recGrab %>% 
                filter(recType=="H")
# 5211 recs
herbRex_byExpd <- group_by(herbRex, expdName)
herbExpds <- 
        summarize(herbRex_byExpd, count=n(), collGroups=n_distinct(collector)) %>%
        arrange(-count, expdName)
# write out summary
#write.csv(herbExpds, file=file.choose())  

# create query to get/join herbarium specimens info
qry <- "SELECT 
[Herbarium specimens].[id] AS herbspecID,
[Herbarium specimens].[FlicFound], 
[Herbarium specimens].[FlicStatus],
[Herbarium specimens].[FlicNotes],
[Herbarium specimens].[FlicIssue]
FROM [Herbarium specimens];"

# run query, store as 'herbariaInfo' object
FlicsFieldsInfo <- sqlQuery(con_livePadmeArabia, qry)

herbRex <- 
herbRex %>%
        # add column
        mutate(recID, origID=gsub("H-", "", recID))

# join ranks to recGrab records
herbSpxInfo <- sqldf("SELECT * FROM herbRex LEFT JOIN FlicsFieldsInfo ON herbRex.origID=FlicsFieldsInfo.herbspecID")
glimpse(herbSpxInfo)

# show breakdown
summarize(group_by(herbSpxInfo, FlicStatus), count=n())

# create query to join herbarium info
qry <- "SELECT 
        [Herbarium specimens].[id] AS herbspecID,
        [Herbaria].[Acronym] AS herbariumCode
        FROM [Herbarium specimens] 
        INNER JOIN [Herbaria] ON [Herbarium specimens].[Herbarium] = [Herbaria].[id]
        ;"

# run query, store as 'herbariaInfo' object
herbariaInfo <- sqlQuery(con_livePadmeArabia, qry)

# join ranks to recGrab records
herbrInfo <- sqldf("SELECT * FROM herbRex LEFT JOIN herbariaInfo ON herbRex.origID=herbariaInfo.herbspecID")

herbrInfo <- %>%
        summarize(group_by(herbrInfo, herbariumCode), count=n()) %>%
        arrange(-count)
# write out summary
#write.csv(herbExpds, file=file.choose()) 



# Ours Vs Theirs (number of species records)

# total
###

# expedition names which count as 'us'
RBGElist <- c("SOC-90-1", "YE/SOC-89-1", "YE/SOC-92-1", "SOC-96-1", "YE/SOC-93-1", "SOC-98-1", "Banfield Socotra", "SOC-00-1", "Miller Socotra (misc)", "Alexander Socotra Expedition", "SOC-01-1", "SOC-99-2", "YE/SOC-07-1", "YE/SOC-02-1", "Morris Socotra", "YE/SOC-06-1")
# expedition names which count as 'not-us'
otherList <- c("BIOTA Yemen Project", "Middle East Command Expedition to Socotra", "Thulin & Gifri Socotra", "Ogilvie-Grant-Forbes", "Balfour Cockburn Scott (B.C.S) Socotra Expedition", "Desert Locust Survey", "Expedition Riebeck", "Oxford University Expedition to Socotra", "Tardelli/Baldini Socotra", "Vienna Academy of Sciences to South Arabia", "Hannon, Christie, Oakman; Socotra 2002", "Bruyns Socotra 2007", "Van Damme Expedition", "Bilaidi Expedition", "Cronk Expedition to Socotra", "Mies Expedition", "Bent Expedition", "Czech Team Socotra November 2014")



odbcCloseAll()

#########################


fielRex <- 
        recGrab %>% 
                filter(recType=="F")
# 20,005 recs
fielRex_byExpd <- group_by(fielRex, expdName)
fielExpds <- 
        summarize(fielRex_byExpd, count=n(), collGroups=n_distinct(collector)) %>%
        arrange(-count, expdName)
# write out summary
#write.csv(fielExpds, file=file.choose())



# pull apart record type

# herb / unmounted 

# publicly avail

# number of species with > 10 species in ALL vs publicly avail.


