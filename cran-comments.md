## Test environments

* local Windows install (x86_64, mingw32), R-release (4.2.2)
* win-builder (devel and release)
* mac-builder (release)
* GitHub Actions (linux, macos, windows)

## R CMD check results

There was no error or warning, and one note :
```
❯ checking R code for possible problems ... NOTE
  bold_filter: no visible binding for global variable 'nucleotides'
  bold_filter: no visible binding for global variable '.I'
  Undefined global functions or variables:
    .I nucleotides
```

This isn't a problem; these variables don't need to be defined in the global scope since they will be evaluated in the data.table's scope.

## Reverse dependencies

We checked 2 reverse dependencies, comparing R CMD check results across CRAN and dev versions of this package.
No problems were found.
See summary at <https://github.com/ropensci/bold/blob/master/revdep/README.md>.

-----

This version has updated many functions for efficiency and to fix some bugs. It introduces 2 new functions and makes 2 functions deprecated.

Thanks!

Salix Dubois
