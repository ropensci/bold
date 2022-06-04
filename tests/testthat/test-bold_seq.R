# tests for bold_seq fxn in bold
context("bold_seq")

vcr::use_cassette("bold_seq_works_taxon", {
  test_that("bold_seq returns the correct dimensions/classes", {
    skip_on_cran()
  
    a <- bold_seq(taxon='Coelioxys')
    expect_is(a, "data.frame")
    expect_is(a$processid, "character")
    expect_is(a$identification, "character")
    expect_is(a$marker, "character")
    expect_is(a$accession, "character")
    expect_is(a$sequence, "character")
  })
})

vcr::use_cassette("bold_seq_works_bin", {
  test_that("bold_seq returns the correct dimensions/classes", {
    b <- bold_seq(bin='BOLD:AAA5125')
    expect_is(b, "data.frame")
    expect_is(b$processid, "character")
    expect_is(b$identification, "character")
    expect_is(b$marker, "character")
    expect_is(b$accession, "character")
    expect_is(b$sequence, "character")
  })
})

vcr::use_cassette("bold_seq_works_taxon_response", {
  test_that("bold_seq returns the correct dimensions/classes", {
    c <- bold_seq(taxon='Coelioxys', response=TRUE)
    expect_equal(c$status_code, 200)
    expect_equal(c$response_headers$`content-type`, "application/x-download")
    expect_is(c, "HttpResponse")
    expect_is(c$response_headers, "list")
  })
})


test_that("bold_seq returns correct error when parameters empty or not given", {
  skip_on_cran()
  
  expect_error(bold_seq(taxon = ''), "must provide a non-empty value")
  expect_error(bold_seq(), "must provide a non-empty value")
})
