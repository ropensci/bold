#' Search BOLD for taxonomy data by BOLD ID.
#'
#' @param id (integer) One or more BOLD taxonomic identifiers. required.
#' @param dataTypes (character) Specifies the datatypes that will be
#' returned. 'all' returns all data. 'basic' returns basic taxon information.
#' 'images' returns specimen images.
#' @param includeTree (logical) If `TRUE` (default: `FALSE`), returns a list
#' containing information for parent taxa as well as the specified taxon.
#' @template otherargs
#'
#' @name bold_tax_id-deprecated
#' @seealso \code{\link{bold-deprecated}}
#' @keywords internal
NULL

#' @rdname bold-deprecated
#' @section \code{bold_tax_id}:
#' For \code{bold_tax_id}, use \code{\link{bold_tax_id2}}.
#'
#' @references
#' http://v4.boldsystems.org/index.php/resources/api?type=taxonomy
#' @seealso [bold_tax_name()]
#' @examples \dontrun{
#' bold_tax_id(id = 88899)
#' bold_tax_id(id = 88899, includeTree = TRUE)
#' bold_tax_id(id = 88899, includeTree = TRUE, dataTypes = "stats")
#' bold_tax_id(id = c(88899,125295))
#'
#' ## dataTypes parameters
#' bold_tax_id(id = 88899, dataTypes = "basic")
#' bold_tax_id(id = 88899, dataTypes = "stats")
#' bold_tax_id(id = 88899, dataTypes = "images")
#' bold_tax_id(id = 88899, dataTypes = "geo")
#' bold_tax_id(id = 88899, dataTypes = "sequencinglabs")
#' bold_tax_id(id = 88899, dataTypes = "depository")
#' bold_tax_id(id = c(88899, 125295), dataTypes = "geo")
#' bold_tax_id(id = c(88899, 125295), dataTypes = "images")
#'
#' ## Passing in NA
#' bold_tax_id(id = NA)
#' bold_tax_id(id = c(88899, 125295, NA))
#'
#' ## get http response object only
#' bold_tax_id(id = 88899, response=TRUE)
#' bold_tax_id(id = c(88899, 125295), response=TRUE)
#'
#' ## curl debugging
#' bold_tax_id(id = 88899, verbose = TRUE)
#' }
#'
#' @export
bold_tax_id <- function(id, dataTypes = "basic", includeTree = FALSE,
                        response = FALSE, ...) {
  .Deprecated("bold_tax_id2")
  #-- arguments check
  if (missing(id)) stop("argument 'id' is missing, with no default")
  if (!grepl("true|false", includeTree, ignore.case = TRUE))
    warning("'includeTree' should be either TRUE or FALSE.")
  if (!inherits(id, c("character", "numeric", "integer")))
    warning("'id' should be of class character, numeric or integer.")
  #-- make sure user have correct data types
  dataTypes <- .check_dataTypes_dep(dataTypes)
  if (!nzchar(dataTypes)) {
    out <- data.frame(input = id, noresults = NA)
  } else {
    #-- prep query parameters
    params <- list(dataTypes = dataTypes, includeTree = tolower(includeTree))
    #-- make URL
    URL <- b_url("API_Tax/TaxonData")
    #-- fetch data from the api
    res <- lapply(`names<-`(id, id), function(x) {
      # no need to do the call if id is NA
      if (is.na(x))
        data.frame(input = NA, noresults = NA)
      else
        .get_response_dep(args = c(taxId = x, params), url = URL, ...)
    })
    if (response) {
      out <- res
    } else {
      out <- b_rbind(mapply(FUN = .process_response_dep, x = res, y = id,
                             MoreArgs = list(z = includeTree, w = dataTypes),
                             SIMPLIFY = FALSE))
      if (NCOL(out) == 1) {
        out$noresults <- NA
      }
    }
  }
  out
}
.process_response_dep <- function(x, y, z, w){
  if (is.data.frame(x)) return(x)
  tt <- rawToChar(x$content)
  out <- if (x$status_code > 202) "stop" else jsonlite::fromJSON(tt)
  if ( length(out) == 0 || identical(out[[1]], list()) || any(out == "stop") ) {
    data.frame(input = y, stringsAsFactors = FALSE)
  } else {
    if (w %in% c("stats",'images','geo','sequencinglabs','depository')) out <- out[[1]]
    trynames <- tryCatch(as.numeric(names(out)), warning = function(w) w)
    if (!inherits(trynames, "simpleWarning")) names(out) <- NULL
    if (any(vapply(out, function(x) is.list(x) && length(x) > 0, logical(1)))) {
      out <- lapply(out, function(x) Filter(length, x))
    } else {
      out <- Filter(length, out)
    }
    if (!is.null(names(out))) {
      df <- data.frame(out, stringsAsFactors = FALSE)
    } else {
      df <- b_rbind(lapply(out, data.frame, stringsAsFactors = FALSE))
    }
    row.names(df) <- NULL
    if ("parentid" %in% names(df)) df <- df[order(df[,"parentid"]),]
    row.names(df) <- NULL
    data.frame(input = y, df, stringsAsFactors = FALSE)
  }
}
.get_response_dep <- function(args, url, ...){
  cli <- crul::HttpClient$new(url = url)
  out <- cli$get(query = args, ...)
  out$raise_for_status()
  stopifnot(out$headers$`content-type` == 'text/html; charset=utf-8')
  return(out)
}
.check_dataTypes_dep <- function(x){
  x <- stringi::stri_split_fixed(x, ",", simplify = TRUE)
  # corrects for the json typo in case the option is taken from a previous query
  if (any(x == "depositories")) {
    x[x == "depositories"] <- "depository"
  }
  if (length(x) > 1 && any(x == "all")) {
    x <- "all"
  } else {
    wrongType <- !x %in% c(
      "basic",
      "stats",
      "geo",
      "images",
      "sequencinglabs",
      "depository",
      "thirdparty",
      "all"
    )
    if (any(wrongType)) {
      wt <- b_ennum(x[wrongType], quote = TRUE)
      warning(wt,
              if (sum(wrongType) > 1) " are not valid data types"
              else " is not a valid data type",
              if (!all(wrongType)) " and will be skipped." else ".",
              "\nThe possible data types are:",
              "\n  - basic\n  - stats\n  - geo\n  - images",
              "\n  - sequencinglabs\n  - depository\n  - thirdparty\n  - all")
      x <- x[!wrongType]
    }
    x <- paste(x, collapse = ",")
  }
  x
}
