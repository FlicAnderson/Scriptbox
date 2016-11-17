## Trees of Arabia :: script_findOccurrenceTotals-GBIF-Padme_Trees_Arabia.R
# ======================================================== 
# (17th November 2016)
# Author: Flic Anderson
#
# dependent on: "O://CMEP\ Projects/Scriptbox/database_connections/function_livePadmeArabiaCon.R"
# saved at: O://CMEP\ Projects/Scriptbox/data_various/script_findOccurrenceTotals-GBIF-Padme_Trees_Arabia.R
# source: source("O://CMEP\ Projects/Scriptbox/data_various/script_findOccurrenceTotals-GBIF-Padme_Trees_Arabia.R")
#
# AIM: Pull out records into R for species in Arabia Socotra from 
# .... Padme Arabia using SQL given a taxonName, print to console.  
# .... queries built based on structure of:
# .... "O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabSpecieswithFullLatLon.R"

# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) Load libraries, functions, source scripts
# 1) 
# 2) Build query 
# 3) Run the query
# 4) Show the output

# ---------------------------------------------------------------------------- #

# 0) 


spsPick <- c(
        "Avicennia marina (Forssk.) Vierh.",
        "Ozoroa insignis Delile",
        "Searsia natalensis (Bernh. ex Krauss) F.A.Barkley",
        "Cussonia holstii Harms ex Engl.",
        "Aloe rivierei Lavranos & A.Newton",
        "Cordia africana Lam.",
        "Ehretia obtusifolia Hochst. ex DC.",
        "Commiphora quadricincta Schweinf.",
        "Cadaba heterotricha Stocks ex Hook.",
        "Maytenus undata (Thunb.) Blakelock",
        "Diospyros mespiliformis Hochst. ex DC.",
        "Euphorbia smithii S.Carter",
        "Acacia gerardii Benth.",
        "Acacia nilotica (L.) Willd. ex Delile",
        "Bauhinia ellenbeckii Harms",
        "Prosopis cineraria (L.) Druce",
        "Dombeya schimperianum A.Rich.",
        "Grewia trichocarpa Hochst. ex A.Rich.",
        "Bersama abyssinica Fresen.",
        "Ficus palmata Forssk.", 
        "Myrsine africana L.",
        "Berchemia discolor (Klotzsch) Hemsl.",
        "Prunus arabica (Oliv.) Meikle",
        "Oncoba spinosa Forssk.",
        "Nuxia congesta R.Br. ex Fresen."
)

# taxon keys from GBIF found using: 
#head( name_suggest(q='Berchemia discolor') )
# AND also (where there was more than one species-level match using name_suggest():
#name_backbone(name='Nuxia congesta', rank='species', kingdom='plants')
# these were then written into the list below. 
# this *could* be automated, but it's not necessarily wise, as there are often
# taxonomic hassles which arise and should be dealt with by hand.

taxKeys <- c(
        2925403, 7321499, 5544278, 3035216, 2778089, 
        5660325, 4066252, 3993713, 8188508, 3793292, 
        4071204, 3067647, 2980376, 2978421, 2953893, 
        5358521, 6712742, 4259969, 3845259, 5361916, 
        7331120, 3876514, 3022146, 3879362, 4055888
)

#occ_count(taxonKey=c(2925403), georeferenced=TRUE)

for(i in 1:length(taxKeys)){
        print(occ_count(taxonKey=taxKeys[i], georeferenced=TRUE))
}
# [1] 1322
# [1] 470
# [1] 254
# [1] 170
# [1] 1
# [1] 297
# [1] 138
# [1] 1
# [1] 18
# [1] 728
# [1] 2187
# [1] 11
# [1] 115
# [1] 231
# [1] 13
# [1] 14
# [1] 13
# [1] 46
# [1] 442
# [1] 184
# [1] 1262
# [1] 224
# [1] 33
# [1] 352
# [1] 572





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

spsPick_noAuth <- c(
        "Avicennia marina",
        "Ozoroa insignis",
        "Searsia natalensis",
        "Cussonia holstii",
        "Aloe rivierei",
        "Cordia africana",
        "Ehretia obtusifolia",
        "Commiphora quadricincta",
        "Cadaba heterotricha",
        "Maytenus undata",
        "Diospyros mespiliformis",
        "Euphorbia smithii",
        "Acacia gerardii",
        "Acacia nilotica",
        "Bauhinia ellenbeckii",
        "Prosopis cineraria",
        "Dombeya schimperianum",
        "Grewia trichocarpa",
        "Bersama abyssinica",
        "Ficus palmata", 
        "Myrsine africana",
        "Berchemia discolor",
        "Prunus arabica",
        "Oncoba spinosa",
        "Nuxia congesta"
)

###---------------------- USER INPUT REQUIRED HERE --------------------------###

# 2)

i <- 1

