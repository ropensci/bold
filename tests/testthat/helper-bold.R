# set up vcr
library("vcr")
invisible(vcr::vcr_configure(dir = "../fixtures", write_disk_path = "../bold_trace_files"))
