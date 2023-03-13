#' Get BOLD specimen + sequence data.
#'
#' @template args
#' @template otherargs
#' @param marker (character) Returns all records containing matching marker
#' codes. See Details.
#' @param format (character) One of xml or tsv (default). tsv format gives
#' back a data.frame object. xml gives back parsed xml as a list.
#' @param sepfasta (logical) If `TRUE`, the fasta data is separated into
#' a list with names matching the processid's for each records. Works with both 'tsv' and 'xml' format.
#' Note: This means multiple sequences can have the same name if a process id has multiple sequences.
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
  params <- b_pipe_params(
      taxon = taxon,
      geo = geo,
      ids = ids,
      bin = bin,
      container = container,
      institutions = institutions,
      researchers = researchers,
      marker = marker
    )
  res <- b_GET(query = c(params, format = format),
               api = 'API_Public/combined', ...)
  if (response) {
    res
  } else {
    out <- b_parse(res, format, cleanData, raise = TRUE)
    if (!sepfasta)
      out
    else
      b_sepFasta(out, format = format)
  }
}
#' Seperate sequences (fasta) from `bold_seqspec` output.
#'
#' @param x      (object) The output of a `bold_seqspec` call.
#' @param format (character) The format used in the `bold_seqspec` call. One of 'tsv' (default) or 'xml'.
#'
#' @return A list of length two : the specimen data and the sequences list.
#'
#' @examples \dontrun{
#' res <- bold_seqspec(taxon='Osmia')
#' res <- b_sepFasta(res)
#' # (same as bold_seqspec(taxon='Osmia', sepFasta = TRUE))
#' }
#' @export
b_sepFasta <- function(x, format = "tsv"){
  switch(format,
         tsv = {
           list(data = x[, !names(x) %in% "nucleotides"],
                fasta = `names<-`(as.list(x$nucleotides),
                                  x$processid))
         },
         xml = {
           recs <- xml2::xml_find_all(x, "//processid")
           fasta <- list()
           # must be for loop so record without sequences are also included (so the behavior is the same as when format is 'tsv')
           for (rec in recs) {
             seq <-  xml2::xml_text(xml2::xml_find_all(rec, "..//nucleotides"))
             n <- length(seq)
             len <- length(fasta) + 1
             if (n) {
              fasta[len:(len + n - 1)] <- as.list(seq)
              names(fasta)[len:(len + n - 1)] <- xml2::xml_text(rec)
             } else {
               fasta[[len]] <- list(NULL)
               names(fasta[[len]]) <- xml2::xml_text(rec)
             }

           }
           # not removing nucleotides since xml2::xml_remove advise against it
           list(data = x, fasta = fasta)
         }
  )
}
