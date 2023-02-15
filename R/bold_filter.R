#' Filter BOLD specimen + sequence data (output of bold_seqspec)
#'
#' Picks either shortest or longest sequences, for a given grouping variable
#' (e.g., species name)
#'
#' @export
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
#' res <- bold_seqspec(taxon='Osmia')
#' maxx <- bold_filter(res, by = "species_name")
#' minn <- bold_filter(res, by = "species_name", how = "min")
#'
#' vapply(maxx$nucleotides, nchar, 1, USE.NAMES = FALSE)
#' vapply(minn$nucleotides, nchar, 1, USE.NAMES = FALSE)
#' }
bold_filter <- function(x, by, how = "max", returnTibble = TRUE) {
  if (!inherits(x, "data.frame")) stop("'x' must be a data.frame")
  if (!how %in% c("min", "max")) stop("'how' must be one of 'min' or 'max'")
  if (!by %in% names(x)) stop(sprintf("'%s' is not a valid column in 'x'", by))
  xsp <- split(x, x[[by]])
  out <- setrbind(lapply(xsp, function(z) {
    lgts <- vapply(z$nucleotides, function(w) nchar(gsub("-", "", w)), 1,
                   USE.NAMES = FALSE)
    z[eval(parse(text = paste0("which.", how)))(lgts), ]
  }))
  if (returnTibble && requireNamespace("tibble", quietly = TRUE)) {
    tibble::as.tibble(out)
  } else {
    out
  }
}
bold_filter2 <- function(x, by, how = "max", returnTibble = TRUE) {
  if (!inherits(x, c("data.frame", "matrix"))) stop("'x' must be a data.frame or matrix")
  if (!by %in% names(x)) stop(sprintf("'%s' is not a valid column in 'x'", by))
  if (!how %in% c("min", "max")) stop("'how' must be one of 'min' or 'max'")
  .fun <- list(min = which.min, max = which.max)
  # why not use this package if it's already a dependency.
  # So much more efficient.
  xdt <- data.table::as.data.table(x)
  .rows <- xdt[,{
    lgts <- stringi::stri_count_regex(nucleotides,"[^-]")
    .I[.fun[[how]](lgts)]
  }, by = by]$V1
  out <- x[.rows,]
  # so the output is ordered in the same way as before
  out <- out[order(out[[by]]),]
  rownames(out) <- NULL
  if (returnTibble && requireNamespace("tibble", quietly = TRUE)) {
    tibble::as.tibble(out)
  } else {
    out
  }
}
bench::mark(bold_filter(res, "species_name"), bold_filter2(res, "species_name")) # :)
