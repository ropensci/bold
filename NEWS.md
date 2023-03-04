bold 1.3.0
==========

### NEW FEATURES
* New function `bold_identify_taxonomy()` to add taxonomic information to the output of `bold_identify()` and replace `bold_identify_parents()`. Instead of taking the taxon names from the `bold_identify()` output, and use `bold_tax_name()` to get the taxonomic ID to then pass it to `bold_tax_id()` to get the parent names, we take the process ids from the `bold_identify()` output and then pass them to `bold_specimens()`. This has the advantages of being faster and, more importantly, making sure the correct taxonomy is returned. The function has less arguments since the filtering of the result isn't necessary anymore. Since the result now has only one line per row of input, the output is always in 'wide' format (like when using `bold_identify_parents()` with `wide=TRUE`). There is one new argument `taxOnly` which is `TRUE` by default and return only the taxonomic data. However, since `bold_specimens()` also returns other data (habitat, country, image_url, etc), setting this argument to `FALSE` will also join that data to the input.

* New function `bold_tax_id2()` which will eventually replace `bold_tax_id()`. The main changes are in the format of the output. For the `dataTypes`  'basic', 'stats', 'images' and 'thirdparty', the output doesn't change. For the `dataTypes` 'sequencinglabs', 'geo' and 'depository', instead of having one (sometimes very) wide data.frame, the result is now in 'long' format, with the columns 'input', 'taxid', 'sequencinglabs|country|depository' and 'count'. For the `dataTypes` 'all' or when selecting more than one dataTypes, the output is a list for each data types containing their respective data.frame. When setting includeTree to `TRUE`, the parents' data is rbinded to their respective data.frame. The function also check that all arguments are the correct type and that the `dataTypes` chosen are valid.

* The now deprecated `bold_tax_id()` has the same argument checks as `bold_tax_id2()` but will throw warnings instead of errors to not affect existing workflows. Also, if a chosen `dataTypes` is invalid, it gets removed to not make unnecessary requests.

* Similarly, the now deprecated `bold_identify_parents()` has new argument checks and will throw warnings to not affect existing workflows.

* `bold_specimens()` and `bold_seqspec()` have a new parameter `cleanData` which, when set to `TRUE`, replaces empty strings ("") by NAs and strings containing only duplicated values by their unique value (ex : "COI-5P|COI-5P|COI-5P" becomes "COI-5P").

### MINOR IMPROVEMENTS

* made tests for the new functions
* made tests for the `bold_trace()` function
* added test to existing functions to improved test coverage
* added/completed argument checks for every functions
* using `data.table` when possible, removed `dplyr` and `reshape` dependencies
* using `stringi` instead of `stringr` which removed `stringr`'s other dependencies
* added more details to the documentation of some functions

