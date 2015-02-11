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

# import exported specimens spreadsheet from Padme 'Export to BG-Base' feature
# source spreadsheet:
message("........ please choose file to filter specimens from: ")
#importSource <- file.choose()
#importSource <- "C://Padme//EXPORT_TO_BGBASE//test//test_21Jan15_cleomeSocotraMillerSpecimens_x2.xls"

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


# For source (B) - spreadsheet -
# column of names -> crrntDet

# call function if importSource is a spreadsheet file
if(spsImport==TRUE) {
        print("... using spreadsheet method to import file...")
        # load xlsx package to library
        if (!require(xlsx)){
                install.packages("xlsx")
                library(xlsx)
        }
        # run the spreadsheet import method function
        source("O:/CMEP\ Projects/Scriptbox/database_importing/function_importNames_xlsx.R")
        # RUN & CALL importNames_xlsx() function
        importNames_xlsx()
        # print dimensions of crrntDet
        #dim(crrntDet)       
}
