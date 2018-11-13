bbase <- function() 'http://v4.boldsystems.org/index.php/'

bc <- function(x) Filter(Negate(is.null), x)

split_fasta <- function(x){
  temp <- paste(">", x, sep = "")
  seq <- str_replace_all(str_split(str_replace(temp[[1]], "\n", "<<<"), 
                                   "<<<")[[1]][[2]], "\n", "")
  seq <- gsub("\\\r|\\\n", "", seq)
  stuff <- str_split(x, "\\|")[[1]][c(1:3)]
  list(id = stuff[1], name = stuff[2], gene = stuff[1], sequence = seq)
}

pipeornull <- function(x){
  if (!is.null(x)) { 
    paste0(x, collapse = "|") 
  } else { 
    NULL
  }
}

check_args_given_nonempty <- function(arguments, x){
  paramnames <- x
  matchez <- any(paramnames %in% names(arguments))
  if (!matchez) {
    stop(sprintf("You must provide a non-empty value to at least one of\n  %s", 
                 paste0(paramnames, collapse = "\n  ")))
  } else {
    arguments_noformat <- arguments[ !names(arguments) %in% 'combined_download' ]
    argslengths <- vapply(arguments_noformat, nchar, numeric(1), 
                          USE.NAMES = FALSE)
    if (any(argslengths == 0)) {
      stop(sprintf("You must provide a non-empty value to at least one of\n  %s", 
                   paste0(paramnames, collapse = "\n  ")))
    }
  }   
}

process_response <- function(x, y, z, w){
  tt <- rawToChar(x$content)
  out <- if (x$status_code > 202) "stop" else jsonlite::fromJSON(tt)
  if ( length(out) == 0 || identical(out[[1]], list()) || out == "stop" ) {
    data.frame(input = y, stringsAsFactors = FALSE)
  } else {
    if (w %in% c("stats",'images','geo','sequencinglabs','depository')) out <- out[[1]]
    trynames <- tryCatch(as.numeric(names(out)), warning = function(w) w)
    if (!inherits(trynames, "simpleWarning")) names(out) <- NULL
    if (any(vapply(out, function(x) is.list(x) && length(x) > 0, logical(1)))) {
        out <- lapply(out, function(x) Filter(length, x))
    } else {
        out <- Filter(length, out)
    }
    if (!is.null(names(out))) {
      df <- data.frame(out, stringsAsFactors = FALSE)
    } else {
      df <- do.call(rbind.fill, lapply(out, data.frame, stringsAsFactors = FALSE))
    }
    row.names(df) <- NULL
    if ("parentid" %in% names(df)) df <- sort_df(df, "parentid")
    row.names(df) <- NULL
    data.frame(input = y, df, stringsAsFactors = FALSE)
  }
}

get_response <- function(args, url, ...){
  cli <- crul::HttpClient$new(url = url)
  out <- cli$get(query = args, ...)
  out$raise_for_status()
  stopifnot(out$headers$`content-type` == 'text/html; charset=utf-8')
  return(out)
}

b_GET <- function(url, args, ...){
  cli <- crul::HttpClient$new(url = url)
  out <- cli$get(query = args, ...)
  out$raise_for_status()
  if (grepl("html", out$response_headers$`content-type`)) {
    stop(out$parse("UTF-8"))
  }
  return(out)
}

strextract <- function(str, pattern) {
  regmatches(str, regexpr(pattern, str))
}

strdrop <- function(str, pattern) {
  regmatches(str, regexpr(pattern, str), invert = TRUE)
}
