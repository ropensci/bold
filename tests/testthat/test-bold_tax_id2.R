context("bold_tax_id2")

test_that("bold_tax_id2 returns the correct object (one ID)", {
  skip_on_cran()
  vcr::use_cassette("bold_tax_id2", {
    test <- bold_tax_id2(id = 88899)
  })
  expect_is(test, "data.frame")
  expect_is(test$input, "integer")
  expect_is(test$taxid, "integer")
  expect_is(test$tax_rank, "character")
  expect_equal(test$taxid, test$input)
  expect_equal(NROW(test), 1)
})

test_that("bold_tax_id2 returns the correct object (multiple IDs)", {
  skip_on_cran()
  vcr::use_cassette("bold_tax_id2", {
    test <- bold_tax_id2(id = c(88899, 125295))
  })
  expect_is(test, "data.frame")
  expect_equal(NROW(test), 2)
  expect_equal(test$taxid, test$input)
})
test_that("bold_tax_id2 returns the correct object (multiple IDs, but one NA)", {
  skip_on_cran()
  vcr::use_cassette("bold_tax_id2", {
    test <- bold_tax_id2(id = c(88899, 125295, NA))
  })
  expect_is(test, "data.frame")
  expect_equal(NROW(test), 3)
  expect_equal(test$taxid, test$input)
})

test_that("bold_tax_id2 returns the correct object (one ID, but NA)", {
  test <- bold_tax_id2(id = NA)
  expect_is(test, "data.frame")
  expect_equal(NROW(test), 1)
  expect_length(test, 2)
  expect_equal(test$taxid, test$input)
})

test_that("bold_tax_id2 returns the correct object (response)", {
  skip_on_cran()
  vcr::use_cassette("bold_tax_id2", {
    test <- bold_tax_id2(id = 88899, response = TRUE)
  })
  expect_is(test, "list")
  test <- test[["88899"]]
  expect_length(test, 2)
  expect_is(test$response, "HttpResponse")
  expect_equal(test$response$status_code, 200)
  expect_equal(test$response$response_headers$`content-type`, "text/html; charset=utf-8")
  expect_is(test$response$response_headers, "list")
  expect_is(test$warning, "character")
  expect_equal(test$warning, "")
})

test_that("bold_tax_id2 'dataTypes' param works as expected (stats)", {
  skip_on_cran()
  vcr::use_cassette("bold_tax_id2", {
    test <- bold_tax_id2(id = 88899, dataTypes = "stats")
  })
  expect_is(test, "data.frame")
  expect_equal(NROW(test), 1)
})

test_that("bold_tax_id2 'dataTypes' param works as expected (stats without public marker seqs)", {
  skip_on_cran()
  vcr::use_cassette("bold_tax_id2", {
    test <- bold_tax_id2(id = 660837, dataTypes = "stats")
  })
  expect_is(test, "data.frame")
  expect_equal(NROW(test), 1)
})

test_that("bold_tax_id2 'dataTypes' param works as expected (geo)", {
  skip_on_cran()
  vcr::use_cassette("bold_tax_id2", {
    test <- bold_tax_id2(id = 88899, dataTypes = "geo")
  })
  expect_is(test, "data.frame")
  expect_equal(NROW(test), 8)
  expect_named(test, c("input", "taxid", "country", "count"))
})

test_that("bold_tax_id2 'dataTypes' param works as expected (sequencinglabs)", {
  skip_on_cran()
  vcr::use_cassette("bold_tax_id2", {
    test <- bold_tax_id2(id = 88899, dataTypes = "sequencinglabs")
  })
  expect_is(test, "data.frame")
  expect_gt(NROW(test), 1)
  expect_named(test, c("input", "taxid", "sequencinglabs", "count"))
})

test_that("bold_tax_id2 'dataTypes' param works as expected (all)", {
  skip_on_cran()
  vcr::use_cassette("bold_tax_id2", {
    test <- bold_tax_id2(id = 88899, dataTypes = "all")
  })
  expect_is(test, "list")
  expect_length(test, 7)
  expect_is(test$basic, "data.frame")
  expect_is(test$stats, "data.frame")
  expect_equal(NROW(test$basic), 1)
  expect_named(test, c("basic", "stats", "country", "images", "sequencinglabs", "depository", "thirdparty"))
})

test_that("bold_tax_id2 'dataTypes' param works as expected (basic & stats)", {
  skip_on_cran()
  vcr::use_cassette("bold_tax_id2", {
    test <- bold_tax_id2(id = 660837, dataTypes = c("basic", "stats"))
  })
  expect_is(test, "list")
  expect_is(test[[1]], "data.frame")
  expect_is(test[[2]], "data.frame")
  expect_equal(NROW(test[[1]]), 1)
  expect_is(attr(test, "param"), "list")
  expect_length(attr(test, "param"), 2)
})

test_that("bold_tax_id2 'dataTypes' param works as expected (basic & stats; as written for bold_tax_id)", {
  skip_on_cran()
  vcr::use_cassette("bold_tax_id2", {
    test <- bold_tax_id2(id = 660837, dataTypes = c("basic,stats"))
  })
  expect_is(test, "list")
  expect_is(test[[1]], "data.frame")
  expect_is(test[[2]], "data.frame")
  expect_equal(NROW(test[[1]]), 1)
  expect_is(attr(test, "param"), "list")
  expect_length(attr(test, "param"), 2)
})


test_that("bold_tax_id2 'includeTree' param works as expected", {
  skip_on_cran()
  vcr::use_cassette("bold_tax_id2", {
    test <- bold_tax_id2(id = 88899, includeTree = TRUE)
  })
  expect_is(test, "data.frame")
  expect_equal(NROW(test), 5)
})

test_that("bold_tax_id2 'includeTree' param works as expected (with 2 dataTypes)", {
  skip_on_cran()
  vcr::use_cassette("bold_tax_id2", {
    test <- bold_tax_id2(id = 88899, dataTypes = c("basic", "geo"), includeTree = TRUE)
  })
  expect_is(test, "list")
  expect_is(test[[1]], "data.frame")
  expect_is(test[[2]], "data.frame")
  expect_equal(NROW(test[[1]]), 5)
  expect_true(all(test[[1]][,"taxid"] %in% unique(test[[2]][,"taxid"])))
})

test_that("bold_tax_id2 fails well", {
  expect_error(bold_tax_id2(), "argument \"id\" is missing, with no default")
  expect_error(bold_tax_id2(id = 88899, dataTypes = 5), "'dataTypes' must be of class character.")
  expect_error(bold_tax_id2(id = 88899, dataTypes = "basics"), "'basics' is not a valid data type")
  expect_error(bold_tax_id2(id = 88899, dataTypes = c("basics", "stat")), "'basics' and 'stat' are not valid data type")
  expect_error(bold_tax_id2(id = 88899, includeTree = 5), "'includeTree' must be of class logical.")
})
