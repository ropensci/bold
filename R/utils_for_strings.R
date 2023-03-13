b_extract <- function(str, pattern, mode = "all",
                      fixed = FALSE, simplify = TRUE, ...) {
  switch(mode,
         first = {
           if (!fixed)
             stringi::stri_extract_first_regex(str = str, pattern = pattern, ...)
           else
             stringi::stri_extract_first_fixed(str = str, pattern = pattern, ...)
         },
         last = {
           if (!fixed)
             stringi::stri_extract_last_regex(str = str, pattern = pattern, ...)
           else
             stringi::stri_extract_last_fixed(str = str, pattern = pattern, ...)
         },
         all = {
           if (!fixed)
             stringi::stri_extract_all_regex(str = str,
                                             pattern = pattern,
                                             simplify = simplify,
                                             ...)
           else
             stringi::stri_extract_all_fixed(str = str,
                                             pattern = pattern,
                                             simplify = simplify,
                                             ...)
         },
         str)
}
b_words <- function(str, mode = "first", ...) {
  switch(mode,
         first = stringi::stri_extract_first_words(str = str, ...),
         last = stringi::stri_extract_last_words(str = str, ...),
         all = stringi::stri_extract_all_words(str = str, ...),
         str
  )
}
b_replace <- function(str, pattern, replacement, fixed = FALSE, ...) {
  if (!fixed)
    stringi::stri_replace_all_regex(str = str, pattern = pattern,
                                    replacement = replacement, ...)
  else
    stringi::stri_replace_all_fixed(str = str, pattern = pattern,
                                    replacement = replacement, ...)
}
b_detect <- function(str, pattern, fixed = FALSE, ...) {
  if (!fixed)
    stringi::stri_detect_regex(str = str, pattern = pattern, ...)
  else
    stringi::stri_detect_fixed(str = str, pattern = pattern, ...)
}
b_split <- function(str, pattern, fixed = FALSE, ...) {
  if (!fixed)
    stringi::stri_split_regex(str = str, pattern = pattern, ...)
  else
    stringi::stri_split_fixed(str = str, pattern = pattern, ...)
}
b_count <- function(str, pattern, fixed = FALSE, ...) {
  if (!fixed)
    stringi::stri_count_regex(str = str, pattern = pattern, ...)
  else
    stringi::stri_count_fixed(str = str, pattern = pattern, ...)
}
b_drop <- function(str, pattern) {
  to <- stringi::stri_locate_first_fixed(str = str, pattern = pattern)[[1]] - 1L
  stringi::stri_sub(str = str, to = to)
}
b_lines <- function(str) {
  stringi::stri_split_lines1(str = str)
}
