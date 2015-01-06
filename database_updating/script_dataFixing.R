# Socotra :: script_dataFixing.R
# ======================================================== 
# (7th October 2014)
# Author: Flic Anderson


# AIM: Fix the Socotra data in various ways


# clear workspace
rm(list=ls())

# set working directory
#setwd("Z:/socotra/Socotra/expeditionScripts/")

# load/install necessary packages
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


# set up connection:
# source function to open connections to {LIVE Padme}
#source("O://CMEP Projects/Scriptbox/function_TESTPadmeArabiaCon.R")
#source("C://Users//rbgeuser/Desktop/Flic_REMOVE/Scriptbox/function_TESTPadmeArabiaCon.R")
source("O:/CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R") 
        # run function:
livePadmeArabiaCon()
        # opens connection "con_livePadmeArabia" 
        # from location at "locat_livePadmeArabia"

# run function:
#TESTPadmeArabiaCon()
# opens connection "con_TESTPadmeArabia" 
# from location at "locat_TESTPadmeArabia"

# pull in the tables required
#  if having problems, add Sys.sleep(2) between queries
#Herb <- sqlQuery(con_TESTPadmeArabia, query="SELECT * FROM [Herbarium Specimens]")  # appx 71k records
#Team <- sqlQuery(con_livePadmeArabia, query="SELECT * FROM [Teams]")  # appx 2.5k records
#Lnam <- sqlQuery(con_livePadmeArabia, query="SELECT * FROM [Latin Names]")  # appx 10.5k records
#Geog <- sqlQuery(con_livePadmeArabia, query="SELECT * FROM [Geography]")  # appx 8k records
Team <- sqlQuery(con_livePadmeArabia, query="SELECT * FROM [Teams]")  # appx 2.5k records
Expd <- sqlQuery(con_livePadmeArabia, query="SELECT * FROM [Expeditions]")  # 53 records 

# get names of fields for herbarium specimens table
sqlColumns(con_livePadmeArabia, "Herbarium specimens")[4]

#Team.[name for display] AS importedCollector

# Join collectors (and others) onto herbarium specimens records to allow Miller subset
# [Herb].[Collector Key] == [Team].[id]
collectionsQry <- "
SELECT
Herb.[id],
Herb.[Expedition], 
Team.[name for display] AS collector,
Team.[id] AS teamID,
Herb.[importedCollector] AS importedCollector,
Herb.[Collector Number] AS collNumFull,
Herb.[Collection number] & '' & Herb.postfix AS collNum,
Herb.[Collection number] AS collNumShort,
Hrbr.[Acronym] AS institute,
Lnam.[Full Name] AS taxonFull,
Lnam.[sortName] AS taxon,
Geog.[fullName] AS fullLocation,
Geog.[Latitude 1 Decimal] AS geog_lat,
Geog.[Longitude 1 Decimal] AS geog_lon, 
Herb.[Date 1 Days] AS date1DD, 
Herb.[Date 1 Months] AS date1MM, 
Herb.[Date 1 Years] AS date1YYYY, 
Herb.[FlicFound], 
Herb.[FlicStatus], 
Herb.[FlicNotes], 
Herb.[FlicIssue],
Lnam.[FullSort]
FROM (((((([Herbarium specimens] AS [Herb] LEFT JOIN [Geography] AS [Geog] ON Herb.Locality=Geog.ID)
  LEFT JOIN [Herbaria] AS [Hrbr] ON Herb.Herbarium=Hrbr.id)
    LEFT JOIN [determinations] AS [Dets] ON Herb.id=Dets.[specimen key])
      LEFT JOIN [Synonyms tree] AS [Snym] ON Dets.[latin name key] = Snym.member)
        LEFT JOIN [Latin Names] AS [Lnam] ON Snym.[member of] = Lnam.id)
          LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id)
            LEFT JOIN [Teams] AS [DetTeam] ON Dets.[Det by] = DetTeam.id
WHERE Geog.fullName LIKE '%Socotra%' AND Dets.Current=TRUE;" #10719

# run query
#collections <- sqlQuery(con_TESTPadmeArabia, qry)
collections <- sqlQuery(con_livePadmeArabia, collectionsQry)   # 8409 obs, 22 vars


head(collections[order(collections$FullSort, na.last=TRUE),])

names(collections)

# fix importedCollector -> collector (where no collector existed)
#source("Z://fufluns/scripts/script_importCollectorFix.R")
##source("C://Users//rbgeuser/Desktop/Flic_REMOVE/fufluns2/fufluns/scripts/script_importCollectorFix.R")


# all records collected by/with Miller
millers <- collections[collections$collector %in% levels(collections$collector)[grep("Miller", levels(collections$collector))],]
# 3306 obs of 22 variables


