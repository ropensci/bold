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