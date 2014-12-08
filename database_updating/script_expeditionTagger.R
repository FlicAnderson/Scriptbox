# Socotra :: script_expeditionTagger.R
# ======================================================== 
# (9th October 2014)
# Author: Flic Anderson
# mini script for "script_dataFixing.R"


# AIM: to pull out groups of Miller records by expedition, checking that all of
# ... Miller's records are encapsulated by the query, check for other issues 
# ... that can be fixed, or formatting to standardise, & update {Live Padme} 
# ... expedition fields with an expedition code for that trip.

## DEPRECATED - source("Z://fufluns/scripts/script_dataFixing.R")
## LAPTOP SOURCE - source("C://Users//rbgeuser/Desktop/Flic_REMOVE/fufluns2//fufluns/scripts/script_dataFixing.R")
source("O://CMEP Projects/Scriptbox/database_updating/script_dataFixing.R")


##------------------------------8000s--YE/SOC-89-1----------------------------##

## split off first trip (8000s)
tempTrip <- millers[which(millers$tripCat=="8000s"),]
# 802 obs. of 21 variables

## check all collection numbers within expected range (tripLimits #1)
summary(tempTrip$collNumShort)
# how many are NOT in expected range?
sum(!(tempTrip$collNumShort %in% tripLimits))

table(tempTrip$Expedition)

# show number of collections per year
table(tempTrip$date1YYYY)
  # one year only - good
# show number of collections per month
table(tempTrip$date1MM)
  # 2 concurrent months - good
# show number of collections per day
table(tempTrip$date1DD)
  # range of days - good

  # show number of collections per day
  table(sort(tempTrip$dateConcat))
  # plot number of collections over dates of trip
  plot(table(sort(tempTrip$dateConcat)))
  # plot number of collections per day in the trip  
  plot(table(sort(weekdays(tempTrip$dateConcat))))  # not sure how to show in Mon -> Sun order

  # how many are found vs how many are NOT FOUND
  table(tempTrip$FlicFound, useNA="always")
  # 433 found; 369 NA

  # show WHERE they're found (only show used categories and also NA)
  table(tempTrip$FlicStatus[, drop=TRUE], useNA="always")

# look at collectors for that trip & number of specimens per collector: 
table(tempTrip$collector[,drop=TRUE])
# this is a good way of weeding out which ones may be incorrect etc

#Miller, A.G. 
#14 
#Miller, A.G. et al. 
#134 
#Miller, A.G., Guarino, L., Obadi, N., Hassan, S.K.M. & Mohammed, N. 
#654 

# tempTrip = 8k
# expedition = YE/SOC-89-1
expdID = 28

# # loop SELECT/UPDATE script for 8k trip
for(i in 1:length(tempTrip$id)){
  # start of loop
  
  # print current iteration imported collector & the collectorID being updated to  
  print(tempTrip$id[i])
  # split the output a little for readability
  message("...")
  
  # SELECT QUERY: check current settings for records with importedCollector[i]
  qry_checkCurrent <- paste0("SELECT [Herb].[id], [Herb].[Expedition], [Expd].[expeditionTitle] AS expdTitle, [Team].[name for display] AS collector, [Herb].[Locality] FROM ([Herbarium specimens] AS [Herb] LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id) LEFT JOIN [Expeditions] AS [Expd] ON [Herb].[Expedition]=[Expd].[id] WHERE [Herb].[id]=", tempTrip$id[i], ";")
  # print results of sqlQuery
  print(sqlQuery(con_TESTPadmeArabia, qry_checkCurrent))
  
  # UPDATE QUERY: update [Herbarium specimens].[Collector Key] settings with colID[i] in records with importedCollector[i]
  qry_updateCurrent <- paste0("UPDATE [Herbarium specimens] SET [Herbarium specimens].[Expedition]=", expdID, "  WHERE [Herbarium specimens].[id]=", tempTrip$id[i], " AND [Herbarium specimens].[Expedition] IS NULL;")
  print(sqlQuery(con_TESTPadmeArabia, qry_updateCurrent))
  # print results of sqlQuery
  
  # SELECT QUERY: check new settings for records with importedCollector[i]
  qry_newCurrent <- paste0("SELECT [Herb].[id], [Herb].[Expedition], [Expd].[expeditionTitle] AS expdTitle, [Team].[name for display] AS collector, [Herb].[Locality] FROM ([Herbarium specimens] AS [Herb] LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id) LEFT JOIN [Expeditions] AS [Expd] ON [Herb].[Expedition]=[Expd].[id] WHERE [Herb].[id]=", tempTrip$id[i], ";")
  # print results of sqlQuery
  print(sqlQuery(con_TESTPadmeArabia, qry_newCurrent))
  
  # split up output again before next iteration
  message("...................................................................")
  
  # end of loop  
}

#source("O://CMEP Projects/Scriptbox/database_updating/script_dataFixing.R")

##-----------------------------10000s-----SOC-90-1----------------------------##


## split off first trip (10000s)
tempTrip <- millers[which(millers$tripCat=="10000s"),]
# 819 obs. of 22 variables

# look at collectors for that trip & number of specimens per collector: 
table(tempTrip$collector[,drop=TRUE])
# this is a good way of weeding out which ones may be incorrect etc

#Miller, A.G. 
#23 
#Miller, A.G. et al. 
#172 
#Miller, A.G., Bazara'a, M., Guarino, L. & Kassim, N. 
#617
#Miller, A.G., Guarino, L., Bazara'a, M. & Kassim, N. 
#4 
#Miller, A.G., Hyam, R.D., Al Khulaidi, A-W.A., Sulaiman, A.S. & Talib, N.M. 
#1
# NOTE: the Miller/Hyam/Al Kulaidi/etc one seems likely to be wrong.

## check all collection numbers within expected range (tripLimits #1)
summary(tempTrip$collNumShort)
# how many are NOT in expected range?
sum(!(tempTrip$collNumShort %in% tripLimits))
if(sum(!(tempTrip$collNumShort %in% tripLimits))>0){
  message("... at least one collection number not within expected range - ACTION REQUIRED")
  tempTrip[which(!(tempTrip$collNumShort %in% tripLimits)),]  
}
# NOTES: 
# 1 record not in 'expected' range - M10685b - Orthosiphon ferrugineus.
# taxon in this case is ENDEMIC so must be from Socotra. 
# BUT date is 1998, not 1990, so may not be part of 10000s trip.
# ignore this 'error' since nothing can be done about it except changing expedition

# any pre-existing expedition codes?
table(tempTrip$Expedition)

