#' Search BOLD for taxonomy data by taxonomic name
#'
#' @export
#' @param name (character) One or more scientific names. required.
#' @param fuzzy (logical) Whether to use fuzzy search or not (default: `FALSE`)
#' @template otherargs
#' @references
#' http://v4.boldsystems.org/index.php/resources/api?type=taxonomy
#' @details The `dataTypes` parameter is not supported in this function.
#' If you want to use that parameter, get an ID from this function and pass
#' it into `bold_tax_id`, and then use the `dataTypes` parameter.
#' @seealso \code{\link[bold]{bold_tax_id()}}
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

bold_tax_name <- function(name, fuzzy = FALSE, response = FALSE,
                          tax_division = NULL, tax_rank = NULL, ...) {
  assert(name, "character")
  if(!missing(fuzzy)) assert(fuzzy, "logical")
  if(length(tax_division)){
    assert(tax_division, "character")
    if(!all(tax_division %in% c("Animalia", "Protista", "Fungi", "Plantae")))
      stop("'tax_division' must be one or more of ",
           toStr(c("Animalia", "Protista", "Fungi", "Plantae")))
  }
  if(length(tax_rank)){
    assert(tax_rank, "character")
    tax_rank <- tolower(tax_rank)
    if(!tax_rank %in% names(all_ranks))
      stop("Invalid tax_rank name.")
  }

  res <- lapply(`names<-`(name, name), function(x)
    get_response(args = c(taxName = x, fuzzy = fuzzy),
                 url =b_url("API_Tax/TaxonSearch"), ...)
  )
  if (response) {
    res
  } else {
    out <- setrbind(lapply(res, process_tax_name,
                           tax_division = tax_division,
                           tax_rank = tax_rank),
                    idcol = "input")
    w <- vapply(res, `[[`, "", "warning")
    attr(out, "errors") <- bc(w[nzchar(w)])
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
    } else {
      out <- data.frame(taxid = NA)
    }
  } else {
    out <- data.frame(taxid = NA)
  }
  out
}
