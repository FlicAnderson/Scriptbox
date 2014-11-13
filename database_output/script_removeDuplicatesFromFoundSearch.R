# Socotra :: script_removeDuplicatesFromFoundSearch.R
# ======================================================== 
# (29th October 2014)
# Author: Flic Anderson

# AIM: Fix the Socotra data in various ways


summary(complete.cases(collections$collNum, collections$collector))

notCompletes <- which(!(complete.cases(collections$collNum, collections$collector)))
notCompletes <- collections[notCompletes,]  

# FIND DUPLICATED NUMBERS?

# ARE COLLECTORS SAME?

# IS ONE/MORE found?

# IF NOT FOUND, ADD ONLY 1 OF THE SET TO UNFOUND LIST

# IF FOUND, ADD BOTH TO FOUND LIST


# get number of unique collector number/collectors
length(unique(paste(collections$collNum, collections$collector, sep=":")))
# 6386 in 8634 of collections


a <- paste(paste0("PADME_ID-", collections$id), collections$collNum, collections$collector, collections$FlicFound, sep=":")
# 8634
b <- paste(collections$collNum, collections$collector, "", sep=":")
# 8634

# founds  
c <-  b[grep("(*.):found", a)]
# not founds
d <-  b[grep("(*.):found", a, invert=TRUE)]

# founds + padmeID + FlicFound
cA <-  a[grep("(*.):found", a)]
# not founds + padmeID + FlicFound
dA <-  a[grep("(*.):found", a, invert=TRUE)]

# does this add up?
length(c) + length(d)==length(a)

length(which(d %in% c))
#462 not-founds in found!

length(which(!(d %in% c)))
# not-founds in found!

duplicates <- a[which(d %in% c)]


