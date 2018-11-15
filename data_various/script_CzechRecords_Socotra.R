
# Use exiftool: 
#  @ top level folder with exiftool.exe @ that location:
#  in command prompt with working directory @ that location (use cd and dir):
#
#     "exiftool -r -csv -filename -gps:GPSDateStamp -n -gps:GPSLatitude -gpsLongitude ./ >imageData.csv"
#
#  which:
#       recursively goes through all folders below
#       extracts filename, GPSLatitude, GPSLongitude (in decimal degrees), date
#       exports to csv file called imageData.csv at that location



# rename file to denote datasource

setwd("Z:/FlicCZ/NEEDGPS_Hana Habrova")

HanaGPS <- read.csv("HanaHabrovaImageGPS_decimal.csv", header=TRUE)
HanaData <- read.csv("READY TO ADD GPS_DataFromHanaHabrovaPhotos.csv", header=TRUE)

library("dplyr")
library("magrittr")

#a <- left_join(HanaData, HanaGPS, by=c("Filename"="FileName"), copy=TRUE)

HanaData <- tbl_df(HanaData) %>% 
        mutate(lowFilename = tolower(Filename))

HanaGPS <- tbl_df(HanaGPS) %>% 
        mutate(lowFilename = tolower(FileName))

HanaDataComplete <- left_join(HanaData, HanaGPS, by=c("lowFilename"="lowFilename"), copy=TRUE)

#?write.csv()

write.csv(HanaDataComplete, file="HanaHabrovaImageData_Complete.csv", na="", row.names=FALSE)

library(lubridate)

HanaDataComplete <- HanaDataComplete %>% 
        mutate(Date_Year= year(ymd(HanaDataComplete$GPSDateStamp))) %>%
        mutate(Date_Month = month(ymd(HanaDataComplete$GPSDateStamp))) %>%
        mutate(Date_Day = day(ymd(HanaDataComplete$GPSDateStamp))) %>%
        mutate(MainLocationName="Socotra") %>%
        mutate(LatitudeDecimal=GPSLatitude) %>%
        mutate(LongitudeDecimal=GPSLongitude) %>%
        mutate(ExpeditionName="Hana Habrova 2016, Mendel University, CZ") %>%
        mutate(IsFieldRecord. = "Y")
        

write.csv(HanaDataComplete, file="HanaHabrovaImageData_Complete.csv", na="", row.names=FALSE)



# Use exiftool: 
#  @ top level folder with exiftool.exe @ that location:
#  in command prompt with working directory @ that location (use cd and dir):
#
#     "exiftool -r -csv -filename -gps:GPSDateStamp -n -gps:GPSLatitude -gpsLongitude ./ >imageData.csv"
#
#  which:
#       recursively goes through all folders below
#       extracts filename, GPSLatitude, GPSLongitude (in decimal degrees), date
#       exports to csv file called imageData.csv at that location



# rename file to denote datasource

setwd("Z:/FlicCZ/NEEDGPS_Lukas Karas/")

LukasGPS <- read.csv("LukasKarasImageGPS_decimal.csv", header=TRUE)
LukasData <- read.csv("DataFromLukasKarasPlantPhotos_Oct2016.csv", header=TRUE)

LukasData <- tbl_df(LukasData) %>%
        mutate(lowFilename = tolower(Filename))

LukasGPS <- tbl_df(LukasGPS) %>%
        mutate(lowFilename = tolower(FileName))

LukasDataComplete <- left_join(LukasData, LukasGPS, by=c("lowFilename"="lowFilename"), copy=TRUE)

#names(LukasData)
#names(LukasGPS)


write.csv(LukasDataComplete, file="LukasKarasImageData_Complete.csv", na="", row.names=FALSE)

library(lubridate)

LukasDataComplete <- LukasDataComplete %>% 
        mutate(Date_Year= year(ymd(LukasDataComplete$GPSDateStamp))) %>%
        mutate(Date_Month = month(ymd(LukasDataComplete$GPSDateStamp))) %>%
        mutate(Date_Day = day(ymd(LukasDataComplete$GPSDateStamp))) %>%
        #mutate(MainLocationName="Socotra") %>%
        mutate(LatitudeDecimal=GPSLatitude) %>%
        mutate(LongitudeDecimal=GPSLongitude) %>%
        mutate(ExpeditionName="") %>%
        mutate(ExpeditionName="Lukás Karas 2016, Mendel University, CZ") %>%
        mutate(IsFieldRecord. = "Y")


write.csv(LukasDataComplete, file="LukasKarasImageData_Complete.csv", na="", row.names=FALSE)

# ----------------

setwd("Z:/FlicCZ/NEEDGPS_Hana Habrova")

a <- read.table(file="coordinates_2002_19-93.txt", quote="", skip=15, header=FALSE)