# show number of collections per year
table(tempTrip$date1YYYY, useNA="always")
# show number of collections per month
table(tempTrip$date1MM, useNA="always")
# show number of collections per day
#table(tempTrip$date1DD, useNA="always")
table(sort(tempTrip$dateConcat), useNA="always")
  # some collections show year of 1980, 

# fixed problems
# @ "script_dateFixes.R"

# plot number of collections over dates of trip
plot(table(sort(tempTrip$dateConcat)))
# plot number of collections per day in the trip  
plot(table(sort(weekdays(tempTrip$dateConcat))))  # not sure how to show in Mon -> Sun order

# how many are found vs how many are NOT FOUND
table(tempTrip$FlicFound, useNA="always")
# 400 found; 419 NA

# show WHERE they're found (only show used categories and also NA)
table(tempTrip$FlicStatus[, drop=TRUE], useNA="always")

#tripIDs <- tempTrip$id[- 

# tempTrip = 10k
# expedition = SOC-90-1
expdID = 29

# # loop SELECT/UPDATE script for 8k trip
for(i in 1:length(tempTrip$id)){
  # start of loop
  
  # print current iteration imported collector & the collectorID being updated to  
  print(tempTrip$id[i])
  # split the output a little for readability
  message("...")
  
  # SELECT QUERY: check current settings for records with importedCollector[i]
  qry_checkCurrent <- paste0("SELECT [Herb].[id], [Herb].[Expedition], [Expd].[expeditionTitle] AS expdTitle, [Team].[name for display] AS collector, [Herb].[Locality] FROM ([Herbarium specimens] AS [Herb] LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id) LEFT JOIN [Expeditions] AS [Expd] ON [Herb].[Expedition]=[Expd].[id] WHERE [Herb].[id]=", tempTrip$id[i], ";")
  # print results of sqlQuery
  print(sqlQuery(con_TESTPadmeArabia, qry_checkCurrent))
  
  # UPDATE QUERY: update [Herbarium specimens].[Collector Key] settings with colID[i] in records with importedCollector[i]
  qry_updateCurrent <- paste0("UPDATE [Herbarium specimens] SET [Herbarium specimens].[Expedition]=", expdID, "  WHERE [Herbarium specimens].[id]=", tempTrip$id[i], " AND [Herbarium specimens].[Expedition] IS NULL;")
  print(sqlQuery(con_TESTPadmeArabia, qry_updateCurrent))
  # print results of sqlQuery
  
  # SELECT QUERY: check new settings for records with importedCollector[i]
  qry_newCurrent <- paste0("SELECT [Herb].[id], [Herb].[Expedition], [Expd].[expeditionTitle] AS expdTitle, [Team].[name for display] AS collector, [Herb].[Locality] FROM ([Herbarium specimens] AS [Herb] LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id) LEFT JOIN [Expeditions] AS [Expd] ON [Herb].[Expedition]=[Expd].[id] WHERE [Herb].[id]=", tempTrip$id[i], ";")
  # print results of sqlQuery
  print(sqlQuery(con_TESTPadmeArabia, qry_newCurrent))
  
  # split up output again before next iteration
  message("...................................................................")
  
  # end of loop  
}

#source("O://CMEP Projects/Scriptbox/database_updating/script_dataFixing.R")


##-----------------------------11000s----YE/SOC-92-1--------------------------##

#source("O://CMEP Projects/Scriptbox/database_updating/script_dataFixing.R")
## split off trip (11000s)
tempTrip <- millers[which(millers$tripCat=="11000s"),]
# 465 obs. of 22 variables

# look at collectors for that trip & number of specimens per collector: 
table(tempTrip$collector[,drop=TRUE])
# this is a good way of weeding out which ones may be incorrect etc

#Miller, A.G.        
#4
#Miller, A.G. & Nyberg, J.A. 
#424
#Miller, A.G. & Nyberg, J.A. et al. 
#14
#Miller, A.G. et al.        
#22                  
#Nyberg, J.A. & Miller, A.G. 
#1
# NOTE: Approximately right :s  Too many versions of the same collector team though

## check all collection numbers within expected range (tripLimits #1)
summary(tempTrip$collNumShort)
# how many are NOT in expected range?
sum(!(tempTrip$collNumShort %in% tripLimits))
if(sum(!(tempTrip$collNumShort %in% tripLimits))>0){
  message("... at least one collection number not within expected range - ACTION REQUIRED")
  tempTrip[which(!(tempTrip$collNumShort %in% tripLimits)),]  
}
# NOTES: 
# 5 records not in expected range, but form a list of consecutive numbers on 
# edge of range (11501:11505) and are ENDEMIC species. Seems legit.

# any pre-existing expedition codes?
table(tempTrip$Expedition)
# No

# show number of collections per year
table(tempTrip$date1YYYY, useNA="always")
# show number of collections per month
table(tempTrip$date1MM, useNA="always")
# show number of collections per day
table(tempTrip$date1DD, useNA="always")

# show dates & number of collections on those
table(sort(tempTrip$dateConcat), useNA="always")
# plot number of collections over dates of trip
plot(table(sort(tempTrip$dateConcat)))
# plot number of collections per day in the trip  
plot(table(sort(weekdays(tempTrip$dateConcat))))  # not sure how to show in Mon -> Sun order

# fixed problems
# @ "script_dateFixes.R"

# how many are found vs how many are NOT FOUND
table(tempTrip$FlicFound, useNA="always")
# 331 found; 134 NA

# show WHERE they're found (only show used categories and also NA)
table(tempTrip$FlicStatus[, drop=TRUE], useNA="always")

# tempTrip = 11k
tempTrip <- millers[which(millers$tripCat=="11000s"),]
# expedition = YE/SOC-92-1
expdID = 30
# tripLimits = 11101:11371

