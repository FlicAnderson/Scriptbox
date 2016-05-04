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
importSource <- "O://CMEP\ Projects//Socotra//EthnographicData_2014//EthnographicData_SocotraSPECIES-LIST_endemics.xlsx"

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
        select(species, endemicScore) #%>%
        #filter(endemicScore==1) %>%
        #write.csv(file=file.choose(),row.names=FALSE)

# add fullTax column with concat of name parts
endemics <- 
        endemics %>%
                mutate(fullTax=paste(species, sspOrVar, sep=" ")) 
# check for duplicate fullTax now

##### TO DO: 
# link to latin names etc etc & write endemic y/n data into the database.  
#### 

# # Padme Data:: ethnographicAnnotationsPadme.R
# # ======================================================== 
# # 03 May 2016
# # Author: Flic Anderson
# # dependent on: "O:/CMEP Projects/Scriptbox/database_importing/script_latinNamesMatcher.R"; 
# # ... 
# 
# 
# # AIM: to write ethnographic annotation scores (by Anna Hunt from "Ethnoflora of
# # ... Socotra") to categories already input into Padmeand match the names in her
# # ... spreadsheet to Padme latin names to allow linking of annotation scores to 
# # ... Padme's tables by associating matching latin names with their Padme ID, 
# # ... matching the column headings to annotation titles and annotation list 
# # ... members and write in those scores to the annotation list selection table
# # ... and other tables as necessary.
# 
# # list of functions defined: importEthnog_xlsx(readEthnogInfo; 
# 
# rm(list=ls())
# 
# # source functions:
# # test location
# #source("O:/CMEP\ Projects/Scriptbox/function_TESTPadmeArabiaCon.R")
# source("O:/CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R")
# source("O:/CMEP\ Projects/Scriptbox/database_importing/script_latinNamesMatcher.R")
# 
# # running script_latinNamesMatcher, selected "Z://fufluns//databasin//taxaDataGrab//Socotra SPECIES LIST.xlsx": 
# # ........ please choose file to check names from: 
# # [1] "... using spreadsheet method to import file..."
# # [1] "... source database connection online:  C:/Padme/padmecode.mdb"
# # ........ enter 'TRUE' if taxon names HAVE authorities 
# # attached (ie. in same column), or 'FALSE' if there is NO authority information attached
# # ... FALSE
# # ........ enter FIRST ROW index to read in from - format '1' 
# # ... 5
# # ........ enter LAST ROW index to read in - format '295' (if uncertain as to exact number, overestimate!) 
# # ... 921
# # ........ enter COLUMN index to read in - format '1,2' 
# # - 1st column species names, 2nd column for any subspecific epithets 
# # (example: column 1 contains 'Adenium obesum', column 2 contains 'subsp. sokotranum')
# # ... 4,6
# # [1] "... all names in correct format; carry on with analysis"
# # [1] "... using spreadsheet method to extract and check names... "
# # [1] "... 15 names need to be fixed from determinations << Z:\\fufluns\\databasin\\taxaDataGrab\\Socotra SPECIES LIST.xlsx"
# # ........ choose or create a .CSV file to hold the names requiring checking/fixing
# # [1] "... 15 names requiring manual checking/fixing saved to file >> C:\\Users\\fanderson\\Desktop\\ethnogoutput.csv"
# # [1] "... name checking complete!"
# 
# # found CORRECT names for taxa, added to column called replaceWith in C:\\Users\\fanderson\\Desktop\\ethnogoutput.csv
# 
# # read in corrected names: 
# datA <- read.csv("C:\\Users\\fanderson\\Desktop\\ethnogoutput.csv")
# #names(datA)
# #[1] "Species_Name"        "Subspecific_Epithet" "Taxon"               "replaceWith" 
# 
# # datA$Taxon + datA$replaceWith should provide the data pairs for updating the names