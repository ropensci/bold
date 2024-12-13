context("bold_trace")

if (!(!interactive() && !identical(Sys.getenv("NOT_CRAN"), "true"))) {
  test_that("bold_trace returns the correct object", {
    dest.dir <- vcr::vcr_configuration()$write_disk_path
    dest.dir <- normalizePath(file.path(dest.dir, "taxon"))
    vcr::use_cassette("bold_trace", {
      test <- bold_trace(taxon = "Bombus ignitus", geo = "Japan", dest = dest.dir)
    })
    expect_is(test, "boldtrace")
    expect_is(test$destfile, "character")
    expect_is(test$destdir, "character")
    expect_is(test$ab1, "character")
    expect_length(test$ab1, 8L)
    expect_is(test$args, "character")
  })
  
  test_that("bold_trace returns the correct object (with ids)", {
    dest.dir <- vcr::vcr_configuration()$write_disk_path
    dest.dir <- normalizePath(file.path(dest.dir, "ids"))
    vcr::use_cassette("bold_trace", {
      test <- bold_trace(ids = c('ACRJP618-11','ACRJP619-11'), dest = dest.dir)
    })
    expect_is(test, "boldtrace")
    expect_is(test$destfile, "character")
    expect_is(test$destdir, "character")
    expect_is(test$ab1, "character")
    expect_length(test$ab1, 3L)
    expect_is(test$args, "character")
  })
  
  test_that("print.bold_trace prints properly", {
    dest.dir <- vcr::vcr_configuration()$write_disk_path
    dest.dir <- normalizePath(file.path(dest.dir, "taxon"))
    vcr::use_cassette("bold_trace", {
      test <- bold_trace(taxon = "Bombus ignitus", geo = "Japan", dest = dest.dir)
    })
    test <- capture.output(test)
    expect_is(test, "character")
    expect_length(test, 11L)
    expect_true(sum(!nzchar(test)) == 2)
    expect_true(sum(grepl(".ab1$", test)) == 8)
  })
  
  test_that("bold_read_trace works properly", {
    dest.dir <- vcr::vcr_configuration()$write_disk_path
    dest.dir <- normalizePath(file.path(dest.dir, "taxon"))
    vcr::use_cassette("bold_trace", {
      test <- bold_trace(taxon = "Bombus ignitus", geo = "Japan", dest = dest.dir)
    })
    test_trace <- bold_read_trace(test)
    expect_is(test_trace, "list")
    expect_length(test_trace, 8)
    expect_is(test_trace[[1]], "sangerseq")
    test_trace <- bold_read_trace(test$ab1[1:2])
    expect_is(test_trace, "list")
    expect_length(test_trace, 2)
    expect_is(test_trace[[1]], "sangerseq")
    # error in path file
    expect_warning(bold_read_trace(gsub("_F","", test$ab1[1])), "Couldn't find the trace file:")
    test_trace <- suppressWarnings(bold_read_trace(gsub("_F","", test$ab1[1])))
    expect_is(test_trace, "list")
    expect_length(test_trace, 1)
    expect_length(test_trace[[1]], 0)
  })
  
  test_that("bold_trace fails well", {
    expect_error(bold_trace(), "You must provide a non-empty value to at least one of")
    expect_error(bold_trace(taxon = ''), "You must provide a non-empty value to at least one of")
    expect_error(bold_trace(taxon = 5, geo = 1), "'taxon' and 'geo' must be of class character")
    expect_error(bold_trace(taxon = 'Coelioxys', overwrite = 5), "'overwrite' should be one of TRUE or FALSE")
    expect_error(bold_trace(taxon = 'Coelioxys', dest = TRUE), "'dest' must be of class character")
  })
}
