# tests for bold_specimens fxn in bold
context("bold_specimens")

library("httr")

a <- bold_specimens(taxon='Osmia')
b <- bold_specimens(taxon='Osmia', format='xml', response=TRUE)

test_that("bold_specimens returns the correct dimensions or values", {
  expect_equal(ncol(a), 59)
  expect_equal(length(b), 8)
  
  expect_equal(b$status_code, 200)
  expect_equal(b$headers$`content-type`, "application/x-download")
})

test_that("bold_specimens returns the correct classes", {
  expect_is(a, "data.frame")
  expect_is(b, "response")
  
  expect_is(a$recordID, "integer")
  expect_is(a$directions, "character")
  
  expect_is(b$headers, "insensitive")
})

test_that("Throws warning on call that takes forever including timeout in callopts", {
  expect_error(bold_specimens(geo='Costa Rica', callopts=timeout(2)), "Operation timed out")
})