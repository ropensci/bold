context("bold_tax_id")

vcr::use_cassette("bold_tax_id", {
  test_that("bold_tax_id returns the correct classes", {
    skip_on_cran()

    test <- bold_tax_id(88899)
    expect_is(test, "data.frame")
    expect_is(test$input, "numeric")
    expect_is(test$taxid, "integer")
    expect_is(test$tax_rank, "character")

    test <- bold_tax_id(125295)
    expect_is(test, "data.frame")

    test <- bold_tax_id(c(88899, 125295))
    expect_is(test, "data.frame")
    expect_equal(NROW(test), 2)
    expect_equal(test$taxid, test$input)
  })
}, match_requests_on = c("method", "uri", "query"))

vcr::use_cassette("bold_tax_id_datatypes", {
  test_that("bold_tax_id dataTypes param works as expected", {
    skip_on_cran()

    test <- bold_tax_id(88899, dataTypes = "stats")
    expect_is(test, "data.frame")
    expect_equal(NROW(test), 1)

    test <- bold_tax_id(660837, dataTypes = "stats")       # no public marker sequences
    expect_is(test, "data.frame")
    expect_equal(NROW(test), 1)

    test <- bold_tax_id(88899, dataTypes = "geo")
    expect_is(test, "data.frame")
    expect_equal(NROW(test), 8)
    expect_named(test, c("input", "taxid", "country", "count"))

    test <- bold_tax_id(88899, dataTypes = "sequencinglabs")
    expect_is(test, "data.frame")
    expect_equal(NROW(test), 9)
    expect_named(test, c("input", "taxid", "sequencinglabs", "count"))

    test <- bold_tax_id(660837, dataTypes = c("basic","stats")) # no public marker sequences
    expect_is(test, "list")
    expect_is(test[[1]], "data.frame")
    expect_is(test[[2]], "data.frame")
    expect_equal(NROW(test[[1]]), 1)
    expect_is(attr(test, "param"), "list")
    expect_length(attr(test, "param"), 2)
  })
}, match_requests_on = c("method", "uri", "query"))


vcr::use_cassette("bold_tax_id_includetree_param", {
  test_that("includeTree param works as expected", {
    skip_on_cran()

    test <- bold_tax_id(id = 88899, includeTree = TRUE)
    expect_is(test, "data.frame")
    expect_equal(NROW(test), 5)

    test <- bold_tax_id(id = 88899, dataTypes = c("basic", "geo"), includeTree = TRUE)
    expect_is(test, "list")
    expect_is(test[[1]], "data.frame")
    expect_is(test[[2]], "data.frame")
    expect_equal(NROW(test[[1]]), 5)
    expect_true(all(test[[1]]$taxid %in% unique(test[[2]]$taxid)))
  })
})

test_that("bold_tax_id fails well", {
  skip_on_cran()
  expect_error(bold_tax_id(), "argument \"id\" is missing, with no default")
})
