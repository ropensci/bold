context("bold_tax_name")

test_that("bold_tax_name returns the correct object", {
  skip_on_cran()
  vcr::use_cassette("bold_tax_name", {
    test <- bold_tax_name(name = "Diplura")
  })
  expect_is(test, "data.frame")
  expect_is(test$input, "character")
  expect_is(test$taxid, "integer")
})

test_that("bold_tax_name returns the correct object (multiple names)", {
  skip_on_cran()
  vcr::use_cassette("bold_tax_name", {
    test <- bold_tax_name(name = c("Apis", "Puma concolor", "Pinus concolor"))
  })
  expect_is(test, "data.frame")
  expect_is(test$input, "character")
  expect_is(test$taxid, "integer")
})
test_that("bold_tax_name returns the correct object (using filters)", {
  skip_on_cran()
  vcr::use_cassette("bold_tax_name", {
    test <- bold_tax_name(name = "Actinocephalus", tax_rank = "genus")
  })
  expect_is(test, "data.frame")
  expect_is(test$input, "character")
  expect_is(test$taxid, "integer")
  expect_equal(NROW(test), 2)
  expect_equal(unique(test$tax_rank), "genus")

  vcr::use_cassette("bold_tax_name", {
    test <- bold_tax_name(name = "Actinocephalus", tax_division = "Protista")
  })
  expect_is(test, "data.frame")
  expect_is(test$input, "character")
  expect_is(test$taxid, "integer")
  expect_equal(NROW(test), 1)
  expect_equal(test$tax_division, "Protista")
})

test_that("bold_tax_name returns the correct object (when taxon not found)", {
  skip_on_cran()
  vcr::use_cassette("bold_tax_name", {
    test <- bold_tax_name(name = "Actino")
  })
  expect_is(test, "data.frame")
  expect_is(test$input, "character")
  expect_is(test$taxid, "integer")
  expect_true(is.na(test$taxid))
})

test_that("bold_tax_name returns the correct object (response)", {
  skip_on_cran()
  vcr::use_cassette("bold_tax_name", {
    test <- bold_tax_name(name = "Diplura", response = TRUE)
  })
  expect_is(test, "list")
  test <- test[["Diplura"]]
  expect_length(test, 2)
  expect_is(test$response, "HttpResponse")
  expect_equal(test$response$status_code, 200)
  expect_equal(test$response$response_headers$`content-type`, "text/html; charset=utf-8")
  expect_is(test$response$response_headers, "list")
  expect_is(test$warning, "character")
  expect_equal(test$warning, "")
})

test_that("bold_tax_name 'fuzzy' param works", {
  skip_on_cran()
  vcr::use_cassette("bold_tax_name", {
    test <- bold_tax_name(name = "Diplur", fuzzy = TRUE)
    test_not <- bold_tax_name(name = "Diplur", fuzzy = FALSE)
  })
  expect_is(test, "data.frame")
  expect_is(test$input, "character")
  expect_gt(NROW(test), NROW(test_not))
})

test_that("bold_tax_name works when  'name' containts single quotes", {
  skip_on_cran()
  vcr::use_cassette("bold_tax_name", {
    test <- bold_tax_name(name = "Diplur", fuzzy = TRUE)
    test_not <- bold_tax_name(name = "Diplur", fuzzy = FALSE)
  })
  expect_is(test, "data.frame")
  expect_is(test$input, "character")
  expect_gt(NROW(test), NROW(test_not))
})

test_that("bold_tax_name fails well", {
  # name required
  expect_error(bold_tax_name(), "argument 'name' is missing, with no default")
  # catch wrong type param inputs
  expect_error(bold_tax_name(name = "Diplur", response = 5),
               "'response' should be one of TRUE or FALSE")
  expect_error(bold_tax_name(name = "Diplur", fuzzy = 5),
               "'fuzzy' should be one of TRUE or FALSE")
  expect_error(bold_tax_name(name = "Diplur", tax_division = 5),
               "'tax_division' must be of class character")
  expect_error(bold_tax_name(name = "Diplur", tax_division = "Mushrooms"),
               "'tax_division' must be one or more of Animalia, Protista, Fungi and Plantae")
  expect_error(bold_tax_name(name = "Diplur", tax_rank = 5),
               "'tax_rank' must be of class character")
  expect_error(bold_tax_name(name = "Diplur",
                             tax_rank = c("genus", "notArank")),
               "'notarank' is not a valid rank name")
})