# # loop SELECT/UPDATE script for 11k trip
for(i in 1:length(tempTrip$id)){
  # start of loop
  
  # print current iteration imported collector & the collectorID being updated to  
  print(tempTrip$id[i])
  # split the output a little for readability
  message("...")
  
  # SELECT QUERY: check current settings for records with importedCollector[i]
  qry_checkCurrent <- paste0("SELECT [Herb].[id], [Herb].[Expedition], [Expd].[expeditionTitle] AS expdTitle, [Team].[name for display] AS collector, [Herb].[Locality] FROM ([Herbarium specimens] AS [Herb] LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id) LEFT JOIN [Expeditions] AS [Expd] ON [Herb].[Expedition]=[Expd].[id] WHERE [Herb].[id]=", tempTrip$id[i], ";")
  # print results of sqlQuery
  print(sqlQuery(con_TESTPadmeArabia, qry_checkCurrent))
  
  # UPDATE QUERY: update [Herbarium specimens].[Collector Key] settings with colID[i] in records with importedCollector[i]
  qry_updateCurrent <- paste0("UPDATE [Herbarium specimens] SET [Herbarium specimens].[Expedition]=", expdID, "  WHERE [Herbarium specimens].[id]=", tempTrip$id[i], " AND [Herbarium specimens].[Expedition] IS NULL;")
  print(sqlQuery(con_TESTPadmeArabia, qry_updateCurrent))
  # print results of sqlQuery
  
  # SELECT QUERY: check new settings for records with importedCollector[i]
  qry_newCurrent <- paste0("SELECT [Herb].[id], [Herb].[Expedition], [Expd].[expeditionTitle] AS expdTitle, [Team].[name for display] AS collector, [Herb].[Locality] FROM ([Herbarium specimens] AS [Herb] LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id) LEFT JOIN [Expeditions] AS [Expd] ON [Herb].[Expedition]=[Expd].[id] WHERE [Herb].[id]=", tempTrip$id[i], ";")
  # print results of sqlQuery
  print(sqlQuery(con_TESTPadmeArabia, qry_newCurrent))
  
  # split up output again before next iteration
  message("...................................................................")
  
  # end of loop  
}


##-----------------------------12000s----YE/SOC-93-1--------------------------##

#source("O://CMEP Projects/Scriptbox/database_updating/script_dataFixing.R")
## split off the trip
tempTrip <- millers[which(millers$tripCat=="12000s"),]
# 155 obs. of 22 variables

# look at collectors for that trip & number of specimens per collector: 
table(tempTrip$collector[,drop=TRUE])
# this is a good way of weeding out which ones may be incorrect etc

#Miller, A.G.        
#155

## check all collection numbers within expected range (tripLimits #1)
summary(tempTrip$collNumShort)
# how many are NOT in expected range?
sum(!(tempTrip$collNumShort %in% tripLimits))
if(sum(!(tempTrip$collNumShort %in% tripLimits))>0){
  message("... at least one collection number not within expected range - ACTION REQUIRED")
  tempTrip[which(!(tempTrip$collNumShort %in% tripLimits)),]  
}
#NOTES: all seems fine

# any pre-existing expedition codes?
table(tempTrip$Expedition)
# No

# show number of collections per year
table(tempTrip$date1YYYY, useNA="always")
# show number of collections per month
table(tempTrip$date1MM, useNA="always")
# show number of collections per day
#table(tempTrip$date1DD, useNA="always")

# show dates & number of collections on those
table(sort(tempTrip$dateConcat), useNA="always")
# plot number of collections over dates of trip
plot(table(sort(tempTrip$dateConcat)))
# plot number of collections per day in the trip  
plot(table(sort(weekdays(tempTrip$dateConcat))))  # not sure how to show in Mon -> Sun order

# fixed problems
# @ "script_dateFixes.R"

# how many are found vs how many are NOT FOUND
table(tempTrip$FlicFound, useNA="always")
# 108 found; 47 NA

# show WHERE they're found (only show used categories and also NA)
table(tempTrip$FlicStatus[, drop=TRUE], useNA="always")

# tempTrip = 12k
tempTrip <- millers[which(millers$tripCat=="12000s"),]
# expedition = YE/SOC-93-1
expdID = 31
# tripLimits = 12500:12693

# # loop SELECT/UPDATE script for 12k trip
for(i in 1:length(tempTrip$id)){
  # start of loop
  
  # print current iteration imported collector & the collectorID being updated to  
  print(tempTrip$id[i])
  # split the output a little for readability
  message("...")
  
  # SELECT QUERY: check current settings for records with importedCollector[i]
  qry_checkCurrent <- paste0("SELECT [Herb].[id], [Herb].[Expedition], [Expd].[expeditionTitle] AS expdTitle, [Team].[name for display] AS collector, [Herb].[Locality] FROM ([Herbarium specimens] AS [Herb] LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id) LEFT JOIN [Expeditions] AS [Expd] ON [Herb].[Expedition]=[Expd].[id] WHERE [Herb].[id]=", tempTrip$id[i], ";")
  # print results of sqlQuery
  print(sqlQuery(con_TESTPadmeArabia, qry_checkCurrent))
  
  # UPDATE QUERY: update [Herbarium specimens].[Collector Key] settings with colID[i] in records with importedCollector[i]
  qry_updateCurrent <- paste0("UPDATE [Herbarium specimens] SET [Herbarium specimens].[Expedition]=", expdID, "  WHERE [Herbarium specimens].[id]=", tempTrip$id[i], " AND [Herbarium specimens].[Expedition] IS NULL;")
  print(sqlQuery(con_TESTPadmeArabia, qry_updateCurrent))
  # print results of sqlQuery
  
  # SELECT QUERY: check new settings for records with importedCollector[i]
  qry_newCurrent <- paste0("SELECT [Herb].[id], [Herb].[Expedition], [Expd].[expeditionTitle] AS expdTitle, [Team].[name for display] AS collector, [Herb].[Locality] FROM ([Herbarium specimens] AS [Herb] LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id) LEFT JOIN [Expeditions] AS [Expd] ON [Herb].[Expedition]=[Expd].[id] WHERE [Herb].[id]=", tempTrip$id[i], ";")
  # print results of sqlQuery
  print(sqlQuery(con_TESTPadmeArabia, qry_newCurrent))
  
  # split up output again before next iteration
  message("...................................................................")
  
  # end of loop  
}


##-----------------------------14000s----SOC-96-1-----------------------------##

#source("O://CMEP Projects/Scriptbox/database_updating/script_dataFixing.R")
## split off the trip
tempTrip <- millers[which(millers$tripCat=="14000s"),]
# 333 obs. of 22 variables

# look at collectors for that trip & number of specimens per collector: 
table(tempTrip$collector[,drop=TRUE])
# this is a good way of weeding out which ones may be incorrect etc

#Miller, A.G. & Alexander, D. 
#245
#Miller, A.G., Alexander, D. & Ali, N.A. 
#88

## check all collection numbers within expected range (tripLimits #1)
summary(tempTrip$collNumShort)
# how many are NOT in expected range?
sum(!(tempTrip$collNumShort %in% tripLimits))
if(sum(!(tempTrip$collNumShort %in% tripLimits))>0){
  message("... at least one collection number not within expected range - ACTION REQUIRED")
  tempTrip[which(!(tempTrip$collNumShort %in% tripLimits)),]  
}
#NOTES: fixed one collection number inversion on LIVE_Padme

# any pre-existing expedition codes?
table(tempTrip$Expedition)
# No

