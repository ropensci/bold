url <- "http://services.boldsystems.org/eSearch.php?taxon_inc=(Cottus)&geo_inc=(Canada)&geo_exc=(Quebec,Ontario,New Brunswick)&return_type=json"
getURL(url)

#
url <- "http://services.boldsystems.org/eFetch.php?record_type=full&id_type=sampleid&ids=(08-SRNP-102876)&return_type=json"
fromJSON(url)

# Function to get sequences for a taxonomic group
url <- "http://services.boldsystems.org/eSearch.php?taxon_inc=(Formicidae)&geo_exc=(Canada)&return_type=xml"
out <- getURL(url)
reclength <- length(xmlTreeParse(out)[[1]][[1]])
outlist <- xmlToList(out)
laply(outlist[1:reclength], function(x) x$specimen_identifiers$sampleid, .progress="text")
laply(outlist[1:10], getseqs, .progress="text")
getseqs <- function(x) {
  sampleid_ <- x$specimen_identifiers$sampleid
  url <- paste("http://services.boldsystems.org/eFetch.php?record_type=sequence&id_type=sampleid&ids=(", sampleid_, ")&return_type=json", sep='')
  seq_ <- fromJSON(url)$record$nucleotides
  return(seq_)
}


  
  
  
  


url <- "http://services.boldsystems.org/eSearch.php?taxon_inc=(Saturniidae)&geo_exc=(Canada)&return_type=text"
out <- 
  read.table(url, header = T, sep = "\t", nrow=100)
str(out)


xmlToDataFrame( nodes = xmlChildren(xmlRoot(xmlParse(out))) )