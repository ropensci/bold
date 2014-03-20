#' Search BOLD for sequences.
#'
#' Get sequences for a taxonomic name, id, bin, container, institution, researcher, geographic 
#' place, or gene. 
#' 
#' @import httr stringr
#' @export
#' @param taxon (character) Returns all records containing matching taxa. Taxa includes the ranks of 
#' phylum, class, order, family, subfamily, genus, and species.
#' @param ids (character) Returns all records containing matching IDs. IDs include Sample IDs, 
#' Process IDs, Museum IDs and Field IDs. 
#' @param bin (character) Returns all records contained in matching BINs. A BIN is defined by a 
#' Barcode Index Number URI. 
#' @param container (character) Returns all records contained in matching projects or datasets.
#' Containers include project codes and dataset codes 
#' @param institutions (character) Returns all records stored in matching institutions. Institutions 
#' are the Specimen Storing Site. (spaces need to be encoded)
#' @param researchers (character) Returns all records containing matching researcher names. 
#' Researchers include collectors and specimen identifiers. (spaces need to be encoded)
#' @param geo (character) Returns all records collected in matching geographic sites. Geographic 
#' sites includes countries and province/states. (spaces need to be encoded)
#' @param marker (character) Returns all records containing matching marker codes. 
#' @param callopts (character) curl debugging opts passed on to httr::GET
#' @return A list with each element of length 4 with slots for id, name, gene, and sequence.
#' @examples \dontrun{
#' bold_seq(taxon='Coelioxys')
#' bold_seq(taxon='Aglae')
#' bold_seq(taxon=c('Coelioxys','Osmia'))
#' bold_seq(ids='ACRJP618-11')
#' bold_seq(ids=c('ACRJP618-11','ACRJP619-11'))
#' bold_seq(bin='BOLD:AAA5125')
#' bold_seq(container='ACRJP')
#' bold_seq(institutions='Biodiversity Institute of Ontario')
#' bold_seq(researchers='Thibaud Decaens')
#' bold_seq(geo='Ireland')
#' bold_seq(geo=c('Ireland','Denmark'))
#' bold_seq(marker='COI')
#' bold_seq(marker=c('rbcL','matK'))
#' }

bold_seq <- function(taxon = NULL, ids = NULL, bin = NULL, container = NULL, institutions = NULL, 
  researchers = NULL, geo = NULL, marker = NULL, callopts=list()) 
{
  url <- 'http://www.boldsystems.org/index.php/API_Public/sequence'
  
  args <- compact(list(taxon=pipeornull(taxon), geo=pipeornull(geo), ids=pipeornull(ids), 
                       bin=pipeornull(bin), container=pipeornull(container), 
                       institutions=pipeornull(institutions), researchers=pipeornull(researchers), 
                       marker=pipeornull(marker)))
  out <- GET(url, query=args, callopts)
  # check HTTP status code
  stop_for_status(out)
  # check mime-type (Even though BOLD folks didn't specify correctly)
  assert_that(out$headers$`content-type`=='application/x-download')
  tt <- content(out, as = "text")
  res <- strsplit(tt, ">")[[1]][-1]
  output <- lapply(res, split_fasta)
  return(output)
}

split_fasta <- function(x){
  temp <- paste(">", x, sep="")
  seq <- str_replace_all(str_split(str_replace(temp[[1]], "\n", "<<<"), "<<<")[[1]][[2]], "\n", "")
  stuff <- str_split(x, "\\|")[[1]][c(1:3)]
  list(id=stuff[1], name=stuff[2], gene=stuff[1], sequence=seq)
}

pipeornull <- function(x){
  if(!is.null(x)){ paste0(x, collapse = "|") } else { NULL }
}