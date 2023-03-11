context("bold_stats")

test_that("bold_stats returns the correct object", {
  skip_on_cran()
  vcr::use_cassette("bold_stats", {
    test <- bold_stats(taxon = "Coelioxys")
  })
  expect_is(test, "list")
  expect_type(test$total_records, "integer")
  expect_type(test$records_with_species_name, "integer")
  expect_is(test$bins, "list")
  expect_is(test$countries, "list")
  expect_is(test$order, "list")
})
test_that("bold_stats returns the correct object (simplify & drill_down)", {
  skip_on_cran()
  vcr::use_cassette("bold_stats", {
    test <- bold_stats(taxon = "Coelioxys", simplify = TRUE)
  })
  expect_is(test, "list")
  expect_length(test, 2L)
  expect_type(test$overview, "list")
  expect_type(test$overview$records_with_species_name, "integer")
  expect_type(test$drill_down, "list")
  expect_is(test$drill_down$bins, "data.frame")
  expect_is(test$drill_down$countries, "data.frame")
  expect_is(test$drill_down$order, "data.frame")
})
test_that("bold_stats returns the correct object (simplify & overview)", {
  skip_on_cran()
  vcr::use_cassette("bold_stats", {
    test <- bold_stats(taxon = "Coelioxys", simplify = TRUE, dataType = "overview")
  })
  expect_is(test, "data.frame")
  expect_type(test, "list")
  expect_equal(nrow(test), 1L)
  expect_type(test$records_with_species_name, "integer")
})

test_that("bold_stats return response", {
  skip_on_cran()
  vcr::use_cassette("bold_stats", {
    test <-  bold_stats(taxon = "Coelioxys", response = TRUE)
  })
  expect_is(test, "HttpResponse")
  expect_equal(test$status_code, 200)
  expect_is(test$parse("UTF-8"), "character")
  expect_match(test$parse("UTF-8"), "countries")
})

test_that("bold_stats many taxa passed to taxon param", {
  skip_on_cran()
  vcr::use_cassette("bold_stats", {
    test <- bold_stats(taxon = c("Coelioxys", "Osmia"))
  })
  expect_is(test, "list")
})

test_that("bold_stats fails well", {
  expect_error(bold_stats(),
    "You must provide a non-empty value to at least one of")
  expect_error(bold_stats(taxon = 5), "'taxon' must be of class character")
  expect_error(bold_stats(taxon = 5, bin = 1), "'taxon' and 'bin' must be of class character")
  expect_error(bold_stats(taxon = 5, bin = 1, dataType = "all"), "'dataType' must be one of 'overview' or 'drill_down'")
  expect_error(bold_stats(taxon = "Osmia", response = 5), "'response' should be one of TRUE or FALSE")
})
