#' Add taxonomic parent names to a data set containing the process IDs of identified sequences.
#'
#' @param x   A single data.frame or matrix, or a list of. Usually the output from a call to \code{\link{bold_identify}}. Required.
#' @param taxOnly   (logical) If TRUE (Default), only the taxonomic names and ids are added (equivalent format to the results of \code{\link{bold_identify_parents}} when `wide`is set to TRUE. If FALSE, also joins the rest of the data returned by \code{\link{bold_specimens}}.
#'
#' @details This function gets the process ids from the
#' input data.frame(s) (ID column), then queries \code{\link{bold_specimens}}
#' to get the sample information and adds it to the input data.frame(s).
#'
#' Records in the input data that do not have matches for parent names
#' simply get NA values in the added columns.
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

#' @export
methods::setGeneric(name = "bold_identify_taxonomy",
                    def = function(x, taxOnly = TRUE){
                      standardGeneric("bold_identify_taxonomy")
                    },
                    signature = "x"
)
#' @rdname bold_identify_taxonomy
methods::setMethod(
  f = "bold_identify_taxonomy",
  signature = signature("list"),
  definition = function(x, taxOnly = TRUE) {
    b_assert_length(x, len = 0L, name = "x")
    taxOnly <- b_assert_logical(taxOnly, name = "taxOnly")
    hasID <- vapply(x, \(x) "ID" %in% colnames(x), NA)
    if (all(!hasID)) {
      stop("no column 'ID' found in x")
    } else {
      lapply(x, b_identify_taxonomy, taxOnly = taxOnly)
    }
  }
)
#' @rdname bold_identify_taxonomy
methods::setMethod(
  f = "bold_identify_taxonomy",
  signature = signature("matrix"),
  definition = function(x, taxOnly = TRUE) {
    b_assert_length(x, len = 0L, name = "x")
    b_identify_taxonomy(x, taxOnly = b_assert_logical(taxOnly, name = "taxOnly"))
  }
)
#' @rdname bold_identify_taxonomy
methods::setMethod(
  f = "bold_identify_taxonomy",
  signature = signature("data.frame"),
  definition = function(x, taxOnly = TRUE) {
    b_assert_length(x, len = 0L, name = "x")
    b_identify_taxonomy(x, taxOnly = b_assert_logical(taxOnly, name = "taxOnly"))
  }
)
#' @rdname bold_identify_taxonomy
methods::setMethod(
  f = "bold_identify_taxonomy",
  signature = signature("missing"),
  definition = function(x, taxOnly = TRUE) {
      stop("argument 'x' is missing, with no default")
  }
)
b_identify_taxonomy <- function(x, taxOnly){
  if (!any(colnames(x) == "ID")) {
    warning("No column 'ID' found, skipped", call. = FALSE, immediate. = TRUE)
    data.frame(x)
  } else {
    # get the process ids
    IDs <- x[,"ID", drop = TRUE]
    # get the taxonomic data
    tax <- bold_specimens(ids = unique(IDs))
    if (taxOnly) {
      # only returns the taxonomic data
      tax <- tax[, c("processid", names(tax)[b_detect(names(tax), "_taxID|_name")])]
    }
    tax[tax == ""] <- NA
    # remove empty columns
    tax <- tax[,colSums(is.na(tax)) != nrow(tax)]
    # sort output by input IDs
    rownames(tax) <- tax[,"processid"]
    data.frame(x, tax[IDs, -1], row.names =  NULL)
  }
}