Expd <- sqlQuery(con_livePadmeArabia, query="SELECT * FROM [Expeditions]")  # 53 records 
tripDetails <- Expd[, c(1, 2)]
# tripDetails
# id                                    expeditionTitle
# 1   1                               Desert Locust Survey
# 2   2                                               ARTP
# 3   3                                             SA08-1
# 4   6                                              O08-1
# 5   7                                              O84-1
# 6   8                                              O94-1
# 7  10                                      Mandaville-79
# 8  11                               Ogilvie-Grant-Forbes
# 9  12                                        Berlin Hein
# 10 13                                              Faten
# 11 14 Hilleshg Expedition to the Kingdom of Saudi Arabia
# 12 16                                             KW12-1
# 13 17                                            OMP13-2
# 14 18                                           KUW-13-1
# 15 19                                          E00647486
# 16 20                                          E00647568
# 17 21                                           OMP-12/4
# 18 22                                            AWK 13A
# 19 23                                            AWK 13B
# 20 24                                            OMP12-1
# 21 25                                         SOC-07-Oct
# 22 26                                        YE/SOC-07-1
# 23 27                                           SOC-08-1
# 24 28                                        YE/SOC-89-1
# 25 29                                           SOC-90-1
# 26 30                                        YE/SOC-92-1
# 27 31                                        YE/SOC-93-1
# 28 32                                           SOC-96-1
# 29 33                                           SOC-98-1
# 30 34                                           SOC-99-1
# 31 35                                           SOC-00-1
# 32 36                                           SOC-01-1
# 33 37                                        YE/SOC-02-1
# 34 38                                     YE/SOC-03/04-1
# 35 39                                        YE/SOC-06-1
# 36 40                                        YE/SOC-07-2
# 37 41                   1824 British Military Expedition
# 38 42  Balfour Cockburn Scott (B.C.S) Socotra Expedition
# 39 43                                 Expedition Riebeck
# 40 44         Vienna Academy of Sciences to South Arabia
# 41 46            Oxford University Expedition to Socotra
# 42 47               Archaeological Expedition to Socotra
# 43 48                                 Bilaidi Expedition
# 44 49                        Cronk Expedition to Socotra
# 45 50                                              MADAR
# 46 51                                              MP095
# 47 52                                              DOJAN
# 48 53                                              DOFEB
# 49 54    Middle East Command Expedition to Socotra, 1967
# 50 55                                  Qatar Survey 2014
# 51 56                                  Qatar Survey 2013
# 52 57                                   Oman Survey 2013
# 53 59             Hannon, Christie, Oakman; Socotra 2002

# show unique expeditions for Socotra records & their numbers
table(sqldf("SELECT Expd.expeditionTitle FROM collections LEFT JOIN Expd ON collections.Expedition=Expd.id"))

# Balfour Cockburn ...   Berlin Hein    Cronk Expedition to Socotra 
# 146                    26             1 

# Expedition Riebeck     Faten          Hannon, Christie, Oakman; Socotra 2002 
# 21                     5              29 

# Ogilvie-Grant-Forbes   SOC-00-1       SOC-01-1 
# 4                      173            71 

# SOC-90-1               SOC-96-1       SOC-98-1 
# 799                    332            154 

# SOC-99-1               YE/SOC-07-1    YE/SOC-89-1 
# 211                    27             786 

# YE/SOC-92-1            YE/SOC-93-1 
# 452                    148 


##---------------------------MILLER TRIPS-------------------------------------##

## MANUALLY ENTERED MILLER EXPEDITION DETAILS INTO PADME (12/Oct/2014)

## PULL OUT TEAMS WITH MILLER IN
# check they're all correct

# number of unique collectors for Socotra records
length(unique(collections$collector)) # (105 ex. 85 ex. 84 ex 106 ex. 86 ex. 95) collector combos
# how many contain "Miller"
sum(grepl("Miller", levels(collections$collector))) # x17 (prev. 18) contain "Miller"

# indices of levels of collector factor which contain "Miller"
grep("Miller", levels(collections$collector))
# [1] 17 22 70 71 72 73 74 75 76 77 78 79 80 81 82 83 86

# show all levels
levels(collections$collector)
## long list 
# 104 levels

# show all levels which contain "Miller"
levels(collections$collector)[grep("Miller", levels(collections$collector))]
# visual inspection of levels(collections$collector) suggests that these are all of the ones we need?
# YES

# all records collected by/with Miller
millers <- collections[collections$collector %in% levels(collections$collector)[grep("Miller", levels(collections$collector))],]
# 3306

