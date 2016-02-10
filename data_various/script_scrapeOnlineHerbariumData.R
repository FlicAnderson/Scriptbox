## Socotra Project :: script_scrapeOnlineHerbariumData.R
# ==============================================================================
# (10th Feb 2016)
# Author: Flic Anderson
#
# dependent on: 
# saved at: O://CMEP\ Projects/Scriptbox/data_various/script_scrapeOnlineHerbariumData.R
# source("O://CMEP\ Projects/Scriptbox/data_various/script_scrapeOnlineHerbariumData.R")
#
# AIM: 
# .... 
# .... 
# .... 
# .... 
# .... 
# .... 

# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) Load libraries, functions, source scripts
# 1) Get url; scrape data; deal with multiple-page searches
# 2) parse xml elements; extract data; tidy data
# 3) set up padme connection; get relevant padme data
# 4) compare scraped data to padme data; return:
        # a) things which aren't in our data
        # b) things where their data is more complete/up-to-date
# 5) output: 
        # a) list of things to add to our data in an easily-importable format; 
        # b) list of things we need to update in our data
# 6) end; close connections, tidy up objects 

# ---------------------------------------------------------------------------- #

# 0) 

# load required packages, install if they aren't installed already
# {XML} - tools for working in XML
if (!require(XML)){
        install.packages("XML")
        library(XML)
}
# {httr} - tools for working in html
if (!require(httr)){
        install.packages("httr")
        library(httr)
}
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

# open connection to live padme
source("O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R")
livePadmeArabiaCon()


# 1) 

# get url
url <- "http://www.bgbm.org/herbarium/result.cfm?searchart=5"

#html <- htmlTreeParse(url, useInternalNodes = TRUE)
#Error in `[.XMLInternalDocument`(x, seq_len(n)) : 
#No method for subsetting an XMLInternalDocument with integer

con <- url("http://ww2.bgbm.org/herbarium/result.cfm?searchart=5")
htmlCode <- readLines(con)

# scrape data

# deal with multiple-page searches


# 2) 

# parse elements

# extract data

# tidy data


# 3) 

# set up padme connection 

# get relevant padme data


# 4) 

# compare scraped data to padme data

# return 
        # a) things which aren't in our data
        # b) things where their data is more complete/up-to-date


# 5)

# output 
        # a) list of things to add to our data in an easily-importable format; 
        # b) list of things we need to update in our data


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

print(" ... script_scrapeOnlineHerbariumData.R complete!")
