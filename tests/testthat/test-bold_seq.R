context("bold_seq")

if (!(!interactive() && !identical(Sys.getenv("NOT_CRAN"), "true")))  {
  test_that("bold_seq returns the correct object", {
    vcr::use_cassette("bold_seq", {
      test <- bold_seq(taxon = 'Coelioxys')
    })
    expect_is(test, "data.frame")
    expect_is(test$processid, "character")
    expect_is(test$identification, "character")
    expect_is(test$marker, "character")
    expect_is(test$accession, "character")
    expect_is(test$sequence, "character")
  })
  
  test_that("bold_seq returns the correct object (using bin)", {
    vcr::use_cassette("bold_seq", {
      test <- bold_seq(bin = 'BOLD:AAA5125')
    })
    expect_is(test, "data.frame")
    expect_is(test$processid, "character")
    expect_is(test$identification, "character")
    expect_is(test$marker, "character")
    expect_is(test$accession, "character")
    expect_is(test$sequence, "character")
  })
  test_that("bold_seq returns the correct object (response)", {
    vcr::use_cassette("bold_seq", {
      test <- bold_seq(taxon = 'Coelioxys', response = TRUE)
    })
    expect_equal(test$status_code, 200)
    expect_is(test, "HttpResponse")
    expect_equal(test$response_headers$`content-type`,
                 "application/x-download")
    expect_is(test$response_headers, "list")
  })
  
  
  test_that("bold_seq fails well", {
    expect_error(bold_seq(),
                 "You must provide a non-empty value to at least one of")
    expect_error(bold_seq(taxon = ''),
                 "You must provide a non-empty value to at least one of")
    expect_error(bold_seq(taxon = 5, geo = 1),
                 "'taxon' and 'geo' must be of class character")
    expect_error(
      bold_seq(taxon = 'Coelioxys', response = 5),
      "'response' should be one of TRUE or FALSE"
    )
  })
}
