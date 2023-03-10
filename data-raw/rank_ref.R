## code to prepare `rank_ref` dataset :
rank_ref <- `names<-`(
  c(
    'kingdom',
    'phylum',
    'class',
    'order',
    'family',
    'subfamily',
    'tribe',
    'genus',
    'species',
    'subspecies'
  ),
  c(
    'kingdoms',
    'phylums',
    'classes',
    'orders',
    'families',
    'subfamilies',
    'tribes',
    'genera',
    'species',
    'subspecies'
  )
)
usethis::use_data(rank_ref, overwrite = TRUE)
