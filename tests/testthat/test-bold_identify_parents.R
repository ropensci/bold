context("bold_identify_parents")

# bold_identify_list <- bold_identify(sequences = sequences$seq2)
# save(bold_identify_list, file = "tests/testthat/bold_identify_list.rda")
# load("tests/testthat/bold_identify_list.rda")
load("bold_identify_list.rda")

vcr::use_cassette("bold_identify_parents", {
  test_that("bold_identify_parents works as expected", {
    aa <- bold_identify_parents(bold_identify_list)
    expect_is(aa, "list")
    expect_equal(length(aa), 1)
    expect_is(aa[[1]], "data.frame")
    expect_gt(NROW(aa[[1]]), 100)
    expect_is(aa[[1]]$ID, "character")
    expect_is(aa[[1]]$sequencedescription, "character")
    expect_lt(length(unique(aa[[1]]$ID)), length(aa[[1]]$ID))
  })
})

vcr::use_cassette("bold_identify_parents_wide", {
  test_that("bold_identify_parents return response", {
    aa <- bold_identify_parents(bold_identify_list, wide = TRUE)
    expect_is(aa, "list")
    expect_equal(length(aa), 1)
    expect_is(aa[[1]], "data.frame")
    expect_gt(NROW(aa[[1]]), 10)
    expect_equal(length(unique(aa[[1]]$ID)), length(aa[[1]]$ID))
  })
})

test_that("bold_identify_parents fails well", {
  skip_on_cran()

  # x required
  expect_error(bold_identify_parents(), "argument \"x\" is missing")

  # only supported types
  expect_error(bold_identify_parents(matrix()), "method for matrix")

  # required column taxonomicidentification
  expect_error(bold_identify_parents(mtcars),
    "no fields 'taxonomicidentification' found in input")
})

test_that("bold_identify_parents: catch wrong type param inputs", {
  skip_on_cran()
  
  vcr::use_cassette("bold_identify_parents_wrong_type", {
    w <- bold_seq(ids = "COLNO026-09")
    ww <- bold_identify(w$sequence)
  })

  expect_error(bold_identify_parents(ww[[1]][1, ], tax_rank = 5),
    "tax_rank must be of class character")
})
