bold_compact <- function (l) Filter(Negate(is.null), l)

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