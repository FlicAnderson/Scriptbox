## Socotra Project :: script_dataGrabFullLatLonOrGazLatLon_Socotra.R
# ==============================================================================
# (4th June 2015)
# Author: Flic Anderson
#
# dependent on: "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R"
# saved at: O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R
# source: source("O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Socotra.R")
#
# AIM: Pull out records into R for species in Socotra from 
# .... Padme Arabia using SQL via the RODBC connection set up in another script. 
# .... Includes lat/lon from Padme gazetteer where no lat /lon are present &
# .... ignore records which only list locat as "Socotra" or "Socotra Archipelago"
# .... as these would proliferate 1 location (the mid-point for Socotra or the 
# .... islands; unhelpful). 
# .... Then save as CSV file (.csv) for future use.

# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) Load libraries, functions, source scripts
# 1) 
# 2) Build query 
# 3) Run the query
# 4) Show the output
# 5) Save the output to .csv

# ---------------------------------------------------------------------------- #

# 0) 

# load required packages, install if they aren't installed already
# {RODBC} - ODBC Database Access
if (!require(RODBC)){
  install.packages("RODBC")
  library(RODBC)
} 
if (!require(sqldf)){
        install.packages("sqldf")
        library(sqldf)
} 
# open connection to live padme
source("O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R")
livePadmeArabiaCon()


# 1) 

###---------------------- USER INPUT REQUIRED HERE --------------------------###

# please input the location you're searching for, as shown in the examples below:
# examples: 
#locatName <- "Socotra"
#locatName <- "Socotra Archipelago"
#locatName <- "Hadibo"
#locatName <- "Socotra"

###---------------------- USER INPUT REQUIRED HERE --------------------------###

# 2)

# get headings for herbarium specimens and field notes and literature records tables
#Herb <- sqlQuery(con_livePadmeArabia, query="SELECT TOP 1 * FROM [Herbarium specimens]")
#Fiel <- sqlQuery(con_livePadmeArabia, query="SELECT TOP 1 * FROM [Field notes]")
#Litr <- sqlQuery(con_livePadmeArabia, query="SELECT TOP 1 * FROM [literature records]")

# build HERB query
# Adapted from script_dataGrabSpecieswithFullLatLon.R
qry1 <- paste0("
SELECT 'H-' & Herb.id AS recID, 
Team.[name for display] AS collector,
Herb.[Collector Number] AS collNumFull, ",
# Lnam.[Full Name] AS detAs,
# HERE the Lnam.FullName is replaced by the ACCEPTED NAME
# THIS IS NOT WHAT IT WAS ORIG DET AS BUT THE ACCEPTED UPDATED NAME
"LnSy.[Full Name] AS detAs,
Herb.[Latitude 1 Direction] AS lat1Dir,
Herb.[Latitude 1 Degrees] AS lat1Deg,
Herb.[Latitude 1 Minutes] AS lat1Min,
Herb.[Latitude 1 Seconds] AS lat1Sec,
Herb.[Latitude 1 Decimal] AS lat1Dec, ",
#IIF no decimal latitude, then use geography/gazetteer latitude, but if it's there, use that as AnyLat
"IIf(IsNull(Herb.[Latitude 1 Decimal]),Geog.[Latitude 1 Decimal],Herb.[Latitude 1 Decimal]) AS AnyLat,
Herb.[Longitude 1 Direction] AS lon1Dir,
Herb.[Longitude 1 Degrees] AS lon1Deg,
Herb.[Longitude 1 Minutes] AS lon1Min,
Herb.[Longitude 1 Seconds] AS lon1Sec,
Herb.[Longitude 1 Decimal] AS lon1Dec, ",
#IIF no decimal longitude, then use geography/gazetteer longitude, but if it's there, use that as AnyLon
"IIf(IsNull(Herb.[Longitude 1 Decimal]),Geog.[Longitude 1 Decimal],Herb.[Longitude 1 Decimal]) AS AnyLon,
Herb.[coordinateSource] AS coordSource,
Herb.[coordinateAccuracy] AS coordAccuracy,
Herb.[coordinateAccuracyUnits] AS coordAccuracyUnits,
iif(isnull(Herb.[Latitude 1 Decimal]),'G','S') as coordSourcePlus,
Herb.[Date 1 Days] AS dateDD, 
Herb.[Date 1 Months] AS dateMM, 
Herb.[Date 1 Years] AS dateYY,
Geog.fullName AS fullLocation ",
# Joining tables: Herb, Geog, Herbaria, Determinations, Synonyms tree, Latin Names, Teams x2, CoordinateSources
               "FROM ((((((((Determinations AS Dets 
RIGHT JOIN [Herbarium specimens] AS Herb ON Dets.[specimen key] = Herb.id) 
LEFT JOIN [Latin Names] AS Lnam ON Dets.[latin name key] = Lnam.id) 
LEFT JOIN [Synonyms tree] AS Synm ON Lnam.id = Synm.member) 
LEFT JOIN [Latin Names] AS LnSy ON Synm.[member of] = LnSy.id) 
LEFT JOIN Geography AS Geog ON Herb.Locality = Geog.ID) 
LEFT JOIN Teams AS Team ON Herb.[Collector Key] = Team.id) 
LEFT JOIN Herbaria ON Herb.Herbarium = Herbaria.id) 
LEFT JOIN CoordinateSources AS Coor ON Herb.coordinateSource = Coor.id) 
LEFT JOIN Teams AS DtTm ON Dets.[Det by] = DtTm.id ",
# WHERE: 
"WHERE ",
# only pull out records with current dets: 
"Dets.Current=True ",

