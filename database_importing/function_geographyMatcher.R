# Scriptbox :: function_geographyMatcher.R
# ======================================================== 
# (8th January 2016)
# Author: Flic Anderson
# ~ function
#
# to source: 
# source("O:/CMEP\ Projects/Scriptbox/database_importing/function_geographyMatcher.R")
# to run:
#geographyMatcher(data, oneWordDescription)

# ---------------------------------------------------------------------------- #

# AIM: For use in other scripts, GEOGRAPHY-MATCHING version of function_latinNamesMatcher.R
# .... Get padme geographic IDs for import
# .... 
# .... 
# .... Note: IDEA & SKELETON ONLY

# ---------------------------------------------------------------------------- #

# CODE SUMMARY # 
# 0) Set up: Load libraries
# 1) Import/acquisition: source required scripts, get data
# 2) Check against padme geographic names: get padme names through connection, compare names
# 3) Output fix-requiring names & report: write fix-req names to file, output summary to console
# 4) Tidy up & end: remove unnecessary objects, close connections

# ---------------------------------------------------------------------------- #


### FUNCTION: non-interactive complete check geography thing
#geographyMatcher(data, oneWordDescription){
        # function goes here
                #data - subset data to get geographical names IDs and geography IDs for
                #oneWordDescription - for saving out
#}


#postgres does something like:
with uniquenames as (
        select name
        from [geo names]
        group by name
        having count(*)=1
), safegeonames as (
        select =[geo names].*
                from [geo names]
        join uniquenames on uniquenames.name=[geo names].name
)
update spreadsheet
set geonameid=safegeonames.geonameid
where spreadsheet.locality=safegeonames.name


# basically I want [spreadsheet].[locality] to get matched with Padme geographic names &
# UPDATE as follows:
# [spreadsheet].[geoID] <- [Geography].[ID] 
        # (or poss [Geographical names].[geographyId] where [Geographical names].[current] is TRUE)
# [spreadsheet].[geoNamID] <- [Geographical names].[id]
        # (id of geo names record which matches the [spreadsheet].[locality] string, even if it's not current, since it accurately represents the data being imported)

#