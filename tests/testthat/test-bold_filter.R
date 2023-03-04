context("bold_filter")

test_that("bold_filter works as expected", {
  vcr::use_cassette("bold_seqspec", {
    test_data <- bold_seqspec(taxon = "Coelioxys")
  })

  # max
  test <- bold_filter(test_data, by = "species_name")

  expect_is(test, "data.frame")
  expect_gt(NROW(test), 10)
  expect_gt(NCOL(test), 10)
  expect_equal(length(unique(test$species_name)), NROW(test))

  # actually got max
  taxon <- "Coelioxys elongata"
  o_lens <- nchar(test_data[test_data$species_name == taxon, "nucleotides", drop = TRUE])
  new_lens <- nchar(test[test$species_name == taxon, "nucleotides", drop = TRUE])
  expect_equal(new_lens, max(o_lens))


  # min
  test <- bold_filter(as.matrix(test_data), by = "species_name", how = "min")

  expect_is(test, "data.frame")
  expect_gt(NROW(test), 10)
  expect_gt(NCOL(test), 10)
  expect_equal(length(unique(test$species_name)), NROW(test))

  # actually got max
  new_lens <- nchar(test[test$species_name == taxon, "nucleotides", drop = TRUE])
  expect_equal(new_lens, min(o_lens))
})

test_that("bold_filter returns fails well", {
  expect_error(bold_filter(), "argument \"x\" is missing")
  expect_error(bold_filter(x = 5, by = 1), "'x' must be of class data.frame or matrix.")
  expect_error(bold_filter(x = mtcars, by = "foobar"),
               "'foobar' is not a valid column in 'x'")
  expect_error(bold_filter(x = mtcars, "mpg", "adf"),
               "'how' must be one of 'min' or 'max'")
})
