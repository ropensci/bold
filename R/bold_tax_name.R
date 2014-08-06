#' Search BOLD for taxonomy data by taxonomic name.
#'
#' @import httr assertthat reshape jsonlite
#' @export
#' @param name (character) One or more scientific names.
#' @param fuzzy (logical) Whether to use fuzzy search or not (default: FALSE).
#' @template otherargs
#' @references \url{http://boldsystems.org/index.php/resources/api?type=taxonomy}
#' @examples \dontrun{
#' bold_tax_name(name='Diplura')
#' bold_tax_name(name='Osmia')
#' bold_tax_name(name=c('Diplura','Osmia'))
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

  get_response <- function(x){
    args <- bold_compact(list(taxName=x, fuzzy=if(fuzzy) TRUE else NULL))
    res <- GET(url, query=args, ...)
    warn_for_status(res)
    assert_that(res$headers$`content-type`=='text/html; charset=utf-8')
    return(res)
  }
  
  process_response <- function(x, name2){
    tt <- content(x, as = "text")
    out <- fromJSON(tt)
    matchagst <- names(out[which.max(sapply(out, function(b) length(names(b))))][[1]])
    out <- lapply(out, function(x) {
      rr <- if(!all(matchagst %in% names(x))) matchagst[!matchagst %in% names(x)]
      if(length(rr)>0){
        tmp <- c(NA, x)
        names(tmp)[1] <-rr
        tmp
      } else { x }
    })
    df <- if("taxid" %in% names(out)) data.frame(out, stringsAsFactors = FALSE) else do.call(rbind, lapply(out, data.frame, stringsAsFactors = FALSE))
    row.names(df) <- NULL
    ff <- sort_df(df, "parentid")
    row.names(ff) <- NULL
    data.frame(name=name2, ff, stringsAsFactors = FALSE)
  }
  
  tmp <- lapply(name, get_response)
  if(response){ tmp } else {  
    do.call(rbind, lapply(tmp, process_response, name2=name))
  }
}