# Socotra :: script_importCollectorFix.R
# ======================================================== 
# (7th October 2014)
# Author: Flic Anderson
# mini script for "script_dataFixing.R"
# located at: source("O:/CMEP\ Projects/Scriptbox/database_importing/script_importCollectorFix.R")

# RUN ONCE ALREADY!
# run 06/01/2015 (1pm) on LIVE PADME 

# AIM: Identify and fix missing collectors where importedCollector has been given 
# ... FOR SOCOTRAN SPECIMENS ONLY!!

## COLLECTIONS WITHOUT COLLECTORS
nrow(collections[is.na(collections$collector),]) #1597 records
collections[is.na(collections$collector),][1:10,] 
  # some records attributed to "wp"s - possible to ID collectors if they're Miller trip records?

## IMPORTED-COLLECTORS
importCols <- levels(collections$importedCollector) # 46 levels (output as character)
unique(collections$importedCollector) # 46 levels (output as factor)

# colIDs are TEAM.ID for each of the imported collector strings found below. These are the fixes to be applied. Manually looked up and checked.
colIDs <- c(36049, 36051, 35832, 35832, 35833, 35833, 35834, 35834, 35835, 35837, 35830, 35839, 35841, 35843, 35844, 35845, 35846, 35847, 35848, 35848, 35825, 35848, 35849, 35850, 35840, 35339, 36054, 36057, 36059, 36060, 36061, 36062, 36063, 36065, 36067, 36068, 36069, 36070, 36071, 36071, 36074, 9307, 35512, 33832, 36056, 35517)

# IMPORTED-COLLECTORS WHERE COLLECTOR IS NA
unique(collections$importedCollector[which(is.na(collections$collector))])

### INVESTIGATE IMPORTED-COLLECTORS 
## find importedCollectors which do not match Teams
##Team <- sqlQuery(con_TESTPadmeArabia, query="SELECT * FROM [Teams]")  # appx 2.5k records
#displayName <- Team[,7] # create variable from [Team].[name for display]
#sum(importCols %in% displayName) # how many importedCollector strings in displayName?
## none of the names match 
## therefore ALL importedCollectors do not match [Team].[name for display]
#name <- Team[,2] # create variable from [Team].[name]
#sum(imprtCols %in% name) # how many importedCollector strings in displayName?
## none of the names match

# test loop
for(i in 1:length(importCols)){
  print(importCols[i])
  print(colIDs[i])
}

# loop SELECT/UPDATE script
#time the loop:
system.time(
        for(i in 1:length(importCols)){
                # start of loop
                
                # print current iteration imported collector & the collectorID being updated to  
                print(importCols[i])
                print(colIDs[i])
                # split the output a little for readability
                message("...")
                
                # SELECT QUERY: check current settings for records with importedCollector[i]
                qry_checkCurrent <- paste0("SELECT [Herb].[id], [Herb].[Collector Key], [Team].[name for display] AS collector, [Herb].[importedCollector], [Herb].[Locality] FROM [Herbarium specimens] AS [Herb] LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id WHERE [Herb].[importedCollector]='", importCols[i], "';")
                # print results of sqlQuery
                print(sqlQuery(con_livePadmeArabia, qry_checkCurrent))
                
                # UPDATE QUERY: update [Herbarium specimens].[Collector Key] settings with colID[i] in records with importedCollector[i]
                qry_updateCurrent <- paste0("UPDATE [Herbarium specimens] SET [Herbarium specimens].[Collector Key]=", colIDs[i], " WHERE [Herbarium specimens].[importedCollector]='", importCols[i], "';")
                print(sqlQuery(con_livePadmeArabia, qry_updateCurrent))
                # print results of sqlQuery
                
                # SELECT QUERY: check new settings for records with importedCollector[i]
                qry_newCurrent <- paste0("SELECT [Herb].[id], [Herb].[Collector Key], [Team].[name for display] AS collector, [Herb].[importedCollector], [Herb].[Locality] FROM [Herbarium specimens] AS [Herb] LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id WHERE [Herb].[importedCollector]='", importCols[i], "';")
                # print results of sqlQuery
                print(sqlQuery(con_livePadmeArabia, qry_newCurrent))
                
                # split up output again before next iteration
                message("...................................................................")
                
                # end of loop  
        }
# return system time
)


