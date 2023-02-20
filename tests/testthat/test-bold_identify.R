context("bold_identify")

test_that("bold_identify returns the correct object", {
  skip_on_cran()
  vcr::use_cassette("bold_identify", {
    test <- bold_identify(sequences$seq1)
  })
  expect_is(test, 'list')
  expect_is(test[[1]], 'data.frame')
  expect_is(test[[1]]$ID, 'character')
})

test_that("bold_identify returns the correct object (db)", {
  skip_on_cran()

  vcr::use_cassette("bold_identify", {
    test <- bold_identify(sequences$seq1, db = 'COX1_SPECIES')
  })
  expect_is(test, 'list')
  expect_is(test[[1]], 'data.frame')
  expect_is(test[[1]]$ID, 'character')
})

test_that("bold_identify returns the correct object (response)", {
  skip_on_cran()
  vcr::use_cassette("bold_identify", {
    test <- bold_identify(sequences$seq1, response = TRUE)
  })
  expect_is(test, "list")
  test <- test[[1]]
  expect_is(test$response, "HttpResponse")
  expect_equal(test$response$status_code, 200)
  expect_equal(test$response$response_headers$`content-type`, "text/xml")
  expect_is(test$warning, "character")
  expect_equal(test$warning, "")
})

test_that("bold_identify fails well", {
  skip_on_cran()

  expect_error(bold_identify(),
    "argument \"sequences\" is missing, with no default")
  expect_error(bold_identify(sequences = 1),
    "'sequences' must be of class character.")
  expect_error(bold_identify(sequences = "", db = "test"),
    "'db' must be one of 'COX1', 'COX1_SPECIES', 'COX1_SPECIES_PUBLIC' or 'COX1_L640bp'")
})

test_that("bold_identify works for XML that contains &", {
  test_seq <- "AACCCTATACTTTTTATTTGGAATTTGAGCGGGTATAGTAGGTACTAGCTTAAGTATATTAATTCGTCTAGAGCTAGGACAACCCGGTGTATTTTTAGAAGATGACCAAACCTATAACGTTATTGTAACAGCCCACGCTTTTATTATAATTTTCTTCATAATTATACCAATC
    ATAATTGGA"
  vcr::use_cassette("bold_identify", {
    test <- bold_identify(test_seq)
    expect_is(test, 'list')
    expect_is(test[[1]], 'data.frame')
    expect_is(test[[1]]$ID, 'character')
  })
})
