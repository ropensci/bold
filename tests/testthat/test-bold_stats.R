context("bold_stats")

vcr::use_cassette("bold_stats", {
  test_that("bold_stats works as expected", {
    aa <- bold_stats(taxon = "Osmia")
    expect_is(aa, "list")
    expect_type(aa$total_records, "integer")
    expect_type(aa$records_with_species_name, "integer")
    expect_is(aa$bins, "list")
    expect_is(aa$countries, "list")
    expect_is(aa$order, "list")
  })
})

vcr::use_cassette("bold_stats_response_true", {
  test_that("bold_stats return response", {
    aa <- res <- bold_stats(taxon = "Osmia", response = TRUE)
    expect_is(aa, "HttpResponse")
    expect_equal(aa$status_code, 200)
    expect_is(aa$parse("UTF-8"), "character")
    expect_match(aa$parse("UTF-8"), "countries")
  })
})

vcr::use_cassette("bold_stats_many_taxa", {
  test_that("bold_stats many taxa passed to taxon param", {
    aa <- bold_stats(taxon = c("Coelioxys", "Osmia"))
    expect_is(aa, "list")
  })
})

vcr::use_cassette("bold_stats_many_taxa", {
  test_that("bold_stats many taxa passed to taxon param", {
    aa <- bold_stats(taxon = c("Coelioxys", "Osmia"))
    expect_is(aa, "list")
  })
})

test_that("bold_stats fails well", {
  skip_on_cran()

  expect_error(bold_stats(),
    "You must provide a non-empty value to at least one of")
})
