#' Add taxonomic parent names to a data.frame
#'
#' @export
#' @param x (data.frame|list) A single data.frame or a list of - the output from
#' a call to \code{\link[bold]{bold_identify()}}. Required.
#' @param taxOnly (logical) If TRUE, only the taxonomic names and ids are added. If FALSE, also joins the rest of the data returned by \code{\link[bold]{bold_specimens()}}.
#' @template otherargs
#'
#' @details This function gets the process ids from the
#' input data.frame(s) (ID column), then queries \code\link{[bold]{bold_specimens()}}
#' to get the sample information and cbinds it to the input data.frame(s).
#'
#' Records in the input data that do not have matches for parent names
#' simply get NA values in the added columns.
#'
#'
#'
#'
#' @return a data.frame or a list of data.frames with added taxonomic
#' classification.
#'
#' @examples \dontrun{
#' seqs <- bold_identify(sequences = bold::sequences$seq2)
#'
#' seqs_tax <- bold_identify_taxonomy(seqs)
#' head(seqs_tax[[1]])
#'
#' x <- bold_seq(taxon = "Satyrium")
#' seqs <- bold_identify(x$sequence[1:2])
#' seqs_tax <- bold_identify_taxonomy(seqs)
#' seqs_tax
#' }
#'

bold_identify_taxonomy <- function(x, taxOnly = TRUE, response = FALSE, ...) {
  UseMethod("bold_identify_taxonomy")
}

#' @export
bold_identify_taxonomy.default <- function(x, taxOnly = TRUE, response = FALSE, ...) {
  stop("no 'bold_identify_taxonomy' method for ", class(x)[1L], call. = FALSE)
}

#' @export
bold_identify_taxonomy.data.frame <- function(x, taxOnly = TRUE, response = FALSE, ...) {
  assert(taxOnly, "logical")
  assert(response, "logical")
  IDS <- unique(x$ID)
  tax <- bold_specimens(ids = IDS)
  if(taxOnly){
    nms <- names(tax)
    nms <- nms[grep("_taxID|_name",nms)]
    tax <- tax[, c("processid", nms)]
  }
  tax[tax==""] <- NA
  tax <- tax[,colSums(is.na(tax)) != nrow(tax)]
  if(all(x$ID == tax$processid)) print(T)
  if(all(x$ID == tax$processid))
    cbind(x, tax[,-1])
  else
    cbind(x, tax[vapply(x$ID, function(x) which(tax$processid==x), 0),-1])
}

#' @export
bold_identify_taxonomy.list <-
  function(x,
           taxOnly = TRUE,
           response = FALSE,
           ...) {
    assert(taxOnly, "logical")
    assert(response, "logical")
    lapply(x, function(dat) {
      IDS <- unique(dat$ID)
      tax <- bold_specimens(ids = IDS)
      if (taxOnly) {
        nms <- names(tax)
        nms <- nms[grep("_taxID|_name", nms)]
        tax <- tax[, c("processid", nms)]
      }
      tax[tax == ""] <- NA
      tax <- tax[, colSums(is.na(tax)) != nrow(tax)]
      if (all(dat$ID == tax$processid))
        cbind(dat, tax[, -1])
      else
        cbind(dat, tax[vapply(dat$ID, function(x)
          which(tax$processid == x), 0), -1])
    })
  }
