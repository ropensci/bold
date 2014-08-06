#' Search BOLD for taxonomy data by BOlD ID.
#'
#' @export
#' @param id (integer) One or more BOLD taxonomic identifiers
#' @param dataTypes (character) Specifies the datatypes that will be returned. 'all' returns all data.
#' 'basic' returns basic taxon information. 'images' returns specimen images.
#' @param includeTree (logical) If TRUE (default: FALSE), returns a list containing information
#' for parent taxa as well as the specified taxon.
#' @template otherargs
#' @references \url{http://boldsystems.org/index.php/resources/api?type=taxonomy}
#' @examples \dontrun{
#' bold_tax_id(id=88899)
#' bold_tax_id(id=88899, includeTree=TRUE)
#' bold_tax_id(id=c(88899,125295))
#' 
#' ## get httr response object only
#' bold_tax_id(id=88899, response=TRUE)
#' bold_tax_id(id=c(88899,125295), response=TRUE)
#'
#' ## curl debugging
#' library('httr')
#' bold_tax_id(id=88899, config=verbose())
#' }

bold_tax_id <- function(id = NULL, dataTypes='basic', includeTree=FALSE, response=FALSE, ...)
{
  url <- 'http://www.boldsystems.org/index.php/API_Tax/TaxonData'

  get_response <- function(x){
    args <- bold_compact(list(taxId=x, dataTypes=dataTypes, includeTree=if(includeTree) TRUE else NULL))
    res <- GET(url, query=args, ...)
    warn_for_status(res)
    assert_that(res$headers$`content-type`=='text/html; charset=utf-8')
    return(res)
  }
  
  process_response <- function(x, ids){
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
    data.frame(id=ids, ff, stringsAsFactors = FALSE)
  }
  
  tmp <- lapply(id, get_response)
  if(response){ tmp } else {  
    do.call(rbind, lapply(tmp, process_response, ids=id))
  }
}