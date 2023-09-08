## Test environments

* local Windows install (x86_64, mingw32), R-release (4.2.2)
* win-builder (devel and release)
* mac-builder (release)
* GitHub Actions (linux, macos, windows)

## R CMD check results

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

Using mac-builder there was no error or warning and a one note :
```
Package suggested but not available for checking: ‘sangerseqR’
```
This isn't a problem since it's only a suggested package and only used by one function.

## Reverse dependencies

We checked 2 reverse dependencies, comparing R CMD check results across CRAN and dev versions of this package.
No problems were found.
See summary at <https://github.com/ropensci/bold/blob/master/revdep/README.md>.

-----

This version has updated many functions for efficiency and to fix some bugs. It introduces some new functions and makes 2 functions deprecated.

Thanks!

Salix Dubois
