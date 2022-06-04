#' Get BOLD species summary from a BOLD taxid.
#'
#' @export#'
#' @param taxid (integer, numeric or character) A vector of BOLD taxid(s).
#' Can be obtain with `bold_tax_name()`
#'
#' @details Get the species summary table from a taxon's page. Uses webscrapping,
#' so might be unstable. If the taxid is from species, it will give the
#' subspecies summary.
#'
#' @return A list of data.frame (one for each id provided) with 4 columns :
#' species name, number of specimen, number of sequences and
#' number of barcodes with >500bp.
#'
#' @examples \dontrun{
#' bold_species_summary(taxid = c(2890, 2899))
#'
#' # Getting the ids from `bold_tax_name()`
#' taxa <- bold_tax_name(c("Zeus", "Oreosoma"))
#' bold_species_summary(taxid = taxa$taxid)
#' }

bold_species_summary <- function(taxid){
  assert(taxid, c("integer","numeric","character"))
  lapply(`names<-`(taxid, as.character(taxid)), function(id){
    res <- get_response(b_url("/TaxBrowser_TaxonPage/SpeciesSummary"),
                        args = list(taxid = id))
    html <- xml2::read_html(rawToChar(res$response$content))
    tbl <- xml2::xml_find_all(html, xpath = './/tr/td')
    if(!length(tbl)){
      tmp <- xml2::xml_text(xml2::xml_find_all(html, ".//p"))
      if(length(tmp)==1)
        res$warning <- gsub("\\n\\r\\t", "", tmp)
      else res$warning <- "Error reading the web page"
      warning(res$warning)
      return(res)
    }
    tbl <- xml2::xml_text(tbl, trim=TRUE)
    tbl <- tbl[tbl!=""]
    l <- length(tbl)
    header <- gsub(" >", "Min", tolower(tbl[1:4]))
    n <- length(header)
    if(l%%n!=0) warning("Error reading data. Result might be misaligned/incomplete.")
    if(l==n){
      tbl <- rep(NA, n)
    } else {
      tbl <- tbl[-(1:n)]
    }
    tbl <- data.frame(matrix(tbl, ncol = n, byrow = TRUE, dimnames = list(NULL, header)))
    tbl$specimens        <- as.integer(tbl$specimens)
    tbl$sequences        <- as.integer(tbl$sequences)
    tbl$barcodesMin500bp <- as.integer(tbl$barcodesMin500bp)
    tbl
  })
}