# show number of collections per year
table(tempTrip$date1YYYY, useNA="always")
# show number of collections per month
table(tempTrip$date1MM, useNA="always")
# show number of collections per day
#table(tempTrip$date1DD, useNA="always")

# show dates & number of collections on those
table(sort(tempTrip$dateConcat), useNA="always")
# plot number of collections over dates of trip
plot(table(sort(tempTrip$dateConcat)))
# plot number of collections per day in the trip  
plot(table(sort(weekdays(tempTrip$dateConcat))))  # not sure how to show in Mon -> Sun order

# fixed problems
# @ "script_dateFixes.R"

# how many are found vs how many are NOT FOUND
table(tempTrip$FlicFound, useNA="always")
# 227 found; 106 NA

# show WHERE they're found (only show used categories and also NA)
table(tempTrip$FlicStatus[, drop=TRUE], useNA="always")

# tempTrip = 14k
tempTrip <- millers[which(millers$tripCat=="14000s"),]
# expedition = SOC-96-1
expdID = 32
# tripLimits = 14000:14315

# # loop SELECT/UPDATE script for 14k trip
for(i in 1:length(tempTrip$id)){
  # start of loop
  
  # print current iteration imported collector & the collectorID being updated to  
  print(tempTrip$id[i])
  # split the output a little for readability
  message("...")
  
  # SELECT QUERY: check current settings for records with importedCollector[i]
  qry_checkCurrent <- paste0("SELECT [Herb].[id], [Herb].[Expedition], [Expd].[expeditionTitle] AS expdTitle, [Team].[name for display] AS collector, [Herb].[Locality] FROM ([Herbarium specimens] AS [Herb] LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id) LEFT JOIN [Expeditions] AS [Expd] ON [Herb].[Expedition]=[Expd].[id] WHERE [Herb].[id]=", tempTrip$id[i], ";")
  # print results of sqlQuery
  print(sqlQuery(con_TESTPadmeArabia, qry_checkCurrent))
  
  # UPDATE QUERY: update [Herbarium specimens].[Collector Key] settings with colID[i] in records with importedCollector[i]
  qry_updateCurrent <- paste0("UPDATE [Herbarium specimens] SET [Herbarium specimens].[Expedition]=", expdID, "  WHERE [Herbarium specimens].[id]=", tempTrip$id[i], " AND [Herbarium specimens].[Expedition] IS NULL;")
  print(sqlQuery(con_TESTPadmeArabia, qry_updateCurrent))
  # print results of sqlQuery
  
  # SELECT QUERY: check new settings for records with importedCollector[i]
  qry_newCurrent <- paste0("SELECT [Herb].[id], [Herb].[Expedition], [Expd].[expeditionTitle] AS expdTitle, [Team].[name for display] AS collector, [Herb].[Locality] FROM ([Herbarium specimens] AS [Herb] LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id) LEFT JOIN [Expeditions] AS [Expd] ON [Herb].[Expedition]=[Expd].[id] WHERE [Herb].[id]=", tempTrip$id[i], ";")
  # print results of sqlQuery
  print(sqlQuery(con_TESTPadmeArabia, qry_newCurrent))
  
  # split up output again before next iteration
  message("...................................................................")
  
  # end of loop  
}


# close the connection
odbcCloseAll()

##-----------------------------16000s----SOC-98-1-----------------------------##

#source("O://CMEP Projects/Scriptbox/database_updating/script_dataFixing.R")
## split off the trip
tempTrip <- millers[which(millers$tripCat=="16000s"),]
# 153 obs. of 22 variables

# look at collectors for that trip & number of specimens per collector: 
table(tempTrip$collector[,drop=TRUE])
# this is a good way of weeding out which ones may be incorrect etc

#Miller, A.G.
#2
#Miller, A.G., Hyam, R.D., Al Khulaidi, A-W.A., Sulaiman, A.S. & Talib, N.M.
#151

## check all collection numbers within expected range (tripLimits #1)
summary(tempTrip$collNumShort)
# how many are NOT in expected range?
sum(!(tempTrip$collNumShort %in% tripLimits))
if(sum(!(tempTrip$collNumShort %in% tripLimits))>0){
  message("... at least one collection number not within expected range - ACTION REQUIRED")
  tempTrip[which(!(tempTrip$collNumShort %in% tripLimits)),]  
}
#NOTES: all fine

# any pre-existing expedition codes?
table(tempTrip$Expedition)
# No

# show number of collections per year
table(tempTrip$date1YYYY, useNA="always")
# show number of collections per month
table(tempTrip$date1MM, useNA="always")
# show number of collections per day
#table(tempTrip$date1DD, useNA="always")

# show dates & number of collections on those
table(sort(tempTrip$dateConcat), useNA="always")
# plot number of collections over dates of trip
plot(table(sort(tempTrip$dateConcat)))
# plot number of collections per day in the trip  
plot(table(sort(weekdays(tempTrip$dateConcat))))  # not sure how to show in Mon -> Sun order

# fixed problems
# @ "script_dateFixes.R"

# how many are found vs how many are NOT FOUND
table(tempTrip$FlicFound, useNA="always")
# 110 found; 43 NA

# show WHERE they're found (only show used categories and also NA)
table(tempTrip$FlicStatus[, drop=TRUE], useNA="always")

# tempTrip = 16k
tempTrip <- millers[which(millers$tripCat=="16000s"),]
# expedition = SOC-98-1
expdID = 33
# tripLimits = 16000:16137

# # loop SELECT/UPDATE script for 16k trip
for(i in 1:length(tempTrip$id)){
  # start of loop
  
  # print current iteration imported collector & the collectorID being updated to  
  print(tempTrip$id[i])
  # split the output a little for readability
  message("...")
  
  # SELECT QUERY: check current settings for records with importedCollector[i]
  qry_checkCurrent <- paste0("SELECT [Herb].[id], [Herb].[Expedition], [Expd].[expeditionTitle] AS expdTitle, [Team].[name for display] AS collector, [Herb].[Locality] FROM ([Herbarium specimens] AS [Herb] LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id) LEFT JOIN [Expeditions] AS [Expd] ON [Herb].[Expedition]=[Expd].[id] WHERE [Herb].[id]=", tempTrip$id[i], ";")
  # print results of sqlQuery
  print(sqlQuery(con_TESTPadmeArabia, qry_checkCurrent))
  
  # UPDATE QUERY: update [Herbarium specimens].[Collector Key] settings with colID[i] in records with importedCollector[i]
  qry_updateCurrent <- paste0("UPDATE [Herbarium specimens] SET [Herbarium specimens].[Expedition]=", expdID, "  WHERE [Herbarium specimens].[id]=", tempTrip$id[i], " AND [Herbarium specimens].[Expedition] IS NULL;")
  print(sqlQuery(con_TESTPadmeArabia, qry_updateCurrent))
  # print results of sqlQuery
  
  # SELECT QUERY: check new settings for records with importedCollector[i]
  qry_newCurrent <- paste0("SELECT [Herb].[id], [Herb].[Expedition], [Expd].[expeditionTitle] AS expdTitle, [Team].[name for display] AS collector, [Herb].[Locality] FROM ([Herbarium specimens] AS [Herb] LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id) LEFT JOIN [Expeditions] AS [Expd] ON [Herb].[Expedition]=[Expd].[id] WHERE [Herb].[id]=", tempTrip$id[i], ";")
  # print results of sqlQuery
  print(sqlQuery(con_TESTPadmeArabia, qry_newCurrent))
  
  # split up output again before next iteration
  message("...................................................................")
  
  # end of loop  
}


