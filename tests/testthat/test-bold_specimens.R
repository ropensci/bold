# tests for bold_specimens fxn in bold
context("bold_specimens")


test_that("bold_specimens returns the correct object", {
  vcr::use_cassette("bold_specimens", {
    test <- bold_specimens(taxon = 'Coelioxys')
  })
  test <- bold_specimens(taxon = 'Coelioxys')
  expect_is(test, "data.frame")
  expect_is(test$recordID, "integer")
  expect_is(test$processid, "character")
})

test_that("bold_specimens returns the correct object (response)", {
  skip_on_cran()
  vcr::use_cassette("bold_specimens", {
    test <- bold_specimens(taxon = 'Coelioxys', response = TRUE)
  })
  expect_equal(test$status_code, 200)
  expect_is(test, "HttpResponse")
  expect_equal(test$response_headers$`content-type`, "application/x-download")
  expect_is(test$response_headers, "list")
})

test_that("bold_specimens returns the correct object (xml)", {
  vcr::use_cassette("bold_specimens", {
    test <- bold_specimens(taxon = 'Coelioxys', format = 'xml')
  })
  expect_is(test, "xml_document")
})

test_that("bold_seq fails well", {
  skip_on_cran()

  expect_error(bold_specimens(), "You must provide a non-empty value to at least one of")
  expect_error(bold_specimens(taxon = ''), "You must provide a non-empty value to at least one of")
  expect_error(bold_specimens(geo = 'Costa Rica', timeout_ms = 2), "Timeout was reached")
})

# FIXME: The test wasn't doing that. The function doesn't throw warning afaik.
# test_that("Throws warning on call that takes forever including timeout in callopts", {})
