context("bold_tax_id")

vcr::use_cassette("bold_tax_id1", {
  test_that("bold_tax_id returns the correct classes", {
    skip_on_cran()

    aa <- bold_tax_id(88899)
    expect_is(aa, "data.frame")
    expect_is(aa$input, "numeric")
    expect_is(aa$taxid, "integer")
    expect_is(aa$tax_rank, "character")
  })
})

vcr::use_cassette("bold_tax_id2", {
  test_that("bold_tax_id returns the correct classes", {
    bb <- bold_tax_id(125295)
    expect_is(bb, "data.frame")
  })
})

test_that("bold_tax_id works with multiple ids passed in", {
  skip_on_cran()

  vcr::use_cassette("bold_tax_id_multiple_ids", {
    aa <- bold_tax_id(c(88899, 125295))
  }, match_requests_on = c("method", "uri", "query"))

  expect_is(aa, "data.frame")
  expect_equal(NROW(aa), 2)
  expect_equal(aa$taxid, aa$input)
})

vcr::use_cassette("bold_tax_id_datatypes_param_basic", {
  test_that("bold_tax_id dataTypes param works as expected", {
    skip_on_cran()
  
    aa <- bold_tax_id(88899, dataTypes = "basic")
    expect_is(aa, "data.frame")
    expect_equal(NROW(aa), 1)
  })
})
  
vcr::use_cassette("bold_tax_id_datatypes_param_stats1", {
  test_that("bold_tax_id_datatypes_param_stats1", {
    skip_on_cran()

    bb <- bold_tax_id(88899, dataTypes = "stats")
    expect_is(bb, "data.frame")
    expect_equal(NROW(bb), 1)
  })
})
  
vcr::use_cassette("bold_tax_id_datatypes_param_geo", {
  test_that("bold_tax_id_datatypes_param_geo", {
    skip_on_cran()

    dd <- bold_tax_id(88899, dataTypes = "geo")
    expect_is(dd, "data.frame")
    expect_equal(NROW(dd), 1)
    expect_named(dd, c('input','Brazil','Colombia','Mexico','Panama',
      'Guatemala','Peru','Bolivia','Ecuador'))
  })
})
  
vcr::use_cassette("bold_tax_id_datatypes_param_sequencinglabs", {
  test_that("bold_tax_id_datatypes_param_sequencinglabs", {
    skip_on_cran()

    ee <- bold_tax_id(88899, dataTypes = "sequencinglabs")
    expect_is(ee, "data.frame")
    expect_equal(NROW(ee), 1)
  })
})
  
vcr::use_cassette("bold_tax_id_datatypes_param_stats2", {
  test_that("bold_tax_id_datatypes_param_sequencinglabs", {
    skip_on_cran()

    ff <- bold_tax_id(321215, dataTypes = "stats")       # no public marker sequences
    expect_is(ff, "data.frame")
    expect_equal(NROW(ff), 1)
  })
})
  
vcr::use_cassette("bold_tax_id_datatypes_param_multiple", {
  test_that("bold_tax_id_datatypes_param_sequencinglabs", {
    skip_on_cran()

    gg <- bold_tax_id(321215, dataTypes = "basic,stats") # no public marker sequences
    expect_is(gg, "data.frame")
    expect_equal(NROW(gg), 1)
  })
})

vcr::use_cassette("bold_tax_id_includetree_param", {
  test_that("includeTree param works as expected", {
    skip_on_cran()

    aa <- bold_tax_id(id=88899, includeTree=FALSE)
    expect_is(aa, "data.frame")

    bb <- bold_tax_id(id=88899, includeTree=TRUE)
    expect_is(bb, "data.frame")

    expect_gt(NROW(bb), NROW(aa))
  })
})

test_that("bold_tax_id fails well", {
  skip_on_cran()

  expect_error(bold_tax_id(), "argument \"id\" is missing, with no default")
})
