#' Get BOLD stats
#'
#' @export
#' @inheritParams bold_specimens
#' @param dataType (character) one of "overview"(default) or "drill_down".
#' "overview": the total record counts of (BINs, Countries, Storing Institutions,
#' Orders, Families, Genus, Species). "drill_down": a detailed summary of
#' information which provides record counts by (BINs, Country,
#' Storing Institution, Species).
#'
#' @details The option 'drill_down' for dataTypes currently seems to only
#' returns NA values. This is a problem with the API.
#'
#' @return By default, return a data.frame with the count of total records,
#' records with species name, bins, countries, depositories,
#' order, family, genus, species. If dataType is set to 'drill_down', will
#' return a list.
#'
#' @references
#' http://v4.boldsystems.org/index.php/resources/api?type=webservices
#'
#' @examples \dontrun{
#' x <- bold_stats(taxon='Osmia')
#' x$total_records
#' x$records_with_species_name
#' x$bins
#' x$countries
#' x$depositories
#' x$order
#' x$family
#' x$genus
#' x$species
#'
#' res <- bold_stats(taxon='Osmia', response=TRUE)
#' res$url
#' res$status_code
#' res$response_headers
#'
#' # More than 1 can be given for all search parameters
#' bold_stats(taxon=c('Coelioxys','Osmia'))
#'
#' ## curl debugging
#' ### These examples below take a long time, so you can set a timeout so that
#' ### it stops by X sec
#' bold_stats(taxon='Osmia', verbose = TRUE)
#' # bold_stats(geo='Costa Rica', timeout_ms = 6)
#' }

bold_stats <- function(taxon = NULL, ids = NULL, bin = NULL,
  container = NULL, institutions = NULL, researchers = NULL, geo = NULL,
  dataType = "overview", response=FALSE, ...) {
  assert(response, "logical")
  assert(dataType, "character")
  if(!dataType %in% c("overview", "drill_down"))
    stop("'dataType' must be one of 'overview', 'drill_down'")
  params <- c(pipe_params(taxon = taxon, geo = geo,
                          ids = ids, bin = bin,
                          container = container,
                          institutions = institutions,
                          researchers = researchers),
              dataType = dataType, format = 'json')
  tmp <- b_GET(b_url('API_Public/stats'), params, ...)
  if (response) return(tmp)
  out <- jsonlite::fromJSON(rawToChar(tmp$content))
  if(dataType == "drill_down"){
    out
  } else {
    list2DF(out)
  }
}
