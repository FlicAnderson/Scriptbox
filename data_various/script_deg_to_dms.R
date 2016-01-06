################################################################################
###                                                                          ###
### Conversion from Decimal Degree to DMS                                    ###
###                                                                          ###
### 1. The whole units of degrees will remain the same                       ###
###    (i.e. in 121.135 longitude, start with 121  ).                        ###
### 2. Multiply the decimal by 60 (i.e. .135 * 60 = 8.1).                    ###
### 3. The whole number becomes the minutes (8').                            ###
### 4. Take the remaining decimal and multiply by 60. (i.e. .1 * 60 = 6).    ###
### 5. The resulting number becomes the seconds (6"). Seconds can remain as  ###
###    a decimal.                                                            ###
### 6. Take your three sets of numbers and put them together, Adding         ###
###    seperating values with : (i.e. 121:8:6" longitude)                    ###
### 7. Depending on whether the source number was a latitudinal or           ###
###    longitudinal coordinate, and the sign of the number, add the          ###
###    N/S/E/W specifier                                                     ###
###                                                                          ###
### This script/demo was written by Daniela Cianci and was kindly shared     ###
### with partners in the EDENext FP7 project: Biology and control of         ###
### vector-borne infections in Europe.                                       ###
###                                                                          ###
### It can be freely distributed and re-used by all but please credit        ###
### Daniela Cianci and http://www.edenextdata.com                            ###
###                                                                          ###
### Author: Daniela Cianci (University of Utrecht)                           ###
### Contact: neil.alexander@zoo.ox.ac.uk                                     ###
### website: http://www.edenextdata.com                                      ###
###                                                                          ###
################################################################################

  

### Edited by Flic Anderson
### 6th January 2016
### Saved to: O://CMEP\ Projects/Scriptbox/data_various/script_deg_to_dms.R
### source("O://CMEP\ Projects/Scriptbox/data_various/script_deg_to_dms.R")

### Function to multiply out decimal degrees to DMS format
### Then concatenate output
deg_to_dms<- function (degfloat){
                       deg <- as.integer(degfloat)
                       minfloat <- 60*(degfloat - deg)
                       min <- as.integer(minfloat)
                       secfloat <- 60*(minfloat - min)
                       ### Round seconds to desired accuracy:
                       secfloat <- round(secfloat, digits=3 )
                       ### After rounding, the seconds might become 60
                       ### The following if-tests are not necessary if no 
                       ### rounding is done.
                            if (secfloat == 60) {
                            min <- min + 1
                            secfloat <- 0
                               }
                            if (min == 60){
                            deg <- deg + 1
                            min <- 0
                               }
                       dm<-paste(deg,min,sep=":")
                       dms<-paste(dm,secfloat,sep=":")
                       return (dms)
                            }

#### End Function ###


### Import coordinates in decimal degrees
### Tab delimited file two columns "latitude" and "longitude"
### Demo uses edeninstitutions.txt found in zipfile
#coord<-read.table("edeninstitutions.txt",sep="\t",header=T)
coord<-data.frame(latitude=locatDat$Lat_dec, longitude=locatDat$Lon_dec)


### Define matrix for results:
DMSoutput<-matrix(NA,nrow(coord),2)
colnames(DMSoutput)<-c("dms.lat", "dms.lon")

### For each line in input check +/- value then add  N/E/S/W specifier
### Then apply function using value modulus if it is a negative value
for (i in 1: nrow(coord)){
  ### Ensure Input non-negative and define Direction Prefix:
        # latitude
        if (coord$latitude[i] < 0) {
                paste("S",deg_to_dms(Mod(coord$latitude[i])),sep="") ->DMSoutput[i,1]
        }
        else {
                paste("N",deg_to_dms(coord$latitude[i]),sep="") ->DMSoutput[i,1]
        }
        # longitude
        if (coord$longitude[i] < 0) {
                paste("W",deg_to_dms(Mod(coord$longitude[i])),sep="") ->DMSoutput[i,2]
        }
        else {
                paste("E",deg_to_dms(coord$longitude[i]),sep="")->DMSoutput[i,2]
        }
}

### save to global env
        # needs as.data.frame() in order to prevent errors later...
        # such as "ERROR: $ operator is invalid for atomic vectors"
DMSoutput <<- as.data.frame(DMSoutput)


# uncomment to save Longitudes out in one vector
#DMSLon <<- DMSoutput$dms.lon

# uncomment to save Latitudes out in one vector
#DMSLat <<- DMSoutput$dms.lat

# tidy up objects created
rm(i, coord)

### Save output to Tab delimited file output.txt
#write.table(output, file="edeninstitutions_dms.txt", row.name=F, col.name=T, sep="\t")
