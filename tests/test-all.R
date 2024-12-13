if (!interactive() && !isTRUE(as.logical(Sys.getenv("NOT_CRAN", "false")))) {
  library(testthat)
  test_check('bold')
}
