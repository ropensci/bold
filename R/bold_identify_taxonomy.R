#' Add taxonomic parent names to a data.frame
#'
#' @param x (data.frame|list) A single data.frame or a list of - the output from
#' a call to \code{\link{bold_identify}}. Required.
#' @param taxOnly (logical) If TRUE, only the taxonomic names and ids are added (equivalent format to the results of \code{\link{bold_identify_parents}} when `wide`is set to TRUE. If FALSE, also joins the rest of the data returned by \code{\link{bold_specimens}}.
#'
#' @details This function gets the process ids from the
#' input data.frame(s) (ID column), then queries \code{\link{bold_specimens}}
#' to get the sample information and cbinds it to the input data.frame(s).
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
bold_identify_taxonomy <- function(x, taxOnly = TRUE) {
  UseMethod("bold_identify_taxonomy")
}
#' @export
bold_identify_taxonomy.default <- function(x, taxOnly = TRUE) {
  stop("no 'bold_identify_taxonomy' method for ", class(x)[1L], call. = FALSE)
}
#' @export
bold_identify_taxonomy.matrix <- function(x, taxOnly = TRUE) {
  assert(taxOnly, "logical")
  if (missing(x)) stop("argument 'x' is missing, with no default.")
  if (!"ID" %in% colnames(x)) stop("no column 'ID' found in input.")
  .bold_identify_taxonomy(x, taxOnly = taxOnly)
}
#' @export
bold_identify_taxonomy.data.frame <- function(x, taxOnly = TRUE) {
  assert(taxOnly, "logical")
  if (missing(x)) stop("argument 'x' is missing, with no default.")
  if (!"ID" %in% colnames(x)) stop("no column 'ID' found in input.")
  .bold_identify_taxonomy(x, taxOnly = taxOnly)
}
bold_identify_taxonomy.list <- function(x, taxOnly = TRUE) {
  assert(taxOnly, "logical")
  if (missing(x)) stop("argument 'x' is missing, with no default.")
  if (any(vapply(x, \(x) !"ID" %in% colnames(x), NA))) stop("no column 'ID' found in input.")
  lapply(x, .bold_identify_taxonomy, taxOnly = taxOnly)
}
.bold_identify_taxonomy <- function(x, taxOnly){
  # get the process ids
  IDs <- x[,"ID", drop = TRUE]
  # get the taxonomic data
  tax <- bold_specimens(ids = unique(IDs))
  if (taxOnly) {
    # only returns the taxonomic data
    tax <- tax[, c("processid", grep("_taxID|_name", names(tax), value = TRUE))]
  }
  tax[tax == ""] <- NA
  # remove empty columns
  tax <- tax[,colSums(is.na(tax)) != nrow(tax)]
  # sort output by input IDs
  rownames(tax) <- tax[,"processid"]
  data.frame(x, tax[IDs, -1], row.names =  NULL)
}
