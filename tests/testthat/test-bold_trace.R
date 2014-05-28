# tests for bold_trace fxn in bold
context("bold_trace")

a <- bold_trace(taxon='Osmia', quiet=TRUE)
b <- bold_trace(ids=c('ACRJP618-11','ACRJP619-11'), quiet=TRUE)

test_that("bold_trace returns the correct classes", {
  expect_is(a, "character")
  expect_is(b, "character")
  
  expect_is(a[[1]], "character")
  expect_is(b[[1]], "character")
})