# table out the collection numbers
summary(millers$collNumFull)
# shows that there are lots of collection numbers where there is more than one
# record per number.  This doesn't bode well... IF THE HERBARIUM IS THE SAME, AND DETS ARE SAME!!! 
# IF HERBARIUM IS NOT THE SAME, THIS IS FINE! THEY'RE SPECIMEN DUPLICATES.

# number of unique collection numbers within Millers subset:
length(unique(millers$collNumFull))   # only 2679 out of 3304!

# but for example: 
a <- unique(paste(millers$collNumFull, millers$institute, sep=" "))
length(a)
#2828 unique coll# and Herbarium combos
a[grep("8245", a)]
# "M.8245 E"  "8245 E"    "8245 K"    "8245 UPS"  "8245 KTUH"
rm(a)
# shows that there is a true duplicate record (M.8245 E vs 8245 E) but also 2 herbarium specimen duplicates, which are FINE to have.

# example: 
#millers[which(millers$collNumFull=="11421"),]
#     id    collector             collNumFull taxonFull
#3136 5335  Miller, A.G. & Nyberg, J.A. 11421 Polycarpaea spicata var. capillaris Balf.f.
#3137 5335  Miller, A.G. & Nyberg, J.A. 11421 Polycarpaea Lam. sp. nov.
#5414 25169 Miller, A.G. et al.         11421 Polycarpaea spicata var. capillaris Balf.f.
#5415 25169 Miller, A.G. et al.         11421 Polycarpaea Lam. sp. nov.
#     fullLocation
#ASIA-TEMPERATE: Arabian Peninsula: Republic of Yemen: Socotra: Qarat Salih
#ASIA-TEMPERATE: Arabian Peninsula: Republic of Yemen: Socotra: Qarat Salih
#ASIA-TEMPERATE: Arabian Peninsula: Republic of Yemen: Socotra: Abd al Kuri: Jebel Hassala
#ASIA-TEMPERATE: Arabian Peninsula: Republic of Yemen: Socotra: Abd al Kuri: Jebel Hassala
# but these records do refer to the same place/specimens. I'm not sure why there are 2 record IDs for them though...
# possibly 2 dets are set as current?
# no idea...


## PULL OUT ALL MILLER NUMBER GROUPS
# check they're reasonable numbers and whatnot

names(millers)
str(millers)
tail(millers$collNum)
millers[,7] <- as.character(millers$collNum)
millers[,8] <- as.numeric(as.character(millers$collNumShort))
millers$collNumShort <- as.numeric(as.character(millers$collNumShort))
str(millers)

#millers$collNumFull[1:50]
#millers$collNum[1:50]
#millers$collNumShort[1:50]

# function to cut the upper category for all collection values
tripUp <- function(x) ceiling(max(x)/1000)*1000

# highest collection number value = "101144" - this is probably an error :P
max(millers$collNumShort, na.rm=TRUE)

# get 'ceiling' category
maxCat <- tripUp(max(millers$collNumShort, na.rm=TRUE))
maxCat  # 102000 - this is the next bracket up from the max value (ie. next trip category)

# create the trips (cut by 1000s)
trips <- seq(0, (maxCat-1), by=1000)
# label the trips
tripLabels <- paste(trips, "s", sep="")
# apply the whole lot to the millers records and make a new column for the results
millers$tripCat <- cut(millers$collNumShort, breaks = seq(0, (maxCat), by = 1000), labels=tripLabels, right=FALSE)

# show numbers of specimens which fall into each category (drop empty levels)
table(millers$tripCat[, drop=TRUE])
# how many categories?
nlevels(millers$tripCat[, drop=TRUE])
#15

# 0s 1000s 2000s 8000s 10000s  11000s  12000s  14000s  16000s  17000s  19000s  20000s  22000s  31000s 101000s 
# 6  1     1     788   800     453     148     332     153     212     175     71      5       27     1
# *  *     *                                                                                          *

# * = probable collection number confusion error!!!


table(millers[which(millers$tripCat=="10000s"),]$collector[,drop=TRUE])

# FIX THE EXPEDITION THING - UPDATE THE RECORDS!

# Problem bins: 
# 0s  
# 1000s
# 2000s
# 101000s