# close the connection
odbcCloseAll()


##-----------------------------17000s----SOC-99-1-----------------------------##

#source("O://CMEP Projects/Scriptbox/database_updating/script_dataFixing.R")
## split off the trip
tempTrip <- millers[which(millers$tripCat=="17000s"),]
# 213 obs. of 22 variables

# look at collectors for that trip & number of specimens per collector: 
table(tempTrip$collector[,drop=TRUE])
# varies, but seems approx correct according to the collection notes spreadsheet

#Miller, A.G. 
#21 
#Miller, A.G., Alexander, D., Sulaiman, A.S., Talib, N.M., Hughes, M. & Hyam, R.D. 
#189 
#Miller, A.G., Hyam, R.D., Al Khulaidi, A-W.A., Sulaiman, A.S. & Talib, N.M. 
#1 
#Miller, A.G., Hyam, R.D., Alexander, D. & Hughes, M. 
#2

## check all collection numbers within expected range (tripLimits #1)
summary(tempTrip$collNumShort)
# how many are NOT in expected range?
sum(!(tempTrip$collNumShort %in% tripLimits))
if(sum(!(tempTrip$collNumShort %in% tripLimits))>0){
  message("... at least one collection number not within expected range - ACTION REQUIRED")
  tempTrip[which(!(tempTrip$collNumShort %in% tripLimits)),]  
}
#NOTES: all fine

# any pre-existing expedition codes?
table(tempTrip$Expedition)
# No

# show number of collections per year
table(tempTrip$date1YYYY, useNA="always")
# show number of collections per month
table(tempTrip$date1MM, useNA="always")
# show number of collections per day
#table(tempTrip$date1DD, useNA="always")

# show dates & number of collections on those
table(sort(tempTrip$dateConcat), useNA="always")
# plot number of collections over dates of trip
plot(table(sort(tempTrip$dateConcat)))
# plot number of collections per day in the trip  
plot(table(sort(weekdays(tempTrip$dateConcat))))  # not sure how to show in Mon -> Sun order

# fixed problems
# @ "script_dateFixes.R"

# how many are found vs how many are NOT FOUND
table(tempTrip$FlicFound, useNA="always")
# 141 found; 72 NA

# show WHERE they're found (only show used categories and also NA)
table(tempTrip$FlicStatus[, drop=TRUE], useNA="always")

# tempTrip = 17k
tempTrip <- millers[which(millers$tripCat=="17000s"),]
# expedition = SOC-99-1
expdID = 34
# tripLimits = 17000:17181

# # loop SELECT/UPDATE script for 17k trip
for(i in 1:length(tempTrip$id)){
  # start of loop
  
  # print current iteration imported collector & the collectorID being updated to  
  print(tempTrip$id[i])
  # split the output a little for readability
  message("...")
  
  # SELECT QUERY: check current settings for records with importedCollector[i]
  qry_checkCurrent <- paste0("SELECT [Herb].[id], [Herb].[Expedition], [Expd].[expeditionTitle] AS expdTitle, [Team].[name for display] AS collector, [Herb].[Locality] FROM ([Herbarium specimens] AS [Herb] LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id) LEFT JOIN [Expeditions] AS [Expd] ON [Herb].[Expedition]=[Expd].[id] WHERE [Herb].[id]=", tempTrip$id[i], ";")
  # print results of sqlQuery
  print(sqlQuery(con_TESTPadmeArabia, qry_checkCurrent))
  
  # UPDATE QUERY: update [Herbarium specimens].[Collector Key] settings with colID[i] in records with importedCollector[i]
  qry_updateCurrent <- paste0("UPDATE [Herbarium specimens] SET [Herbarium specimens].[Expedition]=", expdID, "  WHERE [Herbarium specimens].[id]=", tempTrip$id[i], " AND [Herbarium specimens].[Expedition] IS NULL;")
  print(sqlQuery(con_TESTPadmeArabia, qry_updateCurrent))
  # print results of sqlQuery
  
  # SELECT QUERY: check new settings for records with importedCollector[i]
  qry_newCurrent <- paste0("SELECT [Herb].[id], [Herb].[Expedition], [Expd].[expeditionTitle] AS expdTitle, [Team].[name for display] AS collector, [Herb].[Locality] FROM ([Herbarium specimens] AS [Herb] LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id) LEFT JOIN [Expeditions] AS [Expd] ON [Herb].[Expedition]=[Expd].[id] WHERE [Herb].[id]=", tempTrip$id[i], ";")
  # print results of sqlQuery
  print(sqlQuery(con_TESTPadmeArabia, qry_newCurrent))
  
  # split up output again before next iteration
  message("...................................................................")
  
  # end of loop  
}

# close the connection
odbcCloseAll()


##-----------------------------19000s----SOC-00-1-----------------------------##

#source("O://CMEP Projects/Scriptbox/database_updating/script_dataFixing.R")
## split off the trip
tempTrip <- millers[which(millers$tripCat=="19000s"),]
# 176 obs. of 22 variables

# look at collectors for that trip & number of specimens per collector: 
table(tempTrip$collector[,drop=TRUE])
# seems legit

#Miller, A.G. 
#8
#Miller, A.G. & Talib, N.M. 
#168

## check all collection numbers within expected range (tripLimits #1)
summary(tempTrip$collNumShort)
# how many are NOT in expected range?
sum(!(tempTrip$collNumShort %in% tripLimits))
if(sum(!(tempTrip$collNumShort %in% tripLimits))>0){
  message("... at least one collection number not within expected range - ACTION REQUIRED")
  tempTrip[which(!(tempTrip$collNumShort %in% tripLimits)),]  
}
#NOTES: all fine

# any pre-existing expedition codes?
table(tempTrip$Expedition)
# No

