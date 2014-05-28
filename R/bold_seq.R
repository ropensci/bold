#' Search BOLD for sequences.
#'
#' Get sequences for a taxonomic name, id, bin, container, institution, researcher, geographic 
#' place, or gene. 
#' 
#' @import httr stringr
#' @export
#' @template args
#' 
#' @param marker (character) Returns all records containing matching marker codes. 
#' @param callopts (character) curl debugging opts passed on to httr::GET
#' @return A list with each element of length 4 with slots for id, name, gene, and sequence.
#' @examples \dontrun{
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
#' }
#' \donttest{
#' bold_seq(marker='COI-5P')
#' bold_seq(marker=c('rbcL','matK'))
#' }

bold_seq <- function(taxon = NULL, ids = NULL, bin = NULL, container = NULL, institutions = NULL, 
  researchers = NULL, geo = NULL, marker = NULL, response=FALSE, callopts=list()) 
{
  url <- 'http://www.boldsystems.org/index.php/API_Public/sequence'
  
  args <- bold_compact(list(taxon=pipeornull(taxon), geo=pipeornull(geo), ids=pipeornull(ids), 
      bin=pipeornull(bin), container=pipeornull(container), institutions=pipeornull(institutions), 
      researchers=pipeornull(researchers), marker=pipeornull(marker)))
  out <- GET(url, query=args, callopts)
  # check HTTP status code
  stop_for_status(out)
  # check mime-type (Even though BOLD folks didn't specify correctly)
  assert_that(out$headers$`content-type`=='application/x-download')
  tt <- content(out, as = "text")
  res <- strsplit(tt, ">")[[1]][-1]
  output <- lapply(res, split_fasta)
  if(response) out else output
}

split_fasta <- function(x){
  temp <- paste(">", x, sep="")
  seq <- str_replace_all(str_split(str_replace(temp[[1]], "\n", "<<<"), "<<<")[[1]][[2]], "\n", "")
  stuff <- str_split(x, "\\|")[[1]][c(1:3)]
  list(id=stuff[1], name=stuff[2], gene=stuff[1], sequence=seq)
}

pipeornull <- function(x){
  if(!is.null(x)){ paste0(x, collapse = "|") } else { NULL }
}