# REQ: FIX FOR SYNONYMS POPPING UP IN DATA WITH SAME H-IDs

#       the location string doesn't stop at "Socotra" or "Socotran Archipelago": 
#              (to avoid lots of dots at the lat/lon of "Socotra" etc since that's very
#              unhelpful & doesn't give us a true location, even though it's a precise 
#              lat/lon value.
#              NB: The smaller islands Darsa & Semhah are allowed as they're small 
#              enough to be useful location values. Abd Al Kuri is still a bit too big
"AND ((Geog.fullName LIKE '%Socotra:%' OR Geog.fullName LIKE '%Abd al Kuri:%' OR Geog.fullName LIKE '%Semhah' OR Geog.fullName LIKE '%Darsa') ",
#       OR location string does just say Socotra or the Archipelago BUT has 
#       a valid lat/lon (tested on longitude). 
#               This ensures recently imported datasets with GPS/decimal degrees
#               high-accuracy lat/lon are included!
"OR ((Geog.fullName LIKE '%Socotra Archipelago: Socotra' AND Herb.[Longitude 1 Decimal] IS NOT NULL) OR (Geog.fullName LIKE '%Socotra Archipelago' AND Herb.[Longitude 1 Decimal] IS NOT NULL))) AND ((LnSy.[Synonym of]) Is Null) ",
# ORDER BY ...
"ORDER BY Team.[name for display];")


# build FIEL query
# Adapted from script_dataGrabSpecieswithFullLatLon.R & various fieldObs scripts
qry2 <- paste0("
SELECT 'F-' & Fiel.id AS recID,
Team.[name for display] AS collector,
Fiel.[Collector Number] AS collNumFull,
Lnam.[Full Name] AS detAs,
Fiel.[Latitude 1 Direction] AS lat1Dir,
Fiel.[Latitude 1 Degrees] AS lat1Deg,
Fiel.[Latitude 1 Minutes] AS lat1Min,
Fiel.[Latitude 1 Seconds] AS lat1Sec,
Fiel.[Latitude 1 Decimal] AS lat1Dec,",
#IIF no decimal latitude, then use geography/gazetteer latitude, but if it's there, use that as AnyLat
"IIf(IsNull(Fiel.[Latitude 1 Decimal]),Geog.[Latitude 1 Decimal],Fiel.[Latitude 1 Decimal]) AS AnyLat,
Fiel.[Longitude 1 Direction] AS lon1Dir,
Fiel.[Longitude 1 Degrees] AS lon1Deg,
Fiel.[Longitude 1 Minutes] AS lon1Min,
Fiel.[Longitude 1 Seconds] AS lon1Sec,
Fiel.[Longitude 1 Decimal] AS lon1Dec,", 
#IIF no decimal longitude, then use geography/gazetteer longitude, but if it's there, use that as AnyLon
"IIf(IsNull(Fiel.[Longitude 1 Decimal]),Geog.[Longitude 1 Decimal],Fiel.[Longitude 1 Decimal]) AS AnyLon,
Fiel.[coordinateSource] AS coordSource,
iif(isnull(Fiel.[Latitude 1 Decimal]),'G','S') as coordSourcePlus,
Fiel.[coordinateAccuracy] AS coordAccuracy,
Fiel.[coordinateAccuracyUnits] AS coordAccuracyUnits,
Fiel.[Date 1 Days] AS dateDD, 
Fiel.[Date 1 Months] AS dateMM, 
Fiel.[Date 1 Years] AS dateYY,
Geog.fullName AS fullLocation ",
# Joining tables: Field notes, geography, synonyms tree, latin names, teams
"FROM ((([Field notes] AS [Fiel] LEFT JOIN [Geography] AS [Geog] ON Fiel.Locality=Geog.ID)
        LEFT JOIN [Synonyms tree] AS [Snym] ON Fiel.determination = Snym.member)
         LEFT JOIN [Latin Names] AS [Lnam] ON Snym.[member of] = Lnam.id)
          LEFT JOIN [Teams] AS [Team] ON Fiel.[Collector Key]=Team.id ",
