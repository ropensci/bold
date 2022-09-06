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

assert <- function(x, what, name = deparse(substitute(x, env = environment()))) {
  if (length(x) && !inherits(x = x, what = what))
    stop(name, " must be of class ", paste0(what, collapse = ", "), call. = FALSE)
}

setrbind <- function(x, fill = TRUE, use.names = TRUE, idcol = NULL) {
  (x <- data.table::setDF(
    data.table::rbindlist(l = x, fill = fill, use.names = use.names, idcol = idcol))
  )
}

splitByNchar <- function(x, maxN) {
  x <- state.name
  cs <- cumsum(nchar(state.name))
  grps <- list()
  i <- 1
  while (length(x)) {
    grps[[i]] <- x[cs < 50]
    i <- i + 1
    x <- x[cs >= 50]
    cs <- cumsum(nchar(x))
  }
  grps
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

toStr <- function(x) {
  if (!is.character(x)) x <- as.character(x)
  n <- length(x)
  paste(paste(x[-n], collapse = ", "), "and", x[n])
}
