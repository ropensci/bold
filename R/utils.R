b_url <- function(api) paste0('https://v4.boldsystems.org/index.php/', api)

bc <- function(x) if (!length(x)) NULL else x[lengths(x) > 0]

pipe_params <- function(..., paramnames = ...names(), params = list(...)) {
  params <- bc(params)
  if (!length(params))
    stop("You must provide a non-empty value to at least one of\n  - ",
         paste0(paramnames, collapse = "\n  - "))
  wt <- !vapply(params, is.character, logical(1))
  if (any(wt))
    stop(paste(names(wt)[wt], collapse = ", "), " must be character.")
  vapply(params, paste, collapse = "|", character(1))
}

#-------------------------------------------------------------------------------
# TODO: make sure all function using this one have been updated
#-------------------------------------------------------------------------------
get_response <- function(url, args, contentType = 'text/html; charset=utf-8',
                         raise = TRUE, ...) {
  cli <- crul::HttpClient$new(url = url)
  out <- cli$get(query = args, ...)
  w <- ""
  if (out$status_code > 202) {
    x <- out$status_http()
    w <- paste0("HTTP ", x$status_code, ": ", x$message, "\n ", x$explanation)
  } else if (out$response_headers$`content-type` != contentType) {
    w <- paste0("Content was type '", out$headers$`content-type`,
                "'. Should've been type '", contentType, "'.")
  }
  if (w != "") warning(w)
  list(response = out,
       warning = w)
}

b_GET <- function(url, args, ...) {
  cli <- crul::HttpClient$new(url = url)
  out <- cli$get(query = args, ...)
  #-- don't want to stop while looping, error are managed downstream
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
toStr <- function(x, join_word = "and") {
  if (!is.character(x)) x <- as.character(x)
  x <- x[nzchar(x)]
  n <- length(x)
  if (n > 1)
    paste(paste(x[-n], collapse = ", "), join_word, x[n])
  else
    x
}
check_class <- function(x, what, name) {
  if (!inherits(x = x, what = what)) {
    c(name = name, what = toStr(what, "or"))
  } else
    c(name = "", what = "")
}
assert <- function(x,
                   what,
                   name = NULL,
                   checkLength = FALSE) {
  msgLen <- NULL
  msgClass <- NULL
  if (!is.list(x)) {
    if (missing(name))
      name <- deparse(substitute(x))
    if (checkLength &&
        !length(x))
      msgLen <- paste0("\n ", name, " must have length > 0")
    else {
      msgClass <- check_class(x, what, name)
      if (!all(nzchar(msgClass))) msgClass <- NULL
    }
  }
  else {
    if (missing(name)) {
      name <- names(x)
      noNm <- which(!nzchar(name))
      if (length(noNm))
        name[noNm] <- as.character(substitute(x)[noNm + 1])
    }
    if (checkLength) {
      noLen <- which(lengths(x) == 0)
      msgLen <-
        paste0("\n  ", toStr(name[noLen]), " must have length > 0")
      x <- x[-noLen]
      name <- name[-noLen]
      what <- what[-noLen]
    }
    msgClass <- t(mapply(check_class, x, what, name))
    if (nrow(msgClass) > 1)
      msgClass <-
      aggregate(
        name ~ what,
        data = msgClass,
        subset =  rowSums(msgClass == "") == 0,
        FUN = toStr
      )
    msgClass <- as.data.frame(msgClass)
  }
  if (length(msgClass)) {
    msgClass <-
      paste0("\n  ", msgClass[["name"]], " must be of class ", msgClass[["what"]])
  }
  msg <- c(msgLen, msgClass)
  if (length(msg)) {
    stop(msg, call. = FALSE)
  }
}


setrbind <- function(x, fill = TRUE, use.names = TRUE, idcol = NULL) {
  (x <- data.table::setDF(
    data.table::rbindlist(l = x, fill = fill, use.names = use.names, idcol = idcol))
  )
}

b_ranges <- function(l, by) {
  lenOut <- as.integer(ceiling(l/by))
  out <- vector("list", lenOut)
  b <- i <- 1L
  e <- by
  while (!is.na(i) && i < lenOut) {
    out[[i]] <- b:e
    b <- e + 1L
    e <- e + by
    i <- i + 1L
  }
  out[[lenOut]] <- b:l
  out
}
