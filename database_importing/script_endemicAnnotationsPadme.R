# Padme Data:: script_endemicAnnotationsPadme.R
# ======================================================== 
# (6th July 2015)
# Author: Flic Anderson
# based on: "O:/CMEP Projects/Scriptbox/database_importing/script_ethnographicAnnotationsPadme.R"
# dependent on: "O:/CMEP\ Projects/Scriptbox/database_importing/script_latinNamesMatcher.R"; 
# ... "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R"


# AIM: to write endemism annotation scores (by Anna Hunt from "Ethnoflora of
# ... Socotra") to categories already input into Padme and match the names in her
# ... spreadsheet to Padme latin names to allow linking of annotation scores to 
# ... Padme's tables by associating matching latin names with their Padme ID, 
# ... matching the column headings to annotation titles and annotation list 
# ... members and write in those scores to the annotation list selection table
# ... and other tables as necessary.


rm(list=ls())

if (!require(xlsx)){
        install.packages("xlsx")
        library(xlsx)
} 
if (!require(dplyr)){
        install.packages("dplyr")
        library(dplyr)
} 

# source functions:
#source("O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R")
#source("O:/CMEP\ Projects/Scriptbox/database_importing/script_latinNamesMatcher.R")

# set up connection
#livePadmeArabiaCon()

# Endemism & ethnographic scoring data and categories from spreadsheet (importSource) 
# compiled by student Anna Hunt during summer 2014 from Ethnoflora of Socotra

#importSource <- file.choose()
importSource <- "O://CMEP\ Projects//Socotra//Padme\ Data//Socotra SPECIES LIST.xlsx"

# function to import the endemic annotation scores
readEndemicInfo <<- function(){
                # for a subset of columns or rows, enter the indexes required:
                # headings in row 2
                startRow <- 5           # data starts row 5
                endRow <- 921           # data ends row 921   
                colIndex <- c(4,5,6,7,9)           # data starts col 9
                
                # import the ethnographic scores & category names:
                # scores (uses faster read.xlsx2() function)
                endemics <<- read.xlsx2(file=importSource, sheetIndex=1, 
                                            colIndex=c(4,5,6,7,9), startRow=5, endRow=921, 
                                            as.data.frame=TRUE, header=FALSE)
                names(endemics) <<- c("species", "spAuth", "sspOrVar", "sspAuth", "endemicScore")
}
# import ethnographic info/scores
readEndemicInfo()

table(endemics$endemicScore)
# ""       1 
# 603     314 

# 314 endemics according to list.

endemics <- tbl_df(endemics)


endemics %>%
        mutate(fullTax=paste(species, sspOrVar, sep=" ")) %>%
        select(species, endemicScore) %>%
        #filter(endemicScore==1) %>%
        write.csv(file=file.choose(),row.names=FALSE)


##### TO DO: 
# link to latin names etc etc & write endemic y/n data into the database.  
#### 