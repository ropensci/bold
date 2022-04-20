#' Add taxonomic parent names to a data.frame
#'
#' @export
#' @param x (data.frame|list) A single data.frame or a list of - the output from
#' a call to \code{\link[bold]{bold_identify()}}. Required.
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
#' df <- bold_identify(sequences = sequences$seq2)
#'
#' # long format
#' out <- bold_identify_taxonomy(df)
#' str(out)
#' head(out[[1]])
#'
#' # wide format
#' out <- bold_identify_taxonomy(df, wide = TRUE)
#' str(out)
#' head(out[[1]])
#'
#' x <- bold_seq(taxon = "Satyrium")
#' out <- bold_identify(c(x[[1]]$sequence, x[[13]]$sequence))
#' res <- bold_identify_taxonomy(out)
#' res
#'
#' x <- bold_seq(taxon = 'Diplura')
#' out <- bold_identify(vapply(x, "[[", "", "sequence")[1:20])
#' res <- bold_identify_taxonomy(out)
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
  tax <- bold_specimens(ids=IDS)
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
bold_identify_taxonomy.list <- function(x, taxOnly = TRUE, response = FALSE, ...) {
  assert(taxOnly, "logical")
  assert(response, "logical")
  lapply(x, function(dat){
    IDS <- unique(dat$ID)
    tax <- bold_specimens(ids=IDS)
    if(taxOnly){
      nms <- names(tax)
      nms <- nms[grep("_taxID|_name",nms)]
      tax <- tax[, c("processid", nms)]
    }
    tax[tax==""] <- NA
    tax <- tax[,colSums(is.na(tax)) != nrow(tax)]
    if(all(dat$ID == tax$processid))
      cbind(dat, tax[,-1])
    else
      cbind(dat, tax[vapply(dat$ID, function(x) which(tax$processid==x), 0),-1])
  })
}
