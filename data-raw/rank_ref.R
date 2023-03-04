## code to prepare `rank_ref` dataset :
rank_ref <- (function() {
  out <- taxize::rank_ref
  out$rank <- strsplit(out$ranks, ",")
  out <- data.frame(rankid = rep(out$rankid, lengths(out$rank)), rank = unlist(out$rank))
  out$ranks <- gsub("ss$", "sses",
                           gsub("genus$", "genera",
                                gsub("y$", "ies",
                                     gsub("(.*[^ysd])$", "\\1s",
                                          out$rank)
                                )
                           )
  )
  out
})()

usethis::use_data(rank_ref, overwrite = TRUE)
