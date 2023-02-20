#' Search for matches to sequences against the BOLD COI database.
#'
#' @export
#'
#' @param sequences (character) A vector or list of sequences to identify.
#' Required. See Details.
#' @param db (character) The database to match against, one of COX1 (default),
#' COX1_SPECIES, COX1_SPECIES_PUBLIC, OR COX1_L640bp. See Details for
#' more information.
#' @param response (logical) Note that response is the object that returns
#' from the Curl call, useful for debugging, and getting detailed info on
#' the API call.
#' @param keepSeq (logical) If TRUE (default), returns each data.frame
#' with an attribute 'sequence' containing sequence used to get those results.
#' @param ... Further args passed on to \code{\link{crul::verb-GET}}, main
#' purpose being curl debugging
#'
#' @details BOLD only allows one sequences per query. We internally `lapply`
#' over the input values given to the sequences` parameter to search
#' with one sequences per query. Remember this if you have a lot of sequences -
#' you are doing a separate query for each one, so it can take a long time -
#' if you run into errors let us know.
#'
#' @section db parmeter options:
#'
#' - COX1 Every COI barcode record on BOLD with a minimum sequences
#'  length of 500bp (warning: unvalidated library and includes records without
#'  species level identification). This includes many species represented by
#'  only one or two specimens as well as all species with interim taxonomy. This
#'  search only returns a list of the nearest matches and does not provide a
#'  probability of placement to a taxon.
#' - COX1_SPECIES Every COI barcode record with a species level
#'  identification and a minimum sequences length of 500bp. This includes
#'  many species represented by only one or two specimens as well as  all
#'  species with interim taxonomy.
#'  Note : Sometimes it does return matches that don't have a species level
#'  identification. Will be checking with BOLD.
#' - COX1_SPECIES_PUBLIC All published COI records from BOLD and GenBank
#'  with a minimum sequences length of 500bp. This library is a collection of
#'  records from the published projects section of BOLD.
#' - OR COX1_L640bp Subset of the Species library with a minimum sequences
#'  length of 640bp and containing both public and private records. This library
#'  is intended for short sequences identification as it provides maximum overlap
#'  with short reads from the barcode region of COI.
#'
#' @section Named outputs:
#' For a named output list, make sure to pass in a named list or vector to the
#' `sequences` parameter. You can use \code{\link{`names<-`}} or \code{\link{stats::setNames}} to
#' set names on a list or vector of sequences.
#'
#' @return A data.frame or  list of (one per sequences) with the top specimen
#' matches (up to 100) and their details. If the query fails, returns `NULL`.
#' Each data.frame has the attributes `sequence` with the provided
#' sequence to match (unless keepSeq is set to FALSE) and `errors` with the
#' error message given from a failed request.
#'
#' @references
#' http://v4.boldsystems.org/index.php/resources/api?type=idengine
#' @seealso \code{\link{bold_identify_parents}}
#' @examples \dontrun{
#' seq <- sequences$seq1
#' res <- bold_identify(sequences=seq)
#' head(res[[1]])
#' head(bold_identify(sequences=seq, db='COX1_SPECIES')[[1]])
#' }

bold_identify <- function(sequences, db = 'COX1', response=FALSE, keepSeq = TRUE, ...) {
  # make sure sequences are character before the queries
  if (!all(vapply(sequences, inherits, NA, "character"))) {
    stop("`sequences` should be of type character.")
  }
  if (!missing(db)) {
    assert(db, "character", checkLength = TRUE)
    if (!db %in% c("COX1", "COX1_SPECIES", "COX1_SPECIES_PUBLIC", "COX1_L640bp")) {
      stop("'db' must be on of 'COX1', 'COX1_SPECIES', 'COX1_SPECIES_PUBLIC' or 'COX1_L640bp'")
    }
  }
  # loop over sequences since the API only accepts one at a time
  lapply(sequences, function(seq){
    res <- get_response(
      args = bc(list(sequence = seq, db = db)),
      url = b_url('Ids_xml'),
      contentType = 'text/xml'
    )
    if (response) {
      res
    } else {
      out <- .parse_identify_xml(res)
      # add input sequence as attribute to prevent mix up if 'sequences' wasn't named
      if (keepSeq) {
        attr(out, "sequence") <- seq
      }
      attr(out, "errors") <- res$warning
      out
    }
  })
}

.parse_identify_xml <- function(res){
  cNames <- c('ID','sequencedescription','database','citation',
              'taxonomicidentification','similarity','specimen_url',
              'specimen_country', 'specimen_lat','specimen_lon')
  fNames <- c('ID','sequencedescription','database','citation',
              'taxonomicidentification','similarity','url','country',
              'lat', 'lon')
  cont <- rawToChar(res$response$content)
  # DON'T REMOVE, it's there for a reason, see tests
  cont <- stringi::stri_replace_all_fixed(str = cont, pattern = "&", replacement = "&amp;")
  if (res$warning == "") {
    xml <- xml2::read_xml(cont)
  } else {
    xml <- tryCatch(xml2::read_xml(cont), error = function(e) NULL)
    if (is.null(xml)) {
      return(NULL)
    }
  }
  # path to find all tips (fields)
  toget <- "//ID|//sequencedescription|//database|//citation|
    //taxonomicidentification|//similarity|//url|//country|//lat|//lon"

  #-- find nodes
  nodes <- xml2::xml_find_all(xml, toget)

  nodes.len <- length(nodes)
  nodes.data <- xml2::xml_text(nodes)
  nodes.name <- xml2::xml_name(nodes)
  names(nodes.data) <- nodes.name

  #-- making a data.frame from the tips :
  # each match (node) has these 10 fields (in toget);
  # empty ones *should* return ""
  # but in case there are missing fields in their files...
  #--- first we check that each node has indeed 10 fields
  # and that they are the right 10 fields
  nodes.lens <- diff(c(which(nodes.name == "ID"), nodes.len + 1))
  if (all(nodes.lens == 10) &&
     all(unique(nodes.name) %in% fNames)) {
    #--- if so they can be put in a 10 columns matrix by row
    out <- matrix(nodes.data, ncol = 10, byrow = TRUE,
                  dimnames = list(NULL, cNames))
  } else {
    #--- if not, we can place them in the matrix row by row
    #--- prep output matrix using names of the fields
    nRow <- ceiling(nodes.len/10)
    out <- matrix(NA_character_, nrow = nRow, ncol = 10,
                  dimnames = list(NULL, fNames))
    # set start range of first node
    b <- 1L
    for (i in seq_len(nRow)) {
      # how many field in that node
      n <- nodes.lens[[i]]
      # set (new) end range of node
      e <- b + n - 1
      # match tip's names with fields (column's names)
      out[i, nodes.name[b:e]] <- nodes.data[b:e]
      # set new start range of node
      b <- b + n
    }
    # rename the last 4 columns to match their default column's names
    colnames(out)[7:10] <- c('specimen_url',
                             'specimen_country',
                             'specimen_lat',
                             'specimen_lon')
  }
  out <- data.frame(out)
  # change class of number columns
  out[["similarity"]] <- as.numeric(out[["similarity"]])
  out[["specimen_lat"]] <- as.numeric(out[["specimen_lat"]])
  out[["specimen_lon"]] <- as.numeric(out[["specimen_lon"]])
  out
}
