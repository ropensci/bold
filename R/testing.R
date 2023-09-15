request2 <- function (reqs) {
  crulpool <- curl::new_pool()
  multi_res <- list()
  make_request <- function(i) {
    w <- reqs[[i]]$payload
    h <- w$url$handle
    curl::handle_setopt(h, .list = w$options)
    if (!is.null(w$fields)) {
      curl::handle_setform(h, .list = w$fields)
    }
    curl::handle_setheaders(h, .list = w$headers)
    if (is.null(w$disk) && is.null(w$stream)) {
      curl::multi_add(handle = h, done = function(res) multi_res[[i]] <<- res, 
                      fail = function(res) multi_res[[i]] <<- make_async_error(res, 
                                                                               w), pool = crulpool)
    }
    else {
      if (!is.null(w$disk) && is.null(w$stream)) {
        stopifnot(inherits(w$disk, "character"))
        ff <- file(w$disk, open = "wb")
        curl::multi_add(handle = h, done = function(res) {
          close(ff)
          multi_res[[i]] <<- res
        }, fail = function(res) {
          close(ff)
          multi_res[[i]] <<- make_async_error(res, w)
        }, data = ff, pool = crulpool)
      }
      else if (is.null(w$disk) && !is.null(w$stream)) {
        stopifnot(is.function(w$stream))
        multi_res[[i]] <<- make_async_error("", w)
        curl::multi_add(handle = h, done = w$stream, 
                        fail = function(res) multi_res[[i]] <<- make_async_error(res, 
                                                                                 w), pool = crulpool)
      }
    }
  }
  for (i in seq_along(reqs)) make_request(i)
  curl::multi_run(pool = crulpool)
  remain <- curl::multi_list(crulpool)
  if (length(remain)) 
    lapply(remain, curl::multi_cancel)
  multi_res <- b_rm_empty(multi_res)
  Map(function(z, b) {
    if (grepl("^ftp://", z$url)) {
      headers <- list()
    }
    else {
      hh <- rawToChar(z$headers %||% raw(0))
      if (nzchar(hh)) {
        headers <- lapply(curl::parse_headers(hh, multiple = TRUE), 
                          crul:::head_parse)
      }
      else {
        headers <- list()
      }
    }
    HttpResponse$new(method = b$payload$method, url = z$url, 
                     status_code = z$status_code, request_headers = c(useragent = b$payload$options$useragent, 
                                                                      b$headers), response_headers = last(headers), 
                     response_headers_all = headers, modified = z$modified, 
                     times = z$times, content = z$content, handle = b$handle, 
                     request = b)
  }, multi_res, reqs)
}
<environment: 0x000001a2badf4740>
  