# show number of collections per year
table(tempTrip$date1YYYY, useNA="always")
# show number of collections per month
table(tempTrip$date1MM, useNA="always")
# show number of collections per day
#table(tempTrip$date1DD, useNA="always")

# show dates & number of collections on those
table(sort(tempTrip$dateConcat), useNA="always")
# plot number of collections over dates of trip
plot(table(sort(tempTrip$dateConcat)))
# plot number of collections per day in the trip  
plot(table(sort(weekdays(tempTrip$dateConcat))))  # not sure how to show in Mon -> Sun order

# fixed problems
# @ "script_dateFixes.R"

# how many are found vs how many are NOT FOUND
table(tempTrip$FlicFound, useNA="always")
# 133 found; 43 NA

# show WHERE they're found (only show used categories and also NA)
table(tempTrip$FlicStatus[, drop=TRUE], useNA="always")

# tempTrip = 19k
tempTrip <- millers[which(millers$tripCat=="19000s"),]
# expedition = SOC-00-1
expdID = 35
# tripLimits = 19000:19224

# # loop SELECT/UPDATE script for 19k trip
for(i in 1:length(tempTrip$id)){
  # start of loop
  
  # print current iteration imported collector & the collectorID being updated to  
  print(tempTrip$id[i])
  # split the output a little for readability
  message("...")
  
  # SELECT QUERY: check current settings for records with importedCollector[i]
  qry_checkCurrent <- paste0("SELECT [Herb].[id], [Herb].[Expedition], [Expd].[expeditionTitle] AS expdTitle, [Team].[name for display] AS collector, [Herb].[Locality] FROM ([Herbarium specimens] AS [Herb] LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id) LEFT JOIN [Expeditions] AS [Expd] ON [Herb].[Expedition]=[Expd].[id] WHERE [Herb].[id]=", tempTrip$id[i], ";")
  # print results of sqlQuery
  print(sqlQuery(con_TESTPadmeArabia, qry_checkCurrent))
  
  # UPDATE QUERY: update [Herbarium specimens].[Collector Key] settings with colID[i] in records with importedCollector[i]
  qry_updateCurrent <- paste0("UPDATE [Herbarium specimens] SET [Herbarium specimens].[Expedition]=", expdID, "  WHERE [Herbarium specimens].[id]=", tempTrip$id[i], " AND [Herbarium specimens].[Expedition] IS NULL;")
  print(sqlQuery(con_TESTPadmeArabia, qry_updateCurrent))
  # print results of sqlQuery
  
  # SELECT QUERY: check new settings for records with importedCollector[i]
  qry_newCurrent <- paste0("SELECT [Herb].[id], [Herb].[Expedition], [Expd].[expeditionTitle] AS expdTitle, [Team].[name for display] AS collector, [Herb].[Locality] FROM ([Herbarium specimens] AS [Herb] LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id) LEFT JOIN [Expeditions] AS [Expd] ON [Herb].[Expedition]=[Expd].[id] WHERE [Herb].[id]=", tempTrip$id[i], ";")
  # print results of sqlQuery
  print(sqlQuery(con_TESTPadmeArabia, qry_newCurrent))
  
  # split up output again before next iteration
  message("...................................................................")
  
  # end of loop  
}

# close the connection
odbcCloseAll()



##-----------------------------20000s----SOC-01-1-----------------------------##

#source("O://CMEP Projects/Scriptbox/database_updating/script_dataFixing.R")
## split off the trip
tempTrip <- millers[which(millers$tripCat=="20000s"),]
# 74 obs. of 22 variables

# look at collectors for that trip & number of specimens per collector: 
table(tempTrip$collector[,drop=TRUE])
# seems legit

#Miller, A.G. 
#74

## check all collection numbers within expected range (tripLimits #1)
summary(tempTrip$collNumShort)
# how many are NOT in expected range?
sum(!(tempTrip$collNumShort %in% tripLimits))
if(sum(!(tempTrip$collNumShort %in% tripLimits))>0){
  message("... at least one collection number not within expected range - ACTION REQUIRED")
  tempTrip[which(!(tempTrip$collNumShort %in% tripLimits)),]  
}
# NOTES: lots (x29) not included in expected trip limits - but they are on the 
# 20000s spreadsheet, and triplimit numbers were set from notebooks. Probably 
# their notebook missing, but details in spreadsheet.

# any pre-existing expedition codes?
table(tempTrip$Expedition)
# No

# show number of collections per year
table(tempTrip$date1YYYY, useNA="always")
# show number of collections per month
table(tempTrip$date1MM, useNA="always")
# show number of collections per day
#table(tempTrip$date1DD, useNA="always")

# show dates & number of collections on those
table(sort(tempTrip$dateConcat), useNA="always")
# plot number of collections over dates of trip
plot(table(sort(tempTrip$dateConcat)))
# plot number of collections per day in the trip  
plot(table(sort(weekdays(tempTrip$dateConcat))))  # not sure how to show in Mon -> Sun order

# fixed problems
# @ "script_dateFixes.R"

# how many are found vs how many are NOT FOUND
table(tempTrip$FlicFound, useNA="always")
# 17 found; 57 NA

# show WHERE they're found (only show used categories and also NA)
table(tempTrip$FlicStatus[, drop=TRUE], useNA="always")

# tempTrip = 20k
tempTrip <- millers[which(millers$tripCat=="20000s"),]
# expedition = SOC-01-1
expdID = 36
# tripLimits = 20000:20028

# # loop SELECT/UPDATE script for 20k trip
for(i in 1:length(tempTrip$id)){
  # start of loop
  
  # print current iteration imported collector & the collectorID being updated to  
  print(tempTrip$id[i])
  # split the output a little for readability
  message("...")
  
  # SELECT QUERY: check current settings for records with importedCollector[i]
  qry_checkCurrent <- paste0("SELECT [Herb].[id], [Herb].[Expedition], [Expd].[expeditionTitle] AS expdTitle, [Team].[name for display] AS collector, [Herb].[Locality] FROM ([Herbarium specimens] AS [Herb] LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id) LEFT JOIN [Expeditions] AS [Expd] ON [Herb].[Expedition]=[Expd].[id] WHERE [Herb].[id]=", tempTrip$id[i], ";")
  # print results of sqlQuery
  print(sqlQuery(con_TESTPadmeArabia, qry_checkCurrent))
  
  # UPDATE QUERY: update [Herbarium specimens].[Collector Key] settings with colID[i] in records with importedCollector[i]
  qry_updateCurrent <- paste0("UPDATE [Herbarium specimens] SET [Herbarium specimens].[Expedition]=", expdID, "  WHERE [Herbarium specimens].[id]=", tempTrip$id[i], " AND [Herbarium specimens].[Expedition] IS NULL;")
  print(sqlQuery(con_TESTPadmeArabia, qry_updateCurrent))
  # print results of sqlQuery
  
  # SELECT QUERY: check new settings for records with importedCollector[i]
  qry_newCurrent <- paste0("SELECT [Herb].[id], [Herb].[Expedition], [Expd].[expeditionTitle] AS expdTitle, [Team].[name for display] AS collector, [Herb].[Locality] FROM ([Herbarium specimens] AS [Herb] LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id) LEFT JOIN [Expeditions] AS [Expd] ON [Herb].[Expedition]=[Expd].[id] WHERE [Herb].[id]=", tempTrip$id[i], ";")
  # print results of sqlQuery
  print(sqlQuery(con_TESTPadmeArabia, qry_newCurrent))
  
  # split up output again before next iteration
  message("...................................................................")
  
  # end of loop  
}

