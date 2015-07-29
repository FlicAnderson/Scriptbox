library(XML)

# save the URL of the xml file in a variable
xml.url <- "http://www.w3schools.com/xml/plant_catalog.xml"

# get the xml file directly from the web using xmlTreeParse function 
xmlfile <- xmlTreeParse(xml.url)

# check the class of the file:
class(xmlfile)
# [1] "XMLDocument"         "XMLAbstractDocument"

# get the top node using the xmlRoot function 
xmltop = xmlRoot(xmlfile)

# check the xml code of the first subnodes
print(xmltop)[1:2]

# <CATALOG>
#   <PLANT>
#   <COMMON>Bloodroot</COMMON>
#   <BOTANICAL>Sanguinaria canadensis</BOTANICAL>
#   <ZONE>4</ZONE>
#   <LIGHT>Mostly Shady</LIGHT>
#   <PRICE>$2.44</PRICE>
#   <AVAILABILITY>031599</AVAILABILITY>
#   </PLANT>
# ...
# </CATALOG>
# NULL

# to extract the XML values from the document, use xmlSApply:
plantcat <- xmlSApply(xmltop, function (x) xmlSApply(x, xmlValue))

# finally get the data in a dataframe 
plantcat_df <- data.frame(t(plantcat), row.names=NULL)

# have a look at the first rows and columns
plantcat_df[1:5, 1:4]

