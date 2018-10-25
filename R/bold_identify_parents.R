#' Add taxonomic parent names to a data.frame
#'
#' @export
#' @param x (data.frame/list) list of data.frames - the output from a call to
#' \code{\link{bold_identify}}. or a single data.frame from the output from
#' same. required.
#' @param wide (logical) output in long or wide format. See Details.
#' Default: \code{FALSE}
#'
#' @details This function gets unique set of taxonomic names from the input
#' data.frame, then queries \code{\link{bold_tax_name}} to get the
#' taxonomic ID, passing it to \code{\link{bold_tax_id}} to get the parent
#' names, then attaches those to the input data.
#'
#' Records in the input data that do not have matches for parent names
#' simply get NA values in the added columns.
#'
#' @section wide vs long format:
#' When \code{wide = FALSE} you get many rows for each record. Essentially,
#' we \code{cbind} the taxonomic classification onto the one row from the
#' result of \code{\link{bold_identify}}, giving as many rows as there are
#' taxa in the taxonomic classification.
#'
#' When \code{wide = TRUE} you get one row for each record - thus the
#' dimensions of the input data stay the same. For this option, we take just
#' the rows for taxonomic ID and name for each taxon in the taxonomic
#' classification, and name the columns by the taxon rank, so you get
#' \code{phylum} and \code{phylum_id}, and so on.
#'
#' @return a list of the same length as the input
#'
#' @examples \dontrun{
#' df <- bold_identify(sequences = sequences$seq2)
#'
#' # long format
#' out <- bold_identify_parents(df)
#' str(out)
#' head(out[[1]])
#'
#' # wide format
#' out <- bold_identify_parents(df, wide = TRUE)
#' str(out)
#' head(out[[1]])
#' }
bold_identify_parents <- function(x, wide = FALSE, taxid = NULL, 
  taxon = NULL, tax_rank = NULL, tax_division = NULL, parentid = NULL, 
  parentname = NULL, taxonrep = NULL, specimenrecords = NULL) {
  UseMethod("bold_identify_parents")
}

#' @export
bold_identify_parents.default <- function(x, wide = FALSE, taxid = NULL, 
  taxon = NULL, tax_rank = NULL, tax_division = NULL, parentid = NULL, 
  parentname = NULL, taxonrep = NULL, specimenrecords = NULL) {
  stop("no 'bold_identify_parents' method for ", class(x), call. = FALSE)
}

#' @export
bold_identify_parents.data.frame <- function(x, wide = FALSE, taxid = NULL, 
  taxon = NULL, tax_rank = NULL, tax_division = NULL, parentid = NULL, 
  parentname = NULL, taxonrep = NULL, specimenrecords = NULL) {
  bold_identify_parents(list(x), wide)
}

#' @export
bold_identify_parents.list <- function(x, wide = FALSE, taxid = NULL, 
  taxon = NULL, tax_rank = NULL, tax_division = NULL, parentid = NULL, 
  parentname = NULL, taxonrep = NULL, specimenrecords = NULL) {

  # get unique set of names
  uniqnms <-
    unique(unname(unlist(lapply(x, function(z) z$taxonomicidentification))))
  if (is.null(uniqnms)) {
    stop("no fields 'taxonomicidentification' found in input", call. = FALSE)
  }

  # get parent names via bold_tax_name and bold_tax_id
  out <- stats::setNames(lapply(uniqnms, function(w) {
    tmp <- bold_tax_name(w)
    # if length(tmp) > 1, user decides which one
    if (NROW(tmp) > 1) {
      # if (is.null(pick_parent)) {
      #   message("more than 1 parent, but pick_parent is NULL, skipping")
      # } else {
        # pick_parent = list(tax_division = "Animals")
        # pick_parent = 'tax_division == "Animals"'
        # choose <- list(tmp = pick_parent)
        # tmp[parse(text = paste0("tmp$", pick_parent)), ]
        # subset(tmp, parse(text = pick_parent))
        tmp <- filt(tmp, "taxid", taxid)
        tmp <- filt(tmp, "tax_division", tax_division)
      # }
    }
    if (!is.null(tmp$taxid)) {
      tmp2 <- bold_tax_id(tmp$taxid, includeTree = TRUE)
      tmp2$input <- NULL
      return(tmp2)
    } else {
      NULL
    }
  }), uniqnms)
  # remove length zero elements
  out <- bc(out)

  # appply parent names to input data
  lapply(x, function(z) {
    if (wide) {
      # replace each data.frame with a wide version with just
      # taxid and taxon name (with col names with rank name)
      out <- lapply(out, function(h) do.call("cbind", (apply(h, 1, function(x) {
        tmp <- as.list(x[c('taxid', 'taxon')])
        tmp$taxid <- as.numeric(tmp$taxid)
        data.frame(stats::setNames(tmp, paste0(x['tax_rank'], c('_id', ''))),
                   stringsAsFactors = FALSE)
      }))))
    }
    zsplit <- split(z, z$ID)
    setrbind(
      bc(lapply(zsplit, function(w) {
        tmp <- out[names(out) %in% w$taxonomicidentification]
        if (!length(tmp)) return(w)
        suppressWarnings(cbind(w, tmp[[1]]))
      }))
    )
  })
}

# function to help filter get_*() functions for a rank name or rank itself ---
filt <- function(df, col, z) {
  if (NROW(df) == 0) {
    df
  } else {
    if (is.null(z)) return(df)
    mtch <- grep(sprintf("%s", tolower(z)), tolower(df[,col]))
    if (length(mtch) != 0) {
      df[mtch, ]
    } else {
      data.frame(NULL)
    }
  }
}
