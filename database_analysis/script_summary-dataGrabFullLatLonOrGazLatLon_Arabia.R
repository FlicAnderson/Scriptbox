## Padme Output :: script_summary-dataGrabFullLatLonOrGazLatLon_Arabia.R
# ============================================================================ #
# 06 October 2015
# Author: Flic Anderson
#
# dependant on: O://CMEP\-Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Arabia.R
# saved at: O://CMEP\ Projects/Scriptbox/database_analysis/script_summary-dataGrabFullLatLonOrGazLatLon_Arabia.R
# source: 
# source("O:/CMEP\ Projects/Scriptbox/database_analysis/script_summary-dataGrabFullLatLonOrGazLatLon_Arabia.R")
#
# AIM:  Summarises data from script_dataGrabFullLatLonOrGazLatLon_Arabia.R script
# ....  number of unique datapoints, various info on types of records, families, 
# ....  breakdown by collector, 
#
# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 

# 0) 
# 1)  
# 2) 
# 3) 
# 4) 
# 5) 

# ---------------------------------------------------------------------------- #


# 0) load required packages, install if they aren't installed already

# {dplyr} - manipulating data & large data frames as tbl_df objects
if (!require(dplyr)){
  install.packages("dplyr")
  library(dplyr)
}


# 1)  pull in data & create recGrab object: 

source("O://CMEP\ Projects/Scriptbox/database_output/script_dataGrabFullLatLonOrGazLatLon_Arabia.R")

# Number of taxa:
length(unique(recGrab$acceptDetAs))
# 5254 taxa at 6 October 2015

# create object
taxaListArabia <- unique(recGrab$acceptDetAs)
#head(sort(taxaListArabia))

#message(paste0(" ... saving list of accepted taxa names to: O://CMEP\ Projects/taxaListArabia_", Sys.Date(), ".csv"))
# write list of unique taxa
#write.csv(sort(taxaListArabia), file=paste0("O://CMEP\ Projects/taxaListArabia_", Sys.Date(), ".csv"), row.names=FALSE)


# Number of unique locations? (unique(paste0(AnyLat + AnyLon)))
length(unique(paste(recGrab$AnyLat, recGrab$AnyLon)))
# 6323 @ 06/Oct/2015

# Number of taxa with >10 unique locations?
# 1706 unique named locations OR 2265 unique lat+lon combos @ 06/07/2015, see below

# Location with greatest number of taxa?
# ?

# Taxa with greatest number of locations?
# ?


# use DPLYR to manipulate data

# load the data into a dataframe tbl data object aka tbl-df
arabiaData <- tbl_df(recGrab)

# get names of variables
names(arabiaData)

#?manip  # gives info on manipulation functions

# select() {dplyr} function:
# pulls out only some variables

# select(datasource, column1, column2, column5)
select(arabiaData, acceptDetAs, collector, collNumFull)

# filter(datasource, column1 subset, column5 subset)
filter(arabiaData, acceptDetAs=="Aerva revoluta Balf.f.")

# arrange(datasource, column5 in ascending order, desc(column2) in descending order)
arrange(arabiaData, acceptDetAs, dateYY, collector)

# mutate(datasource, newcolumn=AnyLat + " " + AnyLon)
arabiaData <- mutate(arabiaData, LatLon=paste(AnyLat, AnyLon, sep=" "))

# summarize(datasource, summarizingcolumn = summarizing function(column3))
# no easy example here


# group_by(data, grouping variable)
group_by(arabiaData, acceptDetAs)

# group by species & summarize by 1 variable
by_sps <- group_by(arabiaData, acceptDetAs)
summarize(by_sps, avgCollctn=round(mean(dateYY, na.rm=TRUE), digits=0))  # average year of collection by species :)
summarize(by_sps, mednCollctn=round(median(dateYY, na.rm=TRUE), digits=0))  # median year of collection by species :)

# group by species and summarize by multiple variables
datA <- mutate(arabiaData, LatLon=paste(AnyLat, AnyLon, sep=" "))
by_sps <- group_by(datA, acceptDetAs)
by_sps_sum <- summarize(by_sps, 
                        count=n(),
                        collectedBy=n_distinct(collector), 
                        mostRecentCollection=max(dateYY, na.rm=TRUE), 
                        uniqueLatLon=n_distinct(LatLon),
                        uniqueLocation=n_distinct(fullLocation)
)
by_sps_sum

#number of taxa with over 10 unique lat+lon locations:
filter(by_sps_sum, uniqueLatLon>10)
#1844 @ 06/Oct/2015

#number of taxa with over 10 unique named-locations:
filter(by_sps_sum, uniqueLocation>10)
#1706 @ 06/Oct/2015

# number of taxa with over 10 occurrences/records:
filter(by_sps_sum, count>10)
# 2265 taxa with >10 unique latlon locations @ 06/Oct/2015

# Location with greatest number of taxa?
# ?

# Taxa with greatest number of locations?
# ?