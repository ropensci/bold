#' @title Lookup-table for IDs of taxonomic ranks
#'
#' @details
#' Taken from the data set of the same name in the package \link{taxize}.
#'
#' We use this data.frame to do data sorting/filtering based on the ordering
#' of ranks. We change the format so each rank name would have its own row and
#' added a column for the plural form of the names, since some function need to
#' convert them to singular.
#'
#' @format data.frame of 64 rows, with 3 columns:
#'
#' \itemize{
#'   \item{rankid}{a numeric vector of rank ids, consecutive}
#'   \item{ranks}{a character vector of rank names}
#'   \item{order}{a numeric vector of the ranks order (from domain to unspecified)}
#' }
#'
"rank_ref"
