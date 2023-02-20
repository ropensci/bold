b_url <- function(api) paste0('https://v4.boldsystems.org/index.php/', api)

bc <- function(x) if (!length(x)) NULL else x[lengths(x) > 0 & nzchar(x)]

pipe_params <- function(..., paramnames = ...names(), params = list(...)) {
  params <- bc(params)
  if (!length(params))
    stop("You must provide a non-empty value to at least one of:\n\t",
         toStr(paramnames, join_word = "or", quote = TRUE), call. = FALSE)
  wt <- !vapply(params, is.character, logical(1))
  if (any(wt))
    stop(paste(names(wt)[wt], collapse = ", "), " must be of class character.", call. = FALSE)
  vapply(params, paste, collapse = "|", character(1))
}
b_GET <- function(url, args, ...) {
  cli <- crul::HttpClient$new(url = url)
  cli$get(query = args, ...)
}
get_response <- function(url, args, contentType = 'text/html; charset=utf-8',
                         raise = TRUE, ...) {
  out <- b_GET(url = url, args = args, ...)
  w <- ""
  if (out$status_code > 202) {
    x <- out$status_http()
    w <-
      paste0("HTTP ", x$status_code, ": ", x$message, "\n ", x$explanation)
  } else if (out$response_headers$`content-type` != contentType) {
    w <- paste0(
      "Content was type '",
      out$headers$`content-type`,
      "'. Should've been type '",
      contentType,
      "'."
    )
  }
  if (w != "") warning(w)
  list(response = out,
       warning = w)
}
setrbind <- function(x, fill = TRUE, use.names = TRUE, idcol = NULL) {
  (x <- data.table::setDF(
    data.table::rbindlist(l = x, fill = fill, use.names = use.names, idcol = idcol))
  )
}
# more efficient than utils::read.delim
setread <- function(x, header = TRUE, sep = "\t", stringsAsFactors = FALSE) {
  (x <- data.table::setDF(
    data.table::fread(
      text = x,
      header = header,
      sep = sep,
      stringsAsFactors = stringsAsFactors
    )
  ))
}
## not used by anything
# strextract <- function(str, pattern) {
#   regmatches(str, regexpr(pattern, str))
# }
strdrop <- function(str, pattern) {
  regmatches(str, regexpr(pattern, str), invert = TRUE)
}
toStr <- function(x, join_word = "and", quote = FALSE) {
  if (!is.character(x)) x <- as.character(x)
  x <- x[nzchar(x)]
  if (quote) {
    x <- paste0("'", x, "'")
  }
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
  } else {
    if (is.null(name)) {
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
    if (length(msgClass)) {
      if (nrow(msgClass) > 1) {
        msgClass <- data.table::as.data.table(msgClass)
        msgClass <- msgClass[which(rowSums(msgClass == "") == 0),
                             toStr(name), by = "what"]
      }
    }
  }
  if (length(msgClass)) {
    msgClass <- paste0("'", msgClass[["name"]], "' must be of class ",
                       msgClass[["what"]], ".")
  }
  msg <- c(msgLen, msgClass)
  if (length(msg)) {
    stop(msg, call. = FALSE)
  }
}
assert_multi <- function(..., what = "character", params = list(...)) {
  if (is.null(names(params))) {
    names(params) <- paste0("param", seq_along(params))
  } else if (any(names(params) == "")) {
    names(params)[names(params) == ""] <-  paste0("param", seq_along(params)[names(params) == ""])
  }
  params <- bc(params)
  wt <- !vapply(params, inherits, logical(1), what = what)
  if (any(wt))
    stop(toStr(names(wt)[wt], quote = TRUE), " must be of class character.")
}
