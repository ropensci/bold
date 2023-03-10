#' Search BOLD for sequences.
#'
#' Get sequences for a taxonomic name, id, bin, container, institution,
#' researcher, geographic, place, or gene.
#'
#' @template args
#' @template otherargs
#' @param marker (character) Returns all records containing matching
#' marker codes.
#' @template large-requests
#' @template marker
#' @template missing-taxon
#' @references
#' http://v4.boldsystems.org/index.php/resources/api?type=webservices
#'
#' @return A data frame with each element as row and 5 columns for processid, identification,
#' marker, accession, and sequence.
#'
#' @examples \dontrun{
#' bold_seq(taxon='Coelioxys')
#' bold_seq(taxon='Aglae')
#' bold_seq(taxon=c('Coelioxys','Osmia'))
#' bold_seq(ids='ACRJP618-11')
#' bold_seq(ids=c('ACRJP618-11','ACRJP619-11'))
#' bold_seq(bin='BOLD:AAA5125')
#' bold_seq(container='ACRJP')
#' bold_seq(researchers='Thibaud Decaens')
#' bold_seq(geo='Ireland')
#' bold_seq(geo=c('Ireland','Denmark'))
#'
#' # Return the http response object for detailed Curl call response details
#' res <- bold_seq(taxon='Coelioxys', response=TRUE)
#' res$url
#' res$status_code
#' res$response_headers
#'
#' ## curl debugging
#' ### You can do many things, including get verbose output on the curl
#' ### call, and set a timeout
#' bold_seq(taxon='Coelioxys', verbose = TRUE)[1:2]
#' }
#'
#' @export
bold_seq <- function(taxon = NULL, ids = NULL, bin = NULL, container = NULL,
                     institutions = NULL, researchers = NULL, geo = NULL,
                     marker = NULL, response = FALSE, ...) {
  response <- b_assert_logical(response)
  params <- b_pipe_params(
    taxon = taxon,
    ids = ids,
    bin = bin,
    container = container,
    institutions = institutions,
    researchers = researchers,
    geo = geo,
    marker = marker
  )
  res <- b_GET(b_url('API_Public/sequence'), params, ...)
  if (response) {
    res
  } else {
    res$raise_for_status()
    res <- rawToChar(res$content)
    if (grepl("Fatal error", res)) {
      warning("the request timed out, see 'If a request times out'\n",
              "returning partial output")
      # faster than extract/replace
      res <- b_drop(str = res, pattern = "Fatal error")
    }
    b_split_fasta(res)
  }
}
b_split_fasta <- function(x){
  x <- b_lines(str = x)
  if (length(x) %% 2 && # if length(x) %% 2 not 0, it's TRUE
      b_detect(x[length(x)], "^\\s*$")) {
      x <- x[-length(x)]
  }
  id_line <- b_detect(x,"^>")
  n <- which(id_line)
  id <- b_split(str = x[id_line], pattern = ">|\\|", omit_empty = TRUE, simplify = NA, n = 4)
  id <- `names<-`(as.data.frame(id), c("processid", "identification", "marker", "accession"))
  if (all(diff(c(n, length(x) + 1L)) == 2)) {
    sequence <- x[n + 1L]
    data.frame(id, sequence)
  } else if (sum(id_line) == sum(!id_line)) {
    # shouldn't happen but who knows
    warning("The file had an even number of ids and sequences, but they weren't in the proper order.",
            "\n  This shouldn't happen. Output may contain errors.",
            "\n  Please open an issue so we can see when this happens.")
    sequence <- x[!id_line]
    data.frame(id, sequence)
  } else {
    warning("The file had an uneven number of ids and sequenceuences.",
            "\n  This shouldn't happen. Returning data as a list of lines.",
            "\n  Please open an issue so we can see when this happens.")
    # out <- mapply(
    #   \(i, j) {
    #     if (i == 1)
    #       data.frame(id[j,], sequence = x[(j + 1L)], row.names = NULL)
    #     else if (i > 1)
    #       data.frame(id[j,], sequence = x[(j + 1L):(j + i)], row.names = NULL)
    #     else
    #       data.frame(id[j,], sequence = NA_character_, row.names = NULL)
    #   },
    #   diff(c(n - 1L, length(x))),
    #   id_line, SIMPLIFY = FALSE)
    # b_rbind(out)
    x
  }
}
