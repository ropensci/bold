# set up vcr
library("vcr")
invisible(vcr::vcr_configure(dir = normalizePath("../fixtures"), write_disk_path = normalizePath("../bold_trace_files")))
