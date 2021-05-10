bold
====


[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![cran version](https://www.r-pkg.org/badges/version/bold)](https://cran.r-project.org/package=bold)
[![cran checks](https://cranchecks.info/badges/worst/bold)](https://cranchecks.info/pkgs/bold)
[![R-check](https://github.com/ropensci/bold/workflows/R-check/badge.svg)](https://github.com/ropensci/bold/actions/)
[![codecov.io](https://codecov.io/github/ropensci/bold/coverage.svg?branch=master)](https://codecov.io/github/ropensci/bold?branch=master)
[![rstudio mirror downloads](https://cranlogs.r-pkg.org/badges/bold)](https://github.com/metacran/cranlogs.app)

`bold` accesses BOLD barcode data.

The Barcode of Life Data Systems (BOLD) is designed to support the generation and application of DNA barcode data. The platform consists of four main modules: a data portal, a database of barcode clusters, an educational portal, and a data collection workbench.

This package retrieves data from the BOLD database of barcode clusters, and allows for searching of over 1.7M public records using multiple search criteria including sequence data, specimen data, specimen *plus* sequence data, as well as trace files.

Documentation for the BOLD API: http://v4.boldsystems.org/index.php/api_home

See also the taxize book for more options for taxonomic workflows with BOLD: https://taxize.dev/

## Installation

__Installation instructions__

__Stable Version__


```r
install.packages("bold")
```

__Development Version__

Install `sangerseqR` first (used in function `bold::bold_trace()` only)

For R < 3.5


```r
source("http://bioconductor.org/biocLite.R")
biocLite("sangerseqR")
```

For R >= 3.5


```r
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("sangerseqR")
```

Then install `bold`


```r
remotes::install_github("ropensci/bold")
```


## Usage

```r
library("bold")
```


### Search for sequence data only

Default is to get a list back


```r
bold_seq(taxon='Coelioxys')[[1]]
#> $id
#> [1] "ABEE117-17"
#> 
#> $name
#> [1] "Coelioxys elongata"
#> 
#> $gene
#> [1] "ABEE117-17"
#> 
#> $sequence
#> [1] "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------TTATCATTATATACATATCATCCTTCCCCATCAGTTGATTTAGCAATTTTTTYTTTACATTTATCAGGAATTTYTTYTATTATCGGATCAATAAATTTTATTGTAACAATTTTAATAATAAAAAATTATTCAATAAATTATAATCAAATACCTTTATTTCCATGATCAATTTTAATTACTACAATTTTATTATTATTATCATTACCTGTATTAGCAGGAGCTATTACAATATTATTATTTGATCGTAATTTAAATTCATCATTTTTTGACCCAATAGGAGGAGGAGATCCTATTTTATATCAACATTTATTTTG------------------------------------"
```

You can optionally get back the `crul` response object


```r
res <- bold_seq(taxon='Coelioxys', response=TRUE)
res$response_headers
#> $status
#> [1] "HTTP/2 200 "
#> 
#> $server
#> [1] "nginx"
#> 
#> $date
#> [1] "Mon, 20 Apr 2020 16:11:50 GMT"
#> 
#> $`content-type`
#> [1] "application/x-download"
#> 
#> $`x-powered-by`
#> [1] "PHP/5.3.15"
#> 
#> $`content-disposition`
#> [1] "attachment; filename=fasta.fas"
#> 
#> $`x-frame-options`
#> [1] "SAMEORIGIN"
#> 
#> $`x-content-type-options`
#> [1] "nosniff"
#> 
#> $`x-xss-protection`
#> [1] "1; mode=block"
```

### Search for specimen data only

By default you download `tsv` format data, which is given back to you as a `data.frame`


```r
res <- bold_specimens(taxon='Osmia')
head(res[,1:8])
#>      processid   sampleid recordID catalognum   fieldnum
#> 1  BEECA373-06 05-NT-0373   514740            05-NT-0373
#> 2  BEECA607-06 05-NT-0607   516959            05-NT-0607
#> 3  BEECA963-07 01-OR-0790   554153            01-OR-0790
#> 4  BEECB358-07 04-WA-1076   596920 BBSL697174 04-WA-1076
#> 5  BEECB438-07 00-UT-1157   597000 BBSL432653 00-UT-1157
#> 6 BEECC1176-09 02-UT-2849  1060879 BBSL442586 02-UT-2849
#>                    institution_storing collection_code      bin_uri
#> 1   York University, Packer Collection              NA BOLD:AAI2013
#> 2   York University, Packer Collection              NA BOLD:AAC8510
#> 3   York University, Packer Collection              NA BOLD:ABZ3184
#> 4 Utah State University, Logan Bee Lab              NA BOLD:AAC5797
#> 5 Utah State University, Logan Bee Lab              NA BOLD:AAF2159
#> 6   York University, Packer Collection              NA BOLD:AAE5368
```

### Search for specimen plus sequence data

By default you download `tsv` format data, which is given back to you as a `data.frame`


```r
res <- bold_seqspec(taxon='Osmia', sepfasta=TRUE)
res$fasta[1:2]
#> $`BEECA373-06`
#> [1] "-ATTTTATATATAATTTTTGCTATATGATCAGGTATAATCGGATCAGCAATAAGAATTATTATTCGTATAGAATTAAGAATTCCTGGTTCATGAATTTCAAATGATCAAACTTATAACTCTTTAGTAACTGCTCATGCTTTTTTAATAATTTTTTTCTTAGTTATACCTTTTTTAATTGGAGGATTTGGAAATTGATTAATTCCTTTAATATTAGGAATCCCGGATATAGCTTTCCCTCGAATAAATAATATTAGATTTTGACTTTTACCCCCTTCATTAATATTATTACTTTTAAGAAATTTTATAAATCCAAGACCAGGTACTGGATGAACTGTTTATCCTCCTCTTTCTTCTCATTTATTTCATTCTTCTCCTTCAGTTGATATAGCCATTTTTTCTTTACATATTTCCGGTTTATCTTCTATTATAGGTTCGTTAAATTTTATTGTTACAATTATTATAATAAAAAATATTTCTTTAAAACATATCCAATTACCTTTATTTCCATGATCTGTTTTTATTACTACTATCTTATTACTTTTTTCTTTACCTGTTTTAGCAGGAGCTATTACTATATTATTATTTGATCGAAATTTTAATACTTCATTTTTTGATCCTACAGGAGGTGGAGATCCAATCCTTTATCAACATTTATTT"
#> 
#> $`BEECA607-06`
#> [1] "AATATTATATATAATTTTTGCTTTGTGATCTGGAATAATTGGTTCATCTATAAGAATTATTATTCGTATAGAATTAAGAATTCCTGGTTCATGAATTTCAAATGATCAAGTTTATAATTCATTAGTTACAGCTCATGCTTTTTTAATAATTTTTTTTTTAGTTATACCATTTATAATTGGAGGATTTGGAAATTGATTAGTTCCTTTAATATTAGGAATTCCTGATATAGCTTTTCCTCGAATAAATAATATTAGATTTTGATTATTACCACCATCATTAATACTTTTACTTTTAAGAAATTTTTTTAATCCAAGTTCAGGAACTGGATGAACTGTATATCCTCCTCTTTCATCATATTTATTTCATTCTTCACCTTCTGTTGATTTAGCTATTTTTTCTCTTCATATATCAGGTTTATCTTCTATTATAGGTTCATTAAACTTTATTGTAACTATTATTATAATAAAAAATATTTCTTTAAAGTATATTCAATTGCCATTATTTCCATGATCTGTTTTTATTACTACAATTCTTTTATTATTATCATTACCAGTTTTAGCAGGTGCTATTACTATATTATTATTTGATCGAAATTTTAATACTTCATTTTTTGATCCTACAGGAGGGGGAG--------------------------"
```

Or you can index to a specific sequence like


```r
res$fasta['GBAH0293-06']
#> $`GBAH0293-06`
#> [1] "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------TTAATGTTAGGGATTCCAGATATAGCTTTTCCACGAATAAATAATATTAGATTTTGACTGTTACCTCCATCTTTAATATTATTACTTTTAAGAAATTTTTTAAATCCAAGTCCTGGAACAGGATGAACAGTTTATCCTCCTTTATCATCAAATTTATTTCATTCTTCTCCTTCAGTTGATTTAGCAATTTTTTCTTTACATATTTCAGGTTTATCTTCTATTATAGGTTCATTAAATTTTATTGTTACAATTATTATAATAAAAAATATTTCTTTAAAATATATTCAATTACCTTTATTTTCTTGATCTGTATTTATTACTACTATTCTTTTATTATTTTCTTTACCTGTATTAGCTGGAGCTATTACTATATTATTATTTGATCGAAATTTTAATACATCTTTTTTTGATCCAACAGGAGGGGGAGATCCAATTCTTTATCAACATTTATTTTGATTTTTTGGTCATCCTGAAGTTTATATTTTAATTTTACCTGGATTTGGATTAATTTCTCAAATTATTTCTAATGAAAGAGGAAAAAAAGAAACTTTTGGAAATATTGGTATAATTTATGCTATATTAAGAATTGGACTTTTAGGTTTTATTGTT---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
```

### Get trace files

This function downloads files to your machine - it does not load them into your R session - but prints out where the files are for your information.


```r
x <- bold_trace(ids = 'ACRJP618-11', progress = FALSE)
read_trace(x$ab1)
#> Number of datapoints: 8877
#> Number of basecalls: 685
#> 
#> Primary Basecalls: NNNNNNNNNNNNNNNNNNGNNNTTGAGCAGGNATAGTAGGANCTTCTCTTAGTCTTATTATTCGAACAGAATTAGGAAATCCAGGATTTTTAATTGGAGATGATCAAATCTACAATACTATTGTTACGGCTCATGCTTTTATTATAATTTTTTTTATAGTTATACCTATTATAATTGGAGGATTTGGTAATTGATTAGTTCCCCTTATACTAGGAGCCCCAGATATAGCTTTCCCTCGAATAAACAATATAAGTTTTTGGCTTCTTCCCCCTTCACTATTACTTTTAATTTCCAGAAGAATTGTTGAAAATGGAGCTGGAACTGGATGAACAGTTTATCCCCCACTGTCATCTAATATTGCCCATAGAGGTACATCAGTAGATTTAGCTATTTTTTCTTTACATTTAGCAGGTATTTCCTCTATTTTAGGAGCGATTAATTTTATTACTACAATTATTAATATACGAATTAACAGTATAAATTATGATCAAATACCACTATTTGTGTGATCAGTAGGAATTACTGCTTTACTCTTATTACTTTCTCTTCCAGTATTAGCAGGTGCTATCACTATATTATTAACGGATCGAAATTTAAATACATCATTTTTTGATCCTGCAGGAGGAGGAGATCCAATTTTATATCAACATTTATTTTGATTTTTTGGACNTCNNNNAAGTTTAAN
#> 
#> Secondary Basecalls:
```

### Large data

Sometimes with `bold_seq()` you request a lot of data, which can cause problems due 
to BOLD's servers. 

An example is the taxonomic name _Arthropoda_. When you send a request like 
`bold_seq(taxon = "Arthropoda")` BOLD attempts to give you back sequences
for all records under _Arthropoda_. This, as you can imagine, is a lot of 
sequences. 



```r
library("taxize")
```

Using `taxize::downstream` get children of _Arthropoda_


```r
x <- downstream("Arthropoda", db = "ncbi", downto = "class")
#> ══  1 queries  ═══════════════
#> ✔  Found:  Arthropoda
#> ══  Results  ═════════════════
#> 
#> ● Total: 1 
#> ● Found: 1 
#> ● Not Found: 0
nms <- x$Arthropoda$childtaxa_name
```

Optionally, check that the name exists in BOLD's data. Any that are not in 
BOLD will give back a row of NAs


```r
checks <- bold_tax_name(nms)
# all is good
checks[,1:5]
#>     taxid         taxon tax_rank tax_division parentid
#> 1   26059   Pycnogonida    class     Animalia       20
#> 2      63     Arachnida    class     Animalia       20
#> 3      74   Merostomata    class     Animalia       20
#> 4  493944     Pauropoda    class     Animalia       20
#> 5   80390      Symphyla    class     Animalia       20
#> 6      85     Diplopoda    class     Animalia       20
#> 7      75     Chilopoda    class     Animalia       20
#> 8      82       Insecta    class     Animalia       20
#> 9     372    Collembola    class     Animalia       20
#> 10 734357       Protura    class     Animalia       20
#> 11     84     Remipedia    class     Animalia       20
#> 12     73 Cephalocarida    class     Animalia       20
#> 13     68  Branchiopoda    class     Animalia       20
#> 14 765970   Hexanauplia    class     Animalia       20
#> 15     69  Malacostraca    class     Animalia       20
#> 16 889450 Ichthyostraca    class     Animalia       20
#> 17     NA          <NA>     <NA>         <NA>       NA
#> 18     80     Ostracoda    class     Animalia       20
```

Then pass those names to `bold_seq()`. You could pass all names in at once,
but we're trying to avoid the large data request problem here, so run each 
one separately with `lapply` or a for loop like request. 


```r
out <- lapply(nms, bold_seq)
```

## Citation

Get citation information for `bold` in R by running: `citation(package = 'bold')`

## Meta

* Please [report any issues or bugs](https://github.com/ropensci/bold/issues)
* License: MIT
* Get citation information for `bold` in R doing `citation(package = 'bold')`
* Please note that this project is released with a [Contributor Code of Conduct](https://ropensci.org/code-of-conduct/). By participating in this project you agree to abide by its terms.
