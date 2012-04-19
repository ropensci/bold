#' getseqs 
#'
#' Get sequences for a taxonomic group
#' @import RCurl XML plyr RJSONIO
#' @param taxoninc taxonomic group to include in search (character)
#' @param taxonexc taxonomic group to exclude in search (character)
#' @param geoinc geographic location to include (character)
#' @param geoexc geographic location to exclude (character)
#' @param url base URL for the BOLD API (leave to default)
#' @export
#' @examples \dontrun{
#' getsampleids(taxoninc = 'Andrena')
#' getsampleids(taxoninc = 'Andrenidae')
#' }
getsampleids <- function(taxoninc = NA, taxonexc = NA, geoinc = NA, geoexc = NA, 
    url = "http://services.boldsystems.org/eSearch.php?", ...) 
{  
  taxoninc_ <- paste("taxon_inc=(", taxoninc, ")", sep='')
  if (!is.na(taxonexc)) {taxonexc_ <- paste('&taxon_exc=(', taxonexc, ")", sep='')} else {taxonexc_ <- NULL}
  if (!is.na(geoinc)) {geoinc_ <- paste('&geo_inc=(', geoinc, ")", sep='')} else {geoinc_ <- NULL}
  if (!is.na(geoexc)) {geoexc_ <- paste('&geo_exc=(', geoexc, ")", sep='')} else {geoexc_ <- NULL}
  taxurl <- paste(url, taxoninc_, taxonexc_, geoinc_, geoexc_, "&return_type=xml", sep='')  
  out <- getURL(taxurl)
  reclength <- length(xmlTreeParse(out)[[1]][[1]])
  outlist <- xmlToList(out)
  laply(outlist[1:reclength], function(x) x$specimen_identifiers$sampleid, .progress="text")
}