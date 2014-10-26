bc <- function (l) Filter(Negate(is.null), l)

split_fasta <- function(x){
  temp <- paste(">", x, sep="")
  seq <- str_replace_all(str_split(str_replace(temp[[1]], "\n", "<<<"), "<<<")[[1]][[2]], "\n", "")
  stuff <- str_split(x, "\\|")[[1]][c(1:3)]
  list(id=stuff[1], name=stuff[2], gene=stuff[1], sequence=seq)
}

pipeornull <- function(x){
  if(!is.null(x)){ paste0(x, collapse = "|") } else { NULL }
}

make_url <- function(url, args){
  tmp <- parse_url(url)
  tmp$query <- args
  build_url(tmp)
}

check_args_given_nonempty <- function(arguments, x){
  paramnames <- x
  matchez <- any(paramnames %in% names(arguments))
  if(!matchez){
    stop(sprintf("You must provide a non-empty value to at least one of\n  %s", paste0(paramnames, collapse = "\n  ")))
  } else {
    arguments_noformat <- arguments[ !names(arguments) %in% 'combined_download' ]
    argslengths <- vapply(arguments_noformat, nchar, numeric(1), USE.NAMES = FALSE)
    if(any(argslengths == 0))
      stop(sprintf("You must provide a non-empty value to at least one of\n  %s", paste0(paramnames, collapse = "\n  ")))
  }   
}

process_response <- function(x, y, z, w){
  tt <- content(x, as = "text")
  out <- fromJSON(tt)
  if(length(out)==0){
    data.frame(input=y, stringsAsFactors = FALSE)
  } else {
    if(w %in% c("stats",'images','geo','sequencinglabs','depository')) out <- out[[1]]
    trynames <- tryCatch(as.numeric(names(out)), warning=function(w) w)
    if(!is(trynames, "simpleWarning")) names(out) <- NULL
    if(!is.null(names(out))){ df <- data.frame(out, stringsAsFactors = FALSE) } else {
      df <- do.call(rbind.fill, lapply(out, data.frame, stringsAsFactors = FALSE))
    }
    row.names(df) <- NULL
    if("parentid" %in% names(df)) df <- sort_df(df, "parentid")
    row.names(df) <- NULL
    data.frame(input=y, df, stringsAsFactors = FALSE)
  }
}
