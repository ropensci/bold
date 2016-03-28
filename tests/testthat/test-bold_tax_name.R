context("bold_tax_name")

a <- bold_tax_name(name='Diplura')
b <- bold_tax_name(name=c('Diplura','Osmia'))
cc <- bold_tax_name(name=c("Apis","Puma concolor","Pinus concolor"))

test_that("bold_tax_name returns the correct classes", {
  expect_is(a, "data.frame")
  expect_is(b, "data.frame")
  expect_is(cc, "data.frame")
  
  expect_is(a$input, "character")
  expect_is(a$taxid, "integer")
})

test_that("bold_tax_name fails well", {
  expect_error(bold_tax_name(), "argument \"name\" is missing, with no default")
})

test_that("fuzzy works", {
  aa <- bold_tax_name(name='Diplur', fuzzy=TRUE)
  aa_not <- bold_tax_name(name='Diplur', fuzzy=FALSE)
  
  expect_is(aa, "data.frame")
  expect_is(aa$input, "character")
  expect_gt(NROW(aa), NROW(aa_not))
})
