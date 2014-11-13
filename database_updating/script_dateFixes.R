# Socotra :: script_dateFixes.R
# ======================================================== 
# (13th October 2014)
# Author: Flic Anderson
# fixes script for "script_expeditionTagger.R"


# AIM: to fix date problems in herbarium specimen data for Miller trips by expedition

##------------------------------8000s--YE/SOC-89-1----------------------------##

## split off first trip (8000s)
#tempTrip <- millers[which(millers$tripCat=="8000s"),]
# seem fine. No updates needed

##-----------------------------10000s-----SOC-90-1----------------------------##
## split off trip (10000s)
tempTrip <- millers[which(millers$tripCat=="10000s"),]

# 10k_YYYY
tempTrip[which(tempTrip$date1YYYY==1980),]
qry10A <- "SELECT [Herb].[id], [Herb].[Expedition], [Expd].[expeditionTitle] AS expdTitle, [Team].[name for display] AS collector, [Herb].[Locality], Herb.[Date 1 Days] AS date1DD, Herb.[Date 1 Months] AS date1MM, Herb.[Date 1 Years] AS date1YYYY  FROM ([Herbarium specimens] AS [Herb] LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id) LEFT JOIN [Expeditions] AS [Expd] ON [Herb].[Expedition]=[Expd].[id] WHERE ([Herb].[id]=39476 OR [Herb].[id]=73611);"
sqlQuery(con_TESTPadmeArabia, qry10A)

qry1B <- "UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Years]=1990 WHERE ([Herb].[id]=39476);"
sqlQuery(con_TESTPadmeArabia, qry1B)
qry1B <- "UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Years]=1990 WHERE ([Herb].[id]=73611);"
sqlQuery(con_TESTPadmeArabia, qry1B)

qry10C <- "SELECT [Herb].[id], [Herb].[Expedition], [Expd].[expeditionTitle] AS expdTitle, [Team].[name for display] AS collector, [Herb].[Locality], Herb.[Date 1 Days] AS date1DD, Herb.[Date 1 Months] AS date1MM, Herb.[Date 1 Years] AS date1YYYY  FROM ([Herbarium specimens] AS [Herb] LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id) LEFT JOIN [Expeditions] AS [Expd] ON [Herb].[Expedition]=[Expd].[id] WHERE ([Herb].[id]=39476 OR [Herb].[id]=73611);"
sqlQuery(con_TESTPadmeArabia, qry10C)

# 10k_MM

tempTrip[which(tempTrip$date1MM==11),]
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Months]=2 WHERE [Herb].[id]=18948;")
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Months]=2 WHERE [Herb].[id]=18949;")

# 10k_NA
tempTrip[which(is.na(tempTrip$date1YYYY)),]

sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=30, Herb.[Date 1 Months]=1, Herb.[Date 1 Years]=1990 WHERE [Herb].[id]=37137;")
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=1, Herb.[Date 1 Months]=2, Herb.[Date 1 Years]=1990 WHERE [Herb].[id]=7261;")
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=10, Herb.[Date 1 Months]=2, Herb.[Date 1 Years]=1990 WHERE [Herb].[id]=71341;")


##-----------------------------11000s----YE/SOC-92-1--------------------------##

##source("Z://fufluns/scripts/script_dataFixing.R")
## split off trip (11000s)
tempTrip <- millers[which(millers$tripCat=="11000s"),]

# 11k_YYYY
tempTrip[which(tempTrip$date1YYYY==1993),]
# fix problems
qry11A <- "SELECT [Herb].[id], [Herb].[Expedition], [Expd].[expeditionTitle] AS expdTitle, [Team].[name for display] AS collector, [Herb].[Locality], Herb.[Date 1 Days] AS date1DD, Herb.[Date 1 Months] AS date1MM, Herb.[Date 1 Years] AS date1YYYY  FROM ([Herbarium specimens] AS [Herb] LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id) LEFT JOIN [Expeditions] AS [Expd] ON [Herb].[Expedition]=[Expd].[id] WHERE [Herb].[id]=38281;"
sqlQuery(con_TESTPadmeArabia, qry11A)

