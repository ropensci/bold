#' @section Large requests:
#' Some requests can lead to errors. These often have to do with requesting
#' data for a rank that is quite high in the tree, such as an Order,
#' for example, Coleoptera. If your request is taking a long time,
#' it's likely that something will go wrong on the BOLD server side,
#' or we'll not be able to parse the result here in R because
#' R can only process strings of a certain length. \code{bold}
#' users have reported errors in which the resulting response from
#' BOLD is so large that we could not parse it. 
#' 
#' A good strategy for when you want data for a high rank is to
#' do many separate requests for lower ranks within your target
#' rank. You can do this manually, or use the function 
#' \code{taxize::downstream} to get all the names of a lower
#' rank within a target rank. There's an example in the README
#' (https://docs.ropensci.org/bold/#large-data)
#' 
#' @section If a request times out:
#' This is likely because you're request was for a large number of 
#' sequences and the BOLD service timed out. You still should get 
#' some output, those sequences that were retrieved before the time 
#' out happened. As above, see the README
#' (https://docs.ropensci.org/bold/#large-data) for an example of
#' dealing with large data problems with this function.
