#' Search for matches to sequences against the BOLD COI database.
#'
#' @export
#'
#' @param sequences (character) Returns all records containing matching marker
#' codes. Required. One or more. See Details.
#' @param db (character) The database to match against, one of COX1,
#' COX1_SPECIES, COX1_SPECIES_PUBLIC, OR COX1_L604bp. See Details for
#' more information.
#' @param response (logical) Note that response is the object that returns
#' from the Curl call, useful for debugging, and getting detailed info on
#' the API call.
#' @param ... Further args passed on to \code{\link[crul]{HttpClient}}, main
#' purpose being curl debugging
#'
#' BOLD only allows one sequence per query. We internally \code{lapply}
#' over the input values given to the \code{sequences} parameter to search
#' with one sequence per query. Remember this if you have a lot of sequences -
#' you are doing a separate query for each one, so it can take a long time -
#' if you run into errors let us know.
#'
#' @section db parmeter options:
#' \itemize{
#'  \item COX1 Every COI barcode record on BOLD with a minimum sequence
#'  length of 500bp (warning: unvalidated library and includes records without
#'  species level identification). This includes many species represented by
#'  only one or two specimens as well as all species with interim taxonomy. This
#'  search only returns a list of the nearest matches and does not provide a
#'  probability of placement to a taxon.
#'  \item COX1_SPECIES Every COI barcode record with a species level
#'  identification and a minimum sequence length of 500bp. This includes
#'  many species represented by only one or two specimens as well as  all
#'  species with interim taxonomy.
#'  \item COX1_SPECIES_PUBLIC All published COI records from BOLD and GenBank
#'  with a minimum sequence length of 500bp. This library is a collection of
#'  records from the published projects section of BOLD.
#'  \item OR COX1_L604bp Subset of the Species library with a minimum sequence
#'  length of 640bp and containing both public and private records. This library
#'  is intended for short sequence identification as it provides maximum overlap
#'  with short reads from the barcode region of COI.
#' }
#'
#' @section Named outputs:
#' To maintain names on the output list of data make sure to pass in a
#' named list to the \code{sequences} parameter. You can for example,
#' take a list of sequences, and use \code{\link{setNames}} to set names.
#'
#' @return A data.frame with details for each specimen matched. if a
#' failed request, returns \code{NULL}
#' @references
#' \url{http://v4.boldsystems.org/index.php/resources/api?type=idengine}
#' @seealso \code{\link{bold_identify_parents}}
#' @examples \dontrun{
#' seq <- sequences$seq1
#' res <- bold_identify(sequences=seq)
#' head(res[[1]])
#' head(bold_identify(sequences=seq, db='COX1_SPECIES')[[1]])
#' }

bold_identify <- function(sequences, db = 'COX1', response=FALSE, ...) {
  foo <- function(a, b){
    args <- bc(list(sequence = a, db = b))
    cli <- crul::HttpClient$new(url = paste0(bbase(), 'Ids_xml'))
    out <- cli$get(query = args, ...)
    out$raise_for_status()
    stopifnot(out$headers$`content-type` == 'text/xml')

    if (response) {
      out
    } else {
      tt <- out$parse('UTF-8')
      tt <- gsub("&", "&amp;", tt)
      xml <- xml2::read_xml(tt)
      nodes <- xml2::xml_find_all(xml, "//match")
      toget <- c("ID","sequencedescription","database",
                 "citation","taxonomicidentification","similarity")
      outlist <- lapply(nodes, function(x){
        tmp2 <- vapply(toget, function(y) {
          tmp <- xml2::xml_find_first(x, y)
          stats::setNames(xml2::xml_text(tmp), xml2::xml_name(tmp))
        }, "")
        spectmp <- xml2::as_list(xml2::xml_find_first(x, "specimen"))
        spectmp <- unnest(spectmp)
        names(spectmp) <- c('specimen_url','specimen_country',
                            'specimen_lat','specimen_lon')
        spectmp[sapply(spectmp, is.null)] <- NA
        data.frame(c(tmp2, spectmp), stringsAsFactors = FALSE)
      })
      do.call(rbind.fill, outlist)
    }
  }
  lapply(sequences, foo, b = db)
}

unnest <- function(x){
  if (is.null(names(x))) {
    list(unname(unlist(x)))
  } else {
    do.call("c", lapply(x, unnest))
  }
}

parse_identify_one <- function(x) {
  xml <- xml2::read_xml(x)
  nodes <- xml2::xml_find_all(xml, "//match")
  toget <- c("ID","sequencedescription","database",
             "citation","taxonomicidentification","similarity")
  outlist <- lapply(nodes, function(x){
    tmp2 <- vapply(toget, function(y) {
      tmp <- xml2::xml_find_first(x, y)
      stats::setNames(xml2::xml_text(tmp), xml2::xml_name(tmp))
    }, "")
    spectmp <- xml2::as_list(xml2::xml_find_first(x, "specimen"))
    spectmp <- unnest(spectmp)
    names(spectmp) <- c('specimen_url','specimen_country',
                        'specimen_lat','specimen_lon')
    spectmp[sapply(spectmp, is.null)] <- NA
    data.frame(c(tmp2, spectmp), stringsAsFactors = FALSE)
  })
  do.call(rbind.fill, outlist)
}

#' async identify
#' @export
#' @examples
#' res <- bold_identify_async(x = sequences)
bold_identify_async <- function(x, db = 'COX1', ...) {
  reqs <- lapply(x, function(s) {
    crul::HttpRequest$new(
      url = "http://v4.boldsystems.org/index.php/Ids_xml",
      opts = list(...)
    )$get(query = bc(list(sequence = s, db = db)))
  })
  out <- crul::AsyncVaried$new(.list = reqs)
  out$request()
  xmls <- out$parse()
  lapply(xmls, parse_identify_one)
}
