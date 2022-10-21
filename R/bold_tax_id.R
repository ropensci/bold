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
#' "thirdparty" returns information from third parties: includes wikipedia_summary summary, wikipedia_summary URL.
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
bold_tax_id <-
  function(id,
           dataTypes = 'basic',
           includeTree = FALSE,
           response = FALSE,
           ...) {
    #-- arguments check
    # no need to do the call if id is na
    if (length(id) == 1 &&
        is.na(id))
      return(data.frame(input = NA, noresults = NA))
    assert(dataTypes, "character")
    assert(includeTree, "logical")
    # assert(oneRow, "logical")
    assert(id, c("character", "numeric", "integer"))

    # corrects for the json typo in case the option is taken from a previous query
    dataTypes[dataTypes == "depo"] <- "depository"
    dataTypes[dataTypes == "depositories"] <- "depository"
    dataTypes[dataTypes == "labs"] <- "sequencinglabs"
    if (any(
      wrongType <- !dataTypes %in% c(
        "basic",
        "stats",
        "geo",
        "images",
        "sequencinglabs",
        "depository",
        "thirdparty",
        "all"
      )
    )) {
      msg <- ' is not one of the possible dataTypes.
      \n\tOptions are:
      \n\t\t"basic", "stats", "geo", "images", "sequencinglabs (or labs)",
      "depository (or depo)","thirdparty" and "all"'
      if (sum(wrongType) > 1)
        stop(toStr(dataTypes[wrongType]), msg)
      else
        stop(dataTypes[wrongType], msg)
    }

    #-- prep query params
    params <- list(
      dataTypes = paste(dataTypes, collapse = ","),
      includeTree = tolower(includeTree)
    )

    #-- make URL
    URL <- b_url("API_Tax/TaxonData")

    #-- fetch data from the api
    res <- lapply(`names<-`(id, id), function(x)
      get_response(args = c(taxId = x, params), url = URL, ...))
    if (response) {
      res
    } else {
      #-- make data.frame with the response(s)
      out <- mapply(
        process_tax_id,
        res,
        ids = id,
        MoreArgs = list(types = dataTypes, tree = includeTree),
        SIMPLIFY = FALSE
      )
      if (length(dataTypes) == 1) {
        if (dataTypes %in% c("basic", "thirdparty", "images", "stats")) {
          out <- b_set(out, dataTypes, idcol = "input")
        } else {
          out <- Reduce(function(.x, .y) {
            o <- merge(.x,
                       .y,
                       by = c("taxid", names(out), "count"),
                       all = TRUE)
            o[order(o[, "count"], decreasing = TRUE),]
          }, lapply(out, `[[`, names(out)))
        }
      } else if (length(dataTypes) > 1 || dataTypes == "all") {
        if (!includeTree) {
          out <- b_set(out, idcol = "input")
        }
      }
      w <- vapply(res, `[[`, "", "warning")


      # -- add attributes to output
      attr(out, "errors") <- bc(w[nzchar(w)])
      attr(out, "params") <- c(params)
      #-- this happens when the API return an empty array ([])
      # if (any(lengths(out) == 0)) {
      # attr(out, "empty") <- id[lengths(out)]
      out
    }
  }
process_tax_id <- function(x, ids, types, tree) {
  out <-
    if (nzchar(x$warning) || x$response$status_code > 202)
      NULL
  else
    jsonlite::fromJSON(rawToChar(x$response$content))
  if (!length(out) || identical(out[[1]], list())) {
    data.frame(taxid  = NA, stringsAsFactors = FALSE)
  } else {
    if (!tree) {
      out <- format_tax_id(out, ids = ids)
    } else {
      tmp <- lapply(names(out), \(id) format_tax_id(out[[id]], id))
      out <- b_set(tmp)
      if ("basic" %in% names(out) &&
          "parentid" %in% names(out[["basic"]])) {
        out[["basic"]] <-
          out[["basic"]][order(out[["basic"]][["parentid"]]), ]
      }
    }
  }
  out
}
b_set <- function(x, nms = NULL, idcol = FALSE) {
  if (missing(nms)) nms <- unique(c(lapply(x, names), recursive = TRUE))
  out <- lapply(nms, function(nm) {
    setrbind(lapply(x, `[[`, nm), idcol = idcol)
  })
  `names<-`(out, nms)
}
format_tax_id <- function(x, ids) {
  # 'geo' isn't group like the others for some reason
  # it's split between country and site map, default
  # was to return only 'country' (although I'm not sure why),
  # so removing the sitemap
  x$sitemap <- NULL
  # some dataTypes returns data.frames or long lists
  # flattening all of those would make the data frame very large.
  x <- checkIfIs(x, "basic")
  x <- checkIfIs(x, "thirdparty")
  x <- checkIfIs(x, "stats")
  x <- checkIfIs(x, "list")
  x
}
format_tax_id_stats <- function(x) {
  dat <- data.frame(as.list(c(x, recursive = TRUE)))
  names(dat) <-
    gsub("^stats\\.|public(?=marker)", "", names(dat), perl = TRUE)
  isMarker <- grepl("marker", names(dat))
  dat[c(which(!isMarker), which(isMarker))]
}
format_tax_id_list <- function(x, ids) {
  lapply(names(x), function(nm) {
    z <- c(x[[nm]], recursive = TRUE, use.names = TRUE)
    `names<-`(data.frame(ids, names(z), z, row.names = NULL),
              c("taxid", nm, "count"))
  })
}
checkIfIs <- function(x, what = NULL, ids = NULL) {
  .is <- switch(
    what,
    basic = names(x) %in% c("taxid", "taxon", "tax_rank", "tax_division",
                            "parentid", "parentname", "taxonrep"),
    thirdparty = names(x) %in% c("wikipedia_summary", "wikipedia_link"),
    stats = names(x) == "stats",
    list = vapply(x, class, character(1L)) == "list"
  )

  if (any(.is)) {
    x <- switch(what,
                stats = {
                  x[["stats"]] <- format_tax_id_stats(x[["stats"]])
                  x
                },
                list = {
                  x[.is] <- lapply(x[.is], format_tax_id_list, ids = ids)
                  x
                },
                {
                  x[[what]] <- data.frame(x[.is])
                  if (sum(.is) > 1)
                    x[c(.is, F)] <- NULL
                  else
                    x[[1]] <- NULL
                  x
                })
  }
  x
}
