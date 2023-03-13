#' Get the error messages and parameters used for a request from a bold output.
#'
#' @param x   Any object with the attributes "errors" and "params". Usually the output of \code{\link{bold_tax_name}} or \code{\link{bold_tax_id2}}.
#'
#' @return A list of the attributes 'errors' and 'params' of the object.
#' @examples \dontrun{
#' x <- bold_tax_name(name=c("Apis","Felis","Pinus"), tax_division = "Animalia")
#' bold_get_errors(x)
#' y <- bold_tax_id2(id = c(88899999, 125295, NA_integer_), dataTypes = c("basic", "stats"))
#' bold_get_errors(y)
#' }
#' @export
bold_get_attr <- function(x){
  if (missing(x)) stop("argument 'x' is missing, with no default")
  if (is.data.frame(x)) {
    attributes(x)[c("errors", "params")]
  } else {
    lapply(x, bold_get_attr)
  }
}
#' Get the error messages from a bold output.
#'
#' @param x   Any object with an attribute "errors". Usually the output of \code{\link{bold_tax_name}} or \code{\link{bold_tax_id2}}.
#'
#' @return The 'errors' attribute of the object.
#' @examples \dontrun{
#' x <- bold_tax_name(name=c("Apis","Felis","Pinus"), tax_division = "Animalia")
#' bold_get_errors(x)
#' y <- bold_tax_id2(id = c(88899999, 125295, NA_integer_), dataTypes = c("basic", "stats"))
#' bold_get_errors(y)
#' }
#' @rdname bold_get_attr
#' @export
bold_get_errors <- function(x){
  if (missing(x)) stop("argument 'x' is missing, with no default")
  if (is.data.frame(x)) {
    attr(x, which = "errors", exact = TRUE)
  } else {
    lapply(x, attr, which = "errors", exact = TRUE)
  }
}
#' Get the parameters used for a request from a bold output.
#'
#' @param x   Any object with an attribute "params". Usually the output of \code{\link{bold_tax_name}} or \code{\link{bold_tax_id2}}.
#'
#' @return The 'params' attribute of the object.
#' @examples \dontrun{
#' x <- bold_tax_name(name=c("Apis","Felis","Pinus"), tax_division = "Animalia")
#' bold_get_params(x)
#' y <- bold_tax_id2(id = c(88899999, 125295, NA_integer_), dataTypes = c("basic", "stats"))
#' bold_get_params(y)
#' }
#' @rdname bold_get_attr
#' @export
bold_get_params <- function(x){
  if (missing(x)) stop("argument 'x' is missing, with no default")
  if (is.data.frame(x)) {
    attr(x, which = "params", exact = TRUE)
  } else {
    lapply(x, attr, which = "params", exact = TRUE)
  }
}
