test_that("bold_trace returns the correct object", {
  skip_on_cran()
  dest.dir <- vcr::vcr_configuration()$write_disk_path
  vcr::use_cassette("bold_trace", {
    test <- bold_trace(taxon = "Bombus ignitus", geo = "Japan", dest = file.path(dest.dir, "taxon"))
  })
  expect_is(test, "boldtrace")
  expect_is(test$destfile, "character")
  expect_is(test$destdir, "character")
  expect_is(test$ab1, "character")
  expect_length(test$ab1, 6L)
  expect_is(test$args, "character")
})

test_that("bold_trace returns the correct object (with ids)", {
  skip_on_cran()
  dest.dir <- vcr::vcr_configuration()$write_disk_path
  vcr::use_cassette("bold_trace", {
    test <- bold_trace(ids = c('ACRJP618-11','ACRJP619-11'), dest = file.path(dest.dir, "ids"))
  })
  expect_is(test, "boldtrace")
  expect_is(test$destfile, "character")
  expect_is(test$destdir, "character")
  expect_is(test$ab1, "character")
  expect_length(test$ab1, 3L)
  expect_is(test$args, "character")
})


test_that("bold_trace fails well", {
  skip_on_cran()

  expect_error(bold_trace(), "You must provide a non-empty value to at least one of")
  expect_error(bold_trace(taxon = ''), "You must provide a non-empty value to at least one of")
  expect_error(bold_trace(taxon = 5, geo = 1), "'taxon' and 'geo' must be of class character.")
  expect_error(bold_trace(taxon = 'Coelioxys', overwrite = "true"), "'overwrite' must be of class logical.")
  expect_error(bold_trace(taxon = 'Coelioxys', dest = TRUE), "'dest' must be of class character.")
})
