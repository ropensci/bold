context("bold_trace")
# vcr::vcr_configure(write_disk_path = "D:\\02_rOpenSci\\bold\\tests\\bold_trace_files")
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
test_that("print.bold_trace prints properly", {
  skip_on_cran()
  dest.dir <- vcr::vcr_configuration()$write_disk_path
  vcr::use_cassette("bold_trace", {
    test <- bold_trace(taxon = "Bombus ignitus", geo = "Japan", dest = file.path(dest.dir, "taxon"))
  })
  test <- capture.output(test)
  expect_is(test, "character")
  expect_length(test, 9L)
  expect_true(sum(!nzchar(test)) == 2)
  expect_true(sum(grepl(".ab1$", test)) == 6)
})
test_that("bold_read_trace works properly", {
  skip_on_cran()
  dest.dir <- vcr::vcr_configuration()$write_disk_path
  vcr::use_cassette(
    "bold_trace",
    {
      test <- bold_trace(taxon = "Bombus ignitus",
                         geo = "Japan",
                         dest = file.path(dest.dir, "taxon"))
  })
  test_trace <- bold_read_trace(test)
  expect_is(test_trace, "list")
  expect_length(test_trace, 6)
  expect_is(test_trace[[1]], "sangerseq")
  test_trace <- bold_read_trace(test$ab1[1:2])
  expect_is(test_trace, "list")
  expect_length(test_trace, 2)
  expect_is(test_trace[[1]], "sangerseq")
  # error in path file
  expect_warning(bold_read_trace(gsub("_F","", test$ab1[1])), "Couldn't find the trace file:")
  test_trace <- bold_read_trace(gsub("_F","", test$ab1[1]))
  expect_is(test_trace, "list")
  expect_length(test_trace, 1)
  expect_length(test_trace[[1]], 0)
})
test_that("bold_trace fails well", {
  skip_on_cran()
  expect_error(bold_trace(), "You must provide a non-empty value to at least one of")
  expect_error(bold_trace(taxon = ''), "You must provide a non-empty value to at least one of")
  expect_error(bold_trace(taxon = 5, geo = 1), "'taxon' and 'geo' must be of class character")
  expect_error(bold_trace(taxon = 'Coelioxys', overwrite = 5), "'overwrite' should be one of TRUE or FALSE")
  expect_error(bold_trace(taxon = 'Coelioxys', dest = TRUE), "'dest' must be of class character")
})
