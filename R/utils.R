b_url <- function(api) paste0('https://v4.boldsystems.org/index.php/', api)

b_rm_empty <- function(x) if (!length(x)) NULL else x[lengths(x) > 0 & nzchar(x)]

b_pipe_params <- function(..., paramnames = ...names(), params = list(...)) {
  params <- b_rm_empty(params)
  if (!length(params))
    stop("You must provide a non-empty value to at least one of:\n\t",
         b_ennum(paramnames, join_word = "or", quote = TRUE), call. = FALSE)
  wt <- !vapply(params, is.character, logical(1))
  if (any(wt))
    stop(b_ennum(names(wt)[wt], quote = TRUE), " must be of class character", call. = FALSE)

  if (length(params$taxon)) {
    # in case it comes from `bold_tax_name()` (#84)
    params$taxon <- b_fix_taxonName(params$taxon)
  }
  vapply(params, paste, collapse = "|", character(1))
}
b_GET <- function(url, args, ...) {
  cli <- crul::HttpClient$new(url = url)
  cli$get(query = args, ...)
}
b_check_res <- function(res, contentType = 'text/html; charset=utf-8',
                         raise = TRUE, ...) {
  w <- ""
  if (res$status_code > 202) {
    x <- res$status_http()
    w <- paste0("HTTP ", x$status_code, ": ", x$message, "\n ", x$explanation)
  } else if (res$response_headers$`content-type` != contentType) {
    w <- paste0(
      "Content was type '",
      res$headers$`content-type`,
      "'. Should've been type '",
      contentType,
      "'"
    )
  }
  if (w != "") warning(w)
  list(response = res,
       warning = w)
}
b_rbind <- function(x, fill = TRUE, use.names = TRUE, idcol = NULL) {
  (x <- data.table::setDF(
    data.table::rbindlist(l = x, fill = fill, use.names = use.names, idcol = idcol))
  )
}
b_read <- function(x, header = TRUE, sep = "\t", stringsAsFactors = FALSE, ...) {
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
b_extract <- function(str, pattern, mode = "all",
                      fixed = FALSE, simplify = TRUE, ...) {
  switch(mode,
         first = {
           if (!fixed)
             stringi::stri_extract_first_regex(str = str, pattern = pattern, ...)
           else
             stringi::stri_extract_first_fixed(str = str, pattern = pattern, ...)
         },
         last = {
           if (!fixed)
             stringi::stri_extract_last_regex(str = str, pattern = pattern, ...)
           else
             stringi::stri_extract_last_fixed(str = str, pattern = pattern, ...)
         },
         all = {
           if (!fixed)
             stringi::stri_extract_all_regex(str = str,
                                             pattern = pattern,
                                             simplify = simplify,
                                             ...)
           else
             stringi::stri_extract_all_fixed(str = str,
                                             pattern = pattern,
                                             simplify = simplify,
                                             ...)
         },
         str)
}
b_words <- function(str, mode = "first", ...) {
  switch(mode,
    first = stringi::stri_extract_first_words(str = str, ...),
    last = stringi::stri_extract_last_words(str = str, ...),
    all = stringi::stri_extract_all_words(str = str, ...),
    str
  )
}
b_replace <- function(str, pattern, replacement, fixed = FALSE, ...) {
  if (!fixed)
    stringi::stri_replace_all_regex(str = str, pattern = pattern,
                                    replacement = replacement, ...)
  else
    stringi::stri_replace_all_fixed(str = str, pattern = pattern,
                                    replacement = replacement, ...)
}
b_detect <- function(str, pattern, fixed = FALSE, ...) {
  if (!fixed)
    stringi::stri_detect_regex(str = str, pattern = pattern, ...)
  else
    stringi::stri_detect_fixed(str = str, pattern = pattern, ...)
}
b_split <- function(str, pattern, fixed = FALSE, ...) {
  if (!fixed)
    stringi::stri_split_regex(str = str, pattern = pattern, ...)
  else
    stringi::stri_split_fixed(str = str, pattern = pattern, ...)
}
b_count <- function(str, pattern, fixed = FALSE, ...) {
  if (!fixed)
    stringi::stri_count_regex(str = str, pattern = pattern, ...)
  else
    stringi::stri_count_fixed(str = str, pattern = pattern, ...)
}
b_drop <- function(str, pattern) {
  to <- stringi::stri_locate_first_fixed(str = str, pattern = pattern)[[1]] - 1L
  stringi::stri_sub(str = str, to = to)
}
b_lines <- function(str) {
  stringi::stri_split_lines1(str = str)
}
b_ennum <- function(x, join_word = "and", quote = FALSE) {
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
b_assert_format <- function(x){
  b_assert_length(x, len = 1L, name = "format")
  switch(tolower(x),
         xml = "xml",
         tsv = "tsv",
         stop("'format' should be one of 'xml' or 'tsv'"))
}
b_assert_logical <- function(x, name = deparse(substitute(x))) {
  b_assert_length(x, len = 1L, name = name)
  switch(tolower(x),
         true = TRUE,
         "1" = TRUE,
         false = FALSE,
         "0" = FALSE,
         na = FALSE,
         stop("'", name, "' should be one of TRUE or FALSE"))
}
b_assert_class <- function(x, what, name, is2nd = FALSE, stopOnFail = TRUE) {
  .fun <- if (stopOnFail) stop else paste0
  if (!inherits(x = x, what = what)) {
    if (!is2nd)
      .fun("'", name, "' must be of class ", b_ennum(what, "or"))
    else
      .fun(" and of class ", b_ennum(what, "or"))
  } else {
    NULL
  }
}
b_assert_length <- function(x, len, name, stopOnFail = TRUE) {
  .fun <- if (stopOnFail) stop else paste0
  if (len < 1 && !length(x)) {
    .fun("'", name, "' can't be empty")
  } else if (len > 0 && length(x) != len) {
    .fun("'", name, "' must be length ", len)
  } else {
    NULL
  }
}
b_assert <- function(x,
                   what,
                   name = NULL,
                   check.length = NULL) {
  if (missing(name)) {
    name <- deparse(substitute(x))
  }
  msgLen <- if (is.numeric(check.length) || is.integer(check.length)) {
    b_assert_length(x = x, len = check.length, name = name)
  } else if (isTRUE(check.length)) {
    b_assert_length(x = x, len = 0, name = name)
  } else {
    NULL
  }
  msgClass <- b_assert_class(x = x, what = what, name = name, is2nd = length(msgLen), stopOnFail = FALSE)
  msg <- c(msgLen, msgClass)
  if (length(msg)) {
    stop(msg, call. = FALSE)
  }
}
b_fix_taxonName <- function(x){
  # (#84)
  stringi::stri_replace_all_regex(
    x,
    # check if supposed to:
    c(
      # be quoted; keep quoted text
      " ('[^']*)$",
      # be in parenthesis; keep parenthesis text
      " (\\([^\\(]*)$",
      # end with a dot (there might be more cases, but haven't seen them yet)
      "( sp(\\. nov)?$)"
    ),
    # add :
    c(
      # closing quote
      " $1\\\\$2\\\\'",
      # closing parenthesis
      "$1$2)",
      # end dot
      "$1"
    ),
    vectorize_all = FALSE)
}
b_cleanData <- function(x, emptyValue = NA){
  col2clean <- vapply(x, \(x) {
    any(stringi::stri_detect_fixed(x, "|", max_count = 1), na.rm = TRUE)
  }, NA)
  col2clean <- which(col2clean, useNames = FALSE)
  for (.col in col2clean) {
    x[[.col]] <- stringi::stri_replace_all_regex(
      x[[.col]],
      # if the same text is repeated
      # or if only "||||"
      "^([^\\|]+)(\\|\\1)+$|^\\|+$",
      # keep first text/replace with nothing
      "$1")
  }
  x[x == ""] <- emptyValue
  x
}