qry1B <- "UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=10, Herb.[Date 1 Months]=2, Herb.[Date 1 Years]=1992 WHERE [Herb].[id]=38281;"
sqlQuery(con_TESTPadmeArabia, qry1B)

qry1C <- "SELECT [Herb].[id], [Herb].[Expedition], [Expd].[expeditionTitle] AS expdTitle, [Team].[name for display] AS collector, [Herb].[Locality], Herb.[Date 1 Days] AS date1DD, Herb.[Date 1 Months] AS date1MM, Herb.[Date 1 Years] AS date1YYYY  FROM ([Herbarium specimens] AS [Herb] LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id) LEFT JOIN [Expeditions] AS [Expd] ON [Herb].[Expedition]=[Expd].[id] WHERE [Herb].[id]=38281;"
sqlQuery(con_TESTPadmeArabia, qry1C)

# 11k_YYYY_NA
tempTrip[which(is.na(tempTrip$date1YYYY)),]

sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=27, Herb.[Date 1 Months]=1, Herb.[Date 1 Years]=1992 WHERE [Herb].[id]=4563;")
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=9, Herb.[Date 1 Months]=2, Herb.[Date 1 Years]=1992 WHERE [Herb].[id]=4792;")
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=9, Herb.[Date 1 Months]=2, Herb.[Date 1 Years]=1992 WHERE [Herb].[id]=5201;")
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=6, Herb.[Date 1 Months]=2, Herb.[Date 1 Years]=1992 WHERE [Herb].[id]=3772;")
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=9, Herb.[Date 1 Months]=2, Herb.[Date 1 Years]=1992 WHERE [Herb].[id]=2446;")
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=27, Herb.[Date 1 Months]=1, Herb.[Date 1 Years]=1992 WHERE [Herb].[id]=34764;")

# 11k_MM_NA
tempTrip[which(is.na(tempTrip$date1MM)),]
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=10, Herb.[Date 1 Months]=2 WHERE [Herb].[id]=25179;")
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=28, Herb.[Date 1 Months]=1 WHERE [Herb].[id]=34860;")

# 11k_MM
tempTrip[which(tempTrip$date1MM==5),]
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=10, Herb.[Date 1 Months]=2 WHERE [Herb].[id]=32852;")

##-----------------------------12000s----YE/SOC-93-1--------------------------##
##source("Z://fufluns/scripts/script_dataFixing.R")
## split off the trip
tempTrip <- millers[which(millers$tripCat=="12000s"),]

# 12k_YYYY_NA
tempTrip[which(is.na(tempTrip$date1YYYY)),]
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=3, Herb.[Date 1 Months]=11, Herb.[Date 1 Years]=1993 WHERE [Herb].[id]=1889;")

##-----------------------------17000s----SOC-99-1-----------------------------##
## split off the trip
tempTrip <- millers[which(millers$tripCat=="17000s"),]

# 17k_YYYY_NA
tempTrip[which(is.na(tempTrip$date1YYYY)),]
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=11, Herb.[Date 1 Months]=2, Herb.[Date 1 Years]=1999 WHERE [Herb].[id]=3191;")
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=15, Herb.[Date 1 Months]=2, Herb.[Date 1 Years]=1999 WHERE [Herb].[id]=6529;")
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=16, Herb.[Date 1 Months]=2, Herb.[Date 1 Years]=1999 WHERE [Herb].[id]=4053;")

##-----------------------------19000s----SOC-00-1-----------------------------##
## split off the trip
tempTrip <- millers[which(millers$tripCat=="19000s"),]

# 19k_YYYY_NA
tempTrip[which(is.na(tempTrip$date1YYYY)),]
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=13, Herb.[Date 1 Months]=2, Herb.[Date 1 Years]=2000 WHERE [Herb].[id]=5520;")
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=8, Herb.[Date 1 Months]=2, Herb.[Date 1 Years]=2000 WHERE [Herb].[id]=37138;")
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=7, Herb.[Date 1 Months]=2, Herb.[Date 1 Years]=2000 WHERE [Herb].[id]=37367;")
# 19k_MM_NA
tempTrip[which(is.na(tempTrip$date1MM)),]
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=14, Herb.[Date 1 Months]=2 WHERE [Herb].[id]=5611;")

