#' @title bold
#' @description bold: A programmatic interface to the Barcode of Life data
#' @section About:
#'
#' This package gives you access to data from BOLD System
#' http://www.boldsystems.org/ via their API
#' (http://v4.boldsystems.org/index.php/api_home)
#'
#' @section Functions:
#'
#' - \code{\link{bold_specimens}} - Search for specimen data
#' - \code{\link{bold_seq}} - Search for and retrieve sequences
#' - \code{\link{bold_seqspec}} - Get sequence and specimen data together
#' - \code{\link{bold_trace}} - Get trace files - saves to disk
#' - \code{\link{read_trace}} - Read trace files into R
#' - \code{\link{bold_tax_name}} - Get taxonomic names via input names
#' - \code{\link{bold_tax_id}} - Get taxonomic names via BOLD identifiers
#' - \code{\link{bold_tax_id2}} - Get taxonomic names via BOLD identifiers (improved)
#' - \code{\link{bold_identify}} - Search for match given a COI sequence
#'
#' Interestingly, they provide xml and tsv format data for the specimen data,
#' while they provide fasta data format for the sequence data. So for the
#' specimen data you can get back raw XML, or a data frame parsed from the
#' tsv data, while for sequence data you get back a list (b/c sequences are
#' quite long and would make a data frame unwieldy).
#'
#' @importFrom crul HttpClient url_build
#' @importFrom xml2 read_xml xml_find_all xml_text xml_name
#' @importFrom jsonlite fromJSON
#' @importFrom data.table data.table setDF rbindlist
#' @importFrom stringi stri_split_lines stri_replace_all_fixed stri_split_fixed stri_extract_all_regex
#' @docType package
#' @name bold-package
#' @aliases bold
NULL

#' List of 3 nucleotide sequences to use in examples for the
#' \code{\link{bold_identify}} function
#'
#' @details Each sequence is a character string, of lengths 410, 600, and 696.
#' @name sequences
#' @format list of length 3
#' @docType data
#' @keywords data
NULL

#' Lookup-table for IDs of taxonomic ranks
#'
#' @details
#' Used in the \code{\link{bold_tax_name-}} function.
#' Taken from the data set of the same name in the package \code{\link{taxize}}.
#'
#' This data.frame is used to do data sorting/filtering based on the ordering
#' of ranks. The format was changed so each rank name would have its own row and
#' added a column for the plural form of the names, since some function need to
#' convert them to singular.
#'
#' @name rank_ref
#' @format data.frame of 64 rows, with 3 columns:
#' \itemize{
#'   \item{rankid}{: a numeric vector of rank ids, consecutive}
#'   \item{ranks}{: a character vector of rank names}
#'   \item{order}{: a numeric vector of the ranks order (from domain to unspecified)}
#' }
#' @docType data
#' @keywords data
NULL
