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

  assert(response, "logical")
  params <- pipe_params(taxon = taxon,
                  ids = ids,
                  bin = bin,
                  container = container,
                  institutions = institutions,
                  researchers = researchers,
                  geo = geo,
                  marker = marker)
  tmp <- b_GET(b_url('API_Public/sequence'), params, ...)
  if (response) {
    tmp
  } else {
    tt <- rawToChar(tmp)
    if (grepl("error", tt)) {
      warning("the request timed out, see 'If a request times out'\n",
        "returning partial output")
      tt <- strdrop(str = tt, pattern = "Fatal+")[[1]]
    }
    split_fasta(tt)
  }
}

split_fasta <- function(x){
  x <- strsplit(x, ">")[[1]][-1]
  tmp <- as.data.frame(stringi::stri_split_fixed(x, "\\\r\\\n", n = 3))
  df <- cbind(as.data.frame(stringi::stri_split_fixed(tmp[,1], "\\|", n = 4)),
              tmp[,2])
  colnames(df) <- c("processid", "identification", "marker",
                    "accession", "sequence")
  df[df==""] <- NA
  df
}
