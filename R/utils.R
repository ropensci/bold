# -- API requests helpers
b_url <- function(api) paste0('https://v4.boldsystems.org/index.php/', api)
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
b_GET <- function(query, api, check = FALSE,
                  contentType = 'text/html; charset=utf-8', ...) {
  cli <- crul::HttpClient$new(url = b_url(api))
  res <- cli$get(query = query, ...)
  if (check) b_CHECK(res = res, contentType = contentType)
  else res
}
b_CHECK <- function(res, contentType) {
  w <- ""
  # get HTTP error if any
  if (res$status_code > 202) {
    x <- res$status_http()
    w <- paste0("HTTP ", x$status_code, ": ", x$message, "\n ", x$explanation)
  }
  # check if the content returned is of the right type
  if (res$response_headers$`content-type` != contentType) {
    w <- paste0(
      "Content was type '", res$headers$`content-type`,
      "' when it should've been type '", contentType, "'")
  }
  # if warning call it now
  if (nzchar(w)) warning(w, call. = FALSE, immediate. = TRUE)
  list(response = res, warning = w)
}
b_parse <- function(res, format, raise = TRUE, cleanData = FALSE, multiple = FALSE){
  if (raise) res$raise_for_status()
  res <- {
    if (!multiple)
      rawToChar(res$content)
    else
      paste0(rawToChar(res$content, multiple = TRUE), collapse = "")
  }
  res <- enc2utf8(res)
  if (res == "") {
    NA
  } else {
    if (b_detect(res, "Fatal error")) {
      # if returning partial output for bold_seq, might as well do that here too
      warning("the request timed out, see 'If a request times out'\n",
              "returning partial output")
      res <- b_drop(str = res, pattern = "Fatal error")
      # if missing, adding closing tag so it can be read properly
      if (format == "xml" && !b_detect(res, "</bold_records")) {
        res <- paste0(res, "</bold_records>")
      }
    }
    switch(
      format,
      xml = b_read_xml(res),
      json = b_read_json(res),
      tsv = b_read_tsv(res, cleanData = cleanData),
      fasta = b_read_fasta(res)
    )
  }
}
b_cleanData <- function(x, emptyValue = NA){
  col2clean <- vapply(x, \(x) {
    any(b_detect(x, "|", max_count = 1, fixed = TRUE), na.rm = TRUE)
  }, NA)
  col2clean <- which(col2clean, useNames = FALSE)
  for (.col in col2clean) {
    x[[.col]] <- b_replace(
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
b_read_json <- function(x){
  jsonlite::parse_json(x, simplifyVector = TRUE, flatten = TRUE)
}
b_read_xml <- function(x) {
  # DON'T REMOVE OPTIONS
  # necessary for large request!
  xml2::read_xml(x, options = c("NOBLANKS", "HUGE"))
}
b_read_tsv <- function(x, header = TRUE, sep = "\t",
                       cleanData = FALSE, ...) {
  x <- data.table::setDF(
    data.table::fread(
      text = x,
      header = header,
      sep = sep,
      ...
    )
  )
  if (cleanData) {
    b_cleanData(x)
  } else {
    x
  }
}
b_nameself <- function(x){
  `names<-`(x, x)
}
b_rm_empty <- function(x) {
  if (!length(x)) {
    NULL
  } else {
    x[lengths(x) > 0 & nzchar(x)]
  }
}
b_rbind <- function(x, fill = TRUE, use.names = TRUE, idcol = NULL) {
  (x <- data.table::setDF(
    data.table::rbindlist(l = x, fill = fill, use.names = use.names, idcol = idcol))
  )
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
b_fix_taxonName <- function(x){
  # see issue #84
  # check if supposed to:
  x <- b_replace(x,
      # be quoted; keep quoted text
      " ('[^']*)$",
      # add closing quote
      " $1\\\\'")
  x <- b_replace(x,
      # be in parenthesis; keep parenthesis text
      " (\\([^\\(]*)$",
      # add closing parenthesis
      "$1)")
  x <- b_replace(x,
      # end with a dot (there might be more cases, but haven't seen them yet)
      "( sp(\\. nov)?$)",
      # add end dot
      "$1")
  x
}
