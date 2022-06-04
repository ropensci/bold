bbase <- function() "https://v4.boldsystems.org/index.php/"
b_url <- function(api) paste0('https://v4.boldsystems.org/index.php/', api)

# bc <- function(x) Filter(Negate(is.null), x)
bc <- function(x) if(!length(x)) NULL else x[lengths(x)>0]



# pipeornull <- function(x){
#   if (!is.null(x)) {
#     paste0(x, collapse = "|")
#   } else {
#     NULL
#   }
# }
pipe_params <- function(..., paramnames = ...names(), params = list(...)){
  params <- bc(params)
  if(!length(params))
    stop("You must provide a non-empty value to at least one of\n  - ",
         paste0(paramnames, collapse = "\n  - "))
  if(any(wt <- !vapply(params, is.character, logical(1))))
    stop(paste(names(wt)[wt], collapse = ", "), " must be character.")
  vapply(params, paste, collapse = "|", character(1))
}

# check_args_given_nonempty <- function(arguments, x){
#   paramnames <- x
#   matchez <- any(paramnames %in% names(arguments))
#   if (!matchez) {
#     stop(sprintf("You must provide a non-empty value to at least one of\n  %s",
#                  paste0(paramnames, collapse = "\n  ")))
#   } else {
#     arguments_noformat <- arguments[ !names(arguments) %in% 'combined_download' ]
#     argslengths <- vapply(arguments_noformat, nchar, numeric(1),
#                           USE.NAMES = FALSE)
#     if (any(argslengths == 0)) {
#       stop(sprintf("You must provide a non-empty value to at least one of\n  %s",
#                    paste0(paramnames, collapse = "\n  ")))
#     }
#   }
# }

#|-----------------------------------------------------------------------------|
#| todo: make sure all function using this one have been updated               |
#|-----------------------------------------------------------------------------|
get_response <- function(url, args, contentType = 'text/html; charset=utf-8',
                         raise = TRUE, ...){
  cli <- crul::HttpClient$new(url = url)
  out <- cli$get(query = args, ...)
  # out$raise_for_status()
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
}
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

b_GET <- function(url, args, ...){
  cli <- crul::HttpClient$new(url = url)
  out <- cli$get(query = args, ...)
  # out$raise_for_status()
  # if (grepl("html", out$response_headers$`content-type`)) {
  #   stop(out$parse("UTF-8"))
  # }
  out
}

strextract <- function(str, pattern) {
  regmatches(str, regexpr(pattern, str))
}

strdrop <- function(str, pattern) {
  regmatches(str, regexpr(pattern, str), invert = TRUE)
}

assert <- function(x, what, name = deparse(substitute(x))){
  if(length(x) && !inherits(x = x, what = what))
    stop(name, " must be of class ", paste0(what, collapse = ", "), call. = FALSE)
}

setrbind <- function(x, fill = TRUE, use.names = TRUE, idcol = NULL) {
  (x <- data.table::setDF(
    data.table::rbindlist(l = x, fill = fill, use.names = use.names, idcol = idcol))
  )
}

# warn_for_status <- function (x){
#   if (x$status_code >= 300) {
#       x <- x$status_http()
#       paste0("HTTP ", x$status_code, ": ", x$message, "\n ", x$explanation)
#   }
# }

splitByNchar <- function(x, maxN){
  x <- state.name
  cs <- cumsum(nchar(state.name))
  grps <- list()
  i <- 1
  while(length(x)){
    grps[[i]] <- x[cs<50]
    i <- i + 1
    x <- x[cs>=50]
    cs <- cumsum(nchar(x))
  }
  grps
}
all_ranks <- (function(){
  Rank <- Ranks <- unlist(strsplit(taxize::rank_ref$ranks, ","))
  Ranks <- gsub("ss$", "sses",
                       gsub("genus$", "genera",
                            gsub("y$", "ies",
                                 gsub("(.*[^ysd])$", "\\1s",
                                      Rank))))
  all_ranks <- `names<-`(c(Rank, Rank), c(Rank, Ranks))
  all_ranks <- all_ranks[unique(names(all_ranks))]
  all_ranks <- data.frame(name = all_ranks,
                          order = as.numeric(
                            factor(all_ranks, unique(all_ranks))))
  all_ranks
})()
b_ranges <- function(l, by){
  lenOut <- as.integer(ceiling(l/by))
  out <- vector("list", lenOut)
  b <- i <- 1L
  e <- by
  while(!is.na(i) && i < lenOut){
    out[[i]] <- b:e
    b <- e+1L
    e <- e+by
    i <- i+1L
  }
  out[[lenOut]] <- b:l
  out
}
