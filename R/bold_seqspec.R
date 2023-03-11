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
#' head(bold_seqspec(taxon='Osmia', timeout_ms = 1))
#' }
#'
#' @export
bold_seqspec <- function(taxon = NULL, ids = NULL, bin = NULL, container = NULL,
                         institutions = NULL, researchers = NULL, geo = NULL,
                         marker = NULL, response = FALSE, format = 'tsv',
                         sepfasta = FALSE, cleanData = FALSE, ...) {
  format <- b_assert_format(format)
  response <- b_assert_logical(response)
  sepfasta <- b_assert_logical(sepfasta)
  cleanData <- b_assert_logical(cleanData)
  params <- c(
    b_pipe_params(
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
    b_seqspec_process(res, format, sepfasta, cleanData)
  }
}
b_seqspec_process <- function(res, format, sepfasta, cleanData){
  res$raise_for_status()
  res <- paste0(rawToChar(res$content, multiple = TRUE), collapse = "")
  res <- enc2utf8(res)
  if (res == "") {
    NA
  } else {
    if (b_detect(res, "Fatal error")) {
      # if returning partial output for bold_seq, might as well do that here too
      warning("the request timed out, see 'If a request times out'\n",
              "returning partial output")
      res <- b_drop(str = res, pattern = "Fatal error")
      # if missing, adding closing tag so it can be read properly
      if (format == "xml" && !b_detect(res, "</bold_records")) {
        res <- paste0(res, "</bold_records>")
      }
    }
    switch(
      format,
      xml = b_seqspec_process_xml(x = res, sepfasta = sepfasta),
      tsv = b_seqspec_process_tsv(
        x = res,
        sepfasta = sepfasta,
        cleanData = cleanData
      )
    )
  }
}
b_seqspec_process_tsv <- function(x, sepfasta, cleanData){
  out <- b_read(x)
  if (cleanData) {
    out <- b_cleanData(out)
  }
  if (!sepfasta) {
    out
  } else {
    list(data = out[, !names(out) %in% "nucleotides"],
         fasta = `names<-`(as.list(out$nucleotides),
                           out$processid))
  }
}
b_seqspec_process_xml <- function(x, sepfasta){
  # don't remove 'options' !
  # prevents failing on large request :)
  out <- xml2::read_xml(x, options = c("NOBLANKS", "HUGE"))
  if (!sepfasta) {
    out
  } else {
    rec <- xml2::xml_find_all(out, "//record")
    fasta <- lapply(rec, \(x) {
      seq <-  xml2::xml_text(xml2::xml_find_all(x, ".//nucleotides"))
      id <- xml2::xml_text(xml2::xml_find_all(x, ".//processid"))
      `names<-`(as.list(seq), rep(id, length(seq)))
    })
    fasta <- unlist(fasta, recursive = FALSE)
    # not removing nucleotides since xml2::xml_remove advise against it
    list(data = out, fasta = fasta)
  }
}

