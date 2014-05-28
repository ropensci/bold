#' bold: A programmatic interface to the Barcode of Life data.
#' 
#' @section About:
#' 
#' This package gives you access to data from BOLD System \url{http://www.boldsystems.org/} via 
#' their API.
#' 
#' @section Functions:
#' 
#' There are currently four functions.
#' 
#' \itemize{
#'  \item bold_specimens - Search for specimen data.
#'  \item bold_seq - Search for and retrieve sequences.
#'  \item bold_seqspec - Get sequence and specimen data together.
#'  \item bold_trace - Get trace files.
#' }
#' 
#' Interestingly, they provide xml and tsv format data for the specimen data, while they provide
#' fasta data format for the sequence data. So for the specimen data you can get back raw XML, or 
#' a data frame parsed from the tsv data, while for sequence data you get back a list (b/c 
#' sequences are quite long and would make a data frame unwieldy).
#' 
#' @docType package
#' @name bold-package
#' @aliases bold
NULL