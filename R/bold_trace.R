#' Get BOLD trace files
#' 
#' @import httr 
#' @importFrom sangerseqR readsangerseq
#' @export
#' @template args 
#' @references \url{http://www.boldsystems.org/index.php/resources/api#trace}
#' 
#' @param marker (character) Returns all records containing matching marker codes. 
#' @param dest (character) A directory to write the files to 
#' @param overwrite (logical) Overwrite existing directory and file?
#' @param progress (logical) Print progress or not. Uses \code{\link[httr]{progress}}.
#' @param ... Futher args passed on to \code{\link[httr]{GET}}.
#' @param x Object to print or read.
#' 
#' @examples \donttest{
#' # The progress dialog is pretty verbose, so quiet=TRUE is a nice touch, but not by default
#' bold_trace(taxon='Osmia', quiet=TRUE)
#' 
#' # Use a specific destination directory
#' bold_trace(taxon='Bombus', institutions='York University', dest="~/mytarfiles")
#' bold_trace(taxon='Bombus', geo='Alaska', dest="~/mytarfiles")
#' 
#' # Another example
#' bold_trace(ids='ACRJP618-11', dest="~/mytarfiles")
#' bold_trace(ids=c('ACRJP618-11','ACRJP619-11'), dest="~/mytarfiles")
#' 
#' # read file in 
#' x <- bold_trace(ids=c('ACRJP618-11','ACRJP619-11'), dest="~/mytarfiles")
#' (res <- read_trace(x$ab1[2]))
#' primarySeq(res)
#' secondarySeq(res)
#' head(traceMatrix(res))
#' }

bold_trace <- function(taxon = NULL, ids = NULL, bin = NULL, container = NULL, 
  institutions = NULL, researchers = NULL, geo = NULL, marker = NULL, dest=NULL, 
  overwrite = TRUE, progress = TRUE, ...)
{
  args <- bc(list(taxon=pipeornull(taxon), geo=pipeornull(geo), ids=pipeornull(ids), 
      bin=pipeornull(bin), container=pipeornull(container), institutions=pipeornull(institutions), 
      researchers=pipeornull(researchers), marker=pipeornull(marker)))
  url <- make_url(paste0(bbase(), 'API_Public/trace'), args)
  if(is.null(dest)){
    destfile <- paste0(getwd(), "/bold_trace_files.tar")
    destdir <- paste0(getwd(), "/bold_trace_files")
  } else {
    destdir <- path.expand(dest)
    destfile <- paste0(destdir, "/bold_trace_files.tar")
  }
  res <- GET(url, write_disk(path = destfile, overwrite = overwrite), if(progress) progress(), ...)
  untar(destfile, exdir = destdir)
  files <- list.files(destdir, full.names = TRUE)
  ab1 <- list.files(destdir, pattern = ".ab1", full.names = TRUE)
  structure(list(destfile=destfile, destdir=destdir, ab1=ab1, args=args), class="boldtrace")
}

#' @export
print.boldtrace <- function(x, ...){
  cat("\n<bold trace files>", "\n\n")
  cat(x$ab1, sep = "\n")
}

#' @export
#' @rdname bold_trace
read_trace <- function(x){
  if(is(x, "boldtrace")){
    if(length(x$ab1) > 1) stop("Number of paths > 1, just pass one in", call. = FALSE)
    readsangerseq(x$ab1)
  } else {
    readsangerseq(x)
  }
}
