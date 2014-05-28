#' @param taxon (character) Returns all records containing matching taxa. Taxa includes the ranks of 
#' phylum, class, order, family, subfamily, genus, and species.
#' @param ids (character) Returns all records containing matching IDs. IDs include Sample IDs, 
#' Process IDs, Museum IDs and Field IDs. 
#' @param bin (character) Returns all records contained in matching BINs. A BIN is defined by a 
#' Barcode Index Number URI. 
#' @param container (character) Returns all records contained in matching projects or datasets.
#' Containers include project codes and dataset codes 
#' @param institutions (character) Returns all records stored in matching institutions. Institutions 
#' are the Specimen Storing Site.
#' @param researchers (character) Returns all records containing matching researcher names. 
#' Researchers include collectors and specimen identifiers.
#' @param geo (character) Returns all records collected in matching geographic sites. Geographic 
#' sites includes countries and province/states.
#' @param response (logical) Note that response is the object that returns from the Curl call, 
#' useful for debugging, and getting detailed info on the API call. 
#' @param callopts (character) curl debugging opts passed on to httr::GET