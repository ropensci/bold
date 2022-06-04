#' Search BOLD for sequences.
#'
#' Get sequences for a taxonomic name, id, bin, container, institution, 
#' researcher, geographic, place, or gene.
#'
#' @export
#' @template args
#' @template otherargs
#' @template large-requests
#' @template marker
#' @references 
#' http://v4.boldsystems.org/index.php/resources/api?type=webservices
#'
#' @param marker (character) Returns all records containing matching 
#' marker codes.
#'
#' @return A data frame with each element as row and 5 columns for processid, identification, 
#' marker, accession, and sequence.
#' 
#' @examples \dontrun{
#' res <- bold_seq(taxon='Coelioxys')
#' bold_seq(taxon='Aglae')
#' bold_seq(taxon=c('Coelioxys','Osmia'))
#' bold_seq(ids='ACRJP618-11')
#' bold_seq(ids=c('ACRJP618-11','ACRJP619-11'))
#' bold_seq(bin='BOLD:AAA5125')
#' bold_seq(container='ACRJP')
#' bold_seq(researchers='Thibaud Decaens')
#' bold_seq(geo='Ireland')
#' bold_seq(geo=c('Ireland','Denmark'))
#'
#' # Return the http response object for detailed Curl call response details
#' res <- bold_seq(taxon='Coelioxys', response=TRUE)
#' res$url
#' res$status_code
#' res$response_headers
#'
#' ## curl debugging
#' ### You can do many things, including get verbose output on the curl 
#' ### call, and set a timeout
#' bold_seq(taxon='Coelioxys', verbose = TRUE)[1:2]
#' # bold_seqspec(taxon='Coelioxys', timeout_ms = 10)
#' }

bold_seq <- function(taxon = NULL, ids = NULL, bin = NULL, container = NULL, 
  institutions = NULL, researchers = NULL, geo = NULL, marker = NULL, 
  response=FALSE, ...) {
  params <- list(taxon = taxon,
                  ids = ids,
                  bin = bin,
                  container = container,
                  institutions = institutions,
                  researchers = researchers,
                  geo = geo,
                  marker = marker)
  paramsNames = names(params)
  params = params[vapply(params, function(x){is.character(x)&&x!=""}, F)]
  if(length(params)==0){
    stop(paste0("You must provide a non-empty value to at least one of\n  ", paste(paramsNames, collapse = "\n  ")))
  }
  params <- vapply(params, paste, collapse = "|", "")
  out <- b_GET(paste0(bbase(), 'API_Public/sequence'), params, ...)
  if (response) { 
    out 
  } else {
    tt <- out$parse("UTF-8")
    if (grepl("error", tt)) {
      warning("the request timed out, see 'If a request times out'\n",
        "returning partial output")
      tt <- strdrop(str = tt, pattern = "Fatal+")[[1]]
    }
    res <- strsplit(tt, ">")[[1]][-1]
    split_fasta(res)
  }
}