# close the connection
odbcCloseAll()




##-----------------------------22000s--YE/SOC-02-1----------------------------##

#source("O://CMEP Projects/Scriptbox/database_updating/script_dataFixing.R")
## split off the trip
tempTrip <- millers[which(millers$tripCat=="22000s"),]
# 5 obs. of 22 variables

# look at collectors for that trip & number of specimens per collector: 
table(tempTrip$collector[,drop=TRUE])
# seems legit

#Miller, A.G. 
#5

## check all collection numbers within expected range (tripLimits #1)
summary(tempTrip$collNumShort)
# how many are NOT in expected range?
sum(!(tempTrip$collNumShort %in% tripLimits))
if(sum(!(tempTrip$collNumShort %in% tripLimits))>0){
  message("... at least one collection number not within expected range - ACTION REQUIRED")
  tempTrip[which(!(tempTrip$collNumShort %in% tripLimits)),]  
}
# NOTES: seems fine 

# any pre-existing expedition codes?
table(tempTrip$Expedition)
# No

# show number of collections per year
table(tempTrip$date1YYYY, useNA="always")
# show number of collections per month
table(tempTrip$date1MM, useNA="always")
# show number of collections per day
#table(tempTrip$date1DD, useNA="always")

# show dates & number of collections on those
table(sort(tempTrip$dateConcat), useNA="always")
# plot number of collections over dates of trip
plot(table(sort(tempTrip$dateConcat)))
# plot number of collections per day in the trip  
plot(table(sort(weekdays(tempTrip$dateConcat))))  # not sure how to show in Mon -> Sun order

# fixed problems
# @ "script_dateFixes.R"

# how many are found vs how many are NOT FOUND
table(tempTrip$FlicFound, useNA="always")
# 2 found; 3 NA

# show WHERE they're found (only show used categories and also NA)
table(tempTrip$FlicStatus[, drop=TRUE], useNA="always")

# tempTrip = 22k
tempTrip <- millers[which(millers$tripCat=="22000s"),]
# expedition = YE/SOC-02-1
expdID = 37
# tripLimits = 22000:22118

# # loop SELECT/UPDATE script for 22k trip
for(i in 1:length(tempTrip$id)){
  # start of loop
  
  # print current iteration imported collector & the collectorID being updated to  
  print(tempTrip$id[i])
  # split the output a little for readability
  message("...")
  
  # SELECT QUERY: check current settings for records with importedCollector[i]
  qry_checkCurrent <- paste0("SELECT [Herb].[id], [Herb].[Expedition], [Expd].[expeditionTitle] AS expdTitle, [Team].[name for display] AS collector, [Herb].[Locality] FROM ([Herbarium specimens] AS [Herb] LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id) LEFT JOIN [Expeditions] AS [Expd] ON [Herb].[Expedition]=[Expd].[id] WHERE [Herb].[id]=", tempTrip$id[i], ";")

  
  
  # print results of sqlQuery
  print(sqlQuery(con_TESTPadmeArabia, qry_checkCurrent))
  
  # UPDATE QUERY: update [Herbarium specimens].[Collector Key] settings with colID[i] in records with importedCollector[i]
  qry_updateCurrent <- paste0("UPDATE [Herbarium specimens] SET [Herbarium specimens].[Expedition]=", expdID, "  WHERE [Herbarium specimens].[id]=", tempTrip$id[i], " AND [Herbarium specimens].[Expedition] IS NULL;")
  print(sqlQuery(con_TESTPadmeArabia, qry_updateCurrent))
  # print results of sqlQuery
  
  # SELECT QUERY: check new settings for records with importedCollector[i]
  qry_newCurrent <- paste0("SELECT [Herb].[id], [Herb].[Expedition], [Expd].[expeditionTitle] AS expdTitle, [Team].[name for display] AS collector, [Herb].[Locality] FROM ([Herbarium specimens] AS [Herb] LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id) LEFT JOIN [Expeditions] AS [Expd] ON [Herb].[Expedition]=[Expd].[id] WHERE [Herb].[id]=", tempTrip$id[i], ";")
  # print results of sqlQuery
  print(sqlQuery(con_TESTPadmeArabia, qry_newCurrent))
  
  # split up output again before next iteration
  message("...................................................................")
  
  # end of loop  
}

# close the connection
odbcCloseAll()


##---------------------------24000s--YE/SOC-03/04-1---------------------------##

#source("O://CMEP Projects/Scriptbox/database_updating/script_dataFixing.R")
## split off the trip
tempTrip <- millers[which(millers$tripCat=="24000s"),]
# NO HERBARIUM RECORDS PULLED OUT!!
# CHECK FIELD NOTES!!

# tempTrip = 24k
# tempTrip <- millers[which(millers$tripCat=="24000s"),]
# expedition = YE/SOC-03/04-1
expdID = 38
# tripLimits = 24000:24359


##---------------------------27000s--YE/SOC-06-1---------------------------##

#source("O://CMEP Projects/Scriptbox/database_updating/script_dataFixing.R")
## split off the trip
tempTrip <- millers[which(millers$tripCat=="27000s"),]
# NO HERBARIUM RECORDS PULLED OUT!!
# CHECK FIELD NOTES!!

# tempTrip = 27k
# tempTrip <- millers[which(millers$tripCat=="27000s"),]
# expedition = YE/SOC-06-1
expdID = 39
# tripLimits = ???


##---------------------------31000s--YE/SOC-07-1---------------------------##


#source("O://CMEP Projects/Scriptbox/database_updating/script_dataFixing.R")
## split off the trip
tempTrip <- millers[which(millers$tripCat=="31000s"),]
# 27 obs. of 22 variables

