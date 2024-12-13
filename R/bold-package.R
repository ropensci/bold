#' @title bold
#' @description bold: A programmatic interface to the Barcode of Life data
#' @section About:
#'
#' This package gives you access to data from BOLD System
#' https://www.boldsystems.org/ via their API
#' (https://v4.boldsystems.org/index.php/api_home)
#'
#' @section Functions:
#'
#' - \code{\link{bold_specimens}} - Search for specimen data
#' - \code{\link{bold_seq}} - Search for and retrieve sequences
#' - \code{\link{bold_seqspec}} - Get sequence and specimen data together
#' - \code{\link{bold_trace}} - Get trace files - saves to disk
#' - \code{\link{read_trace}} - Read trace files into R
#' - \code{\link{bold_tax_name}} - Get taxonomic names via input names
#' - \code{\link{bold_tax_id}} - Get taxonomic names via BOLD identifiers (Deprecated)
#' - \code{\link{bold_tax_id2}} - Get taxonomic names via BOLD identifiers (improved)
#' - \code{\link{bold_identify}} - Search for match given a COI sequence
#' - \code{\link{bold_identify_parents}} - Adds guessed parent ranks (Deprecated)
#' - \code{\link{bold_identify_taxonomy}} - Adds real parent ranks.
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
#' @importFrom methods setGeneric setMethod
#' @import data.table
#' @import stringi
#' @name bold-package
#' @aliases bold
"_PACKAGE"

#' List of 3 nucleotide sequences to use in examples for the
#' \code{\link{bold_identify}} function
#'
#' @details Each sequence is a character string, of lengths 410, 600, and 696.
#' @name sequences
#' @format list of length 3
#' @docType data
#' @keywords data
NULL
