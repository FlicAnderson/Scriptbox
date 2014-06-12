# Padme Data:: Databasin:: userPrompt_IF.R
# ======================================================== 
# (2nd June 2014)
# standalone script


# AIM: require information from the user and carry out other functions dependent on result

# require information (example adds 2 numbers)
fun <- function(){
  print("This function adds together number values of x and y that you give it...")
  x <- readline("what is the value of  x?  ")
  y <- readline("what is the value of y?  ")
  x <- as.numeric(unlist(strsplit(x, ",")))
  y <- as.numeric(unlist(strsplit(y, ",")))
  out1 <- x + y
  return(out1)
}
## uncomment the below if you're running it interactive() == TRUE
## if interactive() == FALSE, then it will ask for the x and y inputs but won't return the result.
#if(interactive())fun()


# carry out functions dependent on result
# (UNFINISHED)