# Actual trips: 
# 8000s <- "8,000s - Socotra - 1989" <- YE/SOC-89-1
# Mainland Yemen (YE): 8000-8168
# Socotra (SOC): 8200-8720
# 10000s <- "10,000s - Socotra - 1990" <- SOC-90-1
# Socotra (SOC): 10000-10469
# 11000s <- "11,000's - Socotra - 1992" <- YE/SOC-92-1
# S.Yemen: 11000-11095
# Socotra: 11101-11371
# N.Yemen: 11515-11527
# 12000s <- "12,000's - Yemen - 1993" <- YE/SOC-93-1
# YE: 12000-12371
# SOC: 12500-12693
# YE: 12701-12734
# 14000s <- "14,000's - Socotra - 1996" <- SOC-96-1
# SOC: 14000-14315
# 16000s <- "16,000's - Socotra - 1998" <- SOC-98-1
# SOC: 16000-16137
# 17000s <- "17,000's - Socotra - 1999" <- SOC-99-1
# SOC: 17000-17181
# 19000s <- "19,000's - Socotra - 2000" <- SOC-00-1
# SOC: 19000-19224
# 20000s <- "20,000's - Socotra - 2001" <- SOC-01-1
# SOC: 20000-20028
# 22000s <- "22,000's - Yemen & Socotra - 2002" <- YE/SOC-02-1
# SOC: 22000-22118
# 24000s <- "24,000's - Yemen & Socotra - 2003 & 04" <- YE/SOC-03/04-1  
# SOC: 24000-24359
# 27000s <- "27,000's - Socotra Feb 2006" <- YE/SOC-06-1    ????
# SOC: ??27000-27199??
# 31000s <- "31,000's - Yemen & Socotra 2007-2_ OCT2007" <- YE/SOC-07-2
# SOC: ??
## ?s <- "YE/SOC-07-1_January" <- YE/SOC-07-01
## ?s <- "SOC-08-1" <- SOC-08-1

# tripCats
tripVals <- c("8000s", "10000s", "11000s", "12000s", "14000s", "16000s",  "17000s", "19000s", "20000s", "22000s", "24000s", "27000s", "31000s")  
# expedition codes
expdNames <- c("YE/SOC-89-1", "SOC-90-1", "YE/SOC-92-1", "YE/SOC-93-1", "SOC-96-1", "SOC-98-1", "SOC-99-1", "SOC-00-1", "SOC-01-1", "YE/SOC-02-1", "YE/SOC-03/04-1", "YE/SOC-06-1", "YE/SOC-07-2")
# trip numbers range which were Socotra not mainland
tripLimits <- c(8200:8720, 10000:10469, 11101:11500, 12500:12693, 14000:14315, 16000:16137, 17000:17181, 19000:19224, 20000:20028, 22000:22118, 24000:24359, NA, NA)

# concatenate the dates
millers$dateConcat <- as.Date(paste(millers$date1DD, millers$date1MM, millers$date1YYYY), format="%d %m %Y")

# make available outside this script
millers <<- millers 

## summarise Found/unfound/issues

# found/unfound overall
table(collections$FlicFound, useNA="ifany")
# found  <NA> 
# 2481  5928 

# now only look for ones which are supposed to be at Edinburgh (E)!
table(collections[which(collections$institute=="E"),]$FlicFound, useNA="ifany")
# found  <NA> 
# 2108  1438 

# found/unfound for millers
table(millers$FlicFound, useNA="ifany")
# found  <NA> 
# 1923  1383 

# found/unfound for MILLERS which are SUPPOSED TO BE AT Edinburgh (E)!
table(millers[which(millers$institute=="E"),]$FlicFound, useNA="ifany")
# found  <NA> 
# 1886  1075 

# issues for millers
table(millers$FlicIssue, useNA="ifany")

## fixes importedCollector -> collector (where no collector existed)
# THIS HAS BEEN RUN, DO NOT RUN AGAIN!
# RUN 06/01/2015 (1pm) on LIVE PADME
##source("O:/CMEP\ Projects/Scriptbox/database_importing/script_importCollectorFix.R")

## fix collector issues 
# e.g. "Miller et al" -> something more useful
# also "W.R. Ogilvie-Grant & H.O. Forbes" -> "H.o. Forbes & W.R.Ogilvie-Grant" so all duplicates are obvious!
        # note that the expedition is still Ogilvie-Grant THEN Forbes, but as Forbes was a botanist, collections should bear his name first.

## fixes problem dates
# THIS HAS BEEN RUN, DO NOT RUN AGAIN!
# RUN 06/01/2015 (1pm) on LIVE PADME
##source("O:/CMEP\ Projects/Scriptbox/database_updating/script_dateFixes.R")


## fixes expedition numbers
# THIS HAS BEEN RUN, DO NOT RUN AGAIN!
# RUN 06/01/2015 (1pm) on LIVE PADME
##source("O:/CMEP\ Projects/Scriptbox/database_updating/script_expeditionTagger.R")


# add family names
## UNNECESSARY, I THINK!
#source("O:/CMEP\ Projects/Scriptbox/database_output/script_addFamilyNames.R")


# Pull out unfounds only



# VERY IMPORTANT!
# CLOSE THE CONNECTION!
#odbcCloseAll()
