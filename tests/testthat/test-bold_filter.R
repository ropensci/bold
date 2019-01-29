context("bold_filter")

test_that("bold_filter works as expected", {
  vcr::use_cassette("bold_filter", {
    res <- bold_seqspec(taxon = "Osmia")
  })
  
  # max
  a <- bold_filter(res, by = "species_name")
  
  expect_is(a, "data.frame")
  expect_gt(NROW(a), 10)
  expect_gt(NCOL(a), 10)
  expect_equal(length(unique(a$species_name)), NROW(a))

  # actually got max
  taxon <- "Osmia bicolor"
  o_lens <- unname(vapply(res[res$species_name == taxon, "nucleotides"],
    nchar, 1))
  new_lens <- unname(vapply(a[a$species_name == taxon, "nucleotides"],
    nchar, 1))
  expect_equal(new_lens, max(o_lens))


  # min
  amin <- bold_filter(res, by = "species_name", how = "min")
  
  expect_is(amin, "data.frame")
  expect_gt(NROW(amin), 10)
  expect_gt(NCOL(amin), 10)
  expect_equal(length(unique(amin$species_name)), NROW(amin))

  # actually got max
  new_lens <- unname(vapply(amin[amin$species_name == taxon, "nucleotides"],
    nchar, 1))
  expect_equal(new_lens, min(o_lens))
})

test_that("bold_filter returns correct error when params empty or not given", {
  skip_on_cran()
  
  expect_error(bold_filter(), "argument \"x\" is missing")
  expect_error(bold_filter(5), "'x' must be a data.frame")
  expect_error(bold_filter(mtcars, "foobar"), 
    "'foobar' is not a valid column in 'x'")
  expect_error(bold_filter(mtcars, "mpg", "adf"), 
    "'how' must be one of 'min' or 'max'")
})