### BUG FIXES
* changed how http responses are read so they throw warnings and return NAs instead of errors. This prevents a long request to stop and fail, loosing the already fetched data. (#74)
* added a note in the documentation of `bold_seq()`, `bold_seqspec()` and `bold_specimen()` that if the `taxon` doesn't have public records, if using another parameter will return all data for that parameter. Users can verify the availability of public records with `bold_stats()`. A note was also added in `bold_tax_name()` that the column 'specimenrecords' relate to the records in the taxonomy browser and not in the public data portal. (#76)
* fixed output of bold_seq() (#79)
* changed the function used to encode to UTF-8 (#81, #86)
* contacted bold so they would fix their typo in 'depository' which prevented fetching related data with `bold_tax_id()` (#83). Added a line in the function to change 'depositories' to 'depository' in case people had been using that.
* added a check for 'name' in `bold_tax_name()` to double escape single quotes. Otherwise it doesn't return the data (#84, #85). Since it's related to the API, this means that the data that comes back also contains errors. So I added a function to repair the names of 'taxon', 'taxonrep' and 'parentname' in the returned object. The function is also used in `pipe_params()` (which is used by `bold_seq()`, `bold_seqspec()` and `bold_specimen()`) to repair the `taxon` parameter in case users use results from previous versions.
* changed the way the response of `bold_seqspec()` is read (#87, #88) thanks @cjfields
* added a note in `bold_stats()` documentation to specify that the record counts include all gene markers (#90).

bold 1.2.0
==========

### MINOR IMPROVEMENTS

* vignettes fix (#77)

bold 1.1.0
==========

### MINOR IMPROVEMENTS

* fix a failing test (#73)


bold 1.0.0
==========

### MINOR IMPROVEMENTS

* change base url for all requests to https from http (#70)
* fixed a warning arising from use of `bold_seqspec()` - we now set the encoding to "UTF-8" before parsing the string to XML (#71)
* `bold_seqspec()` fix: capture "Fatal errors" returned by BOLD servers and pass that along to the user with advice (#66)
* add "Marker" and "Large requests" documentation sections to both `bold_seq()` and `bold_seqspec()`. the marker section details that the marker parameter doesn't actually filter results that you get - but you can filter them yourself. the large requests section gives some caveats associated with large data requests and outlines how to sort it out (#61)


bold 0.9.0
==========

### MINOR IMPROVEMENTS

* improved test coverage (#58)
* allow curl options to be passed into `bold_identify_parents()` (#64)
* fix instructions in README for package `sangerseqR` - instructions depend on which version of R is being used (#65) thanks @KevCaz

### BUG FIXES

* fixes in package for `_R_CHECK_LENGTH_1_LOGIC2_` (#57)
* `bold_identify()` fix: ampersands needed to be escaped (#62) thanks @devonorourke


bold 0.8.6
==========

### MINOR IMPROVEMENTS

* tests that make HTTP requests now use package `vcr` to cache responses, speeds up tests significantly, and no longer relies on an internet connection (#55) (#56)
* `bold_seq()`: sometimes on large requests, the BOLD servers time out, and give back partial output but don't indicate that there was an error. We catch this kind of error now, throw a message for the user, and the function gives back the partial output given by the server. Also added to the documentation for `bold_seq()` and in the README that if you run into this problem try to do many queries that will result in smaller set of results instead of one or fewer larger queries (#52) (#53)
* `bold_seq()`: remove return characters (`\r` and `\n`) from sequences (#54)


bold 0.8.0
==========

### MINOR IMPROVEMENTS

* link to taxize bookdown book in readme and vignette (#51)
* `bold_identify_parents()` gains many new parameters (`taxid`, `taxon`, `tax_rank`, `tax_division`, `parentid`, `parentname`, `taxonrep`, `specimenrecords`) to filter parents based on any of a number of fields - should solve problem where multiple parents found for a single taxon, often in different kingdoms (#50)
* add note in docs of `bold_identify()` that the function uses `lapply` internally, so queries with lots of sequences can take a long time

### BUG FIXES

* fix `bold_specimens()`: use `rawToChar()` on raw bytes instead of `parse()` from `crul` (#47)

bold 0.5.0
==========

### NEW FEATURES

* Now using BOLD's v4 API throughout the package. This was essentially
just a change of the BASE URL for each request (#30)
* Now using `crul` for HTTP requests. Only really affects users in that
specifying curl options works slightly differenlty (#42)

### BUG FIXES

* `marker` parameter in `bold_seqspec` was and maybe still is not working,
in the sense that using the parameter doesn't always limit results to the
marker you specify. Not really fixed - watch out for it, and filter after you
get results back to get markers you want. (#25)
* Fixed bug in `bold_identify_parents` - was failing when no match for a
parent name. (#41) thx @VascoElbrecht
* `tsv` results were erroring in `bold_specimens` and other fxns (#46) - fixed
by switching to new BOLD v4 API (#30)

### MINOR IMPROVEMENTS

* Namespace calls to base pkgs for `stats` and `utils` - replaced
`is` with `inherits` (#39)



bold 0.4.0
==========

### NEW FEATURES

* New function `bold_identify_parents()` to add taxonomic information
to the output of `bold_identify()`. We take the taxon names from `bold_identify`
output, and use `bold_tax_name` to get the taxonomic ID, passing it to
`bold_tax_id` to get the parent names, then attaches those to the input data.
There are two options given what you put for the `wide` parameter. If `TRUE`
you get data.frames of the same dimensions with parent rank name and ID
as new columns (for each name going up the hierarchy) - while if `FALSE`
you get a long data.frame. thanks @dougwyu for inspiring this (#36)

### MINOR IMPROVEMENTS

* replace `xml2::xml_find_one` with `xml2::xml_find_first` (#33)
* Fix description of `db` options in `bold_identify` man file -
COX1 and COX1_SPECIES were switched (#37) thanks for pointing that out
@dougwyu

### BUG FIXES

* Fix to `bold_tax_id` for when some elements returned from the BOLD
API were empty/`NULL` (#32) thanks @fmichonneau !!


bold 0.3.5
==========

### MINOR IMPROVEMENTS

* Added more tests to the test suite (#28)

### BUG FIXES

* Fixed a bug in an internal data parser (#27)

bold 0.3.4
==========

### NEW FEATURES

* Added a code of conduct

### MINOR IMPROVEMENTS

* Switched to `xml2` from `XML` as the XML parser for this package (#26)
* Fixes to `bold_trace()` to create dir and tar file when it doesn't
already exist

### BUG FIXES

* Fixed odd problem where sometimes resulting data from HTTP request
was garbled on `content(x, "text")`, so now using `rawToChar(content(x))`,
which works (#24)


bold 0.3.0
==========

### MINOR IMPROVEMENTS

* Explicitly import non-base R functions (#22)
* Better package level manual file


bold 0.2.6
==========

### MINOR IMPROVEMENTS

* `sangerseqR` package now in Suggests for reading trace files, and is only used in `bold_trace()`
function.
* General code tidying, reduction of code duplication.
* `bold_trace()` gains two new parameters: `overwrite` to choose whether to overwrite an existing
file of the same name or not, `progress` to show a progress bar for downloading or not.
* `bold_trace()` gains a print method to show a tidy summary of the trace file downloaded.

### BUG FIXES

* Fixed similar bugs in `bold_tax_name()` (#17) and `bold_tax_id()` (#18) in which species that were missing from the BOLD database returned empty arrays but 200 status codes. Parsing those as failed attempts now. Also fixes problem in taxize in `bold_search()` that use these two functions.

bold 0.2.0
==========

### NEW FEATURES

* Package gains two new functions for working with the BOLD taxonomy APIs: `bold_tax_name()` and `bold_tax_id()`, which search for taxonomic data from BOLD using either names or BOLD identifiers, respectively. (#11)
* Two new packages in Imports: `jsonlite` and `reshape`.

### MINOR IMPROVEMENTS

* Added new taxonomy API functions to the vignette (#14)
* Added reference URLS to all function doc files to allow easy reference for the appropriate API docs.
* `callopts` parameter changed to `...` throughout the package, so that passing on options to `httr::GET` is done via named parameters, e.g., `config=verbose()`. (#13)
* Added examples of doing curl debugging throughout man pages.


bold 0.1.2
==========

### MINOR IMPROVEMENTS

* Improved the vignette (#8)
* Added small function to print helpful message when user inputs no parameters or zero length parameter values.

### BUG FIXES

* Fixed some broken tests with the new `httr` (v0.4) (#9), and added a few more tests (#7)


bold 0.1.0
==========

### NEW FEATURES

* released to CRAN
