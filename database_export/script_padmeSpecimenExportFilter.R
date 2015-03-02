# Scriptbox :: script_padmeSpecimenExportFilter.R
# ======================================================== 
# (9th February 2015)
# Author: Flic Anderson
# ~ standalone script
# saved at: 
# "O:/CMEP\ Projects/Scriptbox/database_export/script_padmeSpecimenExportFilter.R"
# to run: 
# source("O:/CMEP\ Projects/Scriptbox/database_export/script_padmeSpecimenExportFilter.R")

# AIM: to filter and create separate file of specimen records for export from 
# ... Padme to BG-Base, where filter is "determined to species level or below", 
# ... to avoid printing labels for indet, genus-det or "genus sp." specimens


# load up packages
# load RODBC library
if (!require(RODBC)){
        install.packages("RODBC")
        library(RODBC)
} 
# load sqldf library
if (!require(sqldf)){
        install.packages("sqldf")
        library(sqldf)
} 

# source functions
source("O:/CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R")

### IMPORT EXPORTED DATA ###

# import exported specimens spreadsheet from Padme 'Export to BG-Base' feature

# source spreadsheet:
message("........ please choose file to filter specimens from: ")
#importSource <- file.choose()
importSource <- "C://Padme//EXPORT_TO_BGBASE//test//allMillerSocotra.xls"

# get importSource file extension
extns <- paste0(".", unlist(strsplit(importSource, "[.]"))[2])
# IF extns = database: 
#   A) extns = .mdb
#dbImport <- grepl(".mdb", extns)
# IF extns = spreadsheet:
#   B) extns = .xls/.xlsx
spsImport <- grepl(".xls|.xlsx", extns)
# IF extns = comma separated value file:
#   C) extns = .csv
#csvImport <- grepl(".csv", extns)

# For source (B) - spreadsheet:

# call function if importSource is a spreadsheet file
if(spsImport==TRUE) {
        print("... using spreadsheet method to import file...")
        # load xlsx package to library
        if (!require(xlsx)){
                install.packages("xlsx")
                library(xlsx)
        }
        # run the export-spreadsheet import method function
        source("O:/CMEP\ Projects/Scriptbox/database_export/function_importExportData_xlsx.R")
        # RUN & CALL importNames_xlsx() function
        message("... importing data - this may take over 3 minutes, please be patient")
        importExportData_xlsx()
        # remove structural first row of data (second row of excel sps) is column numbers for BG-Base infrastructure
        #datA <<- datA[-1,]
        # print dimensions of datA
        print(paste0("... Padme export data dimensions are ", dim(datA)[1], " rows by ", dim(datA)[2], " columns"))       
}

### JOIN IMPORTED DATA ON PADME.herbID/USER1 FIELDS ###


# Prep USER1 field

# data padme exported data User1 field is literally called " "User1" " 
# & those quotes screw up the column name when imported
# change this to "USER1"

names(datA)[39] <- "USER1"

# USER1 strings are hashes made of 32-char project hash + :: + padme [Herbarium specimens].[id]
# split User1 to get PadmeIDs

#gsub("[A-Z0-9]*::", "", datA$USER1[1])

message("... isolating PadmeID numbers")

datA$id <- gsub("[A-Z0-9]*::", "", datA$USER1)

# join!

library(sqldf)

# open database link with Padme Arabia
livePadmeArabiaCon()

message("... pulling out live Padme Arabia data")

Herb <- sqlQuery(con_livePadmeArabia, query="SELECT * FROM [Herbarium Specimens]")

# collectionsQry <- "
# SELECT
# Herb.[id],
# Herb.[FlicFound], 
# Herb.[FlicStatus], 
# Herb.[FlicNotes], 
# Herb.[FlicIssue]
# FROM (((((([Herbarium specimens] AS [Herb] LEFT JOIN [Geography] AS [Geog] ON Herb.Locality=Geog.ID)
#   LEFT JOIN [Herbaria] AS [Hrbr] ON Herb.Herbarium=Hrbr.id)
#     LEFT JOIN [determinations] AS [Dets] ON Herb.id=Dets.[specimen key])
#       LEFT JOIN [Synonyms tree] AS [Snym] ON Dets.[latin name key] = Snym.member)
#         LEFT JOIN [Latin Names] AS [Lnam] ON Snym.[member of] = Lnam.id)
#           LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id)
#             LEFT JOIN [Teams] AS [DetTeam] ON Dets.[Det by] = DetTeam.id
# WHERE Geog.fullName LIKE '%Socotra%' AND Herb.FlicStatus LIKE '%unmounted%' AND Herb.Expedition=35;" 
# 
# # run query
# #collections <- sqlQuery(con_TESTPadmeArabia, qry)
# collections <- sqlQuery(con_livePadmeArabia, collectionsQry)   # 8076 (before manual duplicate removal it was 8409) obs, 22 vars
# 
# #head(collections[order(collections$FullSort, na.last=TRUE),])

# tail(grepl("unmounted", collections$FlicStatus))
# tail(collections$FlicStatus)

message("... joining Flic's Found/Status/Issues/Notes data from live padme to exported data")

# join on padme ID field
allDat <- sqldf("SELECT * FROM datA LEFT JOIN Herb USING(id)")

# remove all other columns except ALL columns from datA, and all Flic Notes columns from [Herbarium Specimens]
allDat <- allDat[,c(1:53, 162:164)]

### Subset to only unmounted found ###

# number of specimens in unmounted:
sum(grepl("unmounted", allDat$FlicStatus))

message("... pulling out ONLY UNMOUNTED specimen records")

# subset to unmounted found:
allDat <- allDat[which(grepl("unmounted", allDat$FlicStatus)==TRUE),]

print(paste0("... there are ", sum(grepl("unmounted", allDat$FlicStatus)), " unmounted specimens records here"))

### EXPORT DATA TO SPREADSHEET AGAIN ###

message("... writing records to new file")

write.csv(allDat, file=paste0("C://Padme//EXPORT_TO_BGBASE//test//", "PadmeExportData_unmtdSocotra", "_", Sys.Date(), ".csv"), row.names=FALSE, na="")

message("... all actions complete. END.")
