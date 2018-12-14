# tests for bold_seq fxn in bold
context("bold_seq")

test_that("bold_seq returns the correct dimensions/classes", {
  skip_on_cran()
  
  vcr::use_cassette("bold_seq_works_taxon", {
    a <- bold_seq(taxon='Coelioxys')
    expect_is(a, "list")
    expect_is(a[[1]], "list")
    expect_is(a[[1]]$id, "character")
    expect_is(a[[1]]$sequence, "character")
  })

  vcr::use_cassette("bold_seq_works_bin", {
    b <- bold_seq(bin='BOLD:AAA5125')
    expect_is(b, "list")
  })

  vcr::use_cassette("bold_seq_works_taxon_response", {
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
