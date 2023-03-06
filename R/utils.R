b_url <- function(api) paste0('https://v4.boldsystems.org/index.php/', api)

bc <- function(x) if (!length(x)) NULL else x[lengths(x) > 0 & nzchar(x)]

pipe_params <- function(..., paramnames = ...names(), params = list(...)) {
  params <- bc(params)
  if (!length(params))
    stop("You must provide a non-empty value to at least one of:\n\t",
         toStr(paramnames, join_word = "or", quote = TRUE), call. = FALSE)
  wt <- !vapply(params, is.character, logical(1))
  if (any(wt))
    stop(toStr(names(wt)[wt], quote = TRUE), " must be of class character.", call. = FALSE)

  if (length(params$taxon)) {
    # in case it comes from `bold_tax_name()` (#84)
    params$taxon <- fix_taxonName(params$taxon)
  }
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
setread <- function(x, header = TRUE, sep = "\t", stringsAsFactors = FALSE, ...) {
  (x <- data.table::setDF(
    data.table::fread(
      text = x,
      header = header,
      sep = sep,
      stringsAsFactors = stringsAsFactors,
      ...
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
                   check.length.gt0 = FALSE,
                   check.length.is1 = FALSE) {
  msgLen <- NULL
  msgClass <- NULL
  if (missing(name))
    name <- deparse(substitute(x))
  if (check.length.gt0 && !length(x)) {
    msgLen <- paste0("'", name, "' can't be empty.")
  } else if (check.length.is1 && length(x) != 1) {
    msgLen <- paste0("'", name, "' must be length 1.")
  } else {
    msgClass <- check_class(x, what, name)
    if (all(!nzchar(msgClass))) msgClass <- NULL
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
fix_taxonName <- function(x){
  # (#84)
  stringi::stri_replace_all_regex(
    x,
    c("( )('[^']*)$", "( )(\\([^\\(]*)$", " sp$"),
    c("$1\\\\$2\\\\'", "$1$2)", " sp."),
    vectorize_all = FALSE)
}
cleanData <- function(x, emptyValue = NA, rmEmptyCol = FALSE){
  col2clean <- vapply(x, \(x) {
    any(stringi::stri_detect_fixed(x, "|", max_count = 1), na.rm = TRUE)
  }, NA)
  col2clean <- which(col2clean, useNames = FALSE)
  for (.col in col2clean) {
    x[[.col]] <- stringi::stri_replace_all_regex(x[[.col]], "^([^\\|]+)(\\|\\1)+$|^\\|+$", "$1")
  }
  x[x == ""] <- emptyValue
  if (rmEmptyCol) x[,colSums(is.na(x)) == nrow(x)] <- NULL
  x
}