##-----------------------------20000s----SOC-01-1-----------------------------##
## split off the trip
tempTrip <- millers[which(millers$tripCat=="20000s"),]
# 20k_YYYY_NA
tempTrip[which(is.na(tempTrip$date1YYYY)),]

sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=9, Herb.[Date 1 Months]=2, Herb.[Date 1 Years]=2001 WHERE [Herb].[id]=6402;")
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=11, Herb.[Date 1 Months]=2, Herb.[Date 1 Years]=2001 WHERE [Herb].[id]=6903;")
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=6, Herb.[Date 1 Months]=2, Herb.[Date 1 Years]=2001 WHERE [Herb].[id]=4298;")
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=6, Herb.[Date 1 Months]=2, Herb.[Date 1 Years]=2001 WHERE [Herb].[id]=2728;")
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=9, Herb.[Date 1 Months]=2, Herb.[Date 1 Years]=2001 WHERE [Herb].[id]=2947;")
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=6, Herb.[Date 1 Months]=2, Herb.[Date 1 Years]=2001 WHERE [Herb].[id]=5767;")
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=6, Herb.[Date 1 Months]=2, Herb.[Date 1 Years]=2001 WHERE [Herb].[id]=4747;")
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=6, Herb.[Date 1 Months]=2, Herb.[Date 1 Years]=2001 WHERE [Herb].[id]=1712;")
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=6, Herb.[Date 1 Months]=2, Herb.[Date 1 Years]=2001 WHERE [Herb].[id]=487;")
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=9, Herb.[Date 1 Months]=2, Herb.[Date 1 Years]=2001 WHERE [Herb].[id]=5881;")
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=6, Herb.[Date 1 Months]=2, Herb.[Date 1 Years]=2001 WHERE [Herb].[id]=6399;")
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=9, Herb.[Date 1 Months]=2, Herb.[Date 1 Years]=2001 WHERE [Herb].[id]=894;")
sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=11, Herb.[Date 1 Months]=2, Herb.[Date 1 Years]=2001 WHERE [Herb].[id]=3491;")


##-----------------------------22000s-----------------------------------------##
 # left for now until the data is definitely in!
##-----------------------------22000s-----------------------------------------##



##---------------------------31000s--YE/SOC-07-1------------------------------##
## split off the trip
tempTrip <- millers[which(millers$tripCat=="31000s"),]
# 31k_YYYY_NA
tempTrip[which(is.na(tempTrip$date1YYYY)),]



##---------------------------all collections--date1YYYY------------------------------##
summary(collections$date1YYYY)
#Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
#2    1985    1992    1980    1999   18880    1226 

unique(collections$date1YYYY)

# minimum year is 2...
#collections[which(collections$date1YYYY==2),]$id
#sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Years]=NA WHERE [Herb].[id]=6747;")

# maximum year is 18881...
collections[which(collections$date1YYYY==18881),]$id

#sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=XXXX, Herb.[Date 1 Months]=XXXX, Herb.[Date 1 Years]=XXXX WHERE [Herb].[id]=XXXX;")
#sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=XXXX, Herb.[Date 1 Months]=XXXX, Herb.[Date 1 Years]=XXXX WHERE [Herb].[id]=XXXX;")
#sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=XXXX, Herb.[Date 1 Months]=XXXX, Herb.[Date 1 Years]=XXXX WHERE [Herb].[id]=XXXX;")
#sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=XXXX, Herb.[Date 1 Months]=XXXX, Herb.[Date 1 Years]=XXXX WHERE [Herb].[id]=XXXX;")
#sqlQuery(con_TESTPadmeArabia, query="UPDATE [Herbarium specimens] AS [Herb] SET Herb.[Date 1 Days]=XXXX, Herb.[Date 1 Months]=XXXX, Herb.[Date 1 Years]=XXXX WHERE [Herb].[id]=XXXX;") 

#odbcCloseAll()

message("...dateFixes complete")
