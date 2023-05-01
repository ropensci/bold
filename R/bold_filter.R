if (getRversion() >= "2.15.1") {
  utils::globalVariables(c("nucleotides", ".I"))
}
#' Filter BOLD specimen + sequence data (output of bold_seqspec)
#'
#' Picks either shortest or longest sequences, for a given grouping variable
#' (e.g., species name)
#'
#' @param x (data.frame) a data.frame, as returned from
#' \code{\link{bold_seqspec}}. Note that some combinations of parameters
#' in \code{\link{bold_seqspec}} don't return a data.frame. Stops with
#' error message if this is not a data.frame. Required.
#' @param by (character) the column by which to group. For example,
#' if you want the longest sequence for each unique species name, then
#' pass **species_name**. If the column doesn't exist, error
#' with message saying so. Required.
#' @param how (character) one of "max" or "min", which get used as
#' `which.max` or `which.min` to get the longest or shortest
#' sequence, respectively. Note that we remove gap/alignment characters
#' (`-`)
#' @param returnTibble Whether the output should be a tibble or
#' a data.frame. Default is TRUE, but verifies that the `tibble` package is
#' installed, if it's not, it will be returned as data.frame.
#' Since this package is only used in this function, doing this so it can be
#' moved to suggested instead of dependency without breaking old scripts.
#'
#' @return a data.frame
#' @examples \dontrun{
#' res <- bold_seqspec(taxon = 'Osmia')
#' maxx <- bold_filter(res, by = "species_name")
#' minn <- bold_filter(res, by = "species_name", how = "min")
#'
#' vapply(maxx$nucleotides, nchar, 1, USE.NAMES = FALSE)
#' vapply(minn$nucleotides, nchar, 1, USE.NAMES = FALSE)
#' }
#' @export
bold_filter <- function(x, by, how = "max", returnTibble = TRUE){
  #-- arg check
  if (missing(x)) stop("argument 'x' is missing, with no default")
  if (missing(by)) stop("argument 'by' is missing, with no default")
  b_assert(x, c("data.frame", "matrix"))
  b_assert(by, "character", check.length = 1L)
  if (!by %in% colnames(x)) stop("'", by, "' is not a valid column in 'x'")
  if (!missing(how)) b_assert(how, "character", check.length = 1L)
  if (!missing(returnTibble)) returnTibble <- b_assert_logical(returnTibble)
  how <- switch(tolower(how),
                min = which.min,
                max = which.max,
                stop("'how' must be one of 'min' or 'max'"))
  #-- faster to use data.table by to filter
  xdt <- data.table::as.data.table(x)
  .rows <- xdt[,{
    lgts <- b_count(nucleotides,"[^-N]")
    .I[how(lgts)]
  }, by = by]$V1
  out <- x[.rows,]
  # so the output is ordered in the same way as before
  out <- out[order(out[,by]),]
  rownames(out) <- NULL
  # this make tibble a suggest instead of dependency.
  # Only function still using it.
  if (returnTibble && requireNamespace("tibble", quietly = TRUE)) {
    tibble::as_tibble(out)
  } else {
    out
  }
}
