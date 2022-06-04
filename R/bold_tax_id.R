#' Search BOLD for taxonomy data by BOLD ID.
#'
#' @export
#' @param id (integer|numeric|character) One or more BOLD taxonomic identifiers. required.
#' @param dataTypes (character) One or more BOLD data type. Specifies the
#' information that will be returned. See details for options.
#' @param includeTree (logical) If `TRUE` (default: `FALSE`), returns a list
#' containing information for parent taxa as well as the specified taxon.
#' @param response (logical) If `TRUE` (default: `FALSE`), returns the curl
#' response object.
#' @details
#' @section dataTypes
#' "basic" returns basic taxonomy info: includes taxid, taxon name, tax rank, tax division, parent taxid, parent taxon name.
#' "stats" returns specimen and sequence statistics: includes public species count, public BIN count, public marker counts, public record count, specimen count, sequenced specimen count, barcode specimen count, species count, barcode species count.
#' "geo" returns collection site information: includes country, collection site map.
#' "images" returns specimen images: includes copyright information, image URL, image metadata.
#' "sequencinglabs" returns sequencing labs: includes lab name, record count.
#' "depository" returns specimen depositories: includes depository name, record count.
#' "thirdparty" returns information from third parties: includes Wikipedia summary, Wikipedia URL.
#' "all" returns all information: identical to specifying all data types at once.
#' @template otherargs
#' @references
#' http://v4.boldsystems.org/index.php/resources/api?type=taxonomy
#' @seealso \code{\link[bold]{bold_tax_name()}}
#' @examples \dontrun{
#' bold_tax_id(id=88899)
#' bold_tax_id(id=88899, includeTree=TRUE)
#' bold_tax_id(id=88899, includeTree=TRUE, dataTypes = "stats")
#' bold_tax_id(id=c(88899,125295))
#'
#' ## dataTypes parameter
#' bold_tax_id(id=88899, dataTypes = "basic")
#' bold_tax_id(id=88899, dataTypes = "stats")
#' bold_tax_id(id=88899, dataTypes = "images")
#' bold_tax_id(id=88899, dataTypes = "geo")
#' bold_tax_id(id=88899, dataTypes = "sequencinglabs")
#' bold_tax_id(id=88899, dataTypes = "depository")
#' bold_tax_id(id=88899, dataTypes = "thirdparty")
#' bold_tax_id(id=88899, dataTypes = "all")
#' bold_tax_id(id=c(88899,125295), dataTypes = c("basic", "geo"))
#' bold_tax_id(id=c(88899,125295), dataTypes = c("basic", "stats", "images"))
#'
#' ## Passing in NA
#' bold_tax_id(id = NA)
#' bold_tax_id(id = c(88899,125295,NA))
#'
#' ## get http response object only
#' bold_tax_id(id=88899, response=TRUE)
#' bold_tax_id(id=c(88899,125295), response=TRUE)
#'
#' ## curl debugging
#' bold_tax_id(id=88899, verbose = TRUE)
#' }
bold_tax_id <- function(id, dataTypes = 'basic', includeTree = FALSE,
                        response = FALSE, ...) {
  #-- arguments check
  # no need to do the call if id is na
  if(length(id)==1 && is.na(id)) return(data.frame(input = NA, noresults = NA))
  assert(dataTypes, "character")
  assert(includeTree, "logical")
  # assert(oneRow, "logical")
  assert(id, c("character", "numeric", "integer"))

  # corrects for the json typo in case the option is taken from a previous query
  dataTypes[dataTypes == "depo"] <- "depository"
  dataTypes[dataTypes == "labs"] <- "sequencinglabs"
  if(any(wrongType <- !dataTypes %in% c("basic", "stats", "geo", "images",
                                        "sequencinglabs", "depository",
                                        "depositories", "thirdparty", "all"))){
    msg <- ' is not one of the possible dataTypes.
      \n\tOptions are:
      \n\t\t"basic", "stats", "geo", "images", "sequencinglabs (or labs)",
      "depository (or depo)","thirdparty" and "all"'
    if(sum(wrongType)>1)
      stop(toStr(dataTypes[wrongType]), msg)
    else
      stop(dataTypes[wrongType], msg)
  }

  #-- prep query params
  params <- list(
    dataTypes = if(length(dataTypes)==1) dataTypes else
      paste(dataTypes, collapse = ","),
    includeTree = tolower(includeTree)
  )
  #-- make URL
  URL <- b_url("API_Tax/TaxonData")
  # fetch data from the api
  res <- lapply(`names<-`(id, id), function(x)
    get_response(args = c(taxId = x, params), url = URL, ...))
  if (response) {
    res
  } else {
    #-- make data.frame with the response(s)
    out <- mapply(process_tax_id, res, ids = id,
                  MoreArgs = list(types = dataTypes, tree = includeTree),
                  SIMPLIFY = FALSE)
    if(length(dataTypes) == 1 && dataTypes != "all"){
       if(dataTypes %in% c("basic", "wikipedia", "images", "stats")){
        out <- setrbind(out, idcol = "input")
       } else {
        out <- Reduce(function(.x, .y) merge(.x, .y,by = dataTypes), out)
       }
    } else {
      if(!includeTree){
        dataTypes <- unique(c(lapply(out, names), recursive = TRUE))
        out <- c(b_set(out, dataTypes), b_merge(out, dataTypes))
        names(out) <- dataTypes
      }
    }
    w <- vapply(res, `[[`, "", "warning")
    # #-- add attributes to output
    attr(out, "errors") <- bc(w[nzchar(w)])
    attr(out, "params") <- c(params)#, oneRow = oneRow)
    # # this happens when the API return an empty array ([])
    # if (vapply(, NCOL, 0) == 1) {
      # out$noresults <- NA
    # }
    out
  }
}
process_tax_id <- function(x, ids, types, tree){#, oneRow){
  out <- if (nzchar(x$warning) || x$response$status_code > 202) NULL else
    jsonlite::fromJSON(rawToChar(x$response$content))
  if ( !length(out) || identical(out[[1]], list()) ) {
    data.frame(taxid  = NA, stringsAsFactors = FALSE)
  } else {
    if(!tree) {
      out <- format_tax_id(out, ids = ids)
    } else {
      tmp <- lapply(ids, format_tax_id, li = out)
      types <- unique(c(lapply(tmp, names), recursive = TRUE))
      out <- c(b_set(tmp, types), b_merge(tmp, types))
      if("basic" %in% names(out) && "parentid" %in% names(out[["basic"]])){
        out[["basic"]] <- out[["basic"]][order(out[["basic"]]$parentid),]
      }
      names(out) <- types
    }
    out
  }
}
b_set <- function(x, nms){
  toSet <- c("basic", "wikipedia", "images", "stats")
  toSet <- toSet[toSet %in% nms]
  lapply(toSet, function(z){
    setrbind(lapply(x, `[[`, z), idcol = "input")
  })
}
b_merge <- function(x, nms){
  toMerge <- c("country", "depositry", "geo", "sequencinglabs")
  toMerge <- toMerge[toMerge %in% nms]
  lapply(toMerge, function(z){
    tmp <- lapply(x, `[[`, z)
    if(any(lengths(tmp)==0)){
      tmp
    } else{
      Reduce(function(.x, .y) merge(.x, .y, by = z, all=TRUE), tmp)
    }
  })
}
format_tax_id <- function(x, ids = NULL, li = NULL){
  if(!is.null(li)){
    ids <- x
    x <- li[[as.character(x)]]
  }
  # 'geo' isn't group like the others for some reason
  # it's split between country and site map, default
  # was to return only 'country' (although I'm not sure why),
  # so removing the sitemap
  x$sitemap <- NULL
  # some dataTypes returns data.frames or long lists
  # unlisting all of those would make the data frame very large.
  tmp <- list()
  basic.names <- names(x) %in% c("taxid", "taxon", "tax_rank", "tax_division",
                                  "parentid", "parentname")
  if(length(x) > 1 && any(basic.names)){
    tmp <- c(tmp, list(basic = data.frame(x[basic.names])))
  }
  if("stats" %in% names(x)){
    dat <- data.frame(as.list(c(x[["stats"]], recursive=TRUE)))
    names(dat) <- gsub("^stats\\.|public(?=marker)","", names(dat), perl = TRUE)
    isMarker <- grepl("marker", names(dat))
    tmp <- c(tmp, list(stats = dat[c(which(!isMarker), which(isMarker))]))
    x[["stats"]] <- NULL
  }
  cls <-  vapply(x, class, "")
  if(any(isList <- cls == "list")){
    tmp <- c(tmp, `names<-`(lapply(names(x[isList]), function(nm){
      z <-c(x[[nm]], recursive=TRUE)
      `names<-`(data.frame(names(z), z, row.names = NULL),
                c(nm, paste0("count.", ids)))
    }), names(x[isList])))
  }
  if(any(isDF <- cls == "data.frame")){
    tmp <- c(tmp, `names<-`(x[isDF], names(x[isDF])))
  }
  out <- if(length(tmp)==1) tmp[[1]] else tmp
}
