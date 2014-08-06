#' Get BOLD specimen + sequence data.
#' 
#' @import XML httr assertthat stringr
#' @export
#' @template args 
#' @template otherargs
#' @references \url{http://www.boldsystems.org/index.php/resources/api#combined}
#' 
#' @param marker (character) Returns all records containing matching marker codes. 
#' @param format (character) One of xml or tsv (default). tsv format gives back a data.frame 
#' object. xml gives back parsed xml as a 
#' @param sepfasta (logical) If TRUE, the fasta data is separated into a list with names matching 
#' the processid's from the data frame
#' 
#' @return Either a data.frame, parsed xml, a httr response object, or a list with length two
#' (a data.frame w/o nucleotide data, and a list with nucleotide data)
#' 
#' @examples \dontrun{
#' bold_seqspec(taxon='Osmia')
#' bold_seqspec(taxon='Osmia', format='xml')
#' bold_seqspec(taxon='Osmia', response=TRUE)
#' res <- bold_seqspec(taxon='Osmia', sepfasta=TRUE)
#' res$fasta[1:2]
#' res$fasta['GBAH0293-06']
#' 
#' ## curl debugging
#' ### You can do many things, including get verbose output on the curl call, and set a timeout
#' library("httr")
#' head(bold_seqspec(taxon='Osmia', config=verbose()))
#' head(bold_seqspec(taxon='Osmia', config=timeout(1)))
#' }

bold_seqspec <- function(taxon = NULL, ids = NULL, bin = NULL, container = NULL, 
  institutions = NULL, researchers = NULL, geo = NULL, marker = NULL, response=FALSE, 
  format = 'tsv', sepfasta=FALSE, ...)
{
  format <- match.arg(format, choices = c('xml','tsv'))
  url <- 'http://www.boldsystems.org/index.php/API_Public/combined'
  args <- bold_compact(list(taxon=pipeornull(taxon), geo=pipeornull(geo), ids=pipeornull(ids), 
    bin=pipeornull(bin), container=pipeornull(container), institutions=pipeornull(institutions), 
    researchers=pipeornull(researchers), marker=pipeornull(marker), combined_download=format))
  check_args_given_nonempty(args, c('taxon','ids','bin','container','institutions','researchers','geo','marker'))
  out <- GET(url, query=args, ...)
  # check HTTP status code
  warn_for_status(out)
  # check mime-type (Even though BOLD folks didn't specify correctly)
  assert_that(out$headers$`content-type`=='application/x-download')
  tt <- content(out, as = "text")
  
  if(response){ out } else {
    temp <- switch(format, 
           xml = xmlParse(tt),
           tsv = read.delim(text = tt, header = TRUE, sep = "\t", stringsAsFactors=FALSE)
    )
    if(!sepfasta){ temp }  else {
      if(format == "tsv"){
        fasta <- as.list(temp$nucleotides)
        names(fasta) <- temp$processid
        df <- temp[ , !names(temp) %in% "nucleotides" ]
        list(data=df, fasta=fasta)
      } else { temp }
    }
  }
}
