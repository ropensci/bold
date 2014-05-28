# tests for bold_seqspec fxn in bold
context("bold_seqspec")

a <- bold_seqspec(taxon='Osmia')
b <- bold_seqspec(taxon='Osmia', response=TRUE)
c <- bold_seqspec(taxon='Osmia', sepfasta=TRUE)

test_that("bold_seqspec returns the correct dimensions or values", {
  expect_equal(ncol(a), 63)
  expect_equal(length(b), 8)
  expect_equal(length(c), 2)
  
  expect_equal(b$status_code, 200)
  expect_equal(b$headers$`content-type`, "application/x-download")
})

test_that("bold_seqspec returns the correct classes", {
  expect_is(a, "data.frame")
  expect_is(b, "response")
  expect_is(c, "list")
  expect_is(c$data, "data.frame")
  expect_is(c$fasta, "list")
  expect_is(c$fasta[[1]], "character")
  
  expect_is(a$recordID, "integer")
  expect_is(a$directions, "character")
  
  expect_is(b$headers, "insensitive")
})