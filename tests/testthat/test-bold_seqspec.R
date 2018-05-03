# tests for bold_seqspec fxn in bold
context("bold_seqspec")

test_that("bold_seqspec returns the correct dimensions or values", {
  skip_on_cran()

  vcr::use_cassette("bold_seqspec_one", {
    a <- bold_seqspec(taxon='Osmia')
    expect_is(a, "data.frame")
    expect_is(a$recordID, "integer")
    expect_is(a$directions, "character")
  }, preserve_exact_body_bytes = FALSE)

  vcr::use_cassette("bold_seqspec_two", {
    b <- bold_seqspec(taxon='Osmia', response=TRUE)
    expect_equal(b$status_code, 200)
    expect_equal(b$response_headers$`content-type`, "application/x-download")
    expect_is(b, "HttpResponse")
    expect_is(b$response_headers, "list")
  }, preserve_exact_body_bytes = FALSE)

  vcr::use_cassette("bold_seqspec_three", {
    dd <- bold_seqspec(taxon='Osmia', sepfasta=TRUE)
    expect_is(dd, "list")
    expect_is(dd$data, "data.frame")
    expect_is(dd$fasta, "list")
    expect_is(dd$fasta[[1]], "character")
  }, preserve_exact_body_bytes = FALSE)
})

test_that("bold_seq returns correct error when parameters empty or not given", {
  skip_on_cran()

  expect_error(bold_seqspec(taxon=''), "must provide a non-empty value")
  expect_error(bold_seqspec(), "must provide a non-empty value")
})
