#' getseqs 
#'
#' Get sequences for a taxonomic group
#' @import RCurl XML plyr RJSONIO
#' @param taxoninc taxonomic group to include in search (character)
#' @param taxonexc taxonomic group to exclude in search (character)
#' @param geoinc geographic location to include (character)
#' @param geoexc geographic location to exclude (character)
#' @export
#' @examples \dontrun{
#' getseqs('Coelioxys')
#' getseqs('Aglae')
#' }
getseqs <- function(taxoninc, taxonexc = NA, geoinc = NA, geoexc = NA, 
    url = "http://services.boldsystems.org/eSearch.php?") 
{
  taxoninc_ <- paste("taxon_inc=(", taxoninc, ")", sep='')
  
  if (!is.na(taxonexc)) {taxonexc_ <- paste('&taxon_exc=(', taxonexc, ")", sep='')} else {taxonexc_ <- NULL}
  if (!is.na(geoinc)) {geoinc_ <- paste('&geo_inc=(', geoinc, ")", sep='')} else {geoinc_ <- NULL}
  if (!is.na(geoexc)) {geoexc_ <- paste('&geo_exc=(', geoexc, ")", sep='')} else {geoexc_ <- NULL}
  taxurl <- paste(url, taxoninc_, taxonexc_, geoinc_, geoexc_, "&return_type=xml", sep='')
  out <- getURL(taxurl)
  reclength <- length(xmlTreeParse(out)[[1]][[1]])
  outlist <- xmlToList(out)  
  
  getseqs_ <- function(x) {
    sampleid_ <- x$specimen_identifiers$sampleid
    sequrl <- paste("http://services.boldsystems.org/eFetch.php?record_type=sequence&id_type=sampleid&ids=(", sampleid_, ")&return_type=json", sep='')
    if ( class(try(fromJSON(sequrl)$record$nucleotides, silent=T)) %in% "try-error") 
      {seq_ <- "no sequence for this specimen"} else
      {seq_ <- fromJSON(sequrl)$record$nucleotides}
    return(seq_)
  }
  
  laply(outlist[1:reclength], getseqs_, .progress="text")
}