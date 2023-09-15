b_taxa <- xml2::read_html("https://v4.boldsystems.org/index.php/TaxBrowser_TaxonPage/SpeciesSummary?taxid=41") |> xml2::xml_find_all("//tr") |> vapply(\(x) xml2::xml_children(x)[2] |> xml2::xml_text(), "") |> stringi::stri_replace_all_regex("^\\s+", "")
b_gen <- b_taxa[!stringi::stri_detect_regex(b_taxa, "^[a-z]+\\.|(^| ). ")] |> 
  stringi::stri_extract_first_regex("^[A-z-]+")# |> 
b_gen <- unique(b_gen)

out <- list()
out[[1]] <- bench::mark(
  bold_tax_name_async(b_gen[1:100],
                      response = TRUE),
  bold_tax_name(b_gen[1:100], 
                response = TRUE),
  check = F,
  max_iterations = 1
)
out[[2]] <- bench::mark(
  bold_tax_name_async(b_gen[1:500]),
  bold_tax_name(b_gen[1:500]),
  check = F,
  max_iterations = 1
)
out[[3]] <- bench::mark(
  bold_tax_name_async(b_gen[1:1000]),
  bold_tax_name(b_gen[1:1000]),
  check = F,
  max_iterations = 1
)
 out[[4]] <- bench::mark(
  bold_tax_name_async(b_gen[1:5000]),
  bold_tax_name(b_gen[1:5000]),
  check = F,
  max_iterations = 1
)
out[[5]] <- bench::mark(
  bold_tax_name_async(b_gen[1:10000]),
  bold_tax_name(b_gen[1:10000]),
  check = F,
  max_iterations = 1
)
