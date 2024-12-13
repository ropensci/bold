context("bold_tax_id")

if (!(!interactive() && !identical(Sys.getenv("NOT_CRAN"), "true")))  {
  test_that("bold_tax_id returns the correct object (one ID)", {
    vcr::use_cassette("bold_tax_id2", {
      test <- suppressWarnings(bold_tax_id(id = 88899))
    })
    expect_is(test, "data.frame")
    expect_is(test$input, "numeric")
    expect_is(test$taxid, "integer")
    expect_is(test$tax_rank, "character")
    expect_equal(test$taxid, test$input)
    expect_equal(NROW(test), 1)
  })
  test_that("bold_tax_id returns the correct object (multiple IDs)", {
    vcr::use_cassette("bold_tax_id2", {
      test <- suppressWarnings(bold_tax_id(id = c(88899, 125295)))
    })
    expect_is(test, "data.frame")
    expect_equal(NROW(test), 2)
    expect_equal(test$taxid, test$input)
  })
  test_that("bold_tax_id returns the correct object (multiple IDs, but one NA)",
            {
              vcr::use_cassette("bold_tax_id2", {
                test <- suppressWarnings(bold_tax_id(id = c(88899, 125295, NA)))
              })
              expect_is(test, "data.frame")
              expect_equal(NROW(test), 3)
              expect_equal(test$taxid, test$input)
            })
  
  test_that("bold_tax_id returns the correct object (one ID, but NA)", {
    test <- suppressWarnings(bold_tax_id(id = NA))
    expect_is(test, "data.frame")
    expect_equal(NROW(test), 1)
    expect_length(test, 2)
    expect_named(test, c("input", "noresults"))
  })
  
  test_that("bold_tax_id returns the correct object (response)", {
    vcr::use_cassette("bold_tax_id2", {
      test <- suppressWarnings(bold_tax_id(id = 88899, response = TRUE))
    })
    expect_is(test, "list")
    test <- test[["88899"]]
    expect_is(test, "HttpResponse")
    expect_equal(test$status_code, 200)
    expect_equal(test$response_headers$`content-type`,
                 "text/html; charset=utf-8")
    expect_is(test$response_headers, "list")
  })
  
  test_that("bold_tax_id 'dataTypes' param works as expected (stats)", {
    vcr::use_cassette("bold_tax_id2", {
      test <- suppressWarnings(bold_tax_id(id = 88899, dataTypes = "stats"))
    })
    expect_is(test, "data.frame")
    expect_equal(NROW(test), 1)
  })
  test_that("bold_tax_id 'dataTypes' param works as expected (stats without public marker seqs)",
            {
              vcr::use_cassette("bold_tax_id2", {
                test <- suppressWarnings(bold_tax_id(id = 660837, dataTypes = "stats"))
              })
              expect_is(test, "data.frame")
              expect_equal(NROW(test), 1)
            })
  test_that("bold_tax_id 'dataTypes' param works as expected (geo)", {
    vcr::use_cassette("bold_tax_id2", {
      test <- suppressWarnings(bold_tax_id(id = 88899, dataTypes = "geo"))
    })
    expect_is(test, "data.frame")
    expect_equal(NROW(test), 1)
    expect_equal(ncol(test), 9)
  })
  test_that("bold_tax_id 'dataTypes' param works as expected (sequencinglabs)",
            {
              vcr::use_cassette("bold_tax_id2", {
                test <- suppressWarnings(bold_tax_id(id = 88899, dataTypes = "sequencinglabs"))
              })
              expect_is(test, "data.frame")
              expect_equal(NROW(test), 1)
            })
  test_that("bold_tax_id 'dataTypes' param works as expected (all)", {
    vcr::use_cassette("bold_tax_id2", {
      test <- suppressWarnings(bold_tax_id(id = 88899, dataTypes = "all"))
    })
    expect_is(test, "data.frame")
    expect_equal(NROW(test), 1)
  })
  test_that("bold_tax_id 'dataTypes' param works as expected (basic & stats)",
            {
              vcr::use_cassette("bold_tax_id2", {
                test <- suppressWarnings(bold_tax_id(id = 660837, dataTypes = c("basic,stats")))
              })
              expect_is(test, "data.frame")
              expect_equal(NROW(test), 1)
            })
  test_that("bold_tax_id 'includeTree' param works as expected", {
    vcr::use_cassette("bold_tax_id2", {
      test <- suppressWarnings(bold_tax_id(id = 88899, includeTree = TRUE))
    })
    expect_is(test, "data.frame")
    expect_equal(NROW(test), 5)
  })
  test_that("bold_tax_id 'includeTree' param works as expected (with 2 dataTypes)",
            {
              vcr::use_cassette("bold_tax_id2", {
                test <- suppressWarnings(bold_tax_id(id = 88899,
                                    dataTypes = "basic,geo",
                                    includeTree = TRUE))
              })
              expect_is(test, "data.frame")
              expect_equal(NROW(test), 5)
            })
  test_that("bold_tax_id fails well", {
    expect_error(suppressWarnings(bold_tax_id()), "argument 'id' is missing, with no default")
    expect_warning(bold_tax_id(id = 88899, dataTypes = 5),
                   "'5' is not a valid data type")
    expect_warning(bold_tax_id(id = 88899, dataTypes = "basics"),
                   "'basics' is not a valid data type")
    expect_warning(
      bold_tax_id(id = 88899, includeTree = 5),
      "'includeTree' should be either TRUE or FALSE"
    )
    expect_warning(bold_tax_id(id = ""), "'bold_tax_id' is deprecated")
  })
}
