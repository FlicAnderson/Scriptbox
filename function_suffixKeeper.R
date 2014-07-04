### FUNCTION: suffixKeeper ###
### 3rd July 2014
### Strip away collection numbers and prefixes from collector number suffixes
###

# test values
a <- c("M.8564", "8272", "M 8539", "M.8056A", "11448A", "11504", "M 10019", "M10382", "8381A","9851b", "44")


### function:

suffixKeeper <- function(x){
  gsub("^([A-Za-z]([ ])?|^[A-Za-z][\\.]([ ])?)?([0-9]*)", "", x)
}

print("...function 'suffixKeeper' loaded; to use, call: suffixKeeper(x)")
print("...strips away prefixes and collection numbers from collector numbers")

#test:
#suffixKeeper(a)

###
### to call: suffixKeeper(x)
###
###