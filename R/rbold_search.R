url <- "http://services.boldsystems.org/eSearch.php?taxon_inc=(Cottus)&geo_inc=(Canada)&geo_exc=(Quebec,Ontario,New Brunswick)&return_type=json"
getURL(url)

#
url <- "http://services.boldsystems.org/eFetch.php?record_type=full&id_type=sampleid&ids=(08-SRNP-102876)&return_type=json"
fromJSON(url)

#
url <- "http://services.boldsystems.org/eSearch.php?taxon_inc=(Saturniidae)&geo_exc=(Canada)&return_type=xml"
out <- getURL(url)
out_ <- xmlToDataFrame(out)


length(xmlTreeParse(out)[[1]][[1]])
xmlTreeParse(out)[[1]][[1]][2]
outlist <- xmlToList(out)
laply(outlist[1:10], function(x) x$specimen_identifiers$sampleid, .progress="text")
getspecid <- function(x) {
  x$specimen_identifiers$sampleid
}
do.call(getspecid, outlist[1:10])



url <- "http://services.boldsystems.org/eSearch.php?taxon_inc=(Saturniidae)&geo_exc=(Canada)&return_type=text"
out <- 
  read.table(url, header = T, sep = "\t", nrow=100)
str(out)


xmlToDataFrame( nodes = xmlChildren(xmlRoot(xmlParse(out))) )