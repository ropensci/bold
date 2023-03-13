context("bold_identify_parents")

# bold_identify_list <- bold_identify(sequences = sequences$seq2)
# save(bold_identify_list, file = "tests/testthat/bold_identify_list.rda")
# load("tests/testthat/bold_identify_list.rda")
load("bold_identify_list.rda")

test_that("bold_identify_parents works as expected", {
  vcr::use_cassette("bold_identify_parents", {
    test <- bold_identify_parents(bold_identify_list)
  })
  expect_is(test, "list")
  expect_equal(length(test), 1)
  expect_is(test[[1]], "data.frame")
  expect_gt(NROW(test[[1]]), 100)
  expect_is(test[[1]]$ID, "character")
  expect_is(test[[1]]$sequencedescription, "character")
  expect_lt(length(unique(test[[1]]$ID)), length(test[[1]]$ID))
})

test_that("bold_identify_parents return response", {
  vcr::use_cassette("bold_identify_parents", {
    test <- bold_identify_parents(bold_identify_list, wide = TRUE)
  })
  expect_is(test, "list")
  expect_equal(length(test), 1)
  expect_is(test[[1]], "data.frame")
  expect_gt(NROW(test[[1]]), 10)
  expect_equal(length(unique(test[[1]]$ID)), length(test[[1]]$ID))
})

test_that("bold_identify_parents fails well", {
  # x required
  expect_error(bold_identify_parents(), "argument \"x\" is missing")
  # only supported types
  expect_error(bold_identify_parents(matrix()), "method for matrix")
  # required column taxonomicidentification
  expect_error(
    expect_warning(bold_identify_parents(mtcars),
                   "'bold_identify_parents' is deprecated"),
    "no fields 'taxonomicidentification' found in input")
  # catch wrong type param inputs
  expect_warning(bold_identify_parents(bold_identify_list[[1]][1,], tax_rank = 5),
    "'tax_rank' should be of class character")
})
