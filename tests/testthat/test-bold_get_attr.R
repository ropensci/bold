context("bold_get_attr")

if (!interactive() &&
    !isTRUE(as.logical(Sys.getenv("NOT_CRAN", "false")))) {
  test_that("bold_get_* return the correct objects from bold_tax_id2", {
    vcr::use_cassette("bold_tax_id2", {
      test_id <- bold_tax_id2(id = c(88899, NA))
    })
    test <- bold_get_attr(test_id)
    expect_is(test, "list")
    expect_length(test, 2L)
    expect_named(test, c("errors", "params"))
    expect_is(test$errors, "list")
    expect_is(test$params, "list")
    expect_is(test$errors[[1]], "character")
    expect_is(test$params$dataTypes, "character")
    expect_is(test$params$includeTree, "logical")
    test <- bold_get_errors(test_id)
    expect_is(test, "list")
    expect_length(test, 1L)
    expect_is(test[[1]], "character")
    test <- bold_get_params(test_id)
    expect_is(test, "list")
    expect_length(test, 2L)
    expect_is(test$dataTypes, "character")
    expect_is(test$includeTree, "logical")
  })
  
  test_that("bold_get_* return the correct objects from bold_tax_name", {
    vcr::use_cassette("bold_tax_name", {
      test_name <- bold_tax_name(
        name = c("Apis", "Puma concolor", "Pinus concolor"),
        tax_division = "Animalia"
      )
    })
    test <- bold_get_attr(test_name)
    expect_is(test, "list")
    expect_length(test, 2L)
    expect_named(test, c("errors", "params"))
    expect_is(test$errors, "list")
    expect_is(test$params, "list")
    expect_is(test$errors$`Pinus concolor`, "character")
    expect_is(test$params$fuzzy, "logical")
    expect_is(test$params$tax_division, "character")
    expect_is(test$params$tax_rank, "NULL")
    test <- bold_get_errors(test_name)
    expect_is(test, "list")
    expect_length(test, 1L)
    expect_is(test[[1]], "character")
    test <- bold_get_params(test_name)
    expect_is(test, "list")
    expect_length(test, 3L)
    expect_is(test$fuzzy, "logical")
    expect_is(test$tax_division, "character")
    expect_is(test$tax_rank, "NULL")
  })
  
  test_that("bold_get_* fails well", {
    expect_error(bold_get_attr(), "argument 'x' is missing, with no default")
    expect_error(bold_get_errors(), "argument 'x' is missing, with no default")
    expect_error(bold_get_params(), "argument 'x' is missing, with no default")
  })
}
