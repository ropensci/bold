#' Search BOLD for specimens.
#' 
#' @import XML httr assertthat
#' @export
#' @template args 
#' 
#' @param format (character) One of xml or tsv (default). tsv format gives back a data.frame 
#' object. xml gives back parsed xml as a 
#' 
#' @examples \dontrun{
#' bold_specimens(taxon='Osmia')
#' bold_specimens(taxon='Osmia', format='xml')
#' bold_specimens(taxon='Osmia', response=TRUE)
#' res <- bold_specimens(taxon='Osmia', format='xml', response=TRUE)
#' res$url
#' res$status_code
#' res$headers
#' 
#' # More than 1 can be given for all searh parameters
#' bold_specimens(taxon=c('Coelioxys','Osmia'))
#' 
#' library("httr")
#' head(bold_specimens(geo='Costa Rica', callopts=timeout(6)))
#' head(bold_specimens(taxon="Formicidae", geo="Canada", callopts=timeout(6)))
#' }

bold_specimens <- function(taxon = NULL, ids = NULL, bin = NULL, container = NULL, 
  institutions = NULL, researchers = NULL, geo = NULL, response=FALSE, callopts=list(), 
  format = 'tsv')
{
  format <- match.arg(format, choices = c('xml','tsv'))
  url <- 'http://www.boldsystems.org/index.php/API_Public/specimen'
  args <- bold_compact(list(taxon=pipeornull(taxon), geo=pipeornull(geo), ids=pipeornull(ids), 
      bin=pipeornull(bin), container=pipeornull(container), institutions=pipeornull(institutions), 
      researchers=pipeornull(researchers), specimen_download=format))
  out <- GET(url, query=args, callopts)
  # check HTTP status code
  warn_for_status(out)
  # check mime-type (Even though BOLD folks didn't specify correctly)
  assert_that(out$headers$`content-type`=='application/x-download')
  tt <- content(out, as = "text")
  
  if(response){ out } else {
    switch(format, 
           xml = xmlParse(tt),
           tsv = read.delim(text = tt, header = TRUE, sep = "\t", stringsAsFactors=FALSE)
    )
  }
}