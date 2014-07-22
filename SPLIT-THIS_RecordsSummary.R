# Padme Data:: Databasin:: RecordsSummary.R
# ======================================================== 
# (14th April 2014)
# Companion to databasin.Rmd 

# rough estimates!

# pull out all FIELD OBS and HERBARIUM SPECIMENS for all SOCOTRA records.

# Q: total # of unique records in Padme (Socotra)
  # Q: percentages for herbarium:fieldobs records

# Q: for ALL records, which % are held at Edinburgh (herbarium only?)

# (Q: list of specimens with ACCEPTED names; but do this by creating a list of the accepted names of Socotran plants only, then check they're all still up to date!  Then move onto phase 2.)

#-----------------------------------------------------#
# load required packages, install if they aren't installed already

# {RODBC} - ODBC Database Access
if (!require(RODBC)){
  install.packages("RODBC")
  library(RODBC)
} 

#{sqldf} - Perform SQL Selects on R Data Frames
if (!require(sqldf)){
  install.packages("sqldf")
  library(sqldf)
} 

#-----------------------------------------------------#


locat <- "C:/Padme/padmecode.mdb"
## REAL LOCAT:
##locat <- "Z:/socotra/TESTAREA_Databasin/padmedata"

# open connection called "con" to file at known location
# if this is already open it doesn't do any harm if this command is repeated I think
con <- odbcConnectAccess(locat)

# check the connection is working
odbcGetInfo(con)

## FIELDREX UNION HERBREX <= "RexEst1"
# synonyms INCLUDED:
# THIS WORKS 17/04/2014 10:20am
qry <- "SELECT
Fiel.id,
Team.[name for display] AS collector,
Fiel.[Collector Number] AS collNumFull,
Fiel.[collection number] & '' & Fiel.postfix AS collNum,
Lnam.[Full Name] AS taxonFull,
Lnam.[sortName] AS taxon,
Geog.fullName AS fullLocation,
Geog.[Latitude 1 Decimal] AS geog_lat,
Geog.[Longitude 1 Decimal] AS geog_lon
FROM ((([Field notes] AS [Fiel] LEFT JOIN [Geography] AS [Geog] ON Fiel.Locality=Geog.ID)
LEFT JOIN [Synonyms tree] AS [Snym] ON Fiel.determination = Snym.member)
LEFT JOIN [Latin Names] AS [Lnam] ON Snym.[member of] = Lnam.id)
LEFT JOIN [Teams] AS [Team] ON Fiel.[Collector Key]=Team.id
WHERE Geog.fullName LIKE '%Socotra%'
UNION
SELECT
Herb.id,
Team.[name for display] AS collector,
Herb.[Collector Number] AS collNumFull,
Herb.[Collection number] & '' & Herb.postfix AS collNum,
Lnam.[Full Name] AS taxonFull,
Lnam.[sortName] AS taxon,
Geog.fullName AS fullLocation,
Geog.[Latitude 1 Decimal] AS geog_lat,
Geog.[Longitude 1 Decimal] AS geog_lon
FROM (((((([Herbarium specimens] AS [Herb] LEFT JOIN [Geography] AS [Geog] ON Herb.Locality=Geog.ID)
LEFT JOIN [Herbaria] ON Herb.Herbarium=Herbaria.id)
LEFT JOIN [determinations] AS [Dets] ON Herb.id=Dets.[specimen key])
LEFT JOIN [Synonyms tree] AS [Snym] ON Dets.[latin name key] = Snym.member)
LEFT JOIN [Latin Names] AS [Lnam] ON Snym.[member of] = Lnam.id)
LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id)
LEFT JOIN [Teams] AS [DetTeam] ON Dets.[Det by] = DetTeam.id
WHERE Geog.fullName LIKE '%Socotra%' AND Dets.Current=True
ORDER BY 2
;"
#remove the following once it stops giving an error:
#sqlQuery(con, qry)
# and leave this only:
RexEst1<- sqlQuery(con, qry)
Sys.sleep(2)
nrow(RexEst1)

## LITREX <= "RexEst2"
# LitRex
qry1 <- "SELECT 
Litr.id, 
Lnam.[Full Name] AS taxonFull, 
Lnam.[sortName] AS taxon,
Auth.[name for display] AS collector,
Geog.fullName AS fullLocation, 
Geog.[Latitude 1 Decimal] AS geog_lat,  
Geog.[Longitude 1 Decimal] AS geog_lon 
FROM (Teams AS [Auth] 
RIGHT JOIN ([References] AS [Refr] 
RIGHT JOIN ([Latin Names] AS [Lnam] 
RIGHT JOIN [literature records] AS [Litr] 
ON Lnam.id = Litr.determination) 
ON Refr.id = Litr.Reference) 
ON Auth.id = Refr.Authors) 
LEFT JOIN (Geography AS [Geog] 
RIGHT JOIN LiteratureRecordLocations AS [LRLo] 
ON Geog.ID = LRLo.locality) 
ON Litr.id = LRLo.litrecid 
WHERE Geog.fullName LIKE '%Socotra%'
;"
#tail(sqlQuery(con, qry1))
RexEst2 <- sqlQuery(con, qry1)
Sys.sleep(2)
nrow(RexEst2)

