get_async_response <- function(url, args, contentType = 'text/html; charset=utf-8', ...){
  cli <- crul::Async$new(url = url)
  if(is.list(args)){
    name <- names(args)[1]
    cli$urls <- vapply(args[[1]], function(x) crul:::add_query(c(`names<-`(x,name), args[-1]),cli$urls),"")
  } else{
    name <- deparse(substitute(args))
    cli$urls <- vapply(args, function(x) crul:::add_query(`names<-`(x,name),cli$urls),"")
  }
  outs <- cli$get()
  names(outs) <- names(cli$urls)
  lapply(outs, function(out){
    w <- ""
    if (out$status_code > 202) {
      x <- out$status_http()
      w <- paste0("HTTP ", x$status_code, ": ", x$message, "\n ", x$explanation)
    } else if(out$response_headers$`content-type` != contentType){
      w <- paste0("Content was type '", out$headers$`content-type`,
                  "'. Should've been type '", contentType, "'.")
    }
    if(w != "") warning(w)
    list(response = out,
         warning = w)
  })
}
