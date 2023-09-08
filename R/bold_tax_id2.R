#' Search BOLD for taxonomy data by BOLD ID.
#'
#' @param id (integer|numeric|character) One or more BOLD taxonomic identifiers. required.
#' @param dataTypes (character) One or more BOLD data types: 'basic', 'stats', 'geo', 'images'/'img', 'sequencinglabs'/'labs', 'depository'/'depo', 'thirdparty'/'wiki' or 'all' (default: 'basic'). Specifies the information that will be returned, see details.
#' @param includeTree (logical) If `TRUE` (default: `FALSE`), returns the information for parent taxa as well as the specified taxon, see details.
#' @param response (logical) If `TRUE` (default: `FALSE`), returns the curl response object.
#' @section dataTypes:
#' "basic" returns basic taxonomy info: includes taxid, taxon name, tax rank, tax division, parent taxid, parent taxon name.
#' "stats" returns specimen and sequence statistics: includes public species count, public BIN count, public marker counts, public record count, specimen count, sequenced specimen count, barcode specimen count, species count, barcode species count.
#' "geo" returns collection site information: includes country, collection site map.
#' "images" returns specimen images: includes copyright information, image URL, image metadata.
#' "sequencinglabs" returns sequencing labs: includes lab name, record count.
#' "depository" returns specimen depositories: includes depository name, record count.
#' "thirdparty" returns information from third parties: includes wikipedia_summary summary, wikipedia_summary URL.
#' "all" returns all information: identical to specifying all data types at once.
#' @section includeTree:
#' When `includeTree` is set to true, for the `dataTypes` other than 'basic' the information of the parent taxa are identified by their taxonomic id only. To get their ranks and names too, make sure 'basic' is in `dataTypes`.
#' @template otherargs
#' @references
#' http://v4.boldsystems.org/index.php/resources/api?type=taxonomy
#' @seealso \code{\link{bold_tax_name}}, \code{\link{bold_get_attr}}, \code{\link{bold_get_errors}}, \code{\link{bold_get_params}}
#' @examples \dontrun{
#' bold_tax_id2(id = 88899)
#' bold_tax_id2(id = 88899, includeTree = TRUE)
#' bold_tax_id2(id = 88899, includeTree = TRUE, dataTypes = "stats")
#' bold_tax_id2(id = c(88899, 125295))
#'
#' ## dataTypes parameter
#' bold_tax_id2(id = 88899, dataTypes = "basic")
#' bold_tax_id2(id = 88899, dataTypes = "stats")
#' bold_tax_id2(id = 88899, dataTypes = "images")
#' bold_tax_id2(id = 88899, dataTypes = "geo")
#' bold_tax_id2(id = 88899, dataTypes = "sequencinglabs")
#' bold_tax_id2(id = 88899, dataTypes = "depository")
#' bold_tax_id2(id = 88899, dataTypes = "thirdparty")
#' bold_tax_id2(id = 88899, dataTypes = "all")
#' bold_tax_id2(id = c(88899, 125295), dataTypes = c("basic", "geo"))
#' bold_tax_id2(id = c(88899, 125295), dataTypes = c("basic", "stats", "images"))
#'
#' ## Passing in NA
#' bold_tax_id2(id = NA)
#' bold_tax_id2(id = c(88899, 125295, NA))
#'
#' ## get http response object only
#' bold_tax_id2(id = 88899, response = TRUE)
#' bold_tax_id2(id = c(88899, 125295), response = TRUE)
#'
#' ## curl debugging
#' bold_tax_id2(id = 88899, verbose = TRUE)
#' }
#'
#' @export
bold_tax_id2 <- function(id, dataTypes = 'basic', includeTree = FALSE,
                         response = FALSE, ...) {
    #-- arguments check
    if (missing(id)) stop("argument 'id' is missing, with no default")
    # no need to do the call if id is NA
    if (length(id) == 1 && is.na(id))
      return(data.frame(input = NA, taxid = NA))
    b_assert_logical(includeTree)
    b_assert(dataTypes, "character")
    if (is.list(id)) {
      lapply(id, b_assert, what = c("character", "numeric", "integer"), name = "id")
    } else {
      b_assert(id, c("character", "numeric", "integer"))
    }
    # for compatibility with bold_tax_id
    if (length(dataTypes) == 1 && grepl(",", dataTypes)) {
      dataTypes <- c(b_split(dataTypes, ",", fixed = TRUE, simplify = TRUE))
    }
    dataTypes <- b_assert_dataTypes(dataTypes)
    #-- prep query params
    params <- list(
      dataTypes = paste(dataTypes, collapse = ","),
      includeTree = tolower(includeTree)
    )
    #-- fetch data from the api
    res <- lapply(b_nameself(id), function(x) {
      if (!length(x) || !nzchar(x)) {
        list(response = NULL, warning = "id was empty")
      } else if (is.na(x) || grepl("^NA?$", x)) {
        list(response = NULL, warning = "id was NA")
      } else {
        r <- b_GET(query = c(taxId = x, params), api = "API_Tax/TaxonData",
                   check = TRUE, ...)
        if (nzchar(r$warning) || r$response$status_code > 202) {
          w <- xml2::read_html(r$response$content)
          w <- b_lines(xml2::xml_text(w))
          w <- w[b_detect(w, "Fatal")]
          if (b_detect(w, "non-object")) w <- c(w, "Request returned no match.")
          r$warning <- c(r$warning, w)
          r$response <- NULL
        }
        r
      }
    })
    if (response) {
      res
    } else {
      #-- make data.frame with the response(s)
      #-- fixing dataTypes to match bold response
      if (length(dataTypes) == 1 && dataTypes == "all") {
        dataTypes <- b_dataTypes[1:7]
      }
      dataTypes[dataTypes == "geo"] <- "country"
      #-- parsing bold response by id
      out <- mapply(
        b_process_tax_id,
        res,
        ids = id,
        MoreArgs = list(types = dataTypes, tree = includeTree),
        SIMPLIFY = FALSE
      )
      out <- b_format_tax_id_output(out, types = dataTypes, tree = includeTree)
      # -- add attributes to output
      w <- lapply(res, `[[`, "warning")
      attr(out, "errors") <- b_rm_empty(w)
      attr(out, "params") <- list(dataTypes = dataTypes,
                                  includeTree = includeTree)
      out
    }
  }
