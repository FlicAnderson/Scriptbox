### FUNCTION: collNumKeeper ###
### 3rd July 2014
### Strip away prefixes and suffixes from collector numbers
###

# test values
a <- c("M.8564", "8272", "M 8539", "M.8056A", "11448A", "11504", "M 10019", "M10382", "8381A","9851b", "44")


# complex way:
# remove prefix
#gsub("^([A-Za-z]([ ])?|[A-Za-z][\\.]([ ])?)", "", a)
# remove suffix
#gsub("([A-Za-z])$", "", a)
# all together:
# as.numeric(gsub("^([A-Za-z]([ ])?|[A-Za-z][\\.]([ ])?)", "", gsub("([A-Za-z])$", "", x)))

# remove everything except collNum
### function:

collNumKeeper <- function(x){
        as.numeric(gsub("[^0-9]", "", a))
}

print("...function 'collNumKeeper' loaded; to use, call: collNumKeeper(x)")
print("...strips away prefixes and suffixes from collector numbers")

#test:
#collNumKeeper(a)

###
### to call: collNumKeeper(x)
###
###

