#' Get BOLD specimen + sequence data.
#'
#' @template args
#' @template otherargs
#' @param marker (character) Returns all records containing matching marker
#' codes. See Details.
#' @param format (character) One of xml or tsv (default). tsv format gives
#' back a data.frame object. xml gives back parsed xml as a list.
#' @param sepfasta (logical) If `TRUE`, the fasta data is separated into
#' a list with names matching the processid's from the data frame. Note: This
#' means multiple sequences can have the same name.
#' Default: `FALSE`
#' @param cleanData (logical) If `TRUE`, the cell values containing only duplicated values (ex : "COI-5P|COI-5P|COI-5P") will be reduce to one value ("COI-5P") and empty string will be change to NA. Default: `FALSE`
#'
#' @template large-requests
#' @template marker
#' @template missing-taxon
#' @references
#' http://v4.boldsystems.org/index.php/resources/api?type=webservices
#'
#' @return Either a data.frame, parsed xml, a http response object, or a list
#' of length two (data: a data.frame w/o nucleotide column, and fasta: a list
#' of nucleotides with the processid as name)
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
#'
#' @export
bold_seqspec <- function(taxon = NULL, ids = NULL, bin = NULL, container = NULL,
                         institutions = NULL, researchers = NULL, geo = NULL, marker = NULL,
                         response=FALSE, format = 'tsv', sepfasta = FALSE, cleanData = FALSE, ...) {

  if (!format %in% c('xml', 'tsv')) stop("'format' should be onf of 'xml' or 'tsv'")
  assert(response, "logical")
  params <- c(
    pipe_params(
      taxon = taxon,
      geo = geo,
      ids = ids,
      bin = bin,
      container = container,
      institutions = institutions,
      researchers = researchers,
      marker = marker
    ),
    format = format
  )
  res <- b_GET(b_url('API_Public/combined'), params, ...)
  if (response) {
    res
  } else {
    res$raise_for_status()
    res <- paste0(rawToChar(res$content, multiple = TRUE), collapse = "")
    if (res == "") return(NA)
    res <- enc2utf8(res)
    if (grepl("Fatal error", res)) {
      stop("BOLD servers returned an error - we're not sure what happened\n ",
           "try a smaller query - or open an issue and we'll try to help")
    }
    out <- switch(format,
                  xml = xml2::read_xml(res),
                  tsv = {
                    out <- setread(res)
                    if (format == "tsv" && cleanData) {
                      cleanData(out)
                    } else {
                      out
                    }
                  })
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