# WHERE: 
"WHERE ",
#       the location string doesn't stop at "Socotra" or "Socotran Archipelago": 
#              (to avoid lots of dots at the lat/lon of "Socotra" etc since that's very
#              unhelpful & doesn't give us a true location, even though it's a precise 
#              lat/lon value.
#              NB: The smaller islands Darsa & Semhah are allowed as they're small 
#              enough to be useful location values. Abd Al Kuri is still a bit too big
"((Geog.fullName LIKE '%Socotra:%' OR Geog.fullName LIKE '%Abd al Kuri:%' OR Geog.fullName LIKE '%Semhah' OR Geog.fullName LIKE '%Darsa') ", 
#       OR      location string does just say Socotra or the Archipelago BUT has 
#               a valid lat/lon (tested on longitude). 
#               This ensures recently imported datasets with GPS/decimal degrees
#               high-accuracy lat/lon are included!
"OR ((Geog.fullName LIKE '%Socotra Archipelago: Socotra' AND Fiel.[Longitude 1 Decimal] IS NOT NULL) OR (Geog.fullName LIKE '%Socotra Archipelago' AND Fiel.[Longitude 1 Decimal] IS NOT NULL))) ",
# ORDER BY ...
"ORDER BY Team.[name for display];")



# build LITR query
# adapted from script_dataGrabSpecieswithFullLatLon.R
qry3 <- paste0("
SELECT 'L-' & Litr.id AS recID, 
Auth.[name for display] AS collector,
Litr.id AS collNumFull,
Lnam.[Full Name] AS detAs, 
Litr.[Latitude 1 Direction] AS lat1Dir,
Litr.[Latitude 1 Degrees] AS lat1Deg,
Litr.[Latitude 1 Minutes] AS lat1Min,
Litr.[Latitude 1 Seconds] AS lat1Sec,
Litr.[Latitude 1 Decimal] AS lat1Dec,", 
#IIF no decimal latitude, then use geography/gazetteer latitude, but if it's there, use that as AnyLat
"IIf(IsNull(Litr.[Latitude 1 Decimal]),Geog.[Latitude 1 Decimal],Litr.[Latitude 1 Decimal]) AS AnyLat,
Litr.[Longitude 1 Direction] AS lon1Dir,
Litr.[Longitude 1 Degrees] AS lon1Deg,
Litr.[Longitude 1 Minutes] AS lon1Min,
Litr.[Longitude 1 Seconds] AS lon1Sec,
Litr.[Longitude 1 Decimal] AS lon1Dec,", 
#IIF no decimal longitude, then use geography/gazetteer longitude, but if it's there, use that as AnyLon
"IIf(IsNull(Litr.[Longitude 1 Decimal]),Geog.[Longitude 1 Decimal],Litr.[Longitude 1 Decimal]) AS AnyLon,
Litr.[coordinateSource] AS coordSource,
iif(isnull(Litr.[Latitude 1 Decimal]),'G','S') as coordSourcePlus,
Litr.[coordinateAccuracy] AS coordAccuracy,
Litr.[coordinateAccuracyUnits] AS coordAccuracyUnits,
Litr.[Date 1 Days] AS dateDD, 
Litr.[Date 1 Months] AS dateMM, 
Litr.[Date 1 Years] AS dateYY,
Geog.fullName AS fullLocation ",
# Joining tables: Literature records, Teams, References, Literature Record Locations, geography, latin names
"FROM (Teams AS [Auth] 
      RIGHT JOIN ([References] AS [Refr] 
                  RIGHT JOIN ([Latin Names] AS [Lnam] 
                              RIGHT JOIN [literature records] AS [Litr] 
                              ON Lnam.id = Litr.determination) 
                  ON Refr.id = Litr.Reference) 
      ON Auth.id = Refr.Authors) 
LEFT JOIN (Geography AS [Geog] 
           RIGHT JOIN LiteratureRecordLocations AS [LRLo] 
           ON Geog.ID = LRLo.locality) 
