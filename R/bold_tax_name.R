#' Search BOLD for taxonomy data by taxonomic name
#'
#' @export
#' @param name (character) One or more scientific names. required.
#' @param fuzzy (logical) Whether to use fuzzy search or not (default: FALSE).
#' @template otherargs
#' @references 
#' \url{http://v4.boldsystems.org/index.php/resources/api?type=taxonomy}
#' @details The \code{dataTypes} parameter is not supported in this function. 
#' If you want to use that parameter, get an ID from this function and pass 
#' it into \code{bold_tax_id}, and then use the \code{dataTypes} parameter.
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

bold_tax_name <- function(name, fuzzy = FALSE, response = FALSE, ...) {

  tmp <- lapply(name, function(x)
    get_response(bc(list(taxName = x, fuzzy = if (fuzzy) 'true' else NULL)),
                 url = paste0(bbase(), "API_Tax/TaxonSearch"), ...)
  )
  if (response) {
    tmp 
  } else {
    (vvv <- data.table::setDF(data.table::rbindlist(
      Map(process_tax_name, tmp, name), 
      use.names = TRUE, fill = TRUE)
    ))
  }
}

process_tax_name <- function(x, y) {
  tt <- rawToChar(x$content)
  out <- if (x$status_code > 202) "stop" else jsonlite::fromJSON(tt, flatten = TRUE)
  if ( length(out) == 0 || identical(out[[1]], list()) || out == "stop" ) {
    data.frame(input = y, stringsAsFactors = FALSE)
  } else {
    data.frame(out$top_matched_names, input = y, stringsAsFactors = FALSE)
  }
}
