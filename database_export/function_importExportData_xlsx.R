# Scriptbox :: function_importExportData_xlsx.R
# ======================================================== 
# (2nd March 2015)
# Author: Flic Anderson
# ~ function
# saved at: 
# "O:/CMEP\ Projects/Scriptbox/database_export/function_importExportData_xlsx.R"
# to run: 
# source("O:/CMEP\ Projects/Scriptbox/database_export/function_importExportData_xlsx.R")
#
# to call: importExportData_xlsx()
# object created: datA

### FUNCTION: spreadsheet name import method: importNames_xlsx
importExportData_xlsx <- function(){  
        
        # if subset required:
        # # for a subset of columns or rows, enter the indexes required:
        # # REQUIRE USER INPUT FOR COLUMN/ROW SUBSET
        # rowIndexFirst <<- readline(prompt="........ enter FIRST ROW index to read in from - format '1' ... ")
        # rowIndexLast <<- readline(prompt="........ enter LAST ROW index to read in - format '295' (if uncertain as to exact number, overestimate!) ... ")
        # # fix character -> numeric problem
        # rowIndex <- as.numeric(rowIndexFirst):as.numeric(rowIndexLast)
        # 
        # colIndex <- readline(prompt="........ enter COLUMN index to read in - format '1,2' 
        #          - 1st column species names, 2nd column for any subspecific epithets 
        #          (example: column 1 contains 'Adenium obesum', column 2 contains 'subsp. sokotranum')
        #          ... "
        # )
        # colIndex <- c(as.numeric(unlist(strsplit(colIndex, split=",")))[1] , as.numeric(unlist(strsplit(colIndex, split=",")))[2])
        # #rowIndex <- 1:86
        # #colIndex <- c(6,7)
        
        # import the file
        #check it pulls out the right data: 
        datA <<- read.xlsx(
                        file=importSource, sheetIndex=1, 
                        colIndex=NULL, rowIndex=NULL,
                        header=TRUE,    # first row is column names - use as headers 
                        )
           
        print("... Padme export-data spreadsheet imported to R")

}