for(i in 1:length(spsPick_noAuth)){

        taxonName <- spsPick_noAuth[i]
        
qry1 <- paste0("
SELECT 'H-' & Herb.id AS recID, 
               Team.[name for display] AS collector,
               Herb.[Collector Number] AS collNumFull,
               LnSy.[id] AS lnamID, 
                LnSy.[Full Name] AS acceptDetAs,
               LnSy.[sortName] AS acceptDetNoAuth,
               Lnam.[Full Name] AS detAs,
               Herb.[Latitude 1 Direction] AS lat1Dir,
               Herb.[Latitude 1 Decimal] AS lat1Dec, 
               Herb.[Longitude 1 Direction] AS lon1Dir,
               Herb.[Longitude 1 Decimal] AS lon1Dec, 
               Herb.[Date 1 Days] AS dateDD, 
               Herb.[Date 1 Months] AS dateMM, 
               Herb.[Date 1 Years] AS dateYYYY,
               Geog.fullName AS fullLocation ",
               # Joining tables: Herb, Geog, Herbaria, Determinations, Synonyms tree, Latin Names x2, Teams x2, CoordinateSources
               "FROM ((((((Determinations AS Dets 
RIGHT JOIN [Herbarium specimens] AS Herb ON Dets.[specimen key] = Herb.id) 
LEFT JOIN [Latin Names] AS Lnam ON Dets.[latin name key] = Lnam.id) 
LEFT JOIN [Synonyms tree] AS Synm ON Lnam.id = Synm.member) 
LEFT JOIN [Latin Names] AS LnSy ON Synm.[member of] = LnSy.id) 
LEFT JOIN Geography AS Geog ON Herb.Locality = Geog.ID) 
LEFT JOIN Teams AS Team ON Herb.[Collector Key] = Team.id) ",
               # WHERE: 
               "WHERE ",
               # ... only pull out records with current dets: 
               "Dets.Current=True AND Herb.[Longitude 1 Decimal] IS NOT NULL ", 
               # ... AND no synonyms, accepted names only
               "AND ((LnSy.[Synonym of]) Is Null) ",
               ## pull out specific taxonName
               "AND (LnSy.[sortName] LIKE '%", taxonName, "%' OR Lnam.[sortName] LIKE '%", taxonName, "%');")

# build FIEL query
# Adapted from script_dataGrabSpecies.R & various fieldObs scripts
qry2 <- paste0("SELECT 'F-' & Fiel.id AS recID, 
               Team.[name for display] AS collector,
               Fiel.[Collector Number] AS collNumFull,
               LnSy.[id] AS lnamID, 
                LnSy.[Full Name] AS acceptDetAs,
               LnSy.[sortName] AS acceptDetNoAuth,
               Lnam.[Full Name] AS detAs,
               Fiel.[Latitude 1 Decimal] AS lat1Dec,
               Fiel.[Longitude 1 Decimal] AS lon1Dec,
               Fiel.[Date 1 Days] AS dateDD, 
               Fiel.[Date 1 Months] AS dateMM, 
               Fiel.[Date 1 Years] AS dateYY,
               Geog.fullName AS fullLocation ",
# Joining tables: Field notes, geography, synonyms tree, latin names x2, teams
"FROM (((([Field notes] AS Fiel 
          LEFT JOIN Geography AS Geog ON Fiel.Locality = Geog.ID) 
         LEFT JOIN Teams AS Team ON Fiel.[Collector Key] = Team.id) 
        LEFT JOIN [Latin Names] AS Lnam ON Fiel.determination = Lnam.id) 
       LEFT JOIN [Synonyms tree] AS Snym ON Lnam.id = Snym.member) 
       LEFT JOIN [Latin Names] AS LnSy ON Snym.[member of] = LnSy.id ",
# WHERE: 
"WHERE Fiel.[Longitude 1 Decimal] IS NOT NULL AND ((LnSy.[Synonym of]) Is Null) ",
"AND (LnSy.[sortName] LIKE '%", taxonName, "%' OR Lnam.[sortName] LIKE '%", taxonName, "%');")

# 3)

# run query
herbRex <- sqlQuery(con_livePadmeArabia, qry1) #03/06/2015 1843 req DMS, 3647 req DM, 8166 w/ IFF
fielRex <- sqlQuery(con_livePadmeArabia, qry2) #03/06/2015 4602 req DMS, 6754 req DM, 12253 w/ IFF

# show number of records returned
print(paste(taxonName, ": field=", nrow(fielRex), " herb=", nrow(herbRex)))

i <- i +1

}


# join field and herbarium data vertically
# DON'T PANIC: error created ("Warning message: In `[<-.factor`(`*tmp*`, ri, value
#  = c(NA, NA, NA, NA, NA, NA, NA, : invalid factor level, NA generated)") to do  
# with data type of collNumFull in recGrab1 (factor) vs in recGrab2 (integer) 
# but doesn't matter much!
#recGrab <- rbind(herbRex, fielRex)
#nrow(recGrab) #03/06/2015 6445 req DMS, 10432 req DM, 22285 w/ IFF

# VERY IMPORTANT!
# CLOSE DATABASE CONNECTIONs & REMOVE OBJECTS FROM WORKSPACE!
odbcCloseAll()
rm(list=ls())
