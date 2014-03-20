#' Search BOLD for specimens.
#' 
#' @import XML httr assertthat
#' @importFrom plyr compact
#' @export
#' @param taxon scientitic name of taxon, as e.g., "Cottus" (character)
#' @param geo geographic area to exclude (character)
#' @param format One of xml or tsv (character)
#' @examples \dontrun{
#' bold_specimens(taxon='Osmia', geo='Costa Rica')
#' bold_specimens(taxon="Formicidae", geo="Canada")
#' 
#' res <- bold_specimens(taxon="Formicidae", geo="Canada")
#' head(res)
#' }

bold_specimens <- function(taxon = NULL, geo = NULL, format = 'xml', callopts=list()) 
{
  format <- match.arg(format, choices = c('xml','tsv'))
  url <- 'http://www.boldsystems.org/index.php/API_Public/specimen'
  args <- compact(list(taxon=taxon, geo=geo, specimen_download=format))
  out <- GET(url, query=args, callopts)
  # check HTTP status code
  stop_for_status(out)
  # check mime-type (Even though BOLD folks didn't specify correctly)
  assert_that(out$headers$`content-type`=='application/x-download')
  tt <- content(out, as = "text")
  
  if(format=='xml'){
    res <- xmlParse(tt)
  } else {
    res <- read.delim(text = tt, header = TRUE, sep = "\t")
  }

  return(res)
}

# outlist <- xmlToList(res)
# laply(outlist[1:reclength], function(x) x$specimen_identifiers$sampleid, .progress="text")
# 
# getseqs <- function(x) {
#   sampleid_ <- x$specimen_identifiers$sampleid
#   url <- paste("http://services.boldsystems.org/eFetch.php?record_type=sequence&id_type=sampleid&ids=(", sampleid_, ")&return_type=json", sep='')
#   seq_ <- fromJSON(url)$record$nucleotides
#   return(seq_)
# }
# 
# laply(outlist[1:10], getseqs, .progress="text")