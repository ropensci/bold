context("bold_identify_taxonomy")

# bold_identify_list <- bold_identify(sequences = sequences$seq2)
# save(bold_identify_list, file = "tests/testthat/bold_identify_list.rda")
# load("tests/testthat/bold_identify_list.rda")
# load("bold_identify_list.rda")

test_that("bold_identify_taxonomy works as expected", {
  vcr::use_cassette("bold_identify_taxonomy", {
    test <- bold_identify_taxonomy(bold_identify_list)
  })
  expect_is(test, "list")
  expect_equal(length(test), 1)
  expect_is(test[[1]], "data.frame")
  expect_equal(NROW(test[[1]]), 100)
  expect_is(test[[1]]$ID, "character")
  expect_is(test[[1]]$sequencedescription, "character")
  expect_equal(length(unique(test[[1]]$ID)), length(test[[1]]$ID))
})

test_that("bold_identify_taxonomy works as expected (taxOnly TRUE)", {
  vcr::use_cassette("bold_identify_taxonomy", {
    test <<- bold_identify_taxonomy(bold_identify_list)
  })
  expect_is(test, "list")
  expect_equal(length(test), 1)
  expect_is(test[[1]], "data.frame")
  expect_equal(NROW(test[[1]]), 100)
  expect_equal(NCOL(test[[1]]), 24)
  expect_is(test[[1]]$ID, "character")
  expect_is(test[[1]]$sequencedescription, "character")
  expect_equal(length(unique(test[[1]]$ID)), length(test[[1]]$ID))
})
test_that("bold_identify_taxonomy works as expected (taxOnly FALSE)", {
  vcr::use_cassette("bold_identify_taxonomy", {
    test <- bold_identify_taxonomy(bold_identify_list, taxOnly = FALSE)
  })
  expect_is(test, "list")
  expect_equal(length(test), 1)
  expect_is(test[[1]], "data.frame")
  expect_equal(NROW(test[[1]]), 100)
  expect_gt(NCOL(test[[1]]), 24)
  expect_is(test[[1]]$ID, "character")
  expect_is(test[[1]]$sequencedescription, "character")
  expect_equal(length(unique(test[[1]]$ID)), length(test[[1]]$ID))
})

test_that("bold_identify_taxonomy fails well", {
  skip_on_cran()

  # x required
  expect_error(bold_identify_taxonomy(), "argument \"x\" is missing")
  # only supported types
  expect_error(bold_identify_taxonomy(numeric()), "method for numeric")
  expect_error(bold_identify_taxonomy(x = bold_identify_list, taxOnly = "true"), "method for numeric")
  # required column ID
  expect_error(bold_identify_taxonomy(mtcars),
               "no column 'ID' found in input")
})
