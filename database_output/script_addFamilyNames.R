# Socotra :: script_addFamilyNames.R
# ======================================================== 
# (21th October 2014)
# Author: Flic Anderson

# AIM: Add family names to list of Socotran herbarium specimens for easy sorting
# .... saved at "Z:/fufluns/scripts/script_addFamilyNames.R"

# run function:
TESTPadmeArabiaCon()
# opens connection "con_TESTPadmeArabia" 
# from location at "locat_TESTPadmeArabia"

## run function:
#livePadmeArabiaCon()
## opens connection "con_livePadmeArabia" 
## from location at "locat_livePadmeArabia"

qry <- "SELECT 
  [Latin Names].sortName AS familyName, 
  [names tree].member
  FROM (
    Ranks INNER JOIN [Latin Names] ON Ranks.id = [Latin Names].Rank) 
    INNER JOIN [names tree] ON [Latin Names].id = [names tree].[member of]
WHERE (((Ranks.name)='family'));"
families <- sqlQuery(con_TESTPadmeArabia, qry)
#families <- sqlQuery(con_livePadmeArabia, qry)


qry <- "
SELECT
Herb.[id],
Team.[name for display] AS collector,
Herb.[importedCollector] AS importedCollector,
Herb.[Collector Number] AS collNumFull,
Herb.[Collection number] & '' & Herb.postfix AS collNum,
Herb.[Collection number] AS collNumShort,
Hrbr.[Acronym] AS institute,
Expd.[expeditionTitle] AS expedition,
Lnam.[id] AS lnamID,
Lnam.[Full Name] AS taxonFull,
Lnam.[sortName] AS taxon,
Geog.[fullName] AS fullLocation,
Herb.[FlicFound], 
Herb.[FlicStatus], 
Herb.[FlicNotes],
Herb.[FlicIssue],
Lnam.[FullSort]
FROM ((((((([Herbarium specimens] AS [Herb] LEFT JOIN [Geography] AS [Geog] ON Herb.Locality=Geog.ID)
LEFT JOIN [Herbaria] AS [Hrbr] ON Herb.Herbarium=Hrbr.id)
LEFT JOIN [determinations] AS [Dets] ON Herb.id=Dets.[specimen key])
LEFT JOIN [Synonyms tree] AS [Snym] ON Dets.[latin name key] = Snym.member)
LEFT JOIN [Latin Names] AS [Lnam] ON Snym.[member of] = Lnam.id)
LEFT JOIN [Teams] AS [Team] ON Herb.[Collector Key]=Team.id)
LEFT JOIN [Teams] AS [DetTeam] ON Dets.[Det by] = DetTeam.id)
LEFT JOIN [Expeditions] AS [Expd] ON Herb.Expedition=Expd.id
WHERE Geog.fullName LIKE '%Socotra%' AND Dets.Current=TRUE;" 
hrbspx <- sqlQuery(con_TESTPadmeArabia, qry)
#hrbspx <- sqlQuery(con_livePadmeArabia, qry)


# join family names and rest of data
listSpx <- sqldf("SELECT * FROM hrbspx LEFT JOIN families ON hrbspx.lnamid=families.member")
names(listSpx)

# create dataset with only necessary columns
listSpx <- listSpx[,c(1, 3, 2, 4:8, 18, 10:16)]
names(listSpx)

# order data by family
#newdata <- mtcars[order(mpg, -cyl),] 
listSpx <<- listSpx[order(listSpx$familyName, listSpx$taxon, listSpx$collNumShort, na.last=TRUE),]


# WRITE LISTSPX TO .CSV FILE!!!!
write.csv(listSpx, file="List_HerbariumSpecimens_24Oct2014.csv", row.names=FALSE)