b_process_tax_id <- function(x, ids, types, tree) {
  if (length(x$response)) {
    out <- b_parse(x$response, format = "json", raise = FALSE)
    if (!length(out) || identical(out[[1]], list())) {
      data.frame(taxid = NA)
    } else {
      if (!tree) {
        out <- b_format_tax_id(out, ids = ids)
      } else {
        tmp <-
          lapply(b_nameself(names(out)), function(id) b_format_tax_id(out[[id]], id))
        out <-
          lapply(b_nameself(types), b_grp_dataTypes_tree, x = tmp)
        if ("basic" %in% names(out) &&
            "parentid" %in% names(out[["basic"]])) {
          out[["basic"]] <-
            out[["basic"]][order(out[["basic"]][["parentid"]]), ]
        }
      }
      out
    }
  }
}
b_format_tax_id <- function(x, ids) {
  # 'geo' isn't group like the others for some reason
  # it's split between country and site map, default
  # was to return only 'country' (although I'm not sure why),
  # so removing the sitemap
  x$sitemap <- NULL
  # some dataTypes returns data.frames or long lists
  # simplifying all of those would make the data frame very large.
  # so adjusting for the different types :
  basic.nms <- which(names(x) %in% c("taxid", "taxon", "tax_rank", "tax_division",
                                     "parentid", "parentname", "taxonrep"))
  wiki.nms <- which(names(x) %in% c("wikipedia_summary", "wikipedia_link"))
  if (length(x$stats)) {
    x$stats <- b_format_tax_id_stats(x$stats)
  }
  if (!all(is.na(basic.nms))) {
    x$basic <- data.frame(x[basic.nms])
    x <- x[-basic.nms]
  }
  if (!all(is.na(wiki.nms))) {
    x$thirdparty <- data.frame(x[wiki.nms])
    x <- x[-wiki.nms]
  }
  for (i in which(vapply(x[!names(x) %in% c("stats", "basic", "thirdparty")], class, character(1L)) == "list")) {
    x[i] <- b_format_tax_id_list(x[i], ids = ids)
  }
  x
}
b_format_tax_id_stats <- function(x) {
  if ("publicmarkersequences" %in% names(x)) {
    markers <- which(names(x) == "publicmarkersequences")
    data.frame(as.list(c(x[-markers], x[markers], recursive = TRUE)))
  } else {
    data.frame(as.list(c(x, recursive = TRUE)))
  }
}
b_format_tax_id_list <- function(x, ids) {
  lapply(
    b_nameself(names(x)),
    function(nm) {
      out <- c(x[[nm]], recursive = TRUE, use.names = TRUE)
      out <- data.table::data.table(taxid = ids, names(out), count = out)
      data.table::setnames(out, 2, nm)
      out
    }
  )
}
b_fill_empty <- function(x, types){
  len0 <- lengths(x) == 0
  if (any(len0)) {
    filler <- list(data.frame(col2rm = NA_character_))
    filler <- list(`names<-`(rep(filler, length(types)), types))
    x[which(len0)] <- filler
  }
  x
}
b_format_tax_id_output <- function(x, types, tree) {
  types <- b_nameself(types)
  #-- to match previous behavior of passing NAs
  x <- b_fill_empty(x, types)
  if (tree && length(types) == 1 &&
        !types %in% c("basic", "thirdparty", "images", "stats")) {
      x <- b_rbind(unlist(x, recursive = FALSE, use.names = T), idcol = "input")
      x$input <- as.integer(b_extract(x$input, "^[0-9]+(?=\\.)"))
  }  else {
    x <- lapply(types, b_grp_dataTypes, x = x, idcol = "input")
  }
  if (length(x) == 1) {
    x[[1]]
  } else {
    x
  }
}
b_grp_dataTypes_tree <- function(nm, x) {
  idcol <- if (nm == "stats" || nm == "thirdparty" || nm == "images") "taxid" else NULL
  out <- b_rbind(lapply(x, `[[`, nm), idcol = idcol)
  out$taxid <- as.integer(out$taxid)
  out
}
b_grp_dataTypes <- function(nm, x, idcol = FALSE) {
  out <- b_rbind(lapply(x, `[[`, nm), idcol = idcol)
  out[["input"]] <- as.integer(out[["input"]])
  out[names(out) == "col2rm"] <- NULL
  out
}
