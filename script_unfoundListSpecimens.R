# Socotra :: script_unfoundListSpecimens.R
# ======================================================== 
# (27th October 2014)
# Author: Flic Anderson
# .... saved at "Z:/fufluns/scripts/script_unfoundListSpecimens.R"

# AIM: Pull out and sort list of unfound Socotran herbarium specimens for 
# .... finding/investigation


names(listSpx)
library(dplyr)

# create dataset with only necessary columns
#listSpx <- listSpx[,c(1, 3, 2, 4:8, 18, 10:16)]
names(listSpx)

# order data by family
#newdata <- mtcars[order(mpg, -cyl),] 
#listSpx <<- listSpx[order(listSpx$familyName, listSpx$taxon, listSpx$collNumShort, na.last=TRUE),]
listSpx <- tbl_df(listSpx) 
missingSpx <- 
  listSpx %>%
  select(id, familyName, taxon, collNumFull, collNumShort, collector, expedition, institute, FlicFound, FlicStatus, FlicIssue, FlicNotes) %>%
  filter(is.na(FlicFound), (institute=="E"|is.na(institute))) %>%
  #arrange(familyName, collector, collNumShort) %>%
  arrange(collector, familyName, collNumShort) %>%
  select(id, familyName, taxon, collNumFull, collector, expedition, institute, FlicFound, FlicStatus, FlicIssue, FlicNotes)
  write.csv(missingSpx, file="List_UnfoundSpecimens_27Oct2014.csv")
  #print

listSpx <- tbl_df(listSpx) 
missingSpxE <- 
  listSpx %>%
  select(id, familyName, taxon, collNumFull, collNumShort, collector, expedition, institute, FlicFound, FlicStatus, FlicIssue, FlicNotes) %>%
  filter(is.na(FlicFound), institute=="E") %>%
  #arrange(familyName, collector, collNumShort) %>%
  arrange(collector, familyName, collNumShort) %>%
  select(id, familyName, taxon, collNumFull, collector, expedition, FlicFound, FlicStatus, FlicIssue, FlicNotes)
write.csv(missingSpxE, file="List_UnfoundSpecimens_E-only_27Oct2014_Sort-collector.csv")
nrow(missingSpxE)
#1508

listSpx <- tbl_df(listSpx) 
missingSpxNA <- 
  listSpx %>%
  select(id, familyName, taxon, collNumFull, collNumShort, collector, expedition, institute, FlicFound, FlicStatus, FlicIssue, FlicNotes) %>%
  filter(is.na(FlicFound), is.na(institute)) %>%
  #arrange(familyName, collector, collNumShort) %>%
  arrange(collector, familyName, collNumShort) %>%
  select(id, familyName, taxon, collNumFull, collector, expedition, FlicFound, FlicStatus, FlicIssue, FlicNotes)
write.csv(missingSpxNA, file="List_UnfoundSpecimens_NA-only_27Oct2014_Sort-collector.csv")
nrow(missingSpxNA)
#2478

listSpx <- tbl_df(listSpx) 
missingSpxFamilyE <- 
  listSpx %>%
  select(id, familyName, taxon, collNumFull, collNumShort, collector, expedition, institute, FlicFound, FlicStatus, FlicIssue, FlicNotes) %>%
  filter(is.na(FlicFound), institute=="E") %>%
  #arrange(familyName, collector, collNumShort) %>%
  arrange(familyName, taxon, collector, collNumShort) %>%
  select(id, familyName, taxon, collNumFull, collector, expedition, FlicFound, FlicStatus, FlicIssue, FlicNotes)
write.csv(missingSpxFamilyE, file="List_UnfoundSpecimens_E-only_27Oct2014_Sort-family.csv")
nrow(missingSpxFamilyE)
#1508
# number of unique taxa which have not been found
length(unique(missingSpxFamilyE$taxon))
#606
# missing things by families
plot(table(missingSpxFamilyE$familyName), cex.axis=0.65, las=3)


listSpx <- tbl_df(listSpx) 
missingSpxFamilyNA <- 
  listSpx %>%
  select(id, familyName, taxon, collNumFull, collNumShort, collector, expedition, institute, FlicFound, FlicStatus, FlicIssue, FlicNotes) %>%
  filter(is.na(FlicFound), is.na(institute)) %>%
  #arrange(familyName, collector, collNumShort) %>%
  arrange(familyName, taxon, collector, collNumShort) %>%
  select(id, familyName, taxon, collNumFull, collector, expedition, FlicFound, FlicStatus, FlicIssue, FlicNotes)
write.csv(missingSpxFamilyNA, file="List_UnfoundSpecimens_NA-only_27Oct2014_Sort-family.csv")
nrow(missingSpxFamilyNA)
#2478
# number of unique taxa which have not been found
length(unique(missingSpxFamilyNA$taxon))
#751
# missing things by families
plot(table(missingSpxFamilyNA$familyName), cex.axis=0.5, las=3)