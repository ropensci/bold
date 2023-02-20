context("bold_identify_taxonomy")

# bold_identify_list <- bold_identify(sequences = sequences$seq2)
# save(bold_identify_list, file = "tests/testthat/bold_identify_list.rda")
# load("tests/testthat/bold_identify_list.rda")
load("bold_identify_list.rda")

vcr::use_cassette("bold_identify_taxonomy", {
  test_that("bold_identify_taxonomy works as expected", {
    aa <- bold_identify_taxonomy(bold_identify_list)
    expect_is(aa, "list")
    expect_equal(length(aa), 1)
    expect_is(aa[[1]], "data.frame")
    expect_equal(NROW(aa[[1]]), 100)
    expect_is(aa[[1]]$ID, "character")
    expect_is(aa[[1]]$sequencedescription, "character")
    expect_equal(length(unique(aa[[1]]$ID)), length(aa[[1]]$ID))
  })
})

test_that("bold_identify_taxonomy fails well", {
  skip_on_cran()

  # x required
  expect_error(bold_identify_taxonomy(), "argument \"x\" is missing")

  # only supported types
  expect_error(bold_identify_taxonomy(numeric()), "method for numeric")

  # required column ID
  expect_error(bold_identify_taxonomy(mtcars),
               "no column 'ID' found in input")
})
