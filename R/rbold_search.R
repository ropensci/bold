url <- "http://services.boldsystems.org/eSearch.php?taxon_inc=(Delphinus)&return_type=json"
fromJSON(url)

#
url <- "http://services.boldsystems.org/eFetch.php?record_type=full&id_type=sampleid&ids=(08-SRNP-102876)&return_type=json"
fromJSON(url)


# rbold_search.R

rbold_search <- 
# Args:
#   sciname: scientitic name of taxon, as e.g., "Cottus" (character)
#   geoexc: geographic area to exclude (character)
#   returntype: json or xml (character)
# Examples:
#   rbold_search(sciname = "Formicidae")
#   rbold_search("Formicidae", "Canada")

function(sciname = NA, geoexc = NA, returntype = NA,
  url = 'http://services.boldsystems.org/eSearch.php?',
  ..., 
  curl = getCurlHandle() ) 
{
#   url <- "http://services.boldsystems.org/eSearch.php?taxon_inc=(Formicidae)&geo_exc=(Canada)&return_type=xml"
  
  url2 <- paste(url, "?", sep = "")
  taxon_inc = paste("(", sciname, ")", sep = ""))
  args <- list(taxon_inc = sciname)

  out <- getURL(url)
  reclength <- length(xmlTreeParse(out)[[1]][[1]])
  outlist <- xmlToList(out)
  laply(outlist[1:reclength], function(x) x$specimen_identifiers$sampleid, .progress="text")
  
  getseqs <- function(x) {
    sampleid_ <- x$specimen_identifiers$sampleid
    url <- paste("http://services.boldsystems.org/eFetch.php?record_type=sequence&id_type=sampleid&ids=(", sampleid_, ")&return_type=json", sep='')
    seq_ <- fromJSON(url)$record$nucleotides
    return(seq_)
  }
  
  laply(outlist[1:10], getseqs, .progress="text")
}

  
  
  
  


url <- "http://services.boldsystems.org/eSearch.php?taxon_inc=(Saturniidae)&geo_exc=(Canada)&return_type=text"
out <- read.table(url, header = T, sep = "\t", nrow=100)
str(out)


xmlToDataFrame( nodes = xmlChildren(xmlRoot(xmlParse(out))) )