#' Search BOLD for sequences.
#'
#' Get sequences for a taxonomic name, id, bin, container, institution, researcher, geographic
#' place, or gene.
#'
#' @import httr stringr
#' @export
#' @template args
#' @template otherargs
#' @references \url{http://www.boldsystems.org/index.php/resources/api#sequenceParameters}
#'
#' @param marker (character) Returns all records containing matching marker codes.
#'
#' @return A list with each element of length 4 with slots for id, name, gene, and sequence.
#' @examples \donttest{
#' bold_seq(taxon='Coelioxys')
#' bold_seq(taxon='Aglae')
#' bold_seq(taxon=c('Coelioxys','Osmia'))
#' bold_seq(ids='ACRJP618-11')
#' bold_seq(ids=c('ACRJP618-11','ACRJP619-11'))
#' bold_seq(bin='BOLD:AAA5125')
#' bold_seq(container='ACRJP')
#' bold_seq(institutions='Biodiversity Institute of Ontario')
#' bold_seq(researchers='Thibaud Decaens')
#' bold_seq(geo='Ireland')
#' bold_seq(geo=c('Ireland','Denmark'))
#'
#' # Return the httr response object for detailed Curl call response details
#' res <- bold_seq(taxon='Coelioxys', response=TRUE)
#' res$url
#' res$status_code
#' res$headers
#'
#' ## curl debugging
#' ### You can do many things, including get verbose output on the curl call, and set a timeout
#' library("httr")
#' bold_seq(taxon='Coelioxys', config=verbose())[1:2]
#' bold_seqspec(taxon='Coelioxys', config=timeout(0.1))
#' }
#' 
#' @examples \donttest{
#' bold_seq(marker='COI-5P')
#' bold_seq(marker=c('rbcL','matK'))
#' }

bold_seq <- function(taxon = NULL, ids = NULL, bin = NULL, container = NULL, institutions = NULL,
  researchers = NULL, geo = NULL, marker = NULL, response=FALSE, ...)
{
  url <- 'http://www.boldsystems.org/index.php/API_Public/sequence'

  args <- bc(list(taxon=pipeornull(taxon), geo=pipeornull(geo), ids=pipeornull(ids),
      bin=pipeornull(bin), container=pipeornull(container), institutions=pipeornull(institutions),
      researchers=pipeornull(researchers), marker=pipeornull(marker)))
  check_args_given_nonempty(args, c('taxon','ids','bin','container','institutions','researchers','geo','marker'))
  out <- GET(url, query=args, ...)
  # check HTTP status code
  stop_for_status(out)
  # check mime-type (Even though BOLD folks didn't specify correctly)
  assert_that(out$headers$`content-type`=='application/x-download')
  if(response){ out } else {
    tt <- content(out, as = "text")
    res <- strsplit(tt, ">")[[1]][-1]
    lapply(res, split_fasta)
  }
}
