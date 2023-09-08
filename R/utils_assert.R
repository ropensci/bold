b_assert <- function(x,
                     what,
                     name = NULL,
                     check.length = NULL) {
  if (!length(name)) {
    name <- substitute(x)
  }
  msgLen <- if (length(check.length) && !isFALSE(check.length)) {
      b_assert_length(x = x, len = check.length, name = name,
                      stopOnFail = length(x) > 0)
  } else {
    NULL
  }
  msgClass <- if (length(x)) {
    b_assert_class(x = x, what = what, name = name,
                   is2nd = length(msgLen), stopOnFail = FALSE)
  } else {
    NULL
  }
  msg <- c(msgLen, msgClass)
  if (length(msg)) {
    stop(msg, call. = FALSE)
  }
}
b_assert_class <- function(x, what, name, is2nd = FALSE, stopOnFail = TRUE) {
  .fun <- if (stopOnFail) stop else paste0
  if (!inherits(x = x, what = what)) {
    if (!is2nd)
      .fun("'", name, "' must be of class ", b_ennum(what, "or"))
    else
      .fun(" and of class ", b_ennum(what, "or"))
  } else {
    NULL
  }
}
b_assert_length <- function(x, len, name, stopOnFail = TRUE) {
  len <- as.integer(len)
  if (!is.na(len) && len >= 0) {
    .fun <- if (stopOnFail) stop else paste0
    if (len == 0 && !length(x)) {
      .fun("'", name, "' can't be empty")
    } else if (len > 0 && length(x) != len) {
      .fun("'", name, "' must be length ", len)
    }
  }
}
b_assert_logical <- function(x, name = NULL) {
  b_assert_length(x, len = 1L, name = name)
  if (!length(name)) name <- substitute(x)
  x <- tolower(x)
  if (x == "true" || x == "1")
    TRUE
  else if (x == "false" || x == "0" || x == "na")
    FALSE
  else
    stop("'", name, "' should be one of TRUE or FALSE")
}
b_validate <- function(x, choices, name){
  wrong <- !x %in% choices
  if (any(wrong)) {
    stop(
      b_ennum(x[wrong], quote = TRUE),
      if (sum(wrong) > 1)
        " are not valid "
      else
        " is not a valid ",
      name,
      "\nChoices are ",
      b_ennum(choices, join_word = "or", quote = TRUE),
      call. = FALSE
    )
  }
}
b_get_db <- function(x){
  opts <- list(case_insensitive = TRUE)
  if (b_detect(x, '^COX[1I]$', opts_regex = opts))
    "COX1"
  else if (b_detect(x, '^pub(lic)?$|_public$', opts_regex = opts))
    "COX1_SPECIES_PUBLIC"
  else if (b_detect(x, '^spe(cies)?$|_species$', opts_regex = opts))
    "COX1_SPECIES"
  else if (b_detect(x, '^(cox[1I]_)?(l640)?bp$', opts_regex = opts))
    "COX1_L640bp"
  else
    x
}
b_assert_db <- function(x){
  b_assert(x, "character", name = "db", check.length = 1L)
  x <- b_get_db(x)
  b_validate(x, choices = b_db, name = "db")
  x
}
b_get_tax_division <- function(x){
  x <- tolower(x)
  x[b_detect(x, '^animal')] <- "Animalia"
  x[b_detect(x, '^prot')] <- "Protista"
  x[b_detect(x, '^fun')] <- "Fungi"
  x[b_detect(x, '^plant')] <- "Plantae"
  x
}
b_assert_tax_division <- function(x){
  if (length(x)) {
    b_assert(x, what = "character", name = "tax_division")
    x <- b_get_tax_division(x)
    b_validate(x, choices = b_tax_division, name = "tax_division")
  }
  x
}
b_get_tax_rank <- function(x){
  x <- tolower(x)
  x[b_detect(x, '^king')] <- "kingdom"
  x[b_detect(x, '^phy')] <- "phylum"
  x[b_detect(x, '^cla')] <- "class"
  x[b_detect(x, '^ord')] <- "order"
  x[b_detect(x, '^fam')] <- "family"
  x[b_detect(x, '^subfam')] <- "subfamily"
  x[b_detect(x, '^tribe')] <- "tribe"
  x[b_detect(x, '^gen')] <- "genus"
  x[b_detect(x, '^spe')] <- "species"
  x[b_detect(x, '^subspe')] <- "subspecies"
  x
}
b_assert_tax_rank <- function(x){
  if (length(x)) {
    b_assert(x, what = "character", name = "tax_rank")
    x <- b_get_tax_rank(x)
    b_validate(x, choices = b_tax_rank, name = "tax_rank")
  }
  x
}
b_assert_format <- function(x){
  b_assert(x, what = "character", check.length = 1L, name = "format")
  x <- tolower(x)
  if (x != "xml" && x != "tsv")
    stop("'format' should be one of 'xml' or 'tsv'")
  else
    x
}
b_get_dataTypes <- function(x){
  x <- tolower(x)
  if (any(x == "all")) {
    x <- "all"
  } else {
    # corrects for the json typo in case the option is taken from a previous query
    # and for short versions/typos
    x[x == "basics"] <- "basic"
    x[x == "depo" | x == "depositories"] <- "depository"
    x[x == "labs" | x == "sequencinglab"] <- "sequencinglabs"
    x[x == "stat"] <- "stats"
    x[x == "img"] <- "images"
    x[x == "wiki"] <- "thirdparty"
  }
  x
}
b_assert_dataTypes <- function(x){
  b_assert(x, what = "character", name = "dataTypes", check.length = 0L)
  x <- b_get_dataTypes(x)
  b_validate(x, choices = b_dataTypes, name = "dataTypes")
  x
}
