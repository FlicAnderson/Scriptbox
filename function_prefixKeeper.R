### FUNCTION: prefixKeeper ###
### 3rd July 2014
### Strip away collection numbers and suffixes from collector number prefixes
###

# test values
a <- c("M.8564", "8272", "M 8539", "M.8056A", "11448A", "11504", "M 10019", "M10382", "8381A","9851b", "44")


# remove prefix & collNum
#gsub("([0-9]*)*(([A-Za-z]$)?)", "", a)

### function:
prefixKeeper <- function(x){
  gsub("([0-9]*)*(([A-Za-z]$)?)", "", x)
}

print(". ")
print(".. function 'prefixKeeper' loaded; to use, call: prefixKeeper(x)")
print("... prefixKeeper() strips away collection numbers and suffixes from collector numbers")
print(".... ")


#test:
prefixKeeper(a)

###
### to call: prefixKeeper(x)
###
###