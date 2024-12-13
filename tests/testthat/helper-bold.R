# set up vcr
library(vcr)
invisible(vcr::vcr_configure(
  # dir = normalizePath(file.path(getwd(), "tests/fixtures")),
  # write_disk_path = normalizePath(file.path(getwd(), "tests/bold_trace_files"))
  dir = normalizePath("../fixtures"),
  write_disk_path = normalizePath("../bold_trace_files")
))