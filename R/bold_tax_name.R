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
#' @seealso \code{\link{bold_tax_id}}
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
  b_assert(name, "character")
  # fix for #84:
<<<<<<< Updated upstream
  # name <- stringi::stri_replace_all_regex(name, "(?<=[^\\\\])(['\\(])", "\\\\$1")
  if (!missing(response)) assert(response, "logical")
  if (!missing(fuzzy)) assert(fuzzy, "logical")
=======
  name <- stringi::stri_replace_all_regex(name, "(?<=[^\\\\])'", "\\\\'")
  if (!missing(response)) b_assert(response, "logical")
  if (!missing(fuzzy)) b_assert(fuzzy, "logical")
>>>>>>> Stashed changes
  if (length(tax_division)) {
    b_assert(tax_division, "character")
    if (!all(tax_division %in% c("Animalia", "Protista", "Fungi", "Plantae")))
      stop("'tax_division' must be one or more of ",
           b_ennum(c("Animalia", "Protista", "Fungi", "Plantae")))
  }
  if (length(tax_rank)) {
    b_assert(tax_rank, "character")
    tax_rank <- tolower(tax_rank)
    if (any(!tax_rank %in% rank_ref))
      stop("Invalid tax_rank name.")
  }

  res <- lapply(`names<-`(name, name), function(x)
    b_check_res(b_GET(args = c(taxName = x, fuzzy = tolower(fuzzy)),
                      url = b_url("API_Tax/TaxonSearch"), ...))
  )
  if (response) {
    res
  } else {
    out <- b_rbind(lapply(res, process_tax_name,
                          tax_division = tax_division,
                          tax_rank = tax_rank),
                   idcol = "input")
    w <- vapply(res, `[[`, "", "warning")
    attr(out, "errors") <- b_rm_empty(w)
    out
  }
}

process_tax_name <- function(x, tax_division, tax_rank) {
  if(!nzchar(x$warning)){
    out <- jsonlite::fromJSON(x$response$parse("UTF-8"), flatten = TRUE)
    if (length(out) && length(out$top_matched_names)){
      out <- data.frame(out$top_matched_names, stringsAsFactors = FALSE)
      if(length(tax_division) && length(out$tax_division)) out <- out[out$tax_division %in% tax_division,]
      if(length(tax_rank) && length(out$tax_rank)) out <- out[out$tax_rank %in% tax_rank,]
      out$taxon <- b_fix_taxonName(out$taxon)
      if (any(colnames(out) == "parentname"))
        out$parentname <- b_fix_taxonName(out$parentname)
      if (any(colnames(out) == "taxonrep"))
        out$taxonrep <- b_fix_taxonName(out$taxonrep)
    } else {
      out <- data.frame(taxid = NA_integer_)
    }
  } else {
    out <- data.frame(taxid = NA_integer_)
  }
  out
}