RexEst2$collNumFull <- "NA"
RexEst2$collNum <- "NA" 

names(RexEst1)
names(RexEst2)

## ALL RECORDS <= RexEst1 + RexEst2 <= Literature + Herbarium + Field Obs
# join all record sources
allRex <- rbind(RexEst1, RexEst2)
nrow(allRex)

str(allRex$taxon)


#-----------------------------------------------------#
## Field Observation records only
qry <- "SELECT
Fiel.id,
Team.[name for display] AS collector,
Fiel.[Collector Number] AS collNumFull,
Fiel.[collection number] & '' & Fiel.postfix AS collNum,
Lnam.[Full Name] AS taxonFull,
Lnam.[sortName] AS taxon,
Fiel.[Associated with] AS herbariumSpx,
Geog.fullName AS fullLocation,
Geog.[Latitude 1 Decimal] AS geog_lat,
Geog.[Longitude 1 Decimal] AS geog_lon
FROM ((([Field notes] AS [Fiel] LEFT JOIN [Geography] AS [Geog] ON Fiel.Locality=Geog.ID)
LEFT JOIN [Synonyms tree] AS [Snym] ON Fiel.determination = Snym.member)
LEFT JOIN [Latin Names] AS [Lnam] ON Snym.[member of] = Lnam.id)
LEFT JOIN [Teams] AS [Team] ON Fiel.[Collector Key]=Team.id
WHERE Geog.fullName LIKE '%Socotra%';"
field <- sqlQuery(con, qry)
Sys.sleep(2)
nrow(field)
#-----------------------------------------------------#

#-----------------------------------------------------#
## Field obs, includes associated herbarium specimens in displayed fields
qry <- "SELECT Fiel.id, Team.[name for display] AS collector, Fiel.[Collector Number] AS collNumFull, Fiel.[collection number] & '' & Fiel.postfix AS collNum, Lnam.[Full Name] AS taxonFull, Lnam.[sortName] AS taxon, Herb.[collector number] AS herbariumSpx, Geog.fullName AS fullLocation, Geog.[Latitude 1 Decimal] AS geog_lat, Geog.[Longitude 1 Decimal] AS geog_lon
FROM (((([Field notes] AS Fiel LEFT JOIN Geography AS Geog ON Fiel.Locality = Geog.ID) 
        LEFT JOIN [Synonyms tree] AS Snym ON Fiel.determination = Snym.member) 
       LEFT JOIN [Latin Names] AS Lnam ON Snym.[member of] = Lnam.id) 
      LEFT JOIN Teams AS Team ON Fiel.[Collector Key] = Team.id) 
LEFT JOIN [Herbarium specimens] AS Herb ON Fiel.[Associated with] = Herb.id
WHERE (((Geog.fullName) Like '%Socotra%'));"
#sqlQuery(con,qry)
withAssoc <- sqlQuery(con, qry)
#-----------------------------------------------------#

#-----------------------------------------------------#
## Herbarium specimen records only
qry <- "SELECT
Herb.id,
Team.[name for display] AS collector,
Herb.[Collector Number] AS collNumFull,
Herb.[Collection number] & '' & Herb.postfix AS collNum,
Lnam.[Full Name] AS taxonFull,
Lnam.[sortName] AS taxon,
Geog.fullName AS fullLocation,
Geog.[Latitude 1 Decimal] AS geog_lat,
Geog.[Longitude 1 Decimal] AS geog_lon
FROM (((((([Herbarium specimens] AS [Herb] LEFT JOIN [Geography] AS [Geog] ON Herb.Locality=Geog.ID)
LEFT JOIN [Herbaria] ON Herb.Herbarium=Herbaria.id)
LEFT JOIN [determinations] AS [Dets] ON Herb.id=Dets.[specimen key])
LEFT JOIN [Synonyms tree] AS [Snym] ON Dets.[latin name key] = Snym.member)
LEFT JOIN [Latin Names] AS [Lnam] ON Snym.[member of] = Lnam.id)
LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id)
LEFT JOIN [Teams] AS [DetTeam] ON Dets.[Det by] = DetTeam.id
WHERE Geog.fullName LIKE '%Socotra%' AND Dets.Current=True;"
herb <- sqlQuery(con, qry)
Sys.sleep(2)
nrow(herb)
#-----------------------------------------------------#

