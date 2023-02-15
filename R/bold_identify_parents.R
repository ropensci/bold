#' Add taxonomic parent names to a data.frame
#'
#' @export
#' @param x (data.frame/list) list of data.frames - the output from a call to
#' [bold_identify()]. or a single data.frame from the output from same.
#' required.
#' @param wide (logical) output in long or wide format. See Details.
#' Default: `FALSE`
#' @param taxid  (character) A taxid name. Optional. See `Filtering` below.
#' @param taxon (character) A taxon name. Optional. See `Filtering` below.
#' @param tax_rank (character) A tax_rank name. Optional. See `Filtering`
#' below.
#' @param tax_division (character) A tax_division name. Optional. See
#' `Filtering` below.
#' @param parentid (character) A parentid name. Optional. See `Filtering`
#' below.
#' @param parentname (character) A parentname name. Optional. See `Filtering`
#' below.
#' @param taxonrep (character) A taxonrep name. Optional. See `Filtering`
#' below.
#' @param specimenrecords (character) A specimenrecords name. Optional.
#' See `Filtering` below.
#' @param ... Further args passed on to \code{\link{crul::verb-GET}}, main
#' purpose being curl debugging
#'
#' @details DEPRECATED. See \code{\link{bold_identify_taxonomy}}.
#' This function gets unique set of taxonomic names from the input
#' data.frame, then queries \code{\link{bold_tax_name}} to get the
#' taxonomic ID, passing it to \code{\link{bold_tax_id}} to get the parent
#' names, then attaches those to the input data.
#'
#' Records in the input data that do not have matches for parent names
#' simply get NA values in the added columns.
#'
#' @section Filtering:
#' The parameters `taxid`, `taxon`, `tax_rank`, `tax_division`,
#' `parentid`, `parentname`,`taxonrep`, and `specimenrecords` are not used
#' in the search sent to BOLD, but are used in filtering the data down
#' to a subset that is closer to the target you want. For all these
#' parameters, you can use regex strings since we use \code{\link{grep()}} internally
#' to match. Filtering narrows down to the set that matches your query,
#' and removes the rest. The data.frame that we filter on with these
#' parameters internally is the result of a call to the \code{\link{bold_tax_name()}}
#' function.
#'
#' @section wide vs long format:
#' When `wide = FALSE` you get many rows for each record. Essentially,
#' we `cbind` the taxonomic classification onto the one row from the
#' result of \code{\link{bold_identify()}}, giving as many rows as there are
#' taxa in the taxonomic classification.
#'
#' When `wide = TRUE` you get one row for each record - thus the
#' dimensions of the input data stay the same. For this option, we take just
#' the rows for taxonomic ID and name for each taxon in the taxonomic
#' classification, and name the columns by the taxon rank, so you get
#' `phylum` and `phylum_id`, and so on.
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
#'
#' x <- bold_seq(taxon = "Satyrium")
#' out <- bold_identify(c(x[[1]]$sequence, x[[13]]$sequence))
#' res <- bold_identify_parents(out)
#' res
#'
#' x <- bold_seq(taxon = 'Diplura')
#' out <- bold_identify(vapply(x, "[[", "", "sequence")[1:20])
#' res <- bold_identify_parents(out)
#' }
bold_identify_parents <- function(x, wide = FALSE, taxid = NULL,
                                  taxon = NULL, tax_rank = NULL, tax_division = NULL, parentid = NULL,
                                  parentname = NULL, taxonrep = NULL, specimenrecords = NULL, ...) {
  UseMethod("bold_identify_parents")
}

#' @export
bold_identify_parents.default <- function(x, wide = FALSE, taxid = NULL,
                                          taxon = NULL, tax_rank = NULL, tax_division = NULL, parentid = NULL,
                                          parentname = NULL, taxonrep = NULL, specimenrecords = NULL, ...) {
  stop("no 'bold_identify_parents' method for ", class(x)[1L], call. = FALSE)
}

#' @export
bold_identify_parents.data.frame <- function(x, wide = FALSE, taxid = NULL,
                                             taxon = NULL, tax_rank = NULL, tax_division = NULL, parentid = NULL,
                                             parentname = NULL, taxonrep = NULL, specimenrecords = NULL, ...) {
  bold_identify_parents(list(x), wide, taxid, taxon, tax_rank,
                        tax_division, parentid, parentname, taxonrep, specimenrecords)
}

#' @export
bold_identify_parents.list <- function(x, wide = FALSE, taxid = NULL,
                                       taxon = NULL, tax_rank = NULL, tax_division = NULL, parentid = NULL,
                                       parentname = NULL, taxonrep = NULL, specimenrecords = NULL, ...) {
  # not using deprecated() because I want users to see this *before* it goes on,
  # since this function takes time. That way they can cancel if needed.
  warning("\n'bold_identify_parents' is deprecated.",
          "\nUse 'bold_identify_taxonomy' instead.",
          "It's more accurate as it uses the ID stored into 'x' to find the record's taxonomy.",
          "\nSee help(\"Deprecated\")", call. = FALSE, immediate. = TRUE)

  assert(wide, "logical")

  # get unique set of names
  uniqnms <-
    unique(c(lapply(x, function(z) z$taxonomicidentification), recursive = TRUE, use.names = FALSE))
  if (is.null(uniqnms)) {
    stop("no fields 'taxonomicidentification' found in input", call. = FALSE)
  }

  # get parent names via bold_tax_name and bold_tax_id
  out <- stats::setNames(lapply(uniqnms, function(w) {
    tmp <- bold_tax_name(w, ...)
    # if length(tmp) > 1, user decides which one
    if (NROW(tmp) > 1) {
      tmp <- filt(tmp, "taxid", taxid)
      tmp <- filt(tmp, "taxon", taxon)
      tmp <- filt(tmp, "tax_rank", tax_rank)
      tmp <- filt(tmp, "tax_division", tax_division)
      tmp <- filt(tmp, "parentid", parentid)
      tmp <- filt(tmp, "parentname", parentname)
      tmp <- filt(tmp, "taxonrep", taxonrep)
      tmp <- filt(tmp, "specimenrecords", specimenrecords)
    }
    if (!is.null(tmp$taxid)) {
      tmp2 <- bold_tax_id(tmp$taxid, includeTree = TRUE, ...)
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
    if (is.null(z)) return(NULL)
    if (wide) {
      # replace each data.frame with a wide version with just
      # taxid and taxon name (with col names with rank name)
      out <- lapply(out, function(h) do.call("cbind", (apply(h, 1, function(x) {
        tmp <- as.list(x[c("taxid", "taxon")])
        tmp$taxid <- as.numeric(tmp$taxid)
        data.frame(stats::setNames(tmp, paste0(x["tax_rank"], c("_id", ""))),
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
  assert(z, "character")
  if (NROW(df) == 0) {
    df
  } else {
    if (is.null(z)) return(df)
    mtch <- grep(sprintf("%s", tolower(z)), tolower(df[, col]))
    if (length(mtch) != 0) {
      df[mtch, ]
    } else {
      data.frame(NULL)
    }
  }
}
