# uncomment to set all cassettes at once
# vcr::vcr_configure(dir = normalizePath("./tests/fixtures/"))
# vcr::vcr_configuration()
# vcr::use_cassette("bold_specimens", {
#   bold_specimens(taxon = 'Coelioxys')
#   bold_specimens(taxon = 'Coelioxys', format = 'xml')
# })
# vcr::use_cassette("bold_seqspec", {
#   bold_seqspec(taxon = 'Coelioxys')
# })
# vcr::use_cassette("bold_seq", {
#   bold_seq(taxon = 'Coelioxys')
#   bold_seq(bin = 'BOLD:AAA5125')
# })
# vcr::use_cassette("bold_stats", {
#   bold_stats(taxon = "Coelioxys")
#   bold_stats(taxon = "Coelioxys", simplify = TRUE)
#   bold_stats(taxon = "Coelioxys", simplify = TRUE, dataType = "overview")
#   bold_stats(taxon = c("Coelioxys", "Osmia"))
# })
# vcr::use_cassette("bold_trace", {
#   dest.dir <- vcr::vcr_configuration()$write_disk_path
#   bold_trace(taxon = "Bombus ignitus", geo = "Japan", dest = file.path(dest.dir, "taxon"))
#   bold_trace(ids = c('ACRJP618-11','ACRJP619-11'), dest = file.path(dest.dir, "ids"))
# })
# vcr::use_cassette("bold_tax_id2", {
#   bold_tax_id2(id = 88899)
#   bold_tax_id2(id = c(88899, 125295))
#   bold_tax_id2(id = 88899, includeTree = TRUE)
#   bold_tax_id2(id = 88899, dataTypes = "all")
#   bold_tax_id2(id = 88899, dataTypes = "stats")
#   bold_tax_id2(id = 88899, dataTypes = "geo")
#   bold_tax_id2(id = 88899, dataTypes = "sequencinglabs")
#   bold_tax_id2(id = 88899, dataTypes = c("basic", "geo"), includeTree = TRUE)
#   bold_tax_id2(id = 660837, dataTypes = "stats") # no public marker sequences
#   bold_tax_id2(id = 660837, dataTypes = c("basic","stats")) # no public marker sequences
# })
# vcr::use_cassette("bold_tax_name", {
#   bold_tax_name(name = "Diplura")
#   bold_tax_name(name = c("Apis", "Puma concolor", "Pinus concolor"))
#   bold_tax_name(name = "Diplur", fuzzy = TRUE)
#   bold_tax_name(name = "Diplur", fuzzy = FALSE)
#   bold_tax_name(name = c(
#     "Diplurodes sp.",
#     "Chlamydomonas sp. 18 (FA)",
#     "Chlamydomonas sp. 'Chile J'"
#   ))
# })
# vcr::use_cassette("bold_identify_parents", {
#   load("tests/testthat/bold_identify_list.rda")
#   bold_identify_parents(bold_identify_list)
# })
# vcr::use_cassette("bold_identify_taxonomy", {
#   load("tests/testthat/bold_identify_list.rda")
#   bold_identify_taxonomy(x = bold_identify_list)
# })
# vcr::use_cassette("bold_identify", {
#   bold_identify(sequences$seq1)
#   bold_identify(sequences$seq1, db = 'COX1_SPECIES')
#   bold_identify("AACCCTATACTTTTTATTTGGAATTTGAGCGGGTATAGTAGGTACTAGCTTAAGTATATTAATTCGTCTAGAGCTAGGACAACCCGGTGTATTTTTAGAAGATGACCAAACCTATAACGTTATTGTAACAGCCCACGCTTTTATTATAATTTTCTTCATAATTATACCAATCATAATTGGA")
# })
