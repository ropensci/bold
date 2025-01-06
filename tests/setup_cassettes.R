tests_set_cassette_bold_specimens <- function() {
  message("Recording the 'bold_specimens' cassette.")
  vcr::use_cassette("bold_specimens", {
    bold_specimens(taxon = 'Coelioxys')
    bold_specimens(taxon = 'Coelioxys', format = 'xml')
  })
}
tests_set_cassette_bold_seqspec <- function() {
  message("Recording the 'bold_seqspec' cassette.")
  vcr::use_cassette("bold_seqspec", {
    bold_seqspec(taxon = 'Coelioxys')
  })
}
tests_set_cassette_bold_seq <- function() {
  message("Recording the 'bold_seq' cassette.")
  vcr::use_cassette("bold_seq", {
    bold_seq(taxon = 'Coelioxys')
    bold_seq(bin = 'BOLD:AAA5125')
  })
}
tests_set_cassette_bold_stats <- function() {
  message("Recording  the 'bold_stats' cassette.")
  vcr::use_cassette("bold_stats", {
    bold_stats(taxon = "Coelioxys")
    bold_stats(taxon = "Coelioxys", simplify = TRUE)
    bold_stats(taxon = "Coelioxys",
               simplify = TRUE,
               dataType = "overview")
    bold_stats(taxon = c("Coelioxys", "Osmia"))
  })
}
tests_set_cassette_bold_trace <- function() {
  message("Recording  the 'bold_trace' cassette.")
  vcr::use_cassette("bold_trace", {
    dest.dir <- vcr::vcr_configuration()$write_disk_path
    bold_trace(
      taxon = "Bombus ignitus",
      geo = "Japan",
      dest = file.path(dest.dir, "taxon")
    )
    bold_trace(
      ids = c('ACRJP618-11', 'ACRJP619-11'),
      dest = file.path(dest.dir, "ids")
    )
  })
}
tests_set_cassette_bold_tax_id2 <- function() {
  message("Recording the 'bold_tax_id2' cassette.")
  vcr::use_cassette("bold_tax_id2", {
    bold_tax_id2(id = 88899)
    bold_tax_id2(id = c(88899, 125295))
    bold_tax_id2(id = 88899, includeTree = TRUE)
    bold_tax_id2(id = 88899, dataTypes = "all")
    bold_tax_id2(id = 88899, dataTypes = "stats")
    bold_tax_id2(id = 88899, dataTypes = "geo")
    bold_tax_id2(id = 88899, dataTypes = "sequencinglabs")
    bold_tax_id2(
      id = 88899,
      dataTypes = c("basic", "geo"),
      includeTree = TRUE
    )
    bold_tax_id2(id = 660837, dataTypes = "stats") # no public marker sequences
    bold_tax_id2(id = 660837, dataTypes = c("basic", "stats")) # no public marker sequences
  })
}
tests_set_cassette_bold_tax_name <- function() {
  message("Recording the 'bold_tax_name' cassette.")
  vcr::use_cassette("bold_tax_name", {
    bold_tax_name(name = "Diplura")
    bold_tax_name(name = c("Apis", "Puma concolor", "Pinus concolor"))
    bold_tax_name(name = "Diplur", fuzzy = TRUE)
    bold_tax_name(name = "Diplur", fuzzy = FALSE)
    bold_tax_name(name = c(
      "Diplurodes sp.",
      "Chlamydomonas sp. 18 (FA)",
      "Chlamydomonas sp. 'Chile J'"
    ))
  })
}
tests_set_cassette_bold_identify_parents <- function() {
  message("Recording the 'bold_identify_parents' cassette.")
  vcr::use_cassette("bold_identify_parents", {
    load("tests/testthat/bold_identify_list.rda")
    bold_identify_parents(bold_identify_list)
  })
}
tests_set_cassette_bold_identify_taxonomy <- function() {
  message("Recording the 'bold_identify_taxonomy' cassette.")
  vcr::use_cassette("bold_identify_taxonomy", {
    load("tests/testthat/bold_identify_list.rda")
    bold_identify_taxonomy(x = bold_identify_list)
  })
}
tests_set_cassette_bold_identify <- function() {
  message("Recording the '", bold_identify, "' cassette.")
  vcr::use_cassette("bold_identify", {
    bold_identify(sequences$seq1)
    bold_identify(sequences$seq1, db = 'COX1_SPECIES')
    bold_identify(
      "AACCCTATACTTTTTATTTGGAATTTGAGCGGGTATAGTAGGTACTAGCTTAAGTATATTAATTCGTCTAGAGCTAGGACAACCCGGTGTATTTTTAGAAGATGACCAAACCTATAACGTTATTGTAACAGCCCACGCTTTTATTATAATTTTCTTCATAATTATACCAATCATAATTGGA"
    )
  })
}
tests_setup_cassettes <- function(cassette = "all") {
  invisible(vcr::vcr_configure(
    dir = normalizePath(file.path(getwd(), "tests/fixtures")),
    write_disk_path = normalizePath(file.path(getwd(), "tests/bold_trace_files"))
  ))
  if (length(cassette) == 1 && cassette == "all") {
    cassette <- c(
      "bold_specimens",
      "bold_seqspec",
      "bold_seq",
      "bold_stats",
      "bold_trace",
      "bold_tax_id2",
      "bold_tax_name",
      "bold_identify_parents",
      "bold_identify_taxonomy",
      "bold_identify"
    )
  }
  for (x in cassette) {
    switch (
      x,
      bold_specimens = tests_set_cassette_bold_specimens(),
      bold_seqspec = tests_set_cassette_bold_seqspec(),
      bold_seq = tests_set_cassette_bold_seq(),
      bold_stats = tests_set_cassette_bold_stats(),
      bold_trace = tests_set_cassette_bold_trace(),
      bold_tax_id2 = tests_set_cassette_bold_tax_id2(),
      bold_tax_name = tests_set_cassette_bold_tax_name(),
      bold_identify_parents = tests_set_cassette_bold_identify_parents(),
      bold_identify_taxonomy = tests_set_cassette_bold_identify_taxonomy(),
      bold_identify = tests_set_cassette_bold_identify(),
      stop("No cassette named ", cassette)
    )
  }
}
# tests_setup_cassettes()
