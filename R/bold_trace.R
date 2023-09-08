#' Get BOLD trace files
#'
#' @export
#' @template args
#' @references
#' http://v4.boldsystems.org/index.php/resources/api?type=webservices
#'
#' @param marker (character) Returns all records containing matching
#' marker codes.
#' @param dest (character) A directory to write the files to
#' @param overwrite (logical) Overwrite existing directory and file?
#' @param progress (logical) Print progress or not. NOT AVAILABLE FOR NOW.
#' HOPEFULLY WILL RETURN SOON.
#' @param ... Further args passed on to \code{\link[crul]{verb-GET}}
#' @param x Object to print or read.
#'
#' @examples \dontrun{
#' # Use a specific destination directory
#' bold_trace(taxon = "Bombus ignitus", geo = "Japan", dest = "~/mytarfiles")
#'
#' # Another example
#' # bold_trace(ids='ACRJP618-11', dest="~/mytarfiles")
#' # bold_trace(ids=c('ACRJP618-11','ACRJP619-11'), dest="~/mytarfiles")
#'
#' # read file in
#' x <- bold_trace(ids=c('ACRJP618-11','ACRJP619-11'), dest="~/mytarfiles")
#' (res <- read_trace(x$ab1[2]))
#' # read all files in
#' (res <- read_trace(x))
#'
#' # The progress dialog is pretty verbose, so quiet=TRUE is a nice touch,
#' # but not by default
#' # Beware, this one take a while
#' # x <- bold_trace(taxon='Osmia', quiet=TRUE)
#'
#' if (requireNamespace("sangerseqR", quietly = TRUE)) {
#'  library("sangerseqR")
#'  primarySeq(res)
#'  secondarySeq(res)
#'  head(traceMatrix(res))
#' }
#' }

bold_trace <- function(taxon = NULL, ids = NULL, bin = NULL, container = NULL,
  institutions = NULL, researchers = NULL, geo = NULL, marker = NULL, dest = NULL,
  overwrite = TRUE, progress = TRUE, ...) {

  if (!requireNamespace("sangerseqR", quietly = TRUE)) {
    warning("You will need to install sangerseqR to be able to read in the trace files.",
            call. = FALSE)
  }

  if (!missing(overwrite)) b_assert_logical(overwrite)
  if (!missing(progress)) b_assert_logical(progress)
  if (!is.null(dest)) b_assert(dest, "character", check.length = 1L)
  params <- c(
    b_pipe_params(
      taxon = taxon,
      geo = geo,
      ids = ids,
      bin = bin,
      container = container,
      institutions = institutions,
      researchers = researchers,
      marker = marker
    ))
  if (is.null(dest)) {
    destfile <- paste0(getwd(), "/bold_trace_files.tar")
    destdir <- paste0(getwd(), "/bold_trace_files")
  } else {
    destdir <- path.expand(dest)
    destfile <- paste0(destdir, "/bold_trace_files.tar")
  }
  if (!dir.exists(destdir)) {
    dir.create(destdir, showWarnings = FALSE, recursive = TRUE)
  }
  if (!file.exists(destfile)) file.create(destfile, showWarnings = FALSE)
  res <- b_GET(
    query = params,
    api = 'API_Public/trace',
    disk = destfile,
    ...
  )
  utils::untar(destfile, exdir = destdir)
  ab1 <- list.files(destdir, pattern = ".ab1", full.names = TRUE)
  structure(list(destfile = destfile, destdir = destdir, ab1 = ab1,
                 args = params), class = "boldtrace")
}

#' @export
#' @rdname bold_trace
print.boldtrace <- function(x, ...){
  cat("\n<bold trace files>", "\n\n")
  ff <- x$ab1[1:min(10, length(x$ab1))]
  if (length(ff) < length(x$ab1)) ff <- c(ff, "...")
  cat(ff, sep = "\n")
}

#' @export
#' @rdname bold_trace
read_trace <- function(x){
  .Deprecated("bold_read_trace")
  if (!requireNamespace("sangerseqR", quietly = TRUE)) {
    stop("Please install sangerseqR", call. = FALSE)
  }
  if (inherits(x, "boldtrace")) {
    if (length(x$ab1) > 1) stop("Number of paths > 1, just pass one in",
                                call. = FALSE)
    # sangerseqR::readsangerseq(x$ab1) if it's stop it won't get read
  } else {
    sangerseqR::readsangerseq(x)
  }
}


#' @param x (list or character) Either the boldtrace object returned from
#' \code{\link[bold]{bold_trace}} or the path(s) of bold trace file(s).
#'
#' @export
#' @rdname bold_trace
bold_read_trace <- function(x){
  if (missing(x)) stop("argument 'x' is missing, with no default")
  if (!requireNamespace("sangerseqR", quietly = TRUE)) {
    stop("Please install sangerseqR", call. = FALSE)
  }
  b_assert(x, c("character", "boldtrace"), check.length = 0L)
  trace_paths <- {
    if (is.list(x))
      `names<-`(x$ab1, basename(x$ab1))
    else
      `names<-`(x, basename(x))
  }
  lapply(trace_paths, function(trace_path) {
    if (file.exists(trace_path)) {
      sangerseqR::readsangerseq(trace_path)
    } else {
      warning("Couldn't find the trace file: \"",
              trace_path,"\".\nSkipping.",
              call. = FALSE)
      NULL
    }
  })
}
