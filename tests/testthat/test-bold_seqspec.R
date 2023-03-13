context("bold_seqspec")

test_that("bold_seqspec returns the correct object", {
  skip_on_cran()
  vcr::use_cassette("bold_seqspec", {
    test <- bold_seqspec(taxon = 'Coelioxys')
  })
  expect_is(test, "data.frame")
  expect_is(test$recordID, "integer")
  expect_is(test$directions, "character")
})

test_that("bold_seqspec returns the correct object (response)", {
  skip_on_cran()
  vcr::use_cassette("bold_seqspec", {
    test <- bold_seqspec(taxon = 'Coelioxys', response = TRUE)
  })
  expect_equal(test$status_code, 200)
  expect_equal(test$response_headers$`content-type`, "application/x-download")
  expect_is(test, "HttpResponse")
  expect_is(test$response_headers, "list")
})

test_that("bold_seqspec returns the correct object (cleanData)", {
  skip_on_cran()
  vcr::use_cassette("bold_seqspec", {
    test <- bold_seqspec(taxon = 'Coelioxys', cleanData = TRUE)
  })
  expect_is(test, "data.frame")
  expect_is(test$recordID, "integer")
  expect_is(test$directions, "character")
  expect_false(any(test == "", na.rm = TRUE))
})

test_that("bold_seqspec returns the correct object (sepFasta)", {
  skip_on_cran()
  vcr::use_cassette("bold_seqspec", {
    test <- bold_seqspec(taxon = 'Coelioxys', sepfasta = TRUE)
  })
  expect_is(test, "list")
  expect_is(test$data, "data.frame")
  expect_is(test$fasta, "list")
  expect_is(test$fasta[[1]], "character")
  expect_equal(nrow(test$data), length(test$fasta))
})
test_that("bold_seqspec returns the correct object (sepFasta, xml)", {
  skip_on_cran()
  vcr::use_cassette("bold_seqspec", {
    test <- bold_seqspec(taxon = 'Coelioxys', sepfasta = TRUE, format = "xml")
  })
  expect_is(test, "list")
  expect_is(test$data, "xml_document")
  expect_is(test$fasta, "list")
  expect_is(test$fasta[[1]], "character")
  expect_equal(length(xml2::xml_children(test$data)), length(test$fasta))
})

test_that("bold_seq fails well", {
  expect_error(bold_seqspec(taxon = ''), "You must provide a non-empty value to at least one of")
  expect_error(bold_seqspec(), "You must provide a non-empty value to at least one of")
})