# look at collectors for that trip & number of specimens per collector: 
table(tempTrip$collector[,drop=TRUE])
# seems legit

#Miller, A.G., Banfield, L. & Scott, S. 
#27 

## check all collection numbers within expected range (tripLimits #1)
summary(tempTrip$collNumShort)
# how many are NOT in expected range?
sum(!(tempTrip$collNumShort %in% tripLimits))
if(sum(!(tempTrip$collNumShort %in% tripLimits))>0){
  message("... at least one collection number not within expected range - ACTION REQUIRED")
  tempTrip[which(!(tempTrip$collNumShort %in% tripLimits)),]  
}
# NOTES: ALL not in expected range since not sure what expected range is without
# checking field notebooks

# any pre-existing expedition codes?
table(tempTrip$Expedition)
# YES. All already assigned.

# show number of collections per year
table(tempTrip$date1YYYY, useNA="always")
# show number of collections per month
table(tempTrip$date1MM, useNA="always")
# show number of collections per day
#table(tempTrip$date1DD, useNA="always")

# not possible to track down date

# show dates & number of collections on those
table(sort(tempTrip$dateConcat), useNA="always")
# plot number of collections over dates of trip
plot(table(sort(tempTrip$dateConcat)))
# plot number of collections per day in the trip  
plot(table(sort(weekdays(tempTrip$dateConcat))))  # not sure how to show in Mon -> Sun order

# fixed problems
# @ "script_dateFixes.R"

# how many are found vs how many are NOT FOUND
table(tempTrip$FlicFound, useNA="always")
# 0 found; 27 NA

# show WHERE they're found (only show used categories and also NA)
table(tempTrip$FlicStatus[, drop=TRUE], useNA="always")

# tempTrip = 31k
tempTrip <- millers[which(millers$tripCat=="31000s"),]
# expedition = YE/SOC-07-1
expdID = 26
# tripLimits = ????

# # loop SELECT/UPDATE script for 31k trip
for(i in 1:length(tempTrip$id)){
  # start of loop
  
  # print current iteration imported collector & the collectorID being updated to  
  print(tempTrip$id[i])
  # split the output a little for readability
  message("...")
  
  # SELECT QUERY: check current settings for records with importedCollector[i]
  qry_checkCurrent <- paste0("SELECT [Herb].[id], [Herb].[Expedition], [Expd].[expeditionTitle] AS expdTitle, [Team].[name for display] AS collector, [Herb].[Locality] FROM ([Herbarium specimens] AS [Herb] LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id) LEFT JOIN [Expeditions] AS [Expd] ON [Herb].[Expedition]=[Expd].[id] WHERE [Herb].[id]=", tempTrip$id[i], ";")
  # print results of sqlQuery
  print(sqlQuery(con_TESTPadmeArabia, qry_checkCurrent))
  
  # UPDATE QUERY: update [Herbarium specimens].[Collector Key] settings with colID[i] in records with importedCollector[i]
  qry_updateCurrent <- paste0("UPDATE [Herbarium specimens] SET [Herbarium specimens].[Expedition]=", expdID, "  WHERE [Herbarium specimens].[id]=", tempTrip$id[i], " AND [Herbarium specimens].[Expedition] IS NULL;")
  print(sqlQuery(con_TESTPadmeArabia, qry_updateCurrent))
  # print results of sqlQuery
  
  # SELECT QUERY: check new settings for records with importedCollector[i]
  qry_newCurrent <- paste0("SELECT [Herb].[id], [Herb].[Expedition], [Expd].[expeditionTitle] AS expdTitle, [Team].[name for display] AS collector, [Herb].[Locality] FROM ([Herbarium specimens] AS [Herb] LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id) LEFT JOIN [Expeditions] AS [Expd] ON [Herb].[Expedition]=[Expd].[id] WHERE [Herb].[id]=", tempTrip$id[i], ";")
  # print results of sqlQuery
  print(sqlQuery(con_TESTPadmeArabia, qry_newCurrent))
  
  # split up output again before next iteration
  message("...................................................................")
  
  # end of loop  
}

# close the connection
odbcCloseAll()

##---------------------------????--YE/SOC-07-2---------------------------##

#source("O://CMEP Projects/Scriptbox/database_updating/script_dataFixing.R")
## split off the trip
#tempTrip <- millers[which(millers$tripCat=="????"),]
# NO HERBARIUM RECORDS PULLED OUT!!
# CHECK FIELD NOTES!!

# tempTrip = ???
# tempTrip <- millers[which(millers$tripCat=="????"),]
# expedition = YE/SOC-06-1
expdID = 25==40
# tripLimits = ???

# close the connection
odbcCloseAll()

##---------------------------????--SOC-08-1---------------------------##

#source("O://CMEP Projects/Scriptbox/database_updating/script_dataFixing.R")
## split off the trip
#tempTrip <- millers[which(millers$tripCat=="????"),]
#???
#???

# tempTrip = ???
# tempTrip <- millers[which(millers$tripCat=="????"),]
# expedition = SOC-08-1
expdID = 27
# tripLimits = ???

# close the connection
odbcCloseAll()

































################################################################################




### HERBARIA INFO

# herbaria specimens are at: 
table(millers$institute[, drop=TRUE])
# E     K     KTUH  UPS 
# 3003  117   3     58 
# Tony's distributed his stuff mostly to Edinburgh. 

# show the things he distributed to UPS (allegedly - is this true or another data mistake?)
millers[which(millers$institute=="UPS"),] # all endemic 8000s/10000s stuff so probably legit
millers[which(millers$institute=="K"),]   # all endemic 8000s/10000s stuff so probably legit
millers[which(millers$institute=="KTUH"),]  # (only?) 3 specimens to Kuwait University Herbarium





# WRITE SELECT QUERIES  
  # pull out from database, not collections. 
  # remember this needs to be SOCOTRA ONLY!!!

# WRITE UPDATE QUERIES 
  # pull out from database, not collections. 
  # remember this needs to be SOCOTRA ONLY!!!
  # BE REALLY CAREFUL

## TEST EVERYTHING
# then run queries

##---------------------------NON=MILLER--TRIPS--------------------------------##

# close the connection
#odbcCloseAll()

# Such as: 

# Ogilvie-Grant/Forbes
# Balfour
# Boivin(sp?)
# Wellstead(sp?)
# Cpt. Hay
# Lavronos & Radcliffe-Smith
# Gwynne/etc
# Paulay/Simony?
# Baldini/Tardelli
# Thulin?
# etc

# VERY IMPORTANT!
# CLOSE THE CONNECTION!
#odbcCloseAll()

message("... expedition tagging fix complete")