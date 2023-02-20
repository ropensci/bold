#' Get BOLD specimen + sequence data.
#'
#' @export
#' @template args
#' @template otherargs
#' @template large-requests
#' @template marker
#' @references
#' http://v4.boldsystems.org/index.php/resources/api?type=webservices
#'
#' @param marker (character) Returns all records containing matching marker
#' codes. See Details.
#' @param format (character) One of xml or tsv (default). tsv format gives
#' back a data.frame object. xml gives back parsed xml as a list.
#' @param sepfasta (logical) If `TRUE`, the fasta data is separated into
#' a list with names matching the processid's from the data frame.
#' Default: `FALSE`
#'
#' @return Either a data.frame, parsed xml, a http response object, or a list
#' with length two (a data.frame w/o nucleotide data, and a list with
#' nucleotide data)
#'
#' @examples \dontrun{
#' bold_seqspec(taxon='Osmia')
#' bold_seqspec(taxon='Osmia', format='xml')
#' bold_seqspec(taxon='Osmia', response=TRUE)
#' res <- bold_seqspec(taxon='Osmia', sepfasta=TRUE)
#' res$fasta[1:2]
#' res$fasta['GBAH0293-06']
#'
#' # records that match a marker name
#' res <- bold_seqspec(taxon="Melanogrammus aeglefinus", marker="COI-5P")
#'
#' # records that match a geographic locality
#' res <- bold_seqspec(taxon="Melanogrammus aeglefinus", geo="Canada")
#'
#' ## curl debugging
#' ### You can do many things, including get verbose output on the curl call,
#' ### and set a timeout
#' head(bold_seqspec(taxon='Osmia', verbose = TRUE))
#' ## timeout
#' # head(bold_seqspec(taxon='Osmia', timeout_ms = 1))
#' }

bold_seqspec <- function(taxon = NULL, ids = NULL, bin = NULL, container = NULL,
  institutions = NULL, researchers = NULL, geo = NULL, marker = NULL,
  response=FALSE, format = 'tsv', sepfasta = FALSE, ...) {

  if(!format %in% c('xml', 'tsv')) stop("'format' should be onf of 'xml' or 'tsv'")
  assert(response, "logical")

  params <- c(pipe_params(taxon = taxon, geo = geo, ids = ids,
                          bin = bin, container = container,
                          institutions = institutions,
                          researchers = researchers,
                          marker = marker), format = format)
  res <- b_GET(b_url('API_Public/combined'), params, ...)
  if (response) {
    res
  } else {
    res$raise_for_status()
    res <- paste0(rawToChar(res$content, multiple = TRUE), collapse = "")
    res <- enc2utf8(res)
    if (grepl("Fatal error", res)) {
      stop("BOLD servers returned an error - we're not sure what happened\n ",
        "try a smaller query - or open an issue and we'll try to help")
    }
    out <- switch(
      format,
      xml = xml2::read_xml(res),
      tsv = setread(res)
    )
    if (!sepfasta) {
      out
    } else {
      if (format == "tsv") {
        fasta <- as.list(out$nucleotides)
        names(fasta) <- out$processid
        df <- out[ , !names(out) %in% "nucleotides" ]
        list(data = df, fasta = fasta)
      } else {
        out
      }
    }
  }
}

