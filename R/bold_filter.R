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
#' pass \strong{species_name}. If the column doesn't exist, error
#' with message saying so. Required.
#' @param how (character) one of "max" or "min", which get used as
#' \code{which.max} or \code{which.min} to get the longest or shortest
#' sequence, respectively. Note that we remove gap/alignment characters
#' (\code{-})
#' @return a tibble/data.frame
#' @examples \dontrun{
#' res <- bold_seqspec(taxon='Osmia')
#' maxx <- bold_filter(res, by = "species_name")
#' minn <- bold_filter(res, by = "species_name", how = "min")
#'
#' vapply(maxx$nucleotides, nchar, 1, USE.NAMES = FALSE)
#' vapply(minn$nucleotides, nchar, 1, USE.NAMES = FALSE)
#' }
bold_filter <- function(x, by, how = "max") {
  if (!inherits(x, "data.frame")) stop("'x' must be a data.frame")
  if (!how %in% c("min", "max")) stop("'how' must be one of 'min' or 'max'")
  if (!by %in% names(x)) stop(sprintf("'%s' is not a valid column in 'x'", by))
  xsp <- split(x, x[[by]])
  tibble::as_tibble(setrbind(lapply(xsp, function(z) {
    lgts <- vapply(z$nucleotides, function(w) nchar(gsub("-", "", w)), 1,
                   USE.NAMES = FALSE)
    z[eval(parse(text = paste0("which.", how)))(lgts), ]
  })))
}
