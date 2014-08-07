#' Search BOLD for taxonomy data by BOlD ID.
#'
#' @export
#' @param id (integer) One or more BOLD taxonomic identifiers
#' @param dataTypes (character) Specifies the datatypes that will be returned. 'all' returns all data.
#' 'basic' returns basic taxon information. 'images' returns specimen images.
#' @param includeTree (logical) If TRUE (default: FALSE), returns a list containing information
#' for parent taxa as well as the specified taxon.
#' @template otherargs
#' @references \url{http://boldsystems.org/index.php/resources/api?type=taxonomy#idParameters}
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

  get_response <- function(x, ...){
    args <- bold_compact(list(taxId=x, dataTypes=dataTypes, includeTree=if(includeTree) TRUE else NULL))
    res <- GET(url, query=args, ...)
    warn_for_status(res)
    assert_that(res$headers$`content-type`=='text/html; charset=utf-8')
    return(res)
  }
  
  tmp <- lapply(id, get_response)
  if(response){ tmp } else {  
    do.call(rbind.fill, Map(process_response, x=tmp, y=id, z=includeTree))
  }
}
