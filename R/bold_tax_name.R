#' Search BOLD for taxonomy data by taxonomic name
#'
#' @param name (character) One or more scientific names. required.
#' @param fuzzy (logical) Whether to use fuzzy search or not (default: `FALSE`)
#' @param tax_division (character) Taxonomic division to filter the results.
#' @param tax_rank (character) Taxonomic rank to filter the results.
#' @template otherargs
#' @note The column 'specimenrecords' in the returned object represents the number of species records in BOLD's *Taxonomy Browser*, not the number of records in the *Public Data Portal*. To know the amount of public records available, use \code{\link{bold_stats}}.
#' @references
#' Taxonomy API: http://v4.boldsystems.org/index.php/resources/api?type=taxonomy
#' Taxonomy Browser: https://www.boldsystems.org/index.php/TaxBrowser_Home
#' Public Data Portal: https://www.boldsystems.org/index.php/Public_BINSearch?searchtype=records
#' @details The `dataTypes` parameter is not supported in this function.
#' If you want to use that parameter, get an ID from this function and pass
#' it into `bold_tax_id`, and then use the `dataTypes` parameter.
#' @seealso \code{\link{bold_tax_id}}, \code{\link{bold_get_attr}}, \code{\link{bold_get_errors}}, \code{\link{bold_get_params}}
#' @examples \dontrun{
#' bold_tax_name(name='Diplura')
#' bold_tax_name(name='Osmia')
#' bold_tax_name(name=c('Diplura','Osmia'))
#' bold_tax_name(name=c("Apis","Puma concolor","Pinus concolor"))
#' bold_tax_name(name='Diplur', fuzzy=TRUE)
#' bold_tax_name(name='Osm', fuzzy=TRUE)
#'
#' ## get http response object only
#' bold_tax_name(name='Diplura', response=TRUE)
#' bold_tax_name(name=c('Diplura','Osmia'), response=TRUE)
#'
#' ## Names with no data in BOLD database
#' bold_tax_name("Nasiaeshna pentacantha")
#' bold_tax_name(name = "Cordulegaster erronea")
#' bold_tax_name(name = "Cordulegaster erronea", response=TRUE)
#'
#' ## curl debugging
#' bold_tax_name(name='Diplura', verbose = TRUE)
#' }

#' @export
bold_tax_name <- function(name, fuzzy = FALSE, response = FALSE,
                          tax_division = NULL, tax_rank = NULL, ...) {
  if (missing(name)) stop("argument 'name' is missing, with no default")
  b_assert(name, "character", check.length = 0L)
  # fix for #84:
  name <- b_replace(name, "(?<=[^\\\\])'", "\\\\'")
  if (!missing(response)) response <- b_assert_logical(response)
  if (!missing(fuzzy)) fuzzy <- b_assert_logical(fuzzy)
  if (!missing(tax_division)) tax_division <- b_assert_tax_division(tax_division)
  if (!missing(tax_rank)) tax_rank <- b_assert_tax_rank(tax_rank)
  res <- lapply(b_nameself(name), function(x)
    b_GET(
      query = c(taxName = x, fuzzy = tolower(fuzzy)),
      api = "API_Tax/TaxonSearch",
      check = TRUE,
      ...
    ))
  if (response) {
    res
  } else {
    out <- b_rbind(lapply(res, b_process_tax_name,
                          tax_division = tax_division,
                          tax_rank = tax_rank),
                   idcol = "input")
    w <- lapply(res, `[[`, "warning")
    # using %in% to avoid NAs
    noMatchDiv <- out$taxid %in% -1L
    noMatchRank <- out$taxid %in% -2L
    noMatch <- out$taxid %in% -3L
    out$taxid[noMatchDiv | noMatchRank | noMatch] <- NA_integer_
    w[noMatchDiv] <- "Request returned no match with supplied 'tax_division'"
    w[noMatchRank] <- "Request returned no match with supplied 'tax_rank'"
    w[noMatch] <- "Request returned no match"
    attr(out, "errors") <- b_rm_empty(w)
    attr(out, "params") <- list(fuzzy = fuzzy,
                                tax_division = tax_division,
                                tax_rank = tax_rank)
    out
  }
}

b_process_tax_name <- function(x, tax_division, tax_rank) {
  if (!nzchar(x$warning)) {
    out <- b_parse(x$response, format = "json")
    if (length(out) && length(out$top_matched_names)) {
      out <- data.frame(out$top_matched_names)
      out.nms <- names(out)
      # see issue #84
      if (any(out.nms == "taxon")) out$taxon <- b_fix_taxonName(out$taxon)
      if (any(out.nms == "parentname")) out$parentname <- b_fix_taxonName(out$parentname)
      if (any(out.nms == "taxonrep")) out$taxonrep <- b_fix_taxonName(out$taxonrep)
      if (length(tax_division) && any(out.nms == "tax_division")) {
        if (sum(out$tax_division %in% tax_division)) {
          out <- out[out$tax_division %in% tax_division,]
        } else {
          out <- data.frame(taxid = -1L) # request returned no match with supplied tax_division
        }
      }
      if (length(tax_rank)  && any(out.nms == "tax_rank")) {
        if (sum(out$tax_rank %in% tax_rank)) {
          out <- out[out$tax_rank %in% tax_rank,]
        } else {
          out <- data.frame(taxid = -2L) # request returned no match with supplied tax_rank
        }
      }
    } else {
      out <- data.frame(taxid = -3L) # request returned no match
    }
  } else {
    out <- data.frame(taxid = NA_integer_) # resquest had an error
  }
  out
}