#-----------------------------------------------------#
## herbarium records from E or with blank herbarium field:
qry <- "SELECT
Herb.id,
Team.[name for display] AS collector,
Herb.[Collector Number] AS collNumFull,
Herb.[Collection number] & '' & Herb.postfix AS collNum,
Lnam.[Full Name] AS taxonFull,
Lnam.[sortName] AS taxon,
Geog.fullName AS fullLocation,
Geog.[Latitude 1 Decimal] AS geog_lat,
Geog.[Longitude 1 Decimal] AS geog_lon
FROM (((((([Herbarium specimens] AS [Herb] LEFT JOIN [Geography] AS [Geog] ON Herb.Locality=Geog.ID)
LEFT JOIN [Herbaria] ON Herb.Herbarium=Herbaria.id)
LEFT JOIN [determinations] AS [Dets] ON Herb.id=Dets.[specimen key])
LEFT JOIN [Synonyms tree] AS [Snym] ON Dets.[latin name key] = Snym.member)
LEFT JOIN [Latin Names] AS [Lnam] ON Snym.[member of] = Lnam.id)
LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id)
LEFT JOIN [Teams] AS [DetTeam] ON Dets.[Det by] = DetTeam.id
WHERE Geog.fullName LIKE '%Socotra%' AND Dets.Current=True AND (Herbaria.id=7 OR Herbaria.id IS NULL);"
sqlQuery(con, qry)
Sys.sleep(2)
herbENA <- sqlQuery(con, qry)
nrow(herbENA)
#-----------------------------------------------------#

#-----------------------------------------------------#
## Edinburgh specimens only:
qry <- "SELECT
Herb.id,
Team.[name for display] AS collector,
Herb.[Collector Number] AS collNumFull,
Herb.[Collection number] & '' & Herb.postfix AS collNum,
Lnam.[Full Name] AS taxonFull,
Lnam.[sortName] AS taxon,
Geog.fullName AS fullLocation,
Geog.[Latitude 1 Decimal] AS geog_lat,
Geog.[Longitude 1 Decimal] AS geog_lon
FROM (((((([Herbarium specimens] AS [Herb] LEFT JOIN [Geography] AS [Geog] ON Herb.Locality=Geog.ID)
LEFT JOIN [Herbaria] ON Herb.Herbarium=Herbaria.id)
LEFT JOIN [determinations] AS [Dets] ON Herb.id=Dets.[specimen key])
LEFT JOIN [Synonyms tree] AS [Snym] ON Dets.[latin name key] = Snym.member)
LEFT JOIN [Latin Names] AS [Lnam] ON Snym.[member of] = Lnam.id)
LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id)
LEFT JOIN [Teams] AS [DetTeam] ON Dets.[Det by] = DetTeam.id
WHERE Geog.fullName LIKE '%Socotra%' AND Dets.Current=True AND Herbaria.id=7;"
#sqlQuery(con, qry)
herbE <- sqlQuery(con, qry)
nrow(herbE)
#-----------------------------------------------------#


#-----------------------------------------------------#
## SUMMARIES AND TOTALS!
# Number of LitRex
# total: 1866
print(paste("Padme contains", nrow(RexEst2), "Socotran literature records", sep=" "))
# duplicates removed? (~5%? 2%?):
# ?

# Number of FieldRex
# total: 11013
print(paste("Padme contains", nrow(field), "Socotran field observation records", sep=" "))
# 

# Number of HerbRex
# total: 8052
print(paste("Padme contains", nrow(herb), "Socotran herbarium records", sep=" "))
# number at Edinburgh:
print(paste("Padme contains", nrow(herbE), "Socotran herbarium records at Edinburgh", sep=" "))
# number of field notes associated with herbarium specimens?
# (don't know if this works)

print(paste("Padme contains", nrow(allRex), "Socotran records in total", sep=" "))

# at 17/04/2014 Total ALL REX: 11013 + 8052 + 1866
  # at 17/04/2014 total ALL REX: 20931
# at 22/07/2014 total ALL REX: 11744 + 8118 + 1866
  # at 22/07/2014 total ALL REX: 21728

#-----------------------------------------------------#


# VERY IMPORTANT!
# CLOSE THE CONNECTION!
odbcCloseAll()



# =================================================================================== #



#-----------------------------------------------------#
### list all distinct taxa (no auth)
socotraTaxa <- sqldf("SELECT DISTINCT taxon FROM allRex")
socotraTaxa <- sort(socotraTaxa[,], na.last=TRUE, decreasing=FALSE)
length(socotraTaxa)

#-----------------------------------------------------#
### list all distinct taxa from socotra (full species names with auth.)
socotraTaxaFull <- sqldf("SELECT DISTINCT taxonFull FROM allRex")
socotraTaxaFull <- sort(socotraTaxaFull[,], na.last=TRUE, decreasing=FALSE)
print(paste("Padme contains records for", length(socotraTaxaFull), "distinct taxa found on Socotra in total", sep=" "))
# as of 22/07/2014 this number was 1965 taxa records, including synonyms and only current dets and including random records like "Incana incana" <- the Socotran Warbler, a bird...
#-----------------------------------------------------#


# empty the environment of objects
rm(list=ls())