## TEAM.IDs//HERB.COLLECTOR-KEYS IMPORTED COLLECTOR VALUES WERE SET TO:
#B.Mies & G.J.James <- 36049
#F.Ettwig & F.Bolz <- 36051
#Lisa Banfield & Ahmed Adeeb <- 35832
#Lisa Banfield & Ahmed Adeeb. <- 35832
#Lisa Banfield & Badr Awad Al-Seily <- 35833
#Lisa Banfield & Badr Awad Al-Seily. <- 35833
#Lisa Banfield & Patrick Home Robertson <- 35834
#Lisa Banfield & Patrick Home Robertson. <- 35834
#Lisa Banfield, Abdul Raqeeb & Pal Scholte. <- 35835
#Lisa Banfield, Ahmed Adeeb & Abu Rhumsey. <- 35837
#Lisa Banfield, Ahmed Adeeb & Fahmi Bashwan. <- 35830
#Lisa Banfield, Ahmed Adeeb, Fahmi Bashwan, Mike Thiv & Richard Porter. <- 35839
#Lisa Banfield, Ahmed Adeeb, Paul Scholte, Ahmed Issa. <- 35841
#Lisa Banfield, Patrick Home Robertson & Ahmed Adeeb. <- 35843
#Lisa Banfield, Patrick Home Robertson & Badr Awad Al-Seily <- 35844
#Lisa Banfield, Patrick Home Robertson & Tony Miller <- 35845
#Lisa Banfield, Patrick Home Robertson, Ahmed Adeeb & Fahmi Bashwan. <- 35846
#Lisa Banfield, Patrick Home Robertson, Ahmed Adeeb, Badr Awad Al-Seily & Paul Scholte. <- 35847
#Lisa Banfield, Patrick Home Robertson, Ahmed Adeeb, Mohammed Najeeb & Badr Awad Al-Seily. <- 35848
#Lisa Banfield, Patrick Home Robertson, Ahmed Adeeb, Mohammed Najeeb, Badr Awad Al-Seily <- 35848
#Lisa Banfield, Patrick Home Robertson, Ahmed Adeeb, Mohammed Najeeb, Badr Awad Al-Seily & Paul Scholte. <- 35825
#Lisa Banfield, Patrick Home Robertson, Ahmed Adeeb, Mohammed Najeeb, Badr Awad Al-Seily. <- 35848
#Lisa Banfield, Patrick Home Robertson, Paul Scholte & Badr Awad Al-Seily <- 35849
#Lisa Banfield, Patrick Homer Robertson, Tony Miller, Sabina Knees, Leigh Morris, Mary Gibby <- 35850
#M.Thiv <- 35840
#N.Kilian & P.Hein <- 35339
#N.Kilian, H.Kürschner, C.Oberprieler & S.Kipka <- 36054
#N.Kilian, P.Hein & C.Oberprieler <- 36057
#N.Kilian, P.Hein & H.Kürschner <- 36059
#N.Kilian, P.Hein & S.Kipka <- 36060
#N.Kilian, P.Hein, C.Oberprieler & H.Kürschner <- 36061
#N.Kilian, P.Hein, C.Oberprieler, H.Kürschner & M.Thiv <- 36062
#N.Kilian, P.Hein, C.Oberprieler, H.Kürschner, M.Thiv, M.A.Hubaishan & S.M.A.Al-Gareiri <- 36063
#N.Kilian, P.Hein, C.Oberprieler, S.Kipka, H.Kürschner, A.S.Sulaiman & M.A.Hubaishan <- 36065
#N.Kilian, P.Hein, C.Oberprieler, S.Kipka, M.Thiv & M.A.Hubaishan <- 36067
#N.Kilian, P.Hein, H.Kürschner & M.A.Hubaishan <- 36068
#N.Kilian, P.Hein, S.Kipka & M.Thiv <- 36069
#N.Kilian, P.Hein, S.Kipka, A.S.Sulaiman & M.A.Hubaishan <- 36070
#N.Kilian, P.Hein, S.Kipka, A.S.Sulaiman & M.S. Mirou <- 36071
#N.Kilian, P.Hein, S.Kipka, A.S.Sulaiman & M.S.Mirou <- 36071
#N.Kilian, P.Hein, S.Kipka, M.A.Hubaishan, M.S.Mirou & A.S.Sulaiman <- 36074
#P.Hein <- 9307
#P.Hein & E.v.Raab-Straube <- 35512
#Paul Scholte <- 33832
#S.Kipka <- 36056
#S.O.Bahah <- 35517