#' Add taxonomic parent names to a data.frame
#'
#' @export
#' @param x (data.frame/list) list of data.frames - the output from a call to 
#' \code{\link{bold_identify}}. or a single data.frame from the output from
#' same. required.
#' 
#' @details This function gets unique set of taxonomic names from the input
#' data.frame, then queries \code{\link{bold_tax_name}} to get the 
#' taxonomic ID, passing it to \code{\link{bold_tax_id}} to get the parent
#' names, then attaches those to the input data.
#' 
#' @return a list of the same length as the input
#' 
#' @examples \dontrun{
#' x <- df <- bold_identify(sequences = sequences)
#' out <- bold_identify_parents(df)
#' str(out)
#' head(out$seq1)
#' }
bold_identify_parents <- function(x) {
  UseMethod("bold_identify_parents")
}

#' @export
bold_identify_parents.default <- function(x) {
  stop("no 'bold_identify_parents' method for ", class(x), call. = FALSE)
}

#' @export
bold_identify_parents.data.frame <- function(x) {
  bold_identify_parents(list(x))
}

#' @export
bold_identify_parents.list <- function(x) {
  # get unique set of names
  uniqnms <- 
    unique(unname(unlist(lapply(x, function(z) z$taxonomicidentification))))
  if (is.null(uniqnms)) {
    stop("no fields 'taxonomicidentification' found in input", call. = FALSE)
  }
  
  # get parent names via bold_tax_name and bold_tax_id
  out <- stats::setNames(lapply(uniqnms, function(w) {
    tmp <- bold_tax_name(w)
    if (!is.null(tmp$taxid)) {
      tmp2 <- bold_tax_id(tmp$taxid, includeTree = TRUE)
      tmp2$input <- NULL
      return(tmp2)
    } else {
      NULL
    }
  }), uniqnms)
  
  # appply parent names to input data
  lapply(x, function(z) {
    zsplit <- split(z, z$ID)
    setrbind(lapply(zsplit, function(w) {
      suppressWarnings(cbind(w, out[names(out) %in% 
                                      w$taxonomicidentification][[1]]))
    }))
  })
}
