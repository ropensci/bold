#' Search BOLD for taxonomy data.
#' 
#' @import XML httr assertthat reshape
#' @export
#' @template args 
#' @template otherargs
#' @examples \dontrun{
#' bold_tax_name(name='Diplura')
#' bold_tax_name(name='Osmia')
#' bold_tax_name(name=c('Diplura','Osmia'))
#' }

bold_tax_name <- function(name = NULL, fuzzy=FALSE, callopts=list())
{
  url <- 'http://www.boldsystems.org/index.php/API_Tax/TaxonSearch'
  
  foo <- function(x){
    args <- bold_compact(list(taxName=x, fuzzy=if(fuzzy) TRUE else NULL))
    res <- GET(url, query=args, callopts)
    warn_for_status(res)
    assert_that(res$headers$`content-type`=='text/html; charset=utf-8')
    tt <- content(res, as = "text")
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
    data.frame(name=x, ff, stringsAsFactors = FALSE)
  }
  do.call(rbind, lapply(name, foo))
}