ON Litr.id = LRLo.litrecid ",
# WHERE: 
"WHERE ", 
#       the location string doesn't stop at "Socotra" or "Socotran Archipelago": 
#              (to avoid lots of dots at the lat/lon of "Socotra" etc since that's very
#              unhelpful & doesn't give us a true location, even though it's a precise 
#              lat/lon value.
#              NB: The smaller islands Darsa & Semhah are allowed as they're small 
#              enough to be useful location values. Abd Al Kuri is still a bit too big
"((Geog.fullName LIKE '%Socotra:%' OR Geog.fullName LIKE '%Abd al Kuri:%' OR Geog.fullName LIKE '%Semhah' OR Geog.fullName LIKE '%Darsa')", 
#       OR location string does just say Socotra or the Archipelago BUT has 
#       a valid lat/lon (tested on longitude). 
#               This ensures recently imported datasets with GPS/decimal degrees
#               high-accuracy lat/lon are included!
"OR ((Geog.fullName LIKE '%Socotra Archipelago: Socotra' AND Litr.[Longitude 1 Decimal] IS NOT NULL) OR (Geog.fullName LIKE '%Socotra Archipelago' AND Litr.[Longitude 1 Decimal] IS NOT NULL)))",
# ORDER BY ...
"ORDER BY Auth.[name for display];")


# 3)

# run query
herbRex <- sqlQuery(con_livePadmeArabia, qry1) 
# 03/06/2015 1843 req DMS, 3647 req DM, 8166 w/ IFF, 
# 04/06/2015 6089 rm Socotra w/o latlon
# 05/06/2015 6155 with only accepted names 
# 08/06/2015 6149 (fixed some latin names taxonomy in padme)
fielRex <- sqlQuery(con_livePadmeArabia, qry2) 
# 03/06/2015 4602 req DMS, 6754 req DM, 12253 w/ IFF
# 04/06/2015 12037 rm Socotra w/o latlon
litrRex <- sqlQuery(con_livePadmeArabia, qry3) 
# 03/06/2015 0 req DMS, 31 req DM, 1866 w/ IFF
# 04/06/2015 651 rm Socotra w/o latlon

# show number of records returned
nrow(herbRex)
nrow(fielRex)
nrow(litrRex)

# join field and herbarium data vertically
        # DON'T PANIC: error created ("Warning message: In `[<-.factor`(`*tmp*`, ri, value
        #  = c(NA, NA, NA, NA, NA, NA, NA, : invalid factor level, NA generated)") to do  
        # with data type of collNumFull in recGrab1 (factor) vs in recGrab2 (integer) 
        # but doesn't matter much!

recGrab <- rbind(herbRex, fielRex, litrRex)
nrow(recGrab) 
# 03/06/2015 6445 req DMS, 10432 req DM, 22285 w/ IFF
# 04/06/2015 19497 rm Socotra w/o latlon
# 05/06/2015 18843 herb specimens with only accepted names
recGrab <- recGrab[order(recGrab$dateYY, recGrab$dateMM, recGrab$dateDD, recGrab$collector, na.last=TRUE),]

# 4)

# # show first 6 records returned 
#   # sorted so Edinburgh specimens, then found specimens float to the top 
# head(recGrab[order(order(recGrab$institute, recGrab$FlicFound, decreasing=TRUE, na.last=TRUE)),])
head(recGrab[order(recGrab$dateYY, recGrab$dateMM, recGrab$dateDD, recGrab$collector, na.last=TRUE),])

# 5)

### USER REMINDER: 
# write.csv() function will ask where to save file and what to call it
# enter filename including '.csv', & if asked whether to create file, say 'YES' 
  # write to .csv file
  # sorted so Edinburgh specimens, then found specimens, displayed ascendingly
write.csv(recGrab[order(recGrab$dateYY, recGrab$dateMM, recGrab$dateDD, recGrab$collector, na.last=TRUE),], file=file.choose(), row.names=FALSE)


# Duplicate ID numbers issue fixing: 

# make a table of the counts (table()) of recIDs from recGrab
a <- as.data.frame(table(recGrab$recID))0
# subset out all the records where the frequency of the recID is >1 (ie duplicated)
b <- a[which(a$Freq>1),]; rm(a)
# subset into chunks to look at records & solve problems
b[1:25,]
# SOLVED problems for H- records (~6 occasions of duplication) by looking at the records
# ... all to do with Justicia:
# (Justicia heterocarpa // Justicia heterocarpa subsp. heterocarpa - solved by setting J. heterocarpa subsp. heterocarpa as a synonym of J. heterocarpa as no other subsp exist in database & autonyms are same taxon) 
# (Justicia sp nov A // Justicia alexandri - solved by detting the specimen to J. alexandri, as this specimen 14280 is the HOLOTYPE for this taxon)
# ONGOING problems for F- records (~1026 occasions of duplication)
# need to implement accepted names only for the field records & literature records queries!





# VERY IMPORTANT!
# CLOSE DATABASE CONNECTIONs & REMOVE OBJECTS FROM WORKSPACE!
odbcCloseAll()
rm(list=ls())
