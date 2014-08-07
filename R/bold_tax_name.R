#' Search BOLD for taxonomy data by taxonomic name.
#'
#' @import httr assertthat reshape jsonlite 
#' @importFrom plyr rbind.fill
#' @export
#' @param name (character) One or more scientific names.
#' @param fuzzy (logical) Whether to use fuzzy search or not (default: FALSE).
#' @template otherargs
#' @references \url{http://boldsystems.org/index.php/resources/api?type=taxonomy#nameParameters}
#' @examples \dontrun{
#' bold_tax_name(name='Diplura')
#' bold_tax_name(name='Osmia')
#' bold_tax_name(name=c('Diplura','Osmia'))
#' bold_tax_name(name='Diplur', fuzzy=TRUE)
#' bold_tax_name(name='Osm', fuzzy=TRUE)
#' 
#' ## get httr response object only
#' bold_tax_name(name='Diplura', response=TRUE)
#' bold_tax_name(name=c('Diplura','Osmia'), response=TRUE)
#'
#' ## curl debugging
#' library('httr')
#' bold_tax_name(name='Diplura', config=verbose())
#' }

bold_tax_name <- function(name = NULL, fuzzy=FALSE, response=FALSE, ...)
{
  url <- 'http://www.boldsystems.org/index.php/API_Tax/TaxonSearch'

  get_response <- function(x, ...){
    args <- bold_compact(list(taxName=x, fuzzy=if(fuzzy) 'true' else NULL))
    res <- GET(url, query=args, ...)
    warn_for_status(res)
    assert_that(res$headers$`content-type`=='text/html; charset=utf-8')
    return(res)
  }
  
  tmp <- lapply(name, get_response)
  if(response){ tmp } else {
    do.call(rbind, Map(process_response, x=tmp, y=name))
  }
}

process_response <- function(x, y){
  tt <- content(x, as = "text")
  out <- fromJSON(tt)
  df <- do.call(rbind.fill, lapply(out, data.frame, stringsAsFactors = FALSE))
  row.names(df) <- NULL
  ff <- sort_df(df, "parentid")
  row.names(ff) <- NULL
  data.frame(id=y, ff, stringsAsFactors = FALSE)
}
