#' Get BOLD trace files
#' 
#' This function downloads files to your machine - it does not load them into your R session.
#' 
#' @import httr
#' @export
#' @template args 
#' @references \url{http://www.boldsystems.org/index.php/resources/api#trace}
#' 
#' @param marker (character) Returns all records containing matching marker codes. 
#' @param dest (character) A directory to write the files to 
#' @param ... Futher args passed on to download.file. See examples.
#' 
#' @return Either a data.frame, parsed xml, a httr response object, or a list with length two
#' (a data.frame w/o nucleotide data, and a list with nucleotide data)
#' 
#' @examples \dontrun{
#' # The progress dialog is pretty verbose, so quiet=TRUE is a nice touch, but not by default
#' bold_trace(taxon='Osmia', quiet=TRUE)
#' # Use a specific destination directory
#' bold_trace(taxon='Bombus', institutions='York University', dest="~/mytarfiles")
#' # Another example
#' bold_trace(ids=c('ACRJP618-11','ACRJP619-11'))
#' }

bold_trace <- function(taxon = NULL, ids = NULL, bin = NULL, container = NULL, 
  institutions = NULL, researchers = NULL, geo = NULL, marker = NULL, dest=NULL, ...)
{
  args <- bc(list(taxon=pipeornull(taxon), geo=pipeornull(geo), ids=pipeornull(ids), 
      bin=pipeornull(bin), container=pipeornull(container), institutions=pipeornull(institutions), 
      researchers=pipeornull(researchers), marker=pipeornull(marker)))
  url <- make_url('http://www.boldsystems.org/index.php/API_Public/trace', args)
  if(is.null(dest)){
    destfile <- paste0(getwd(), "/bold_trace_files.tar")
    destdir <- paste0(getwd(), "/bold_trace_files")
  } else {
    destdir <- path.expand(dest)
    destfile <- paste0(destdir, "/bold_trace_files.tar")
  }
  download.file(url, destfile=destfile, ...)
  untar(destfile, exdir = destdir)
  files <- list.files(destdir, full.names = TRUE)
  cat("Trace file extracted with files:", "\n\n")
  cat(files, sep = "\n")
  invisible(files)
}
