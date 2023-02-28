bold_get_errors <- function(x){
  lapply(x, attributes, "errors")
}
bold_get_params <- function(x){
  lapply(x, attributes